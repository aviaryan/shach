%{
	#include <stdio.h>
	#define YYSTYPE char*
	#include "y.tab.h"
	// extern char * yylval;
%}

	int begin_wn = 0;
	int begin_ux = 0;

%%

\n[ \t]*  { printf("TRAILING SPACE < %s >\n", yytext); return NL; }

"#BEGIN UX" {
	begin_ux = 1;
	printf("BEGIN_UX < %s >\n", yytext);
	return BEGIN_UX;
	// handle this in yacc rules.. if begin_ux is set, then only output on unix and v.v.
}

"#END UX" {
	begin_ux = 0;
	printf("END_UX < %s >\n", yytext);
	return END_UX;
}

"#BEGIN WN" {
	begin_wn = 1;
	printf("BEGIN_WN < %s >\n", yytext);
	return BEGIN_WN;
}

"#END WN" {
	begin_wn = 0;
	printf("END_WN < %s >\n", yytext);
	return END_WN;
}

"#BEGIN RAWUX"(.|\n)+"#END RAWUX" {
	yylval = strdup(yytext);
	printf("RAW_UX < %s >\n", yytext); return RAW_UX;
}

"#BEGIN RAWWN"(.|\n)+"#END RAWWN" {
	yylval = strdup(yytext);
	printf("RAW_WN < %s >\n", yytext); return RAW_WN;
}

"+"	{ printf("ADD\n"); return('+');}

"++" {printf("CONCAT\n"); return CONCAT;}

"-"	{ printf("SUB\n"); return('-');}

"*"	{ printf("MULTI\n"); return('*');}

"/"	{ printf("DIVIDE\n"); return('/');}

"**"	{ printf("POWER\n"); return POWER;}

"["	{ printf("OPENSQBR\n"); return ('[');}

"]"	{ printf("CLOSESQBR\n"); return (']');}

"#"[^\n]*   { printf("COMMENT < %s >\n", yytext); }

0|[1-9][0-9]* {
	yylval = strdup(yytext);
	printf("NUMBER < %s >\n", yytext); return NUMBER; 
}

-[1-9][0-9]* {
	yylval = strdup(yytext);
	printf("NEGNUMBER < %s >\n", yytext); return NEGATIVE_NUM;
}

"True"  {printf("TRUE < %s >\n", yytext); return TRUE;}

"False"  {printf("FALSE < %s >\n", yytext); return FALSE;}

"return"  {
	yylval = strdup(yytext);
	printf("RETURN < %s >\n", yytext); return RETURN;
}

"call"   {printf("CALL < %s >\n", yytext); return CALL;}

"print"  {printf("PRINT < %s >\n", yytext); return PRINT;}

"scan" {printf("SCAN < %s >\n", yytext); return SCAN;}

"isfile" {printf("ISFILE < %s >\n", yytext); return ISFILE;}

"isdir" {printf("ISDIR < %s >\n", yytext); return ISDIR;}

"exists" {printf("EXISTS < %s >\n", yytext); return EXISTS;}

"rawbash" {printf("RAWBASH < %s >\n", yytext); return RAWBASH;}

"rawbatch" {printf("RAWBATCH < %s >\n", yytext); return RAWBATCH;}

"bash" {printf("BASH < %s >\n", yytext); return BASH;}

"batch" {printf("BATCH < %s >\n", yytext); return BATCH;}

"loadenv" {printf("LOADENV < %s >\n", yytext); return LOADENV;}

"break" {printf("BREAK < %s >\n", yytext); return BREAK;}

"continue" {printf("CONTINUE < %s >\n", yytext); return CONTINUE;}

"if" {printf("IF < %s >\n", yytext); return IF;}

"else" {printf("ELSE < %s >\n", yytext); return ELSE;}

"elif" {printf("ELIF < %s >\n", yytext); return ELIF;}

"func " {printf("FUNC < %s >\n", yytext); return FUNC;}

"in" {printf("IN < %s >\n", yytext); return IN;}

"for" {printf("FOR < %s >\n", yytext); return FOR;}

"xxx"  {printf("EOFL < %s >\n", yytext); return EOFL; }

"="    { printf("EQUAL\n"); return('=');}

"("    { printf("OPENBRACKET\n"); return('(');}

")"    { printf("CLOSEBRACKET\n"); return(')');}

"{"    { printf("OPENBRACE\n"); return('{');}

"}"    { printf("CLOSEBRACE\n"); return('}');}

","  { printf("COMMA\n"); return(','); }

">"  { printf("GT\n"); return('>'); }

"<"  { printf("LT\n"); return('<'); }

">="  { printf("GTEQ\n"); return GTEQ; }

"<="  { printf("LTEQ\n"); return LTEQ; }

"=="  { printf("EQCOND\n"); return EQCOND; }

"<>"  { printf("NOTEQ\n"); return NOTEQ; }

"&&"  { printf("LOGAND\n"); return LOGAND; }

"||"  { printf("LOGOR\n"); return LOGOR; }

"while" {printf("WHILE < %s >\n", yytext); return WHILE;} 

"file" {printf("READFILE < %s >\n", yytext); return READFILE;}

"dir" {printf("DIR < %s >\n", yytext); return DIR;}

"arrlen" {printf("ARRLEN < %s >\n", yytext); return ARRLEN;}

"strlen" {printf("STRLEN < %s >\n", yytext); return STRLEN;}

\$([a-zA-Z][a-zA-Z0-9_]*|[1-9][0-9]*) {
	yylval = strdup(yytext);
	printf("ID < %s >\n", yytext); return ID;
}

[a-zA-Z0-9_]+  {
	yylval = strdup(yytext);
	printf("FUNC_NAME < %s >\n", yytext); return FUNC_NAME;
}

"~"[^\n\r]+  {
	yylval = strdup(yytext);
	printf("COMMAND < %s >\n", yytext); return COMMAND;
}

\"[^\n\r\"]*\"  {
	yylval = strdup(yytext);
	printf("STR < %s >\n", yytext); return STR;
}

[ \t]*  {
	// this is risky, can cause issues where we remove whitespaces which were actually needed.
	// important to keep in the end
	printf("WHITESPACE\n");
}

.  {printf("INVALID < %s >\n", yytext); return INVALID;}

%%
