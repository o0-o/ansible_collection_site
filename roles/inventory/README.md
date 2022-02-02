Ansible Role: Inventory
===================

Creates inventory directories and files for the [o0_o.site Ansible collection](https://github.com/o0-o/ansible_collection_site) relative to the current working directory.

Requirements
------------

* [`jc`](https://pypi.org/project/jc/) Python Package installed on localhost*

\* If multiple versions of Python are installed, ensure to install with the instance of `pip` associated with the version of Python used by Ansible.

Role Variables
--------------

Available variables are listed below, along with default values and/or examples:

Site Definitions
^^^^^^^^^^^^^^^^

The site variables define a physical or virtual location. The site could be an office, colocation or cloud that share an FQDN, LANs and gateway(s). Site definition variables are used to initialize a site, after which, they are combined into a dictionary and used throughout the o0_o.site collection. Once a site is initialized, simply use the resulting inventory file to run playbooks against it.

The site variables include:

Variable | Description
---|---
site_name | An abbreviated name for the site. It must be at least 2 characters long and can only include lower case letters, numbers and/or dashes. It must begin with a letter and cannot end with a dash.
site_description | A brief description of the site
etld | The registered domain name of the site, also know as the [**e**ffective **T**op **L**evel **D**omain](https://en.wikipedia.org/wiki/Public_Suffix_List).
site_id | The site ID must be a positive integer between 0-255, and it must be unique to the site. It will correspond to the 2nd octet in all local IPv4 addresses for the site. This not only allows us to easily distinguish addresses across sites, but also allows for inter-site routing without risk of address collisions. If an ID isn't provided, one will be randomly assigned.
site_tz | The timezone of the site. If none is provided, an attempt is made to use the timezone configured on localhost. If that fails for some reason, `Etc/GMT` is used.

`site_name`, `etld` and `site_id` should not be changed once a site is initialized. The description may be changed later by manually editing `all.yml`.

If any of these 4 variables are not provided, Ansible will prompt for them (with the default timeout).

Example:

```
site_name: hq
site_description: Example Corp Headquarters
etld: example.com
site_id: 123
site_tz: Etc/GMT
```

Based on the example above, this role would produce blocks or lines in the following files:

`./inventory/hq.example.com.yml`
""""""""""""""""""""""""""""""""

```
all:
  children:
    hq_example_com:
      hosts:
```

`./inventory/group_vars/all.yml`
""""""""""""""""""""""""""""""""

```yaml
# BEGIN Ansible Block - Site: hq.example.xom
hq_example_com:
  created: '1642392591'
  description: Example Corp Headquarters
  etld: example.com
  id: 123
  name: hq
  tz: Etc/GMT
# END Ansible Block - Site: hq.example.xom
```

`./inventory/group_vars/hq_example_com.yml`
"""""""""""""""""""""""""""""""""""""""""""

```yaml
site: hq_example_com
```

Comment Formatting
^^^^^^^^^^^^^^^^^^

Comment formatting variables are used for formatting comment headers and setting Vim modelines in templates throughout the o0_o.site collection.

Default:

```yaml
default_comment_prefix: "# vim: ts=8:sw=8:sts=8:noet\n#"
ansible_comment_prefix: "# vim: ts=2:sw=2:sts=2:et:ft=yaml.ansible\n#"
yaml_comment_prefix: "# vim: ts=2:sw=2:sts=2:et:ft=yaml\n#"
default_comment_postfix: |
  #
  ########################################################################
```

Current Working Directory
^^^^^^^^^^^^^^^^^^^^^^^^^

Inventory, host and group variable files are installed in `./inventory` relative to the current working directory. `cwd` is also used when calling collection playbooks on the commandline. Otherwise, the relative paths (`./`, `../`, etc.) are determined relative to the collection playbook and not from the shell (useful when calling a playbook in a shell script). The default value depends on the `PWD` environmental variable which should be available in any Unix-like operating system.

Default:

```yaml
cwd: "{{lookup('env', 'PWD')}}"
```

Service Definitions
^^^^^^^^^^^^^^^^^^^

Define services here. The IANA service definitions tend to assign both UDP and TCP to services that really only need one or the other. Redefining them here can be helpful in correcting those generalizations. An example might be to distinguish HTTP (TCP port 80) from QUIC (UDP port 80), or to simply avoid needlessly opening TCP port 53 when DNS queries are only being served on UDP port 53.

Default:

```
srv_defs: {}
```

Example:

```
srv_defs:
  dns:
    udp:
    - 53
  www:
    tcp:
    - 80
    - 443
```

IANA Service Definitions
^^^^^^^^^^^^^^^^^^^^^^^^

Default service definitions are derived from the [IANA Service Name and Transport Protocol Port Number Registery](https://www.iana.org/assignments/service-names-port-numbers). This is preferable over `/etc/services` because `/etc/services` can be inconsistent between operating systems and is difficult to parse. If a service definition isn't available in the `srv_defs` dictionary, it falls back to `iana_srv_defs`. `iana_srv_defs` is defined in an Ansible-managed bblock which can be updated by running `tasks/conv_iana-srv-def_to_yaml.yml`, but doing so should not be necessary as the service definitions change infrequently. The values provided by default in this role will be updated on every major release. Note that converting the IANA service defintions to yaml can take several hours so while `tasks/conv_iana-srv-def_to_yaml.yml` is available to run manually, it is never run by the role's `tasks/main.yml`.

Defaults (see `defaults/main.yml`):
```
iana_srv_defs:
  1ci-smcs:
    tcp:
    - 3091
    udp:
    - 3091
  2ping:
    udp:
    - 15998
...
```

Dependencies
------------

None

Example Playbook
----------------

When creating a new site, it's necessary to provide site parameters to the role. This can be done when invoking the role in a playbook:

```yaml
- roles:
  - { role: o0_o.site.inventory, site_name: hq, site_description: Headquarters, etld: example.com }
```

However, since the parameters are only necessary once, it makes more sense to use the `--extra-vars` flag:

```sh
ansible-playbook --extra-vars 'site_name=hq site_description=Headquarters etld=example.com site_tz=Etc/GMT' play.yml
```

If a parameter is missing, the role will prompt for it.

```console
> ansible-playbook play.yml
...
Enter a brief description of the site. Ex: Headquarters:

```

If the site has already been created, this is not necessary as these variables should be supplied by the group variables:

```yaml
- roles:
  - o0_o.site.inventory
```

To perform operations that require coordinating values from multiple sites (such as VPN tunnels), use multiple inventory flags. The last one will get precedence (the `site` dictionary will be set according to the last inventory):

```sh
ansible-playbook --inventory './inventory' --inventory './inventory/site.example.com.yml' play.yml
```

License
-------

MIT
