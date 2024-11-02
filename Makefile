CC    = clang
FLEX  = flex
BISON = bison

LEX_SRC  = src/gocompiler.l
YACC_SRC = src/parser.y

LEX_OUTPUT  = bin/lex.yy.c
YACC_OUTPUT = bin/parser.tab.c
YACC_HEADER = bin/y.tab.h
REPORT_FILE = bin/y.output

CFLAGS  = -Wall -Wextra -Werror
CFLAGS += -Wno-unused-function
CFLAGS += -Wno-implicit-function-declaration
CFLAGS += -I$(shell realpath include)

COMPILER = bin/deigoc
COMPILER_SRC = \
	       $(LEX_OUTPUT) \
	       $(YACC_OUTPUT) \
	       src/ast.c \
	       src/yy.c
COMPILER_ZIP = gocompiler.zip

all: $(COMPILER)

$(COMPILER): $(COMPILER_SRC)
	mkdir --parents "$(shell dirname "$@")"
	$(CC) $(CFLAGS) -o $@ $^

$(LEX_OUTPUT): $(LEX_SRC)
	mkdir --parents "$(shell dirname "$@")"
	$(FLEX) --outfile=$@ $^

$(YACC_OUTPUT) $(YACC_HEADER): $(YACC_SRC)
	mkdir --parents "$(shell dirname "$@")"
	$(BISON) --verbose --report-file=$(REPORT_FILE) --header=$(YACC_HEADER) --output=$(YACC_OUTPUT) --debug $^

$(COMPILER_ZIP): src/gocompiler.l
	rm --force $@
	zip --junk-paths $@ $^

%.c: %.l
	lex --outfile $@ $<

.PHONY: run
run: $(COMPILER)
	./$(COMPILER)

.PHONY: test
test: $(COMPILER)
	./test.sh --metas=1,2 --color=always

.PHONY: clean
clean:
	find . -type f -iname "*.o" -exec rm --force "{}" \;
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
