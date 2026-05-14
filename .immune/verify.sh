#!/usr/bin/env bash
# Auto-verify the immune install attestation. Exit 0 iff both PRs carry the
# expected label. See EXPECTATIONS.md for the contract.
set -euo pipefail

REPO="kimjune01/bat"
STRONG_PR=1
WEAK_PR=2
EXPECT_STRONG="immune:trusted"
EXPECT_WEAK="immune:suspect"

has_label() {
  local pr="$1" want="$2"
  gh pr view "$pr" --repo "$REPO" --json labels \
    --jq "[.labels[].name] | index(\"$want\")" 2>/dev/null
}

strong=$(has_label "$STRONG_PR" "$EXPECT_STRONG")
weak=$(has_label "$WEAK_PR"   "$EXPECT_WEAK")

ok=1
if [ "$strong" = "null" ] || [ -z "$strong" ]; then
  echo "FAIL: PR #${STRONG_PR} (strong) missing label '${EXPECT_STRONG}'" >&2
  ok=0
fi
if [ "$weak" = "null" ] || [ -z "$weak" ]; then
  echo "FAIL: PR #${WEAK_PR} (weak) missing label '${EXPECT_WEAK}'" >&2
  ok=0
fi

if [ "$ok" = "1" ]; then
  echo "PASS: install attested (STRONG=${EXPECT_STRONG}, WEAK=${EXPECT_WEAK})"
  exit 0
fi

echo "" >&2
echo "Current labels on PR #${STRONG_PR}: $(gh pr view ${STRONG_PR} --repo ${REPO} --json labels --jq '[.labels[].name] | join(", ")')" >&2
echo "Current labels on PR #${WEAK_PR}:   $(gh pr view ${WEAK_PR}   --repo ${REPO} --json labels --jq '[.labels[].name] | join(", ")')" >&2
exit 1
