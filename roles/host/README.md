# o0_o.site.host

Configure a generic host. Configuration here can apply to any host including localhost and does not assume Python is available.

## Requirements

None

## Role Variables

Available variables are listed below, along with default values and/or examples:

### Use root user?

By default, if Ansible is using the root user on the host, the host role will create an admin user on the target host use that instead. The host role deploys the SSH key* to the host and updates the `ansible_user` variable. This reduces the complexity of onboarding systems via PXE or other automation where creating (and documenting) users other than root adds administrative overhead and varies between operating systems. The site collection only requires that an SSH key be deployed to the host. The host role provides a platform-agnostic method for creating a non-root admin user.

The user name follows the form of `adm_SUFFIX` where `SUFFIX` is a 4-character string that is randomly generated from the hardware specifications of the host. This should avoid collisions with existing users and generate unique users per host while remaining idempotent.

However, if it is desirable to use the root user, the `use_root_user` variable provides an easy way to allow this. When set to `true`, the host role will skip admin user creation and allow `ansible_user` to be set to `root`.

```
use_root_user: false
```

\* If `ansible_ssh_private_key_file` is defined, the corresponding public key is deployed to the new admin user, otherwise the host role uses the first result of `ls -t ~/.ssh/*.pub` which is the same behavior as `ssh-copy-id`. Note that authorized keys for the root user are left unchanged, so while Ansible will use the newly created admin user, the root user will still be accessible via SSH.

### Host Variables

The following Ansible variables are determined and set by the host role. If values are already present, their validity is tested and if they are invalid, an attempt is made to determine functional values. As mentioned above, if `ansible_user` is `root`, a new account will be created unless `use_root_user` is `true`. If Python is not installed on the target host, the host role will install it using `raw` module commands.

* `ansible_user`

* `ansible_python_interpreter` – Python 3 is preferred except on RHEL 7 or equivalent where Python 2 should be used (no `python3-libselinux`)

* `ansible_become_method` – `doas` is preferred if it is available*

* `selinux_available`**

\* "Availability" is determined by running `doas true`, so `doas` must be both installed and configured so that `ansible_user` can use it. However, if a new admin user is created, `doas` will be configured if it is installed at all.

\** Determining if SELinux is installed on the system based on Ansible facts is murky, so the host role will make its own determination based on the availability of the `getenforce` command and save the boolean result in the `selinux_available` variable.

## Dependencies

### o0_o.site.inventory

The host role depends on the inventory role, specifically for the `save host vars` handler which will update host variables as they change or are discovered by the host role.

## Example Playbook

Since the inventory role does the work of setting up the inventory and host/group variable files, using the host role is very simple. Note that the host role will run `ansible.builtin.setup` (`gather_facts`) once it determines that Python is available or after it installs Python on the target host.

```yaml
# play.yml
- hosts: all
  gather_facts: no
  roles:
  - { role: o0_o.site.host, use_root_user: true }
```

```sh
ansible-playbook --inventory inventory/hq.example.com.yml play.yml
```

License
-------

MIT
