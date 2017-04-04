//Yacc File 

//After Declaration

program : statements  EOF

statements : functionDeclaration statements 
        | statement NL statements
        | EPSILON
        ;

mainStatements : statement NL mainStatements 
        | EPSILON
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

variableAssignment : allVar = allExpr
        ;

conditionalStatement : IF '(' conditionList ')' '{' mainStatements '}' 
        | IF '(' conditionList ')' '{' mainStatements '}' else '{' mainStatements '}' 
        | IF '(' conditionList ) '{' mainStatements '}'  elif_st  ELSE '{' mainStatements '}'
        ;

commandStatement : '~' COMMAND commandHelper
        ;

commandHelper : TEXT 
        | TEXT '{' var '}' commandHelper
        ;

elif_st : ELIF '(' conditionList ')' '{' mainStatements '}'
        ;

loopStatement : forLoop 
        | whileLoop 
        | forLine 
        | forDir
        ;

loopStatements : mainStatements 
        | BREAK 
        | CONTINUE
        ;

whileLoop : WHILE '(' conditionList ')' '{' loopStatements '}'
        ;

forLoop : FOR '(' variableAssignment ';' conditionList ';' expr ')' '{' loopStatements '}'
        ;

forLine : FOR var IN FILE '(' strVal ')' '{' loopStatements '}'
        ;

forDir : FOR var IN DIR '(' strVal ')' '{' loopStatements '}'
        ;

commentStatement : '#' TEXT NL
        ;

funcStatements : mainStatements retStatement NL funcStatements 
        | EPSILON
        ;

functionDeclaration : FUNC FUNC_NAME '(' idList ')' '{' funcStatements '}' NL
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
        | numVal '--' 
        | numVal '++' 
        | id1
        ;

id1 : id2 '*' id1 
        | id2
        ;

id2 : id2 '/' id3 
        | id3
        ;

id3 : id3 '**' id4 
        | id4
        ;

id4 : '(' expr ')' 
        | numVal
        ;

stringExpr : strVal 
        | strVal '++' string1
        ;

boolExpr : boolExpr1 
        | boolVal '&&' boolExpr 
        | boolVal '||' boolExpr
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

conditionList : condition '&&' conditionList 
        | condition '||' conditionList 
        | condition
        ;

condition : expr '<' expr 
        | expr '>' expr 
        | expr '<=' expr 
        | expr '>=' expr 
        | expr '<>' expr 
        | expr '==' expr 
        | stringExpr '==' stringExpr 
        | stringExpr '<>' stringExpr 
        | boolExpr 
        | functionCall
        ;

36. paramList -> allExpr , paramList | EPSILON

37. idList -> allVar , idList | allVar

38. varList -> allVals , varList | allVals

39. var -> $ ID

40. allVar -> var | var [ positiveNum ]

41. string -> “TEXT”

42. num ->NEGATIVE_NUM positiveNum

43. positiveNum -> NUMBER

44. numVal -> allVar | num

45. strVal -> allVar | string

46. boolVal -> allVar | bool

47. vals -> num | string | bool | functionCall

48. allVals - > vals | allVar

49. allExpr -> expr | stringExpr | boolExpr | arrayExpr | functionCall
