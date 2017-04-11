build:
	lex project.lex
	yacc -d project.yacc
	gcc lex.yy.c y.tab.c -ll -ly

test:
	bash tests/test.sh
