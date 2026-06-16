# gh-router — build, test and install
#
#   make build      assemble src/*.sh into a single self-contained bin/gh
#   make test       build, then run the routing test suite
#   make lint       run shellcheck (if installed)
#   make install    install bin/gh into $(BINDIR) and scaffold rules
#   make uninstall  remove the installed wrapper
#   make clean      remove build artifacts

PREFIX  ?= $(HOME)/.local
BINDIR  ?= $(PREFIX)/bin
CONFDIR ?= $(if $(XDG_CONFIG_HOME),$(XDG_CONFIG_HOME),$(HOME)/.config)/gh-router

SRC := src/header.sh src/resolve.sh src/rules.sh src/main.sh
OUT := bin/gh

.PHONY: all build test lint install uninstall clean help

all: build

help:
	@echo "targets: build  test  lint  install  uninstall  clean"
	@echo "vars:    PREFIX=$(PREFIX)  BINDIR=$(BINDIR)  CONFDIR=$(CONFDIR)"

build: $(OUT)

$(OUT): $(SRC)
	@mkdir -p bin
	@cat $(SRC) > $(OUT)
	@chmod +x $(OUT)
	@echo "built $(OUT)"

test: build
	@sh tests/routing_test.sh

lint: build
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(OUT) tests/routing_test.sh && echo "shellcheck: clean"; \
	else \
		echo "shellcheck not installed — skipping"; \
	fi

install: build
	@mkdir -p "$(BINDIR)"
	@install -m 0755 "$(OUT)" "$(BINDIR)/gh"
	@echo "installed $(BINDIR)/gh"
	@mkdir -p "$(CONFDIR)"
	@if [ -f "$(CONFDIR)/rules" ]; then \
		echo "kept      $(CONFDIR)/rules (already exists)"; \
	else \
		cp examples/rules.example "$(CONFDIR)/rules"; \
		echo "created   $(CONFDIR)/rules (edit it to taste)"; \
	fi
	@case ":$(PATH):" in *":$(BINDIR):"*) : ;; \
		*) echo "WARNING: $(BINDIR) is not on PATH — add it to the FRONT" >&2 ;; esac

uninstall:
	@rm -f "$(BINDIR)/gh"
	@echo "removed $(BINDIR)/gh (rules in $(CONFDIR) left untouched)"

clean:
	@rm -rf bin
	@echo "cleaned"
