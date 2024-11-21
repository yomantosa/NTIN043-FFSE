@ECHO OFF
REM
REM Author: Rasmus Lauritsen, Joey Coleman
REM Created: 2013-03-20
REM 
REM Run the Overture commandline tool
REM

set BASE=%~dp0
set VERSION=3.0.2
set NAME=commandlinetool
set JAR=%BASE%\%NAME%-%VERSION%-jar-with-dependencies.jar

IF NOT EXIST %JAR% GOTO ERR_NOJAR

java -jar %JAR% %*
GOTO END

:ERR_NOJAR
echo Executable jar: %JAR% does not exist, please ensure it is in the same directory as this command.

:END
