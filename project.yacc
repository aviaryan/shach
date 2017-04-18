%{
        #include <stdio.h>
        #define YYSTYPE char*
        extern char * yytext;
        extern int begin_wn, begin_ux;
%}

%token NUMBER ID FUNC_NAME COMMAND TRUE FALSE RETURN CALL SCAN PRINT ISFILE ISDIR EXISTS RAWBASH RAWBATCH BASH BATCH NL TEXT BREAK CONTINUE BEGIN_UX END_UX BEGIN_WN END_WN IF ELSE ELIF FUNC IN FOR WHILE READFILE DIR ARRLEN STRLEN LOADENV NEGATIVE_NUM STR POWER EOFL CONCAT GTEQ LTEQ NOTEQ EQCOND LOGAND LOGOR INVALID

%%

program : nlLoop statements EOFL { 
            printf("\nVALID_CODE");
            printf("<< %s >>", $1);
            return 0; 
        }
        ;

statements : functionDeclaration NL statements { sprintf($$, "%s\n%s", $1, $3); }
        | statement nlLoopPlus statements { sprintf($$, "%s\n%s", $1, $3); }
        | { $$=""; }
        ;

mainStatements : statement NL mainStatements { sprintf($$, "%s\n%s", $1, $3); }
        | { $$=""; }
        ;

statement : variableAssignment { $$ = $1; }
        | conditionalStatement { $$ = $1; }
        | functionCall { $$ = $1; }
        | loopStatement { $$ = $1; }
        | uxBlockStatement { $$ = $1; }
        | winBlockStatement { $$ = $1; }
        | commandStatement { $$ = $1; }
        | commentStatement { $$ = $1; }
        ;

variableAssignment : allVar '=' allExpr { sprintf($$, "%s = %s", $1, $3); }
        ;

conditionalStatement : IF '(' conditionList ')' '{' mainStatements '}'   { sprintf($$, "if (%s){\n%s}", $3, $6); }
        | IF '(' conditionList ')' '{' mainStatements '}' ELSE '{' mainStatements '}'   { sprintf($$, "if (%s){\n%s} else {\n%s}", $3, $6, $10); }
        | IF '(' conditionList ')' '{' mainStatements '}'  elif_st  ELSE '{' mainStatements '}'   { sprintf($$, "if (%s){\n%s} %s else {\n%s}", $3, $6, $8, $11); }
        ;

commandStatement : COMMAND { $$ = $1; }
        ;

elif_st : ELIF '(' conditionList ')' '{' mainStatements '}'  { sprintf($$, "elif (%s){\n%s}", $3, $6); }
        ;

conditionalFuncStatement : IF '(' conditionList ')' '{' funcStatements '}'   { sprintf($$, "if (%s){\n%s}", $3, $6); }
        | IF '(' conditionList ')' '{' funcStatements '}' ELSE '{' funcStatements '}'   { sprintf($$, "if (%s){\n%s} else {\n%s}", $3, $6, $10); }
        | IF '(' conditionList ')' '{' funcStatements '}'  elif_func_st  ELSE '{' funcStatements '}'   { sprintf($$, "if (%s){\n%s} %s else {\n%s}", $3, $6, $8, $11); }
        ;

elif_func_st : ELIF '(' conditionList ')' '{' funcStatements '}'  { sprintf($$, "elif (%s){\n%s}", $3, $6); }
        ;

conditionalLoopStatement : IF '(' conditionList ')' '{' loopStatements '}'   { sprintf($$, "if (%s){\n%s}", $3, $6); }
        | IF '(' conditionList ')' '{' loopStatements '}' ELSE '{' loopStatements '}'   { sprintf($$, "if (%s){\n%s} else {\n%s}", $3, $6, $10); }
        | IF '(' conditionList ')' '{' loopStatements '}'  elif_loop_st  ELSE '{' loopStatements '}'   { sprintf($$, "if (%s){\n%s} %s else {\n%s}", $3, $6, $8, $11); }
        ;

elif_loop_st : ELIF '(' conditionList ')' '{' loopStatements '}'
        ;

