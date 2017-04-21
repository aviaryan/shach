%{
        #include <stdio.h>
        #include <string.h>
        #include <stdbool.h>
        #define YYSTYPE char*
        extern char * yytext;
        bool compileBash = true;
        FILE *fp;
        int dataType = 1; // 0 for int, 1 for string
%}

%token NUMBER ID FUNC_NAME COMMAND RETURN CALL SCAN PRINT ISFILE ISDIR EXISTS RAWBASH RAWBATCH BASH BATCH NL TEXT BREAK CONTINUE BEGIN_UX END_UX BEGIN_WN END_WN IF ELSE ELIF FUNC IN FOR WHILE READFILE DIR ARRLEN STRLEN LOADENV NEGATIVE_NUM STR POWER EOFL CONCAT GTEQ LTEQ NOTEQ EQCOND LOGAND LOGOR INVALID RAW_UX RAW_WN
%%

program : nlLoop statements EOFL { 
            printf("\nVALID_CODE");
            if (fp == NULL){
                fprintf(stderr, "Can't open output file\n");
                return 1; 
            } else {
                fprintf(fp,"%s", $2);
                fclose(fp);
                return 0; 
            }
        }
        ;

statements : functionDeclaration nlLoopPlus statements { sprintf($$, "%s\n%s", $1, $3); }
        | statement nlLoopPlus statements { 
            char * s = malloc(lstr2($1, $3));
            sprintf(s, "%s\n%s", $1, $3); $$ = s;
        }
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
        | rawStatementBlock { $$ = $1; }
        ;

variableAssignment : allVar '=' allExpr {
            char * s = malloc(lstr2($1, $3));
            if (compileBash){
                sprintf(s, "%s=%s", &$1[1], $3); $$ = s;
            } else {
                sprintf(s, "set \\a %s=%s", $1, $3); $$ = s;
            }
        }
        ;

conditionalStatement : IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  { 
            char * s = malloc(lstr2($3, $7));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%sfi", $3, $7); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s)", $3, $7); $$ = s;
            }
        }
        | IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}' ELSE '{' nlLoopPlus mainStatements '}'  { 
            char * s = malloc(lstr3($3, $7, $12));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%selse\n%sfi", $3, $7, $12); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s) else (\n%s)", $3, $7, $12); $$ = s;
            }
        }
        | IF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  elif_st  ELSE '{' nlLoopPlus mainStatements '}'  { 
            char * s = malloc(lstr4($3, $7, $9, $13));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%s %s else \n%sfi", $3, $7, $9, $13); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s) %s else (\n%s)\n)", $3, $7, $9, $13); $$ = s;
                // TODO: variable in conditions have %..%
            }
        }
        ;

commandStatement : COMMAND {
            char * temp = &$1[1]; parseVarString(temp);
            $$ = temp;
        }
        ;

elif_st : ELIF '(' conditionList ')' '{' nlLoopPlus mainStatements '}'  { 
            char * s = malloc(lstr2($3, $7));
            if (compileBash){ // http://stackoverflow.com/questions/16034749/
                sprintf(s, "elif (( %s ))\nthen\n%s", $3, $7); $$ = s;
            } else { // http://stackoverflow.com/questions/25384358/
                // multi-elif not handled yet
                sprintf(s, "else (\n if %s (\n%s)", $3, $7); $$ = s;
            }
        }
        ;

conditionalFuncStatement : IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' { 
            char * s = malloc(lstr2($3, $7));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%sfi", $3, $7); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s)", $3, $7); $$ = s;
            }
        }
        | IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' ELSE '{' nlLoopPlus funcStatements '}' {
            char * s = malloc(lstr3($3, $7, $12));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%selse\n%sfi", $3, $7, $12); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s) else (\n%s)", $3, $7, $12); $$ = s;
            }
        }
        | IF '(' conditionList ')' '{' nlLoopPlus funcStatements '}'  elif_func_st  ELSE '{' nlLoopPlus funcStatements '}' {
            char * s = malloc(lstr4($3, $7, $9, $13));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%s %s else \n%sfi", $3, $7, $9, $13); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s) %s else (\n%s)\n)", $3, $7, $9, $13); $$ = s;
            }
        }
        ;

elif_func_st : ELIF '(' conditionList ')' '{' nlLoopPlus funcStatements '}' {
            char * s = malloc(lstr2($3, $7));
            if (compileBash){ // http://stackoverflow.com/questions/16034749/
                sprintf(s, "elif (( %s ))\nthen\n%s", $3, $7); $$ = s;
            } else { // http://stackoverflow.com/questions/25384358/
                // multi-elif not handled yet
                sprintf(s, "else (\n if %s (\n%s)", $3, $7); $$ = s;
            }
        }
        ;

