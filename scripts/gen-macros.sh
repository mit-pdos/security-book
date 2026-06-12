#!/bin/bash
# Regenerate macros/_macros.qmd from macros-common.tex + macros-html-overrides.tex.
# The result is a hidden math block included at the top of every chapter so
# that MathJax picks up the macro definitions on each HTML page.
# (The PDF build gets the macros via include-in-header in _quarto.yml instead.)
set -euo pipefail
cd "$(dirname "$0")/.."

out=macros/_macros.qmd
{
  echo '::: {.content-visible when-format="html"}'
  echo '::: {.hidden}'
  echo '$$'
  # strip comments and blank lines (a blank line would terminate the math block)
  sed -e 's/[ \t]*%.*$//' -e '/^[ \t]*$/d' macros/macros-common.tex macros/macros-html-overrides.tex
  echo '$$'
  echo ':::'
  echo ':::'
} > "$out"
echo "wrote $out"
