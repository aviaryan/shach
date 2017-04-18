%{
        #include <stdio.h>
        #include <string.h>
        #define YYSTYPE char*
        extern char * yytext;
        extern int begin_wn, begin_ux;
%}

%token NUMBER ID FUNC_NAME COMMAND TRUE FALSE RETURN CALL SCAN PRINT ISFILE ISDIR EXISTS RAWBASH RAWBATCH BASH BATCH NL TEXT BREAK CONTINUE BEGIN_UX END_UX BEGIN_WN END_WN IF ELSE ELIF FUNC IN FOR WHILE READFILE DIR ARRLEN STRLEN LOADENV NEGATIVE_NUM STR POWER EOFL CONCAT GTEQ LTEQ NOTEQ EQCOND LOGAND LOGOR INVALID

%%

program : nlLoop statements EOFL { 
            printf("\nVALID_CODE");
            printf("<< %s >>", $2);
            return 0; 
        }
        ;

statements : functionDeclaration nlLoopPlus statements { sprintf($$, "%s\n%s", $1, $3); }
        | statement nlLoopPlus statements { sprintf($$, "%s\n%s", $1, $3); }
        | { $$ = ""; }
        ;

mainStatements : statement nlLoopPlus mainStatements { sprintf($$, "%s\n%s", $1, $3); }
        | { $$ = ""; }
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

conditionalStatement : IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  { 
            char * s = malloc(sizeof(char) * lstr2($3, $7));
            sprintf(s, "if (%s){\n%s}", $3, $7); $$ = s;
        }
        | IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}' ELSE '{' nlLoopPlus mainStatements '}'  { 
            char * s = malloc(sizeof(char) * lstr3($3, $7, $12));
            sprintf(s, "if (%s){\n%s} else {\n%s}", $3, $7, $12); $$ = s;
        }
        | IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  elif_st  ELSE '{' nlLoopPlus mainStatements '}'  { 
            char * s = malloc(sizeof(char) * lstr4($3, $7, $9, $13));
            sprintf(s, "if (%s){\n%s} %s else {\n%s}", $3, $7, $9, $13); $$ = s;
        }
        ;

commandStatement : COMMAND { $$ = $1; }
        ;

elif_st : ELIF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  { 
            char * s = malloc(sizeof(char) * lstr2($3, $7));
            sprintf(s, "elif (%s){\n%s}", $3, $7); $$ = s;
        }
        ;

conditionalFuncStatement : IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' { 
            char * s = malloc(sizeof(char) * lstr2($3, $7));
            sprintf(s, "if (%s){\n%s}", $3, $7); $$ = s;
        }
        | IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' ELSE '{' nlLoopPlus funcStatements '}' {
            char * s = malloc(sizeof(char) * lstr3($3, $7, $12)); 
            sprintf(s, "if (%s){\n%s} else {\n%s}", $3, $7, $12); $$ = s;
        }
        | IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}'  elif_func_st  ELSE '{' nlLoopPlus funcStatements '}' {
            char * s = malloc(sizeof(char) * lstr4($3, $7, $9, $13));
            sprintf(s, "if (%s){\n%s} %s else {\n%s}", $3, $7, $9, $13); $$ = s;
        }
        ;

elif_func_st : ELIF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' {
            char * s = malloc(sizeof(char) * lstr2($3, $7));
            sprintf(s, "elif (%s){\n%s}", $3, $7); $$ = s;
        }
        ;

conditionalLoopStatement : IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' { 
            char * s = malloc(sizeof(char) * lstr2($3, $7));
            sprintf(s, "if (%s){\n%s}", $3, $7); $$ = s;
        }
        | IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' ELSE '{' nlLoopPlus loopStatements '}' {
            char * s = malloc(sizeof(char) * lstr3($3, $7, $12)); 
            sprintf(s, "if (%s){\n%s} else {\n%s}", $3, $7, $12); $$ = s;
        }
        | IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}'  elif_loop_st  ELSE '{' nlLoopPlus loopStatements '}' {
            char * s = malloc(sizeof(char) * lstr4($3, $7, $9, $13));
            sprintf(s, "if (%s){\n%s} %s else {\n%s}", $3, $7, $9, $13); $$ = s;
        }
        ;

elif_loop_st : ELIF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' {
            char * s = malloc(sizeof(char) * lstr2($3, $7));
            sprintf(s, "elif (%s){\n%s}", $3, $7); $$ = s;
        }
        ;

