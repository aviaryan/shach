## Commands list

List of various commands we plan to support and how they look in Unix and Windows format.

### Statements

##### Variable declarations (all types)

```sh
myvar=$(expr 1 + 1)
myvar=2
```

```bat
set "location=bob"
set constant=10
```

----



### Functions

#### isfile()

```sh
if [-f "file"]
then <action>
fi
```

```bat
exist <file> <action>
```

-----

#### isdir()

```sh
if [-d "file"]
then <action>
fi
```

```bat
exist <directory> <action>
```

-----

#### exists()

```sh
if [-e "file"]
then <action>
fi
```

```bat
exist <directory> <action>
```

-----


#### listdir()

```sh
ls <direcotory>
```

```bat
dir <directory>
```

-----

#### scan()

```sh
read <var>
```

```bat
SET /P variable=[promptString]
```

-----

### print()

```sh
echo "string"$var"string"
```

```bat
echo string%var%string
```

-----

#### strlen()

```sh
${#<string>}
```

```bat
@echo off
set str = Hello World
call :strLen str strlen
echo String is %strlen% characters long
exit /b

:strLen
setlocal enabledelayedexpansion

:strLen_Loop
   if not "!%1:~%len%!"=="" set /A len+ = 1 & goto :strLen_Loop
(endlocal & set %2 = %len%)
goto :eof
```

-----


#### arrlen()

```sh
${#<array>[@]}
```

```bat
@echo off
set str = Hello World
call :strLen str strlen
echo String is %strlen% characters long
exit /b

:strLen
setlocal enabledelayedexpansion

:strLen_Loop
   if not "!%1:~%len%!"=="" set /A len+ = 1 & goto :strLen_Loop
(endlocal & set %2 = %len%)
goto :eof
```

-----



#### forLoop()

```sh
# {START..END..INCREMENT}
for i in {0..10..2}
  do 
     echo "Welcome $i times"
 done

```

```bat
rem (START, INCREMENT, END)
for /l %x in (1, 1, 100) do (
   echo %x
   copy %x.txt z:\whatever\etc
)
```

-----


#### forLine()

```sh
while read p; do
  echo $p
done <peptides.txt

```

```bat
for /F "tokens=*" %A in (myfile.txt) do [process] %%A

```

-----



#### forDir()

```sh
for D in /path/to/data; do
    # command 1
    if [ -d "$D" ]
    then
        # command 2
        for i in /path/to/data/$D/*.foo
        do
            # command 3
        done
    fi
done
```

```bat
CD \Work 
FOR /D /r %%G in ("User*") DO Echo We found %%~nxG
```

-----


#### whileLoop()

```sh
while [ $x -le 5 ]
do
  echo "Welcome $x times"
  x=$(( $x + 1 ))
done

```

```bat
@echo off
SET /A "index = 1"
SET /A "count = 5"
:while
if %index% leq %count% (
   echo The value of index is %index%
   SET /A "index = index + 1"
   goto :while
)
```

-----

#### Function with parameters()

```sh
print_something () {
echo Hello $1
}
print_something Mars
print_something Jupiter

```

```bat
:myDosFunc    - here starts my function identified by it's label
echo.
echo. here the myDosFunc function is executing a group of commands
echo. it could do %~1 of things %~2.
goto:eof

echo.going to execute myDosFunc with different arguments
call:myDosFunc 100 YeePEE
```

-----


#### Maths Expression

```sh
myvar=$(expr 1 + 1)
let myvar2=myvar+1
myvar=$((myvar+3))
myvar=$[myvar+2]
$((expression))
expr 3 '*' '(' 2 '+' 1 ')'
let a="3 * (2 + 1)"
```
```bat
@set /a "c=%a%+%b%"
@set /a "d=%c%+1"
set /a "Result = ( 24 << 1 ) & 23"
```

-----



#### strings

```sh
STR="Hello World" 
echo $STR 

foo="Hello"
foo="$foo World"
echo $foo

```

```bat
SET location = "bob"
ECHO We're working with "%location%"

@echo off
set myvar="the list: "
for /r %%i in (*.doc) DO call :concat %%i
echo %myvar%
goto :eof

:concat
set myvar=%myvar% %1;
goto :eof
```

-----
