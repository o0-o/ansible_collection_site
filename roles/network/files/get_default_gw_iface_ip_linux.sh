#!/usr/bin/env sh
# vim: ts=8:sw=8:sts=8:noet:ft=sh
#
# Print the IP address of the default gateway interface in Linux
#
########################################################################

# Debug
#set -x

# Safety first
set -eu

# Enforce strict POSIX with pipefail if available
: set -o posix 2>/dev/null	#for ZSH, BASH or KSH (fails in DASH)
: set -o pipefail 2>/dev/null	#not strictly POSIX, but good to have

ipv4_regex='(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)'
ipv4_regex="${ipv4_regex}(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}"

default_gw_iface="$(	ip route show default		|
			grep -m 1 -o "dev [a-z0-9]*"	|
			cut -d ' ' -f 2				)"

ip -4 -br address show "$default_gw_iface"	|
grep -o -E "$ipv4_regex"

exit 0
