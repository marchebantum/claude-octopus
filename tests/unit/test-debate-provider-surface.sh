#!/usr/bin/env bash
# Regression tests for the debate skill's visible provider contract.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/../helpers/test-framework.sh"
test_suite "Debate provider surface"

SKILL_FILE="$PROJECT_ROOT/skills/skill-debate/SKILL.md"
COMMAND_FILE="$PROJECT_ROOT/.claude/commands/debate.md"
BUILD_FLEET="$PROJECT_ROOT/scripts/helpers/build-fleet.sh"

combined_text="$(printf '%s\n' "$(cat "$SKILL_FILE")" "$(cat "$COMMAND_FILE")")"

test_case "debate docs name Codex and Claude Opus as the core providers"
if assert_contains "$combined_text" "Codex + Claude Opus" "debate docs should state the active provider pair" &&
   assert_contains "$combined_text" "claude-opus" "debate docs should name the runtime agent"; then
    test_pass
fi

test_case "debate docs do not advertise Gemini or Sonnet as core participants"
if assert_not_contains "$combined_text" "Gemini CLI" "Gemini must not be advertised as a debate participant" &&
   assert_not_contains "$combined_text" "Sonnet 4.6" "Sonnet must not be advertised as a debate participant" &&
   assert_not_contains "$combined_text" "current host model" "host synthesis should not masquerade as an Opus provider" &&
   assert_not_contains "$combined_text" "four-way" "debate docs should not promise a four-way run"; then
    test_pass
fi

test_case "debate fleet uses Codex debater and Claude Opus moderator with allowlist"
fleet=$(OCTO_ALLOWED_PROVIDERS="codex claude" "$BUILD_FLEET" debate standard "provider surface" 2>/dev/null)
if assert_contains "$fleet" "codex|Debater|" "Codex should be the debate worker" &&
   assert_contains "$fleet" "claude-opus|Moderator|" "Claude Opus should be the moderator"; then
    test_pass
fi

test_summary
