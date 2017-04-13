%{
        #include <stdio.h>
        extern char * yytext;
        extern int begin_wn, begin_ux;
%}

%token NUMBER ID FUNC_NAME COMMAND TRUE FALSE RETURN CALL SCAN PRINT ISFILE ISDIR EXISTS RAWBASH RAWBATCH BASH BATCH NL TEXT BREAK CONTINUE BEGIN_UX END_UX BEGIN_WN END_WN IF ELSE ELIF FUNC IN FOR WHILE READFILE DIR ARRLEN STRLEN LOADENV NEGATIVE_NUM STR POWER EOFL CONCAT GTEQ LTEQ NOTEQ EQCOND LOGAND LOGOR INVALID

%%

program : statements EOFL {printf("\nVALID_CODE"); return 0;}
        ;

statements : functionDeclaration statements 
        | statement NL statements
        |
        ;

mainStatements : statement NL mainStatements 
        |
        ;

statement : variableAssignment 
        | conditionalStatement 
        | functionCall 
        | loopStatement 
        | uxBlockStatement 
        | winBlockStatement 
        | commandStatement 
        | commentStatement
	| rawBlockStatement
        |
        ;

variableAssignment : allVar '=' allExpr
        ;

conditionalStatement : IF '(' conditionList ')' '{' mainStatements '}'
        | IF '(' conditionList ')' '{' mainStatements '}' ELSE '{' mainStatements '}' 
        | IF '(' conditionList ')' '{' mainStatements '}'  elif_st  ELSE '{' mainStatements '}'
        ;

commandStatement : COMMAND
        ;
	
elif_st : ELIF '(' conditionList ')' '{' mainStatements '}'
        ;

conditionalFuncStatement : IF '(' conditionList ')' '{' funcStatements '}'
        | IF '(' conditionList ')' '{' funcStatements '}' ELSE '{' funcStatements '}' 
        | IF '(' conditionList ')' '{' funcStatements '}'  elif_func_st  ELSE '{' funcStatements '}'
        ;

elif_func_st : ELIF '(' conditionList ')' '{' funcStatements '}'
        ;

conditionalLoopStatement : IF '(' conditionList ')' '{' loopStatements '}'
        | IF '(' conditionList ')' '{' loopStatements '}' ELSE '{' loopStatements '}' 
        | IF '(' conditionList ')' '{' loopStatements '}'  elif_loop_st  ELSE '{' loopStatements '}'
        ;

elif_loop_st : ELIF '(' conditionList ')' '{' loopStatements '}'
        ;

loopStatement : forLoop 
        | whileLoop 
        | forLine 
        | forDir
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
	
rawBlockStatement : BEGIN_RAWUX stringExpr END_RAWUX
	| BEGIN_RAWWN stringExpr END_RAWWN
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
        | strVal CONCAT string1
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

string1 : strVal 
        | strVal CONCAT string1
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

paramList : paramList ',' paramList 
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

var :    ID
        ;

allVar : var 
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
