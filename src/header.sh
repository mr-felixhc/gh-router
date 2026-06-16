#!/bin/sh
# gh-router — route the GitHub CLI (`gh`) to different accounts based on the
# current working directory.
#
# >>> This file is ASSEMBLED by `make build` from src/*.sh. Edit those. <<<
#
# Installed as `gh` ahead of the real gh on $PATH, it picks a GH_CONFIG_DIR per
# directory from the rules file, then exec's the real gh. With no rules file it
# is a transparent pass-through — identical to calling gh directly.
#
# Env:
#   GH_ROUTER_RULES   override the rules file path
#   GH_ROUTER_DEBUG   if non-empty, print the routing decision to stderr
#
# https://github.com/mr-felixhc/gh-router  •  MIT License

set -u

GHR_VERSION="0.1.0"
GHR_RULES=${GH_ROUTER_RULES:-${XDG_CONFIG_HOME:-$HOME/.config}/gh-router/rules}
GHR_ROUTED="default"
