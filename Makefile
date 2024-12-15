CC    = clang
FLEX  = flex
BISON = bison

BISON_FLAGS += --warnings=error=all
# BISON_FLAGS += --warnings=error=conflicts-rr,error=conflicts-sr,error=counterexamples,error=dangling-alias,error=deprecated,error=everything,error=midrule-values,error=none,error=other,error=precedence,error=yacc
BISON_FLAGS += --verbose
BISON_FLAGS += --color=always

LEX_SRC  = src/gocompiler.l
YACC_SRC = src/gocompiler.y

LEX_OUTPUT  = bin/lex.yy.c
YACC_OUTPUT = bin/parser.tab.c
YACC_HEADER = bin/y.tab.h
REPORT_FILE = bin/y.output

CFLAGS += -Wall -Wextra -Werror
CFLAGS += -Wno-unused-function
CFLAGS += -Wno-implicit-function-declaration
CFLAGS += -I$(shell realpath include)
CFLAGS += -I$(shell realpath bin)
CFLAGS += -ggdb

COMPILER      = bin/deigoc
COMPILER_SRC  = \
	       $(LEX_OUTPUT) \
	       $(YACC_OUTPUT) \
	       src/gocompiler.o \
	       src/main.o \
	       src/deigo-string.o \
	       src/lexer.o src/parser.o src/semantics.o src/codegen.o
COMPILER_ZIP  = gocompiler.zip

all: $(COMPILER)

$(COMPILER): $(COMPILER_SRC)
	mkdir --parents "$(shell dirname "$@")"
	$(CC) $(CFLAGS) -o $@ $^

$(LEX_OUTPUT): $(LEX_SRC)
	mkdir --parents "$(shell dirname "$@")"
	$(FLEX) --outfile=$@ $^

$(YACC_OUTPUT) $(YACC_HEADER): $(YACC_SRC)
	mkdir --parents "$(shell dirname "$@")"
	$(BISON) $(BISON_FLAGS) --report-file=$(REPORT_FILE) --header=$(YACC_HEADER) --output=$(YACC_OUTPUT) --debug $^

$(COMPILER_ZIP): include/*.h src/*.[cyl]
	rm --force $@
	zip --junk-paths $@ $^

.PHONY: entrega
entrega: bin/1.zip bin/2.zip bin/3.zip bin/4.zip

%.zip: %-src.zip %-include.zip
	rm --force $@
	-rm --recursive bin/temp-zip
	for zip in $^; do unzip -d bin/temp-zip "$$zip" || true; done
	zip -r --junk-paths $@ ./bin/temp-zip

bin/1-src.zip:
	git archive --format=zip refs/tags/meta1:src > $@

bin/1-include.zip:
	touch $@

bin/2-src.zip:
	git archive --format=zip HEAD:src > $@

bin/2-include.zip:
	git archive --format=zip HEAD:include > $@

bin/3-src.zip:
	git archive --format=zip HEAD:src > $@

bin/3-include.zip:
	git archive --format=zip HEAD:include > $@

bin/4-src.zip:
	git archive --format=zip HEAD:src > $@

bin/4-include.zip:
	git archive --format=zip HEAD:include > $@

src/gocompiler.c:
	@echo "[Excluding $@ from implicit rules]"

%.pdf: %.md
	pandoc $(PANDOC_OPTS) --output=$@ $<

.PHONY: run
run: $(COMPILER)
	./$(COMPILER)

.PHONY: test
test: $(COMPILER)
	./test.sh --metas=1,2,3 --color=always $(TEST_FLAGS)

.PHONY: clean
clean:
	find . -type f -iname "*.o" -exec rm --force "{}" \;
	find ./bin -type f -exec rm --force "{}" \;
	rm --force $(COMPILER) $(COMPILER_ZIP)

.PHONY: .clangd
.clangd:
	rm --force $@

	@echo Diagnostics: | tee --append $@
	@echo '  UnusedIncludes: Strict' | tee --append $@
	@echo '  MissingIncludes: Strict' | tee --append $@
	@echo CompileFlags: | tee --append $@
	@echo '  Add:' | tee --append $@

	@for flag in $(CFLAGS) $(CXXFLAGS) ; do echo "    - $$flag" | tee --append $@ ; done
