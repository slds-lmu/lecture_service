#!/usr/bin/env bash
# Checks the references to sections of exercises-template/README.md, so that a
# renamed or removed section can't leave broken references behind (they are
# synced into every lecture):
# - every README.md#<anchor> in the template, the exercise rules for agents, the
#   workflows synced into lectures, README.md and NEWS.md (and the wiki, if it is
#   checked out in lecture_service.wiki/), and every [...](#<anchor>) inside the
#   README must match one of its headings
# - no reference by number ("section 5", "§5"): numbers change when sections move
# Anchors follow GitHub's rule: lowercase, punctuation removed, spaces as hyphens.
#
#   bash scripts/check_readme_refs.sh
#
# Used in: .github/workflows/check-readme-refs.yaml

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

readme=exercises-template/README.md
paths=(exercises-template .agents/rules-exercises.md service/.github/workflows README.md NEWS.md)
[[ -d lecture_service.wiki ]] && paths+=(lecture_service.wiki)
status=0

# anchors of the README's headings (not of "#" lines inside fenced code blocks)
anchors=$(
  awk '{
    line = $0; sub(/^[[:space:]]+/, "", line)
    if (match(line, /^`+/) && RLENGTH >= 3) {
      if (!fence) { fence = RLENGTH; next }
      if (RLENGTH >= fence && line ~ /^`+[[:space:]]*$/) { fence = 0; next }
    }
    if (!fence && $0 ~ /^#+ /) print
  }' "$readme" |
    sed -E 's/^#+ +//' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 _-]//g; s/ /-/g'
)

duplicates=$(sort <<< "$anchors" | uniq -d)
if [[ -n "$duplicates" ]]; then
  echo "$readme: headings with the same anchor: $duplicates"
  status=1
fi

# input: lines <file>:<line>:<anchor>
check_anchors() {
  local file line anchor
  while IFS=: read -r file line anchor; do
    if ! grep -qxF "$anchor" <<< "$anchors"; then
      echo "$file:$line: #$anchor is not a heading of $readme"
      status=1
    fi
  done
}
check_anchors < <(grep -rnoE 'README\.md#[A-Za-z0-9_-]+' "${paths[@]}" | sed -E 's/README\.md#//')
check_anchors < <(grep -noE '\]\(#[A-Za-z0-9_-]+\)' "$readme" | sed -E "s/\]\(#([^)]*)\)/\1/; s|^|$readme:|")

# references by number: anywhere in the README, elsewhere on lines that mention it
numbered='sections? [0-9]|§ ?[0-9]'
if grep -nE "$numbered" "$readme" | sed "s|^|$readme:|"; then
  status=1
fi
if grep -rnE "README.*($numbered)|($numbered).*README" "${paths[@]}" | grep -v "^$readme:"; then
  status=1
fi
[[ $status -eq 0 ]] || echo "Refer to sections of $readme by anchor (README.md#<anchor>), not by number."

if [[ $status -eq 0 ]]; then
  echo "OK: all references to sections of $readme match its headings."
fi
exit $status
