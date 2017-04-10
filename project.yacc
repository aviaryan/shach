%{
        #include <stdio.h>
        extern char * yytext;
        extern int begin_wn, begin_ux;
%}

%token NUMBER ID FUNC_NAME COMMAND TRUE FALSE RETURN CALL SCAN PRINT ISFILE ISDIR EXISTS RAWBASH RAWBATCH BASH BATCH NL TEXT BREAK CONTINUE BEGIN_UX END_UX BEGIN_WN END_WN IF ELSE ELIF FUNC IN FOR WHILE READFILE DIR ARRLEN STRLEN LOADENV NEGATIVE_NUM STR EOFL

%%

program : statements EOFL {printf("\nVALID_CODE"); return 0;}
        ;

statements : functionDeclaration statements 
        | statement NL statements
        | NL statements
        | statement
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

loopStatement : forLoop 
        | whileLoop 
        | forLine 
        | forDir
	|
        ;

loopStatements : mainStatements 
        | BREAK 
        | CONTINUE
        ;

whileLoop : WHILE '(' conditionList ')' '{' loopStatements '}'
        ;

forLoop : FOR '(' variableAssignment ';' conditionList ';' expr ')' '{' loopStatements '}'
        ;

forLine : FOR var IN READFILE '(' strVal ')' '{' loopStatements '}'
        ;

forDir : FOR var IN DIR '(' strVal ')' '{' loopStatements '}'
	| FOR var IN DIR '(' strVal ')' '{' NL loopStatements '}'
        ;

commentStatement : "#" TEXT
        ;

funcStatements : mainStatements retStatement NL funcStatements 
        |
        ;

functionDeclaration : FUNC ' ' FUNC_NAME '(' idList ')' '{' funcStatements '}' NL
        ;

retStatement : RETURN allVar 
        | RETURN
        ;

functionCall : FUNC_NAME '(' paramList ')' 
        | inbuiltFunc '(' paramList ')'
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
        | numVal "--" 
        | numVal "++" 
        | id1
        ;

id1 : id2 '*' id1 
        | id2
        ;

id2 : id2 '/' id3 
        | id3
        ;

id3 : id3 "**" id4 
        | id4
        ;

id4 : '(' expr ')' 
        | numVal
        ;

stringExpr : strVal 
        | strVal "++" string1
        ;

boolExpr : boolExpr1 
        | boolVal "&&" boolExpr 
        | boolVal "||" boolExpr
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

string1 : string1 '+' strVal 
        | strVal
        ;

conditionList : condition "&&" conditionList 
        | condition "||" conditionList 
        | condition
        ;

condition : expr '<' expr 
        | expr '>' expr 
        | expr "<=" expr 
        | expr ">=" expr 
        | expr "<>" expr 
        | expr "==" expr 
        | stringExpr "==" stringExpr 
        | stringExpr "<>" stringExpr 
        | boolExpr 
        | functionCall
        ;

paramList : allExpr ',' paramList 
        |
        ;

idList : allVar ',' idList 
        | allVar
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
	printf("Invalid string\n");
	return 0;
}
