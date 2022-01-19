#!/usr/bin/env sh
# vim: ts=8:sw=8:sts=8:noet:ft=sh
#
# Print the IP address of the default gateway interface (BSD)
#
########################################################################

# Debug
#set -x

# Safety first
set -eu

# Enforce strict POSIX with pipefail if available
: set -o posix 2>/dev/null	#for ZSH, BASH or KSH (fails in DASH)
: set -o pipefail 2>/dev/null	#not strictly POSIX, but good to have

default_gw_iface="$(	route get default		|
			awk '/interface/ {print $2}'		)"

ifconfig "$default_gw_iface"	|
awk '/inet / {print $2}'

exit 0
