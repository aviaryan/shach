build:
	lex project.lex
	yacc -d -v project.yacc
	gcc lex.yy.c y.tab.c -ll -ly

test:
	bash tests/test.sh
