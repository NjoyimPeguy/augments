#!/usr/bin/env bash
# Structural validator for SDLC Skills.
# Enforces the authoring rules in CLAUDE.md across every skill in skills/.
# Usage: bash scripts/sh/validate-skills.sh   (exit 0 = all pass, 1 = violations)

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

fail=0
note() { printf '  %s\n' "$1"; }
err()  { printf '  FAIL: %s\n' "$1"; fail=1; }

# Patterns that must never appear in shipped skills (see CLAUDE.md).
EXT_REFS='superpowers|obra|mattpocock|pocock|ousterhout|github\.com|https?://|#[0-9]{2,}'
VENDORS='\b(haiku|sonnet|opus|claude|gpt-?[0-9o]|gemini|flash|llama|mistral|openai|anthropic)\b'
# Skill text is part of the harness's scan surface: a literal trigger-word in a
# body can hijack the session (fire a thinking mode, trip an injection detector)
# every time the skill loads. Keep shipped text inert to keyword scanners.
SCANNER_TRIGGERS='\bultrathink\b'
# A skill whose name matches a common built-in slash command gets mis-invoked —
# the harness or model picks the wrong one. Names must not shadow them.
SHADOWED_COMMANDS='^(review|init|compact|clear|help|config|status|commit|test|run|plan|resume|doctor|login|logout|memory|mcp|model|agents|hooks|settings|todos|cost|export|bug|vim)$'

