# Digital book making Makefile
# by Tony McDowell (svet.am@gmail.com)

# Define variables
# Expand the PDFLatex command since it is complex
PDFBUILDCMD = pdflatex -interaction=nonstopmode -shell-escape -verbose

# The name of the main LaTeX file
TOPTEX = main

# The name of the build output directory
BUILD_DIR := build

# OS-specific commands
ifeq ($(OS),Windows_NT) # Windows
	DELCMD := rmdir /S /Q
else
	DELCMD := rm -Rf
endif

PHONY: all clean viewpdf $(BUILD_DIR)

# Default target to build the PDF
all:
	$(error ALL is not a valid target. Build a specific document format: pdf, epub, docx)

# Rule to generate the PDF
pdf: | $(BUILD_DIR)
	$(PDFBUILDCMD) $(TOPTEX).tex --output-directory=$(BUILD_DIR)
# Run PDF build again to insert the table of contents data
# This is normal - https://stackoverflow.com/questions/3863630/latex-tableofcontents-command-always-shows-blank-contents-on-first-build
	$(PDFBUILDCMD) $(TOPTEX).tex --output-directory=$(BUILD_DIR)
	
# Only enable the command below if a bibliography is needed, else it WILL error MAKE	
# $bibtex $(BUILD_DIR)/$(TOPTEX).aux

# Rule to generate the EPUB
epub: $(TOPTEX).tex | $(BUILD_DIR) 
	latexml --dest=$(BUILD_DIR)/$(TOPTEX).xml $(TOPTEX).tex
	latexmlpost -dest=$(BUILD_DIR)/$(TOPTEX).html $(BUILD_DIR)/$(TOPTEX).xml
	ebook-convert $(BUILD_DIR)/$(TOPTEX).html $(BUILD_DIR)/$(TOPTEX).epub

# Rule to generate the DOCX
docx: $(TOPTEX).tex | $(BUILD_DIR) 
	pandoc -o $(BUILD_DIR)/$(TOPTEX).docx $(TOPTEX).tex

# Clean up temporary files
clean:
	@$(DELCMD) $(BUILD_DIR)
	del *.log
	
$(BUILD_DIR):
	@mkdir $@