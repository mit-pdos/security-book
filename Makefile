QUARTO ?= quarto

# Local builds render draft TODO notes; the GitHub Pages workflow doesn't run
# make, so it never sets a profile and the notes are stripped from what ships.
# Use `make final` to reproduce the published build locally.
QUARTO_PROFILE ?= draft
export QUARTO_PROFILE
OUTPUT_DIR := _book

# Inputs to watch for changes.
WATCH_PATHS := index.qmd references.qmd _quarto.yml custom.scss ref.bib chapters macros figs
# What `make watch` rebuilds on each change, and how often it polls (seconds).
WATCH_TARGET ?= pdf
POLL ?= 1

# stat(1) is BSD on macOS, GNU elsewhere.
STAT := $(shell if stat -f '%m' Makefile >/dev/null 2>&1; \
	then echo 'stat -f "%m %N"'; else echo 'stat -c "%Y %n"'; fi)

.PHONY: all html pdf preview watch final clean

all: html pdf

html:
	$(QUARTO) render --to html

pdf:
	$(QUARTO) render --to pdf

# Live-reloading HTML preview in the browser (quarto watches inputs itself).
preview:
	$(QUARTO) preview --to html

# Rebuild $(WATCH_TARGET) whenever a source file changes. Ctrl-C to stop.
watch:
	@echo "Watching $(WATCH_PATHS) -> make $(WATCH_TARGET)  (Ctrl-C to stop)"
	@snapshot() { find $(WATCH_PATHS) -type f ! -name '.*' -exec $(STAT) {} + 2>/dev/null | sort; }; \
	prev=""; \
	while :; do \
		cur=$$(snapshot); \
		if [ "$$cur" != "$$prev" ]; then \
			[ -n "$$prev" ] && echo "==> change detected, rebuilding"; \
			$(MAKE) --no-print-directory $(WATCH_TARGET) || echo "==> build failed"; \
			prev=$$(snapshot); \
		fi; \
		sleep $(POLL); \
	done

# Reproduce the published build locally, with draft TODO notes stripped.
# Setting QUARTO_PROFILE to the empty string does NOT work -- quarto keeps the
# profile active and the notes survive -- so the variable has to be unset.
final:
	env -u QUARTO_PROFILE $(QUARTO) render --to html

clean:
	rm -rf $(OUTPUT_DIR) .quarto
