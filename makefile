.PHONY: all

all:
	flex *.l
	yacc -d *.y
	cc -o bas *.c
