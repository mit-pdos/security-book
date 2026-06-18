QUARTO ?= quarto
OUTPUT_DIR := _book

.PHONY: all html pdf preview clean

all: html pdf

html:
	$(QUARTO) render --to html

pdf:
	$(QUARTO) render --to pdf

preview:
	$(QUARTO) preview --to html

clean:
	rm -rf $(OUTPUT_DIR) .quarto
