########################################################################
# Markdown Processing
########################################################################

MARKDOWN2 =	markdown2

LINK_PATTERNS_FILE = lib/link-patterns.txt

MARKDOWN_FLAGS += -x fenced-code-blocks
MARKDOWN_FLAGS += -x smarty-pants
MARKDOWN_FLAGS += -x link-patterns
MARKDOWN_FLAGS += --link-patterns-file $(LINK_PATTERNS_FILE)

.SUFFIXES:	.md .html

output/%.html: %.md $(LINK_PATTERNS_FILE)
	mkdir -p `dirname $@`
	$(MARKDOWN2) $(MARKDOWN_FLAGS) $< > $@

########################################################################
# File Lists
########################################################################

MARKDOWN_FILES = \
	fma/protocol.md

HTML_FILES = \
	$(addprefix output/,$(subst .md,.html,$(MARKDOWN_FILES)))

########################################################################
# Targets
########################################################################

all:	output $(HTML_FILES)

output:
	mkdir output

clean:
	rm -f $(HTML_FILES)
