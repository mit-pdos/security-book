QUARTO ?= quarto
OUTPUT_DIR := _book

# Inputs to watch for changes.
WATCH_PATHS := index.qmd references.qmd _quarto.yml custom.scss ref.bib chapters macros figs
# What `make watch` rebuilds on each change, and how often it polls (seconds).
WATCH_TARGET ?= pdf
POLL ?= 1

# stat(1) is BSD on macOS, GNU elsewhere.
STAT := $(shell if stat -f '%m' Makefile >/dev/null 2>&1; \
	then echo 'stat -f "%m %N"'; else echo 'stat -c "%Y %n"'; fi)

.PHONY: all html pdf preview watch clean

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

clean:
	rm -rf $(OUTPUT_DIR) .quarto
