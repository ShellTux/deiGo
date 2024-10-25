CFLAGS  = -Wall -Wextra -Werror -std=c11
CFLAGS += -Wno-unused-function -Wno-implicit-function-declaration

COMPILER = bin/deigoc
COMPILER_ZIP = gocompiler.zip

all: $(COMPILER)

$(COMPILER): %: src/gocompiler.o
	mkdir --parents "$(shell dirname "$@")"
	$(CC) -o $@ $^

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
	./test.sh --metas=1

.PHONY: clean
clean:
	find . -type f -iname "*.o" -exec rm --force "{}" \;
	rm --force $(COMPILER) $(COMPILER_ZIP)