conditionalLoopStatement : IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' { 
            char * s = malloc(lstr2($3, $7));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%sfi", $3, $7); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s)", $3, $7); $$ = s;
            }
        }
        | IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' ELSE '{' nlLoopPlus loopStatements '}' {
            char * s = malloc(lstr3($3, $7, $12));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%selse\n%sfi", $3, $7, $12); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s) else (\n%s)", $3, $7, $12); $$ = s;
            }
        }
        | IF '(' conditionList ')' '{' nlLoopPlus loopStatements '}'  elif_loop_st  ELSE '{' nlLoopPlus loopStatements '}' {
            char * s = malloc(lstr4($3, $7, $9, $13));
            if (compileBash){
                sprintf(s, "if (( %s ))\nthen\n%s %s else \n%sfi", $3, $7, $9, $13); $$ = s;
            } else {
                sprintf(s, "if %s (\n%s) %s else (\n%s)\n)", $3, $7, $9, $13); $$ = s;
            }
        }
        ;

elif_loop_st : ELIF '(' conditionList ')' '{' nlLoopPlus loopStatements '}' {
            char * s = malloc(lstr2($3, $7));
            if (compileBash){ // http://stackoverflow.com/questions/16034749/
                sprintf(s, "elif (( %s ))\nthen\n%s", $3, $7); $$ = s;
            } else { // http://stackoverflow.com/questions/25384358/
                // multi-elif not handled yet
                sprintf(s, "else (\n if %s (\n%s)", $3, $7); $$ = s;
            }
        }
        ;

loopStatement : forLoop { $$ = $1; }
        | whileLoop { $$ = $1; }
        | forLine { $$ = $1; }
        | forDir { $$ = $1; }
        ;

nlLoopPlus : NL nlLoop
        ;

nlLoop : NL nlLoop
        |
        ;

loopStatements : statement nlLoopPlus loopStatements { sprintf($$, "%s\n%s", $1, $3); }
        | conditionalLoopStatement nlLoopPlus loopStatements { sprintf($$, "%s\n%s", $1, $3); }
        | BREAK nlLoopPlus { sprintf($$, "break\n"); }
        | CONTINUE nlLoopPlus { sprintf($$, "continue\n"); }
        | { $$ = ""; }
        ;

whileLoop : WHILE '(' conditionList ')' '{' nlLoopPlus loopStatements '}'  {
            char * s = malloc(lstr2($3, $7));
            if (compileBash){
                sprintf(s, "while [%s]\ndo\n%s\ndone", $3, $7); $$ = s;
            } else {
                sprintf(s, ":while\n if %s (\n%s\ngoto :while\n)", $3, $7); $$ = s;
            }
        }
        ;

forLoop : FOR var IN '(' NUMBER ',' NUMBER ',' NUMBER  ')' '{' nlLoopPlus loopStatements '}'  {
            char * s = malloc(lstr5($2, $5, $7, $9, $13));
            if (compileBash){
                sprintf(s, "for %s in {%s..%s..%s}\ndo\n%s\ndone", &$2[1], $5, $9, $7, $13); $$ = s;
            } else {
                sprintf(s, "for /l %%%s in (%s,%s,%s) do(\n%s\n)", $2, $5, $7, $9, $13); $$ = s;
            }
        }
        ;

forLine : FOR var IN READFILE '(' strVal ')' '{' nlLoopPlus loopStatements '}'  {
            char * s = malloc(lstr3($2, $6, $10));
            if (compileBash){
                sprintf(s, "while read %s;do\n%s\ndone <%s", &$2[1], $10, $6); $$ = s;
            } else {
                sprintf(s, "for /F 'tokens=*' %%%s in (%s)do(\n%s\n)",$2, $6, $10); $$ = s;
            }
        }
        ;

forDir : FOR var IN DIR '(' strVal ')' '{' nlLoopPlus loopStatements '}'  { 
            char * s = malloc(lstr3($2, $6, $10));
            if (compileBash){
                sprintf(s, "for %s in %s;do\n%s\ndone", &$2[1], $6, $10); $$ = s;
            } else {
                sprintf(s, "for /d /r %%%s in ('%s')do(\n%s\n)", $2, $6, $10); $$ = s;
            }
        }
       ;

commentStatement : "#" TEXT
        ;

funcStatements : statement nlLoopPlus funcStatements { sprintf($$, "%s\n%s", $1, $3); }
        | conditionalFuncStatement nlLoopPlus funcStatements { sprintf($$, "%s\n%s", $1, $3); }
        | retStatement nlLoopPlus { sprintf($$, "%s\n", $1); }
        | { $$ = ""; }
        ;

