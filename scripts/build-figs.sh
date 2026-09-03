#!/bin/bash
# Build all book figures as SVG.
#  - Compiles the standalone TikZ/forest sources in figs/src/ to PDF.
#  - Converts every source PDF (hand-drawn or TikZ-derived) to SVG in figs/.
# Idempotent: safe to re-run.
#
# Conversion goes through Inkscape rather than `pdftocairo -svg`. pdftocairo
# encodes PDF transparency groups as SVG `feImage` filters that reference
# internal elements. Chrome tolerates those; WebKit (Safari, Preview,
# QuickLook) does not, and silently drops the affected artwork -- whole shapes
# and labels vanish from the figure. Inkscape emits plain paths with
# fill-opacity instead, which every renderer handles.
set -euo pipefail

cd "$(dirname "$0")/.."

command -v inkscape >/dev/null || {
  echo "error: inkscape not found (brew install --cask inkscape)" >&2
  exit 1
}

# PDF -> SVG, refusing to emit a file that would render wrongly for a reader.
#
# --export-text-to-path is required, not cosmetic: Inkscape otherwise imports
# the TikZ figures' labels as live <text> in Computer Modern (CMR10, CMMI10,
# ...), fonts no reader has and that the SVG does not embed, so the labels
# render in a fallback face or not at all.
pdf_to_svg() {
  local src="$1" out="$2"
  inkscape "$src" --export-type=svg --export-plain-svg --export-text-to-path \
    --export-filename="$out" >/dev/null
  if grep -q 'feImage' "$out"; then
    echo "error: $out contains feImage filters; it will not render in WebKit" >&2
    exit 1
  fi
  if grep -q '<text' "$out"; then
    echo "error: $out contains live <text>; labels need embedded fonts" >&2
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