mapfile -t skills < <(find skills -name SKILL.md | sort)
[ ${#skills[@]} -eq 0 ] && { echo "no skills found under skills/"; exit 2; }

for skill in "${skills[@]}"; do
  dir=$(dirname "$skill")
  name_dir=$(basename "$dir")
  echo "• $skill"

  # Frontmatter: name + description present.
  fname=$(awk -F': ' '/^name:/{print $2; exit}' "$skill")
  fdesc=$(awk '/^description:/{sub(/^description: /,""); print; exit}' "$skill")
  [ -z "$fname" ] && err "missing frontmatter 'name'"
  [ -z "$fdesc" ] && err "missing frontmatter 'description'"

  # name must match the directory name.
  [ -n "$fname" ] && [ "$fname" != "$name_dir" ] && err "name '$fname' != directory '$name_dir'"

  # name must not shadow a common harness slash command.
  [ -n "$fname" ] && echo "$fname" | grep -qiE "$SHADOWED_COMMANDS" && err "name '$fname' shadows a common harness command — rename to avoid mis-invocation"

  # description length limit.
  [ "${#fdesc}" -gt 1024 ] && err "description ${#fdesc} chars > 1024"

  # Body length: warn over 80 (ok only for a discipline skill), fail over 120.
  lines=$(wc -l < "$skill")
  if   [ "$lines" -gt 120 ]; then err "$lines lines > 120 (too long even for a discipline skill)"
  elif [ "$lines" -gt 80 ];  then note "warn: $lines lines (>80; acceptable only if a discipline skill)"
  fi

  # (Per-skill triggering records retired — activation is proven by the shared
  # harness-backed runners under tests/, not a static record. See tests/README.md.)

  # No external references, vendor model names, or <angle> placeholders — in every
  # .md of the skill, RECURSIVELY (covers references/ and scripts/ subfolders).
  while IFS= read -r f; do
    body=$(sed 's/`[^`]*`//g' "$f")   # ignore inline code spans
    echo "$body" | grep -qiE "$EXT_REFS"        && err "$(basename "$f"): external reference (repo/issue/URL) — state the principle directly"
    echo "$body" | grep -qiE "$VENDORS"         && err "$(basename "$f"): vendor model name — use a capability tier (small|medium|large)"
    echo "$body" | grep -qiE "$SCANNER_TRIGGERS" && err "$(basename "$f"): harness scanner trigger-word — rephrase so a keyword scan can't hijack the session"
    echo "$body" | grep -qE  '<[a-z][a-z0-9 -]*>' && err "$(basename "$f"): bare <angle> placeholder — use {{double-curly}}"
    # The .sdlc-skills/ output location is mandatory (overridable only by the user),
    # never an optional "default" — keep the convention from drifting back.
    grep -nE '\.sdlc-skills/' "$f" | grep -qi 'default' && err "$(basename "$f"): frames an .sdlc-skills/ path as a 'default' — that location is mandatory (overridable only by the user), not a default"
  done < <(find "$dir" -name '*.md')
done

# Progressive-disclosure links are executable navigation for an agent. Resolve
# them in the canonical install tree; adapter-specific layouts run the same
# helper against their own tree.
echo "• skill reference paths resolve"
if ! bash scripts/sh/validate-skill-reference-paths.sh skills; then fail=1; fi

echo "• every sibling reference is directly disclosed"
while IFS= read -r ref; do
  skill_dir="$(dirname "$(dirname "$ref")")"
  skill_file="$skill_dir/SKILL.md"
  ref_name="$(basename "$ref")"
  grep -Fq "references/$ref_name" "$skill_file" ||
    err "$ref: not referenced directly from $skill_file"
done < <(find skills -path '*/references/*.md' -type f | sort)

# The nudge ships too — and is injected into every session, so a scanner
# trigger-word there fires constantly, not just when one skill loads.
echo "• hooks (scanner trigger-words)"
while IFS= read -r f; do
  sed 's/`[^`]*`//g' "$f" | grep -qiE "$SCANNER_TRIGGERS" && err "$f: harness scanner trigger-word"
done < <(find hooks -name '*.md' 2>/dev/null)

# Retired cadence reminders must stay retired in every supported adapter, not
# only Codex. Both fired on a fixed cadence rather than at a real boundary —
# UserPromptSubmit on every prompt, Stop on every turn whose wording read as a
# completion claim — so each re-spent the same advisory tokens turn after turn,
# and Stop additionally forced an extra model turn by blocking. The routing they
# carried is already resident: the session-start injection carries the router's
# whole body (re-applied after compaction), and the skill descriptions are always
# loaded. A new entry can otherwise restore either path under another script name.
echo "• no cadence reminder hooks (UserPromptSubmit, Stop)"
for hook_config in \
  hooks/hooks.json \
  plugins/sdlc-skills/hooks/hooks.json \
  .kimi-plugin/plugin.json; do
  [ -f "$hook_config" ] || continue
  for retired_event in UserPromptSubmit Stop; do
    grep -q "\"$retired_event\"" "$hook_config" \
      && err "$hook_config: $retired_event is retired across supported adapters"
  done
done
# The pre-edit implementation guard is retired for a different reason than the
# cadence hooks: it fired on a real boundary, but it existed to compensate for a
# skippable session-start POINTER. With the router's body resident, the pair led
# implementation on its own in 2 of 3 measured runs — so the guard is no longer
# the thing holding that boundary, and a hook that denies edits is too blunt to
# keep for the remaining margin. Routing is persuasion; the artifact-level gates
# are what decide. Do not restore it under another name without new evidence.
for retired_script in \
  scripts/sh/implementation-remind.sh \
  scripts/sh/implementation-guard.sh \
  scripts/sh/stop-nudge.sh \
  scripts/sh/stop-nudge-detect.sh \
  scripts/sh/stop-nudge-kimi.sh \
  tests/run-implementation-guard.sh \
  tests/run-stop-nudge.sh; do
  [ ! -e "$retired_script" ] || err "obsolete $retired_script still exists"
done

# Manifest sync: a harness discovers skills only through its manifest, so every
# leaf skill dir must be listed explicitly in the plugin's "skills" array — a
# skill missing from it silently fails to load; a dead entry points nowhere.
actual=$(printf '%s\n' "${skills[@]}" | sed 's|/SKILL.md$||; s|^|./|' | sort -u)
manifest=.claude-plugin/plugin.json
echo "• $manifest (skills array sync)"
if [ ! -f "$manifest" ]; then
  err "missing $manifest"
else
  declared=$(grep -oE '"\./skills/[^"]+"' "$manifest" | tr -d '"' | sort -u)
  missing=$(comm -23 <(printf '%s\n' "$actual") <(printf '%s\n' "$declared"))
  dead=$(comm -13 <(printf '%s\n' "$actual") <(printf '%s\n' "$declared"))
  [ -n "$missing" ] && while IFS= read -r m; do err "skill not in $manifest 'skills' (won't load): $m"; done <<< "$missing"
  [ -n "$dead" ]    && while IFS= read -r d; do err "$manifest 'skills' entry has no SKILL.md: $d"; done <<< "$dead"
fi

echo "• Codex adapter"
if ! bash scripts/sh/validate-codex-plugin.sh; then fail=1; fi

echo "• Kimi adapter"
if ! bash scripts/sh/validate-kimi-plugin.sh; then fail=1; fi

# Version sync: the release version is declared in three manifests and bumped
# together in one release commit (see RELEASING.md). A half-done bump ships
# disagreeing versions, so any disagreement fails.
echo "• manifest versions agree"
versions=""
for manifest in .claude-plugin/plugin.json .claude-plugin/marketplace.json .kimi-plugin/plugin.json; do
  if [ ! -f "$manifest" ]; then err "missing $manifest"; continue; fi
  v=$(grep -m1 -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$manifest" | sed -E 's/.*"([^"]+)"$/\1/')
  if [ -z "$v" ]; then err "$manifest: no \"version\" field"; continue; fi
  versions="$versions$v"$'\n'
done
distinct=$(printf '%s' "$versions" | sort -u | grep -c .)
[ "$distinct" -gt 1 ] && err "manifest versions disagree: $(printf '%s' "$versions" | sort -u | tr '\n' ' ')"

# Internal references: any repo-root docs/ or tests/ markdown path named in a
# shipped or meta file must exist — a broken link ships straight to users.
echo "• internal references (docs/ and tests/ paths resolve)"
while IFS=: read -r src ref; do
  [ -f "$ref" ] || err "$src: internal reference '$ref' does not exist"
done < <(grep -roE '(docs|tests)/[A-Za-z0-9._/-]+\.md' skills docs tests README.md CLAUDE.md | sort -u)

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ all skills pass structural validation"; else echo "✗ violations found"; fi
exit "$fail"
