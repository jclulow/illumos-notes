########################################################################
# Markdown Processing
########################################################################

SED =		sed
MARKDOWN2 =	markdown2

LINK_PATTERNS_FILE = lib/link-patterns.txt

MARKDOWN_FLAGS += -x wiki-tables
MARKDOWN_FLAGS += -x fenced-code-blocks
MARKDOWN_FLAGS += -x smarty-pants
MARKDOWN_FLAGS += -x link-patterns
MARKDOWN_FLAGS += --link-patterns-file $(LINK_PATTERNS_FILE)

.SUFFIXES:	.md .html

COMMON_HEADER = common/header.html
COMMON_FOOTER = common/footer.html
COMMON_HTML = $(COMMON_HEADER) $(COMMON_FOOTER)

output/%.html: %.md $(LINK_PATTERNS_FILE) $(COMMON_HTML)
	mkdir -p `dirname $@`
	$(SED) < $(COMMON_HEADER) > $@ \
		's^==TITLE==^$<^g' && \
	$(MARKDOWN2) $(MARKDOWN_FLAGS) $< >> $@ && \
	$(SED) < $(COMMON_FOOTER) >> $@ \
		's^==TITLE==^$<^g'

########################################################################
# File Lists
########################################################################

MARKDOWN_FILES = \
	index.md \
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
