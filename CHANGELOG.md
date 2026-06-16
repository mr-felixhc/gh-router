# Changelog

All notable changes to this project are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this project uses [SemVer](https://semver.org/).

## [0.1.0] — 2026-06-15

### Added
- Route `gh` to a `GH_CONFIG_DIR` per working directory, evaluated on every call.
- Most-specific (longest) matching rule wins — rule order is irrelevant.
- `default` / `-` config-dir to force gh's default account, overriding broader rules.
- Transparent pass-through when no rules file is present.
- `--gh-router-version` flag, handled by the wrapper without forwarding to gh.
- `GH_ROUTER_DEBUG` to print the routing decision; `GH_ROUTER_RULES` to override the rules path.
- Makefile build that amalgamates `src/*.sh` into a single self-contained `bin/gh`.
- Routing test suite (`make test`) and shellcheck target (`make lint`).
