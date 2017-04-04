%{
	#include "y.tab.h"
%}

%%

0 | [1-9][0-9]* {return NUMBER;}

(-)? {return NUMBER;}

[a-zA-Z][a-zA-Z0-9_]* | [1-9][0-9]* {return ID;}

[a-zA-Z0-9_]+  {return FUNC_NAME;}

[a-zA-Z0-9_-]*   {return COMMAND;}

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

\n   {return NL;}

null  {return EPSILON;}

.*    {return TEXT;}

"break" {return BREAK;}

"continue" {return CONTINUE;}

"#BEGIN UX" {return BEGIN_UX;}

"#END UX" {return END_UX;}

"#BEGIN WN" {return BEGIN_WN;}

"#END WN" {return END_WN;}

"if" {return IF;}

"else" {return ELSE;}

"elif" {return ELIF; printf("saurabh");}

"func" {return FUNC;}

"in" {return IN;}

"for" {return FOR;}

"while" {return WHILE;} 

"file" {return READFILE;}

"dir" {return DIR;}

.|'\n'		{return yytext[0];}

%%
