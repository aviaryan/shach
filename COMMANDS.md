## Commands list

List of various commands we plan to support and how they look in Unix and Windows format.

### Statements

##### Variable declarations (all types)

```sh
```

```bat
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

```{START..END..INCREMENT}
for i in {0..10..2}
  do 
     echo "Welcome $i times"
 done

```

```(START, INCREMENT, END)
for /l %x in (1, 1, 100) do (
   echo %x
   copy %x.txt z:\whatever\etc
)
```

-----


#### forLine()

```for value in $1/*.html
do
cp $value $1/$( basename -s .html $value ).php
done

```

```
```

-----



#### forDir()

```for i in {0..10..2}
  do 
     echo "Welcome $i times"
 done

```

```
```

-----


#### whileLoop()

```while [ $x -le 5 ]
do
  echo "Welcome $x times"
  x=$(( $x + 1 ))
done

```

```@echo off
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

```print_something () {
echo Hello $1
}
print_something Mars
print_something Jupiter

```

```:myDosFunc    - here starts my function identified by it's label
echo.
echo. here the myDosFunc function is executing a group of commands
echo. it could do %~1 of things %~2.
goto:eof

echo.going to execute myDosFunc with different arguments
call:myDosFunc 100 YeePEE
```

-----