loopStatement : forLoop 
        | whileLoop 
        | forLine 
        | forDir
        ;

nlLoopPlus : NL nlLoop
        ;

nlLoop : NL nlLoop
        |
        ;

loopStatements : statement NL loopStatements 
        | conditionalLoopStatement NL loopStatements
        | BREAK nlLoop
        | CONTINUE nlLoop
        |
        ;

whileLoop : WHILE '(' conditionList ')' '{' loopStatements '}'
        ;

forLoop : FOR var IN '(' NUMBER ',' NUMBER ',' NUMBER  ')' '{' loopStatements '}'
        ;

forLine : FOR var IN READFILE '(' strVal ')' '{' loopStatements '}'
        ;

forDir : FOR var IN DIR '(' strVal ')' '{' loopStatements '}'
       ;

commentStatement : "#" TEXT
        ;

funcStatements : statement NL funcStatements 
        | conditionalFuncStatement NL funcStatements
        | retStatement nlLoop
        |
        ;

functionDeclaration : FUNC FUNC_NAME '(' universalIdList ')' '{' funcStatements '}'
        ;

retStatement : RETURN '(' allVals ')'
        | RETURN
        ;

functionCall : FUNC_NAME '(' paramList ')' 
        | inbuiltFunc '(' paramList ')'
        | FUNC_NAME '(' ')'
        | inbuiltFunc '(' ')'
        ;

inbuiltFunc : CALL 
        | PRINT 
        | SCAN 
        | ISFILE 
        | ISDIR 
        | EXISTS 
        | RAWBASH 
        | RAWBATCH 
        | BASH 
        | BATCH 
        | LOADENV 
        | STRLEN 
        | ARRLEN 
        ;

uxBlockStatement : BEGIN_UX statements END_UX
        ;

winBlockStatement : BEGIN_WN statements END_WN
        ;

expr :  id1 '+' expr 
        | id1 '-' expr 
        | id1
        ;

id1 : id2 '*' id1 
        | id2
        ;

id2 : id2 '/' id3 
        | id3
        ;

id3 : id3 POWER id4 
        | id4
        ;

id4 : '(' expr ')' 
        | numVal
        ;

stringExpr : strVal 
        | strVal CONCAT stringExpr
        ;

boolExpr : boolExpr1 
        | boolExpr1 LOGAND boolExpr 
        | boolExpr1 LOGOR boolExpr
        ;

boolExpr1 : '(' boolExpr ')' 
        | boolVal
        ;

bool : TRUE
        | FALSE
        ;

arrayExpr : '{' varList '}' 
        | '[' ']'
        ;

conditionList : condition LOGAND conditionList 
        | condition LOGOR conditionList 
        | condition
        ;

condition : expr '<' expr 
        | expr '>' expr 
        | expr LTEQ expr 
        | expr GTEQ expr 
        | expr NOTEQ expr 
        | expr EQCOND expr 
        | stringExpr EQCOND stringExpr 
        | stringExpr NOTEQ stringExpr 
        | boolExpr 
        | functionCall
        ;

paramList : allExpr ',' paramList 
        | allExpr
        ;

idList : allVals ',' idList 
        | allVals
        ;

universalIdList: idList
        |
        ;

varList : allVals ',' varList 
        | allVals
        ;

var :    ID { $$=$1; }
        ;

allVar : var { $$=$1; }
        | var '[' positiveNum ']'
        ;

string : STR
        ;

num :  positiveNum
        | negativeNum
        ;

positiveNum : NUMBER
        ;

negativeNum : NEGATIVE_NUM  
        ;

numVal : allVar 
        | num
        ;

strVal : allVar 
        | string
        ;

boolVal : allVar 
        | bool
        ;

vals : num 
        | string 
        | bool 
        | functionCall
        ;

allVals : vals 
        | allVar
        ;

allExpr : expr
        | stringExpr
        | boolExpr
        | arrayExpr 
        | functionCall
        ;

%%

int main(){
	yyparse();
	return 0;
}

int yyerror(char *s){
	printf("UNRECOGNIZED_CODE\n");
	return 0;
}
