#!/usr/bin/env bash
# ci-template.test.sh (node) — o template de CI e o hook que a skill distribui obedecem à própria skill.
# O quê: reprova template que (a) dispare por commit/PR (piso 27, via check-ci-triggers.sh) ou (b) traga
#   o furo específico achado na revisão de 2026-10-31 (ver asserts abaixo). Gate sem teste é decoração.
# Saída: exit 0 todos passam, 1 algum falhou.
# strict-ok: harness de teste, soma os casos (`schematize-shell` -> `references/piso.md` secao 1)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI="$HERE/../assets/ci/github-actions-ci.yml"; rc=0
falha() { echo "  FALHOU $1"; rc=1; }
bash "$HERE/check-ci-triggers.sh" "$CI" >/dev/null 2>&1 || falha "template reprovado pelo check-ci-triggers (piso 27)"
grep -qE '^[[:space:]]*pull_request' "$CI" && falha "template tem pull_request"
H="$HERE/../assets/hooks/.pre-commit-config.yaml"
grep -qE "check-diff\.sh HEAD" "$H" && falha "hook chama check-diff.sh HEAD"
# job que só faz echo é verde mentiroso: o passo do test-kit tem de falhar enquanto for placeholder
awk "/test-kit:/,/security-scan:/" "$CI" | grep -q "exit 1" || falha "test-kit sem exit 1 (placeholder verde)"
[ "$rc" -eq 0 ] && echo "ci-template.test(node): OK" || echo "ci-template.test(node): FALHOU"
exit "$rc"
