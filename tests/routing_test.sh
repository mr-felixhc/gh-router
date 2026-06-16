#!/bin/sh
# Routing tests for gh-router.
#
# Builds a fake `gh` that reports the chosen GH_CONFIG_DIR, then drives the
# assembled wrapper (bin/gh) from several directories and asserts the routing.
set -u

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
GH="$ROOT/bin/gh"
[ -x "$GH" ] || { echo "build first: make build" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM
mkdir -p "$TMP/fakebin" "$TMP/work/acme/deep" "$TMP/work/personal-fork" "$TMP/projects/side"

# Fake gh: reports which account (config dir) it was routed to.
cat > "$TMP/fakebin/gh" <<'EOF'
#!/bin/sh
echo "ACCOUNT=${GH_CONFIG_DIR:-DEFAULT}"
EOF
chmod +x "$TMP/fakebin/gh"

# Deliberately list broad rules before specific ones to prove order independence.
cat > "$TMP/rules" <<EOF
# test rules
$TMP/work               /cfg/work
$TMP/work/*             /cfg/work
$TMP/work/acme          /cfg/acme
$TMP/work/acme/*        /cfg/acme
$TMP/work/personal-fork default
EOF

pass=0
fail=0

check() { # description  dir  expected-account
  _got=$( cd "$2" && PATH="$TMP/fakebin:$PATH" GH_ROUTER_RULES="$TMP/rules" "$GH" status 2>/dev/null )
  if [ "$_got" = "ACCOUNT=$3" ]; then
    printf '  ok   %s\n' "$1"
    pass=$((pass + 1))
  else
    printf '  FAIL %s  (got "%s", want "ACCOUNT=%s")\n' "$1" "$_got" "$3"
    fail=$((fail + 1))
  fi
}

check "work root -> work"               "$TMP/work"               /cfg/work
check "acme: specific beats broad"      "$TMP/work/acme"          /cfg/acme
check "acme subdir -> acme"             "$TMP/work/acme/deep"     /cfg/acme
check "personal-fork override -> default" "$TMP/work/personal-fork" DEFAULT
check "unmatched -> default"            "$TMP/projects/side"      DEFAULT

# Pass-through when no rules file exists.
_got=$( cd "$TMP/work" && PATH="$TMP/fakebin:$PATH" GH_ROUTER_RULES=/dev/null "$GH" status 2>/dev/null )
if [ "$_got" = "ACCOUNT=DEFAULT" ]; then
  printf '  ok   no rules -> transparent pass-through\n'
  pass=$((pass + 1))
else
  printf '  FAIL no rules pass-through  (got "%s")\n' "$_got"
  fail=$((fail + 1))
fi

# Version flag is handled by the wrapper, not forwarded to gh.
_got=$( PATH="$TMP/fakebin:$PATH" "$GH" --gh-router-version 2>/dev/null )
case "$_got" in
  "gh-router "*) printf '  ok   --gh-router-version handled locally\n'; pass=$((pass + 1)) ;;
  *) printf '  FAIL --gh-router-version  (got "%s")\n' "$_got"; fail=$((fail + 1)) ;;
esac

echo
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]
