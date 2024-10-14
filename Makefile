CXXFLAGS = -Wall -Wextra -std=c++17

COMPILER = bin/deigoc

all: $(COMPILER)

$(COMPILER): %: src/lexer.o
	$(CC) -o $@ $^

%.c: %.l
	lex --outfile $@ $< 

.PHONY: run
run: $(COMPILER)
	./$(COMPILER)

.PHONY: run-tests
run-tests:
	@echo TODO