functionDeclaration : FUNC FUNC_NAME '(' universalIdList ')' '{' nlLoopPlus funcStatements '}' {
            char * s = malloc(lstr3($2, $4, $8));
            sprintf(s, "func %s(%s){\n%s}", $2, $4, $8); $$ = s;
        }
        ;

retStatement : RETURN '(' allVals ')' {
            char * s = malloc(lstr1($3));
            sprintf(s, "return(%s)", $3); $$ = s;
        }
        | RETURN { $$ = $1; }
        ;

functionCall : inbuiltFunc '(' paramList ')'
        | PRINT '(' paramList ')' {
            deQuoteString(&$3); parseVarString($3);
            char * s = malloc(lstr1($3));
            sprintf(s, "echo %s", $3); $$ = s;
        }
        | SCAN '(' paramList ')' {
            char * s = malloc(lstr1($3));
            if (compileBash){
                sprintf(s, "read %s", &$3[1]); $$ = s;
            } else {
                sprintf(s, "set /p %s=\"\"", $3); $$ = s;
            }
        }
        | RAWBASH '(' paramList ')' {
            if (compileBash){
                deQuoteString(&$3); $$ = $3;
            } else {
                $$ = "";
            }
        }
        | RAWBATCH '(' paramList ')' {
            if (!compileBash){
                deQuoteString(&$3); $$ = $3;
            } else {
                $$ = "";
            }
        }
        | BASH '(' paramList ')' {
            if (compileBash){
                deQuoteString(&$3); parseVarString($3); $$ = $3;
            } else {
                $$ = "";
            }
        }
        | BATCH '(' paramList ')' {
            if (!compileBash){
                deQuoteString(&$3); parseVarString($3); $$ = $3;
            } else {
                $$ = "";
            }
        }
        | FUNC_NAME '(' paramList ')'
        | FUNC_NAME '(' ')'
        ;

inbuiltFunc : CALL 
        | ISFILE 
        | ISDIR 
        | EXISTS 
        | LOADENV 
        | STRLEN 
        | ARRLEN 
        ;

uxBlockStatement : BEGIN_UX nlLoopPlus statements END_UX {
        if (compileBash){
            $$ = $3;
        } else {
            $$ = "";
        }
    }
    ;

winBlockStatement : BEGIN_WN nlLoopPlus statements END_WN {
        if (!compileBash){
            $$ = $3;
        } else {
            $$ = "";
        }
    }
    ;

rawStatementBlock : RAW_UX {
        trimBlock(&$1);
        if (compileBash){
            $$ = $1;
        } else {
            $$ = "";
        }
    }
    | RAW_WN {
        trimBlock(&$1);
        if (!compileBash){
            $$ = $1;
        } else {
            $$ = "";
        }
    }
    ;

expr : id1 '+' expr  {
        char * s = malloc(lstr2($1, $3));
        if (compileBash){
            sprintf(s, "$[%s+%s]", $1, $3); $$ = s;
        } else {
            sprintf(s, "%s+%s", $1, $3); $$ = s;
        }
    }
    | id1 '-' expr  { 
        char * s = malloc(lstr2($1, $3));
        if (compileBash){
            sprintf(s, "$[%s-%s]", $1, $3); $$ = s;
        } else {
            sprintf(s, "%s-%s", $1, $3); $$ = s;
        }
    }
    | id1 { $$ = $1; }
    ;

id1 : id2 '*' id1  {
        char * s = malloc(lstr2($1, $3));
        if (compileBash){
            sprintf(s, "$[%s*%s]", $1, $3); $$ = s;
        } else {
            sprintf(s, "%s*%s", $1, $3); $$ = s;
        }
    }
    | id2 { $$ = $1; }
    ;

id2 : id2 '/' id3  {
        char * s = malloc(lstr2($1, $3));
        if (compileBash){
            sprintf(s, "$[%s/%s]", $1, $3); $$ = s;
        } else {
            sprintf(s, "%s/%s", $1, $3); $$ = s;
        }
    }
    | id3 { $$ = $1; }
    ;

id3 : '(' expr ')'  { 
        char * s = malloc(lstr1($2));
        sprintf(s, "(%s)", $2); $$ = s;
    }
    | numVal { $$ = $1; }
    ;

stringExpr : strVal 
        | strVal CONCAT stringExpr
        ;

arrayExpr : '{' varList '}' {
        char * s = malloc(lstr1($2));
        if (compileBash){
            sprintf(s, "(%s)", $2); $$ = s;
        } else {
            sprintf(s, "%s", $2); $$ = s;
        }
        }
        | '[' ']'
        ;

conditionList : condition LOGAND conditionList 
        | condition LOGOR conditionList 
        | condition { $$ = $1; }
        ;

