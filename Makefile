CXXFLAGS = -Wall -Wextra -std=c++17

COMPILER = bin/deigoc
COMPILER_ZIP = gocompiler.zip

all: $(COMPILER)

$(COMPILER): %: src/gocompiler.o
	$(CC) -o $@ $^

$(COMPILER_ZIP): src/gocompiler.l
	rm --force $@
	zip --junk-paths $@ $^

%.c: %.l
	lex --outfile $@ $< 

.PHONY: run
run: $(COMPILER)
	./$(COMPILER)

.PHONY: run-tests
run-tests: $(COMPILER)
	./test.sh