loopStatement : forLoop { $$ = $1; }
        | whileLoop { $$ = $1; }
        | forLine { $$ = $1; }
        | forDir { $$ = $1; }
        ;

nlLoopPlus : NL nlLoop { printf("nllll"); }
        ;

nlLoop : NL nlLoop { printf("why"); }
        |
        ;

loopStatements : statement nlLoopPlus loopStatements { sprintf($$, "%s\n%s", $1, $3); }
        | conditionalLoopStatement nlLoopPlus loopStatements { sprintf($$, "%s\n%s", $1, $3); }
        | BREAK nlLoopPlus { sprintf($$, "break\n"); }
        | CONTINUE nlLoopPlus { sprintf($$, "continue\n"); }
        | { $$ = ""; }
        ;

whileLoop : WHILE '(' conditionList ')' '{' nlLoopPlus loopStatements '}'
        ;

forLoop : FOR var IN '(' NUMBER ',' NUMBER ',' NUMBER  ')' '{' nlLoopPlus loopStatements '}'
        ;

forLine : FOR var IN READFILE '(' strVal ')' '{' nlLoopPlus loopStatements '}'  {
            int len = strlen($2) + strlen($6) + strlen($10) + 20;
            char * s = malloc(sizeof(char) * len);
            sprintf(s, "for %s in file(%s){\n%s}", $2, $6, $10); $$ = s;
        }
        ;

forDir : FOR var IN DIR '(' strVal ')' '{' nlLoopPlus loopStatements '}'  { 
            int len = strlen($2) + strlen($6) + strlen($10) + 20;
            char * s = malloc(sizeof(char) * len);
            sprintf(s, "for %s in dir(%s){\n%s}", $2, $6, $10); $$ = s;
        }
       ;

commentStatement : "#" TEXT
        ;

funcStatements : statement nlLoopPlus funcStatements 
        | conditionalFuncStatement nlLoopPlus funcStatements
        | retStatement nlLoopPlus
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

expr :  id1 '+' expr  { sprintf($$, "%s+%s", $1, $3); }
        | id1 '-' expr  { sprintf($$, "%s-%s", $1, $3); }
        | id1 { $$ = $1; }
        ;

id1 : id2 '*' id1  { sprintf($$, "%s*%s", $1, $3); }
        | id2 { $$ = $1; }
        ;

id2 : id2 '/' id3  { sprintf($$, "%s/%s", $1, $3); }
        | id3 { $$ = $1; }
        ;

id3 : id3 POWER id4  { sprintf($$, "%s^%s", $1, $3); }
        | id4 { $$ = $1; }
        ;

id4 : '(' expr ')'  { sprintf($$, "(%s)", $2); }
        | numVal { $$ = $1; }
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
        | condition { $$ = $1; }
        ;

condition : expr '<' expr 
        | expr '>' expr 
        | expr LTEQ expr { 
            char * s = malloc(sizeof(char) * lstr2($1, $3));
            sprintf(s, "%s <= %s", $1, $3); $$ = s;
        }
        | expr GTEQ expr { 
            char * s = malloc(sizeof(char) * lstr2($1, $3));
            sprintf(s, "%s >= %s", $1, $3); $$ = s;
        }
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

var :    ID { printf("Ass"); $$ = $1; }
        ;

allVar : var { $$ = $1; }
        | var '[' positiveNum ']'
        ;

string : STR { $$ = $1; }
        ;

num :  positiveNum  { $$ = $1; }
        | negativeNum { $$ = $1; }
        ;

positiveNum : NUMBER { $$ = $1; }
        ;

negativeNum : NEGATIVE_NUM  { $$ = $1; }
        ;

numVal : allVar { $$ = $1; }
        | num { $$ = $1; }
        ;

strVal : allVar { $$ = $1; }
        | string { $$ = $1; printf("Strings"); }
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

allExpr : expr { $$ = $1; }
        | stringExpr
        | boolExpr
        | arrayExpr 
        | functionCall
        ;

%%

int lstr2(char * s1, char * s2){
    return strlen(s1) + strlen(s2) + 20;
}

int lstr3(char * s1, char * s2, char * s3){
    return lstr2(s1, s2) + strlen(s3);
}

int lstr4(char * s1, char * s2, char * s3, char * s4){
    return lstr3(s1, s2, s3) + strlen(s4);
}

int main(){
	yyparse();
	return 0;
}

int yyerror(char *s){
	printf("UNRECOGNIZED_CODE\n");
	return 0;
}
