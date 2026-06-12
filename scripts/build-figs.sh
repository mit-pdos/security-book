#!/bin/bash
# Build all book figures as SVG.
#  - Converts the static PDF figures in figs/ to SVG.
#  - Compiles the standalone TikZ/forest sources in figs/src/ and converts to SVG.
# Idempotent: safe to re-run.
set -euo pipefail

cd "$(dirname "$0")/.."

# Static figures: PDF -> SVG
for f in figs/*.pdf; do
  [ -e "$f" ] || continue
  b="${f%.pdf}"
  pdftocairo -svg "$f" "$b.svg"
  echo "converted $f -> $b.svg"
done

# TikZ/forest figures: TeX -> PDF -> SVG
for s in figs/src/*.tex; do
  b="$(basename "${s%.tex}")"
  (cd figs/src && pdflatex -interaction=nonstopmode -halt-on-error "$b.tex" >/dev/null)
  pdftocairo -svg "figs/src/$b.pdf" "figs/$b.svg"
  echo "rendered figs/src/$b.tex -> figs/$b.svg"
done