condition : expr '<' expr
        | expr '>' expr {
            char * s = malloc(lstr2($1, $3));
            sprintf(s, "%s > %s", $1, $3); $$ = s;
        }
        | expr LTEQ expr { 
            char * s = malloc(lstr2($1, $3));
            sprintf(s, "%s <= %s", $1, $3); $$ = s;
        }
        | expr GTEQ expr { 
            char * s = malloc(lstr2($1, $3));
            sprintf(s, "%s >= %s", $1, $3); $$ = s;
        }
        | expr NOTEQ expr 
        | expr EQCOND expr 
        | stringExpr EQCOND stringExpr 
        | stringExpr NOTEQ stringExpr 
        | functionCall
        ;

paramList : allExpr ',' paramList  {
            char * s = malloc(lstr2($1, $3));
            sprintf(s, "%s,%s", $1, $3); $$ = s;
        }
        | allExpr { $$ = $1; }
        ;

idList : var ',' idList {
            char * s = malloc(lstr2($1, $3));
            sprintf(s, "%s,%s", $1, $3); $$ = s;
        }
        | var { $$ = $1; }
        ;

universalIdList: idList { $$ = $1; }
        | { $$ = ""; }
        ;

varList : allVals ',' varList 
        | allVals
        ;

var :    ID { 
            if (!compileBash){  
                // why? because batch has different types of var syntax
                // %var% %var and so on, so let's adjust that later on
                $$ = &$1[1];
            } else {
                $$ = $1; 
            }
        }
        ;

allVar : var { $$ = $1; }
        | var '[' positiveNum ']'
        ;

string : STR { $$ = $1; dataType=1; }
        ;

num :  positiveNum  { $$ = $1; dataType=0; }
        | negativeNum { $$ = $1; dataType=0; }
        ;

positiveNum : NUMBER { $$ = $1; }
        ;

negativeNum : NEGATIVE_NUM  { $$ = $1; }
        ;

numVal : allVar { $$ = $1; }
        | num { $$ = $1; }
        ;

strVal : allVar { $$ = $1; }
        | string { $$ = $1; }
        ;
    
vals : num { $$ = $1; }
        | string { $$ = $1; }
        | functionCall { $$ = $1; }
        ;

allVals : vals { $$ = $1; }
        | allVar { $$ = $1; }
        ;

allExpr : expr { $$ = $1; }
        | stringExpr { $$ = $1; }
        | arrayExpr { $$ = $1; }
        | functionCall { $$ = $1; }
        ;

%%

int lstr1(char * s1){
    return sizeof(char) * (strlen(s1) + 20);
}

int lstr2(char * s1, char * s2){
    return sizeof(char) * (strlen(s1) + strlen(s2) + 20);
}

int lstr3(char * s1, char * s2, char * s3){
    return sizeof(char) * (strlen(s1) + strlen(s2) + strlen(s3) + 40);
}

int lstr4(char * s1, char * s2, char * s3, char * s4){
    return sizeof(char) * (strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + 50);
}

int lstr5(char * s1, char * s2, char * s3, char * s4, char * s5){
    return sizeof(char) * (strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5) + 50);
}

int trimBlock(char ** str){
    char * s = *str;
    int i, sp, ep, len = strlen(s);
    for (i=0; i<len; i++)
        if (s[i] == '\n') break;
    sp = i+1;
    for (i=len-1; i>=0; i--)
        if (s[i] == '\n') break;
    ep = i-1;
    s[ep+1] = '\0'; *str = &s[sp];
    return 0;
}

int parseVarString(char * s){
    int len = strlen(s);
    int i, j=0;
    // loop
    if (!compileBash){ // batch
        for (i=0; i<len; i++){
            if (s[i] == '{'){
                j--;
                s[j] = '%';
            } else if (s[i] == '}'){
                s[j] = '%';
            } else {
                s[j] = s[i];
            }
            j++;
        }
        s[j] = '\0';
    }
    return 0;
}

int deQuoteString(char ** str){
    char * s = *str; int len = strlen(s);
    s[len-1] = '\0'; *str = &s[1];
    return 0;
}

/*
 * MAIN
 */
int main(int argc, char *argv[]){
    if (argc == 2){
        if (strcmp(argv[1],"batch") == 0){
            compileBash = false;
            fp = fopen("output.bat", "w");
        } else if (strcmp(argv[1],"bash") == 0){
            compileBash = true;
            fp = fopen("output.sh", "w");
        } else {
           printf("<< Invalid type specified. Assuming bash >>\n");
           fp = fopen("output.sh", "w");
        }
   } else {
        printf("<< No type specified. Assuming bash >>\n");
        fp = fopen("output.sh", "w");
    }
    yyparse();
    return 0;
}

int yyerror(char *s){
    printf("UNRECOGNIZED_CODE\n");
    return 0;
}
