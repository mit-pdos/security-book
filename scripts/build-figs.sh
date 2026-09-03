#!/bin/bash
# Build all book figures as SVG.
#  - Compiles the standalone TikZ/forest sources in figs/src/ to PDF.
#  - Converts every source PDF (hand-drawn or TikZ-derived) to SVG in figs/.
# Idempotent: safe to re-run.
set -euo pipefail

cd "$(dirname "$0")/.."

# PDF -> SVG.
#
# Neither available converter is right for every figure, so pick per figure:
#
#   pdftocairo renders embedded fonts faithfully as paths, which the TikZ
#   figures need -- their labels are Computer Modern math. But it encodes PDF
#   transparency groups as SVG `feImage` filters referencing internal elements.
#   Chrome tolerates those; WebKit (Safari, Preview, QuickLook) does not, and
#   silently drops the affected artwork -- whole shapes and labels vanish.
#
#   Inkscape has no such transparency problem, but it substitutes a fallback
#   face for fonts it cannot resolve from the PDF, so Computer Modern math
#   comes out upright sans-serif.
#
# So: convert with pdftocairo, and fall back to Inkscape only for the figures
# whose transparency it mishandles. That is the hand-drawn set, which is pure
# paths with no text, so Inkscape's font weakness cannot bite. A figure needing
# both is not something either tool handles -- fail loudly rather than ship it.
pdf_to_svg() {
  local src="$1" out="$2"

  pdftocairo -svg "$src" "$out"
  grep -q 'feImage' "$out" || return 0

  command -v inkscape >/dev/null || {
    echo "error: $src needs inkscape (brew install --cask inkscape)" >&2
    exit 1
  }
  inkscape "$src" --export-type=svg --export-plain-svg \
    --export-filename="$out" >/dev/null

  if grep -q 'feImage' "$out"; then
    echo "error: $out still has feImage filters; it will not render in WebKit" >&2
    exit 1
  fi
  if grep -q '<text' "$out"; then
    echo "error: $out mixes transparency with text; inkscape will have" >&2
    echo "       substituted fonts for its labels. Convert it by hand." >&2
    exit 1
  fi
}

# TikZ/forest figures: TeX -> PDF. The PDFs land in figs/src/ and are picked up
# by the conversion loop below, alongside the hand-drawn sources.
for s in figs/src/*.tex; do
  [ -e "$s" ] || continue
  b="$(basename "${s%.tex}")"
  (cd figs/src && pdflatex -interaction=nonstopmode -halt-on-error "$b.tex" >/dev/null)
  echo "compiled $s -> figs/src/$b.pdf"
done

# Every source PDF: hand-drawn scans plus the TikZ output compiled above.
for f in figs/src/*.pdf; do
  [ -e "$f" ] || continue
  b="$(basename "${f%.pdf}")"
  pdf_to_svg "$f" "figs/$b.svg"
  echo "converted $f -> figs/$b.svg"
done

# Static figures dropped straight into figs/. Runs last, so a PDF here wins
# over a same-named source in figs/src/.
for f in figs/*.pdf; do
  [ -e "$f" ] || continue
  b="${f%.pdf}"
  pdf_to_svg "$f" "$b.svg"
  echo "converted $f -> $b.svg"
done
