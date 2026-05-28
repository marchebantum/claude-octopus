#!/usr/bin/env bash
# Regression tests for Opus 4.7 dispatch.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/../helpers/test-framework.sh"
test_suite "Claude Opus dispatch"

export PLUGIN_DIR="$PROJECT_ROOT"
export _BARE_OPT=""
source "$PROJECT_ROOT/scripts/lib/utils.sh"
source "$PROJECT_ROOT/scripts/lib/model-resolver.sh"
source "$PROJECT_ROOT/scripts/lib/provider-routing.sh"
source "$PROJECT_ROOT/scripts/lib/dispatch.sh"

test_case "claude-opus resolves to Opus 4.7"
if [[ "$(get_agent_model claude-opus)" == "claude-opus-4.7" ]]; then
    test_pass
else
    test_fail "claude-opus should resolve to claude-opus-4.7"
fi

test_case "xhigh Opus dispatch command passes validation"
export SUPPORTS_XHIGH_EFFORT=true
cmd="$(get_agent_command claude-opus)"
if [[ "$cmd" == "env CLAUDE_CODE_EFFORT_LEVEL=xhigh claude --print --model opus" ]] &&
   validate_agent_command "$cmd"; then
    test_pass
else
    test_fail "expected validated xhigh Opus command, got: $cmd"
fi

test_summary
