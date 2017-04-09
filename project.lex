%{
	#include "y.tab.h"
	extern int yylval;
	
	bool begin_wn = false;
	bool begin_ux = false;
%}

%%

"#BEGIN UX" {
	begin_ux = true;
	return BEGIN_UX;
}

"#END UX" {
	begin_ux = false;
	return END_UX;
}

"#BEGIN WN" {
	begin_wn = true;
	return BEGIN_WN;
}

"#END WN" {
	begin_wn = false;
	return END_WN;
}

"#"[^\n]*   { printf("COMMENT"); }

0 | [1-9][0-9]* {return NUMBER;}

(-)? {return NUMBER;}

"True"  {return TRUE;}

"False"  {return FALSE;}

"return"  {return RETURN;}

"call"   {return CALL;}

"print"  {return PRINT;}

"scan" {return SCAN;}

"isfile" {return ISFILE;}

"isdir" {return ISDIR;}

"exists" {return EXISTS;}

"rawbash" {return RAWBASH;}

"rawbatch" {return RAWBATCH;}

"bash" {return BASH;}

"batch" {return BATCH;}

"loadenv" {return LOADENV;}

\n   {printf("XX"); return NL;}

"break" {return BREAK;}

"continue" {return CONTINUE;}

"if" {return IF;}

"else" {return ELSE;}

"elif" {return ELIF;}

"func" {return FUNC;}

"in" {return IN;}

"for" {return FOR;}

"while" {return WHILE;} 

"file" {return READFILE;}

"dir" {return DIR;}

"xxx" {return EOFL;}

"arrlen" {return ARRLEN;}

"strlen" {return STRLEN;}

"(-)?" {return NEGATIVE_NUM;}

[a-zA-Z][a-zA-Z0-9_]* | [1-9][0-9]* {return ID;}

[a-zA-Z0-9_]+  {return FUNC_NAME;}

[a-zA-Z0-9_-]+  {return COMMAND;}

[^\n\r]*    {printf("tess < %s >", yytext); return TEXT;}

%%
