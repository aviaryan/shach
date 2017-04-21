# Shach Final Report

![Builds Passing](https://img.shields.io/badge/builds-passing-brightgreen.svg)
![Open Source](https://img.shields.io/badge/open-source-blue.svg)

Shach is a simple programming language that can compile to both Bash and Windows Batch.
The user will write the shach script (`.shach`) only once and compile it in any platform to generate
a `.sh` or a `.bat` file or both.


## Table of Contents

* [Motivation](#mvn)
* [Project Development](#dev)
	* [Lex Phase](#lexph)
	* Shach Semantics Phase
	* Final Phase
* Manual
	* Variables
	* Functions
	* Blocks
	* Native commands
* Sample Code
* Building
* Problems Faced
* Future Scope
* [Team](#team)


<a name="mvn"></a>
## Motivation

Both bash and batch are tedious to write. You have to spend a lot of time to 
learn either of them and writing a platform-dependent code for the respective 
Operating System. If the user happens to be a maintainer of a cross-platform 
tool which relies on Bash on Linux/Mac and Batch on Windows as "glue code", 
simultaneously writing code for both of them can be really painful.

Shach comes to your rescue here. Shach is quite easy to write, no complex syntaxes,
different inbuilt functions provided for making the tasks easier and above all you
don’t have to worry about writing different codes for different platforms. 
Cross-compiling is supported so that you can create bash & batch scripts from any
platform, whether it be OSX, Linux or Windows.


<a name="dev"></a>
## Project Development

In the Lex Phase, the team agreed upon what keywords we were going to use for Shach 
and also developed a parser for the statements of the language and formulated the 
grammar. we also formulated test cases in this phase.

In the Intermediate Semantics Phase we developed the symantics of shach and tested 
them rigourously against unit test cases.

In the Final phase, we tested against the the complete Shach programs we had generated
in the lex phase. Also, we incorporated the code to generate .sh and .bat files upon 
compilation.


<a name="lexph"></a>
### Lex Phase

Shach is a case sensitive language. Its keywords are:

```
#BEGIN, #END, UX, WN, RAWUX, RAWWN, return, call, rawbash, rawbatch, bash, batch, 
loadenv, break, continue, if, else, elif, func, in, for, xxx, while 		
```

The tokens of the Shach grammar are:

```
NUMBER, ID, FUNC_NAME, COMMAND, RETURN, CALL, SCAN, PRINT, ISFILE, ISDIR, EXISTS, RAWBASH, 		
RAWBATCH, BASH, BATCH, NL, TEXT, BREAK, CONTINUE, BEGIN_UX, END_UX, BEGIN_WN, END_WN, IF, 
ELSE, ELIF, FUNC, IN, FOR, WHILE, READFILE, DIR, ARRLEN, STRLEN, LOADENV, NEGATIVE_NUM, 
STR, POWER, EOFL, CONCAT, GTEQ, LTEQ, NOTEQ, EQCOND, LOGAND, LOGOR, INVALID, RAW_UX, RAW_WN
```

#### Shach grammar

```yacc
program : nlLoop statements EOFL 

statements : functionDeclaration nlLoopPlus statements
        | statement nlLoopPlus statements 
        | null

mainStatements : statement nlLoopPlus mainStatements 
        | null
        
statement : variableAssignment  
        | conditionalStatement  
        | functionCall  
        | loopStatement  
        | uxBlockStatement  
        | winBlockStatement  
        | commandStatement  
        | commentStatement  
        | rawStatementBlock  
        
variableAssignment : allVar '=' allExpr 

conditionalStatement : IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  
        | IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}' ELSE '{' nlLoopPlus mainStatements '}'  
        | IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  elif_st  ELSE '{' nlLoopPlus mainStatement '}'        
commandStatement : COMMAND 

elif_st : ELIF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  

conditionalFuncStatement : IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' 
        | IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' ELSE '{' nlLoopPlus funcStatements '}' 
        | IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}'  elif_func_st  ELSE '{' nlLoopPlus funcStatements '}' 

elif_func_st : ELIF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' 

conditionalLoopStatement : IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' 
        | IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' ELSE '{' nlLoopPlus loopStatements '}' 
        | IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}'  elif_loop_st  ELSE '{' nlLoopPlus loopStatements '}' 

elif_loop_st : ELIF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' 

loopStatement : forLoop  
        | whileLoop  
        | forLine  
        | forDir  

nlLoopPlus : NL nlLoop

nlLoop : NL nlLoop
        | null

loopStatements : statement nlLoopPlus loopStatements 
        | conditionalLoopStatement nlLoopPlus loopStatements 
        | BREAK nlLoopPlus 
        | CONTINUE nlLoopPlus 
        | null

whileLoop : WHILE '(' conditionList ')' '{' nlLoopPlus loopStatements '}'  

forLoop : FOR var IN '(' NUMBER ',' NUMBER ',' NUMBER  ')' '{' nlLoopPlus loopStatements '}'  

forLine : FOR var IN READFILE '(' strVal ')' '{' nlLoopPlus loopStatements '}'  

forDir : FOR var IN DIR '(' strVal ')' '{' nlLoopPlus loopStatements '}'  

commentStatement : "#" TEXT

funcStatements : statement nlLoopPlus funcStatements 
        | conditionalFuncStatement nlLoopPlus funcStatements 
        | retStatement nlLoopPlus 
        | null
        
functionDeclaration : FUNC FUNC_NAME '(' universalIdList ')' '{' nlLoopPlus funcStatements '}' 

retStatement : RETURN '(' allVals ')' 
        | RETURN  
        
functionCall : inbuiltFunc '(' paramList ')'
        | PRINT '(' paramList ')' 
        | SCAN '(' paramList ')' 
        | RAWBASH '(' paramList ')' 
        | RAWBATCH '(' paramList ')' 
        | BASH '(' paramList ')'
        | BATCH '(' paramList ')' 
        | FUNC_NAME '(' paramList ')'
        | FUNC_NAME '(' ')'

inbuiltFunc : CALL 
        | ISFILE 
        | ISDIR 
        | EXISTS 
        | LOADENV 
        | STRLEN 
        | ARRLEN 
        
uxBlockStatement : BEGIN_UX nlLoopPlus statements END_UX 

winBlockStatement : BEGIN_WN nlLoopPlus statements END_WN 

rawStatementBlock : RAW_UX 
        | RAW_WN 

expr : id1 '+' expr  
        | id1 '-' expr  
        | id1  

id1 : id2 '*' id1  
        | id2  

id2 : id2 '/' id3  
        | id3  

id3 : '(' expr ')'  
        | numVal  
    

stringExpr : strVal 
        | strVal CONCAT stringExpr

arrayExpr : '{' varList '}' 
        | '[' ']'
        
conditionList : condition LOGAND conditionList 
        | condition LOGOR conditionList 
        | condition  
        
condition : expr '<' expr
        | expr '>' expr 
        | expr LTEQ expr 
        | expr GTEQ expr 
        | expr NOTEQ expr 
        | expr EQCOND expr 
        | stringExpr EQCOND stringExpr 
        | stringExpr NOTEQ stringExpr 
        | functionCall

paramList : allExpr ',' paramList  
        | allExpr  
        
idList : var ',' idList
        | var  

universalIdList: idList  
        | null

varList : allVals ',' varList 
        | allVals
        
var :    ID 

allVar : var  
        | var '[' positiveNum ']'
        
string : STR { $$ = $1; dataType=1; }
        
num :  positiveNum  { $$ = $1; dataType=0; }
        | negativeNum { $$ = $1; dataType=0; }
        
positiveNum : NUMBER  
        
negativeNum : NEGATIVE_NUM   
        
numVal : allVar  
        | num  
        
strVal : allVar  
        | string  
        
vals : num  
        | string  
        | functionCall  

allVals : vals  
        | allVar  

allExpr : expr  
        | stringExpr  
        | arrayExpr  
        | functionCall  
```

#### Test Cases

We generated a Travis along with all the test codes in Shach
any changes made to any file will be incorporated only after being verified 
by Travis CI.


### Intermediate Semantics Phase

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.


### Final Phase

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.


## Manual

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.


.....
.....
.....


<a name="team"></a>
## Team

[![Avi Aryan](https://avatars0.githubusercontent.com/u/4047597?v=3&s=130)](http://aviaryan.in) | [![Saurabh Jain](https://avatars3.githubusercontent.com/u/9781788?v=3&s=130)](https://github.com/saurabhjn76) | [![Charu Chhimpa](https://avatars3.githubusercontent.com/u/17537890?v=3&s=130)](https://github.com/CharuChhimpa) | [![Sagrika Rastogi](https://avatars3.githubusercontent.com/u/17158526?v=3&s=130)](https://github.com/Sagrika-Rastogi) | [![Harshit Purohit](https://avatars2.githubusercontent.com/u/10785498?v=3&s=130)](https://github.com/hrshtpurohit)
---|---|---|---|---
[Avi Aryan](http://aviaryan.in) | [Saurabh Jain](https://github.com/saurabhjn76) | [Charu Chhimpa](https://github.com/CharuChhimpa) | [Sagrika Rastogi](https://github.com/Sagrika-Rastogi) | [Harshit Purohit](https://github.com/hrshtpurohit)
