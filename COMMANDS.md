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
