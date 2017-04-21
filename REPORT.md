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
	* [Shach Semantics Phase](#intsem)
	* [Final Phase](#finalph)
* [Manual](#manual)
	* Variables
	* Expressions
	* Conditions
	* Loops
	* Functions
	* Blocks
	* Native commands
* [Sample Code](#ex)
* [Building](#build)
* [Problems Faced](#problems)
* [Future Scope](#future)
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

The grammar of Shach is:

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


<a name="intsem"></a>
### Intermediate Semantics Phase

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.

#### Test Cases

We used TravisCI to continuously test if our grammar was correctly recognizing the tokens or not. 
For that we used 2 types of tests, `test` and `anti-test`. As the name suggest, all `test` files should be 
correctly recognized by our grammar whereas `anti-test` should be discarded by our grammar.


<a name="finalph"></a>
### Final Phase

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.


<a name="manual"></a>
## Manual

Shach syntax is pretty much inspired from bash's expect that it is more human friendly and intuitive. 
This section will cover concepts about how to write code in Shach. 
The file extension for Shach files is `.shach`. 

### Variables

Variables in Shach are preceeded by a dollar `$`, everywhere.

```sh
$intVar = 2
$stringVar = "abcd"
$anotherVar = $stringVar
```

### Expressions

Expressions in Shach have been inspired from C and are very intuitive.

```sh
$intVar = 2 + (2 * 5)
$string = "abcd" ++ "another string"
$int = 4 - 2
$intVar = $intVar * (6 - $int)
$string = "abcd" ++ $string
```

**Note** - For string concat, we have `++` operator.

**Bool** - Like bash and batch, there is no bool type in Shach. If you are looking for a bool like behavior, feel free to use the `int` or `string` type.

### Conditions

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.

### Loops

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.

### Functions

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.

### Blocks

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.

### Native commands

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.


<a name="ex"></a>
## Sample Code

[[ Charu ]]

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat.


<a name="build"></a>
## Building/Compiling

On a Unix computer, run the following commands to build this project.

```sh
flex project.lex
yacc -d project.yacc
gcc lex.yy.c y.tab.c -ll -ly
```

One can also use the shortcut command which is 

```sh
make build
```

Once build is done, `a.out` file will be generated. Run it as follows -

```sh
./a.out < input_file.shach
```

The above command will take `input_file.shach` as the input source code and will create the output bash file called `output.sh` in the same directory.
To generate batch code, run the following.

```sh
./a.out batch < input_file.shach
# ./a.out bash < input_file.shach
```

The above command will generate batch code in `output.bat` file.

When `a.out` is run, it prints the list of found tokens in the terminal. This was added for debugging purposes and will be removed later with a stable release.


<a name="problems"></a>
## Problems Faced

Since it was our first experience designing a compiler, we encountered many challenges.
Intially, our code failed to parse the language, debugging that much big code proved to be a herculean task. Many a times it was hard to determine why the desired regex was not getting matched by the sample code. Later we manifested it by integration tests that passes for the pieces of code. We too have a bad time bridging the gap between bash and batch. There we have some functionalties which were only one way round supported by either bash or batch but not both. It took us long time to figure out the way to handle such cases and implement the cumbersome syntax for the output scripts. During semantics we ran into segmentation fault, bus errors and function declartion prob.. //todo: elaborate.


<a name="future"></a>
## Future Scope

The development of this language surely prompts many new areas of improvements. 
This project does not covers all functionalities related to bash and batch scripts. 
It would have great to implement that provided we’d enough time. 
Though it suceesfully meets the main objective which was to make a platform independent and easy to write progamming language.

For further improvements we would like to implement all the remaining functionalites. 

Also the current error handling only tell the user about error,does not suggest the user what needs to be done. 
We would like to implement auto suggesting feature in case of errors.

Further we would like to make a web service for this, which would let the user to compile and genrate the bash and the batch scripts online. 


<a name="team"></a>
## Team

[![Avi Aryan](https://avatars0.githubusercontent.com/u/4047597?v=3&s=130)](http://aviaryan.in) | [![Saurabh Jain](https://avatars3.githubusercontent.com/u/9781788?v=3&s=130)](https://github.com/saurabhjn76) | [![Charu Chhimpa](https://avatars3.githubusercontent.com/u/17537890?v=3&s=130)](https://github.com/CharuChhimpa) | [![Sagrika Rastogi](https://avatars3.githubusercontent.com/u/17158526?v=3&s=130)](https://github.com/Sagrika-Rastogi) | [![Harshit Purohit](https://avatars2.githubusercontent.com/u/10785498?v=3&s=130)](https://github.com/hrshtpurohit)
---|---|---|---|---
[Avi Aryan](http://aviaryan.in) | [Saurabh Jain](https://github.com/saurabhjn76) | [Charu Chhimpa](https://github.com/CharuChhimpa) | [Sagrika Rastogi](https://github.com/Sagrika-Rastogi) | [Harshit Purohit](https://github.com/hrshtpurohit)
