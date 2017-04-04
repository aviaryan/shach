//Yacc File 

//After Declaration

program : statements  EOF

statements : functionDeclaration statements 
        | statement NL statements
        | EPSILON

mainStatements : statement NL mainStatements 
        | EPSILON

statement : variableAssignment 
        | conditionalStatement 
        | functionCall 
        | loopStatement 
        | uxBlockStatement 
        | winBlockStatement 
        | commandStatement 
        | commentStatement

variableAssignment : allVar = allExpr

conditionalStatement -> IF ( conditionList ) { mainStatements } | IF ( conditionList ) { mainStatements } else { mainStatements } | IF ( conditionList ) { mainStatements }  elif_st  ELSE { mainStatements }

7. commandStatement -> ~ COMMAND commandHelper

8. commandHelper -> TEXT | TEXT {var} commandHelper

9. elif_st -> ELIF ( conditionList) { mainStatements } | ELIF ( conditionList ) { mainStatements }

10. loopStatement -> forLoop | whileLoop | forLine | forDir

11. loopStatements -> mainStatements | BREAK | CONTINUE

12. whileLoop -> WHILE ( conditionList ) { loopStatements }

13. forLoop -> FOR ( variableAssignment ; conditionList ; expr ) { loopStatements }

14. forLine -> FOR var IN FILE( strVal ) { loopStatements }

15. forDir -> FOR var IN DIR( strVal ) { loopStatements }

16. commentStatement -> # TEXT NL

17. funcStatements -> mainStatements retStatement NL funcStatements | EPSILON

18. functionDeclaration -> FUNC FUNC_NAME (idList) { funcStatements } NL

19. retStatement -> RETURN allVar | RETURN

20. functionCall -> FUNC_NAME (paramList) | inbuiltFunc (paramList)

21. inbuiltFunc -> CALL | PRINT | SCAN | ISFILE | ISDIR | EXISTS | RAWBASH | RAWBATCH | BASH | BATCH | LOADENV | STRLEN | ARRLEN 

22. uxBlockStatement -> BEGIN_UX statements END_UX

23. winBlockStatement -> BEGIN_WN statements END_WN

24. expr ->  id1+expr | id1 - expr | numVal -- | numVal ++ | id1

25. id1 -> id2 * id1 | id2

26. id2 -> id2 / id3 | id3

27. id3 -> id3 ** id4 | id4

28. id4 -> ( expr ) | numVal

29. stringExpr -> strVal | strVal ++ string1

30. boolExpr -> boolExpr1 | boolVal && boolExpr | boolVal || boolExpr
boolExpr1 -> ( boolExpr ) | boolVal

31. bool -> TRUE|FALSE

32. arrayExpr -> {varList} | [ ]

33. string1->string1+strVal | strVal

34. conditionList -> condition && conditionList | condition || conditionList | condition

35. condition -> expr < expr | expr > expr | expr <= expr | expr >= expr || expr <> expr | expr == expr | stringExpr == stringExpr | stringExpr <> stringExpr | boolExpr | functionCall

paramList : allExpr ',' paramList 
        | EPSILON

idList : allVar ',' idList 
        | allVar
        ;

varList : allVals ',' varList 
        | allVals
        ;

var : '$' ID
        ;

allVar : var 
        | var '[' positiveNum ']'
        ;

string : '“'TEXT'”'
        ;

num : NEGATIVE_NUM positiveNum
        ;

positiveNum : NUMBER
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
        | boolE
        | arrayExpr 
        | functionCall
        ;
