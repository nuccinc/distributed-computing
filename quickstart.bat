@ECHO OFF&& SETLOCAL&& PUSHD "%~dp0"&& SETLOCAL ENABLEDELAYEDEXPANSION&& SETLOCAL ENABLEEXTENSIONS&& SET V=5&& IF NOT "!V!"=="5" (ECHO DelayedExpansion Failed&& GOTO :EOF)

REM %VOLUME% folder will be created by Docker.
SET "VOLUME=C:\Users\%USERNAME%\.boinc"
SET DOCKER=C:\PROGRA~1\Docker\Docker\"Docker Desktop.exe"
SET "BOINC_CMD_LINE_OPTIONS=--allow_remote_gui_rpc --attach_project http://boinc.bakerlab.org/rosetta/ 2108683_fdd846588bee255b50901b8b678d52ec"

SET "IMG_ALPINE=boinc/client:baseimage-alpine"
SET "IMG_UBUNTU=boinc/client:latest"

REM Select Docker image:
SET IMG=%IMG_ALPINE%

IF [%1]==[--docker-installed] GOTO :DOCKERINSTALLED

IF EXIST %DOCKER% GOTO :DOCKERINSTALLED

REM Install Chocolatey:
ECHO.
ECHO Installing Chocolatey...
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

REM Install Docker:
ECHO.
ECHO Installing Docker...
cinst /y docker-desktop
IF ERRORLEVEL 1 (ECHO Docker failed to install. Please run cinst /y docker-desktop from a new elevated command prompt. & GOTO:EOF)

REM Check for Docker:
IF NOT EXIST %DOCKER% (ECHO Can't find Docker. Please launch Docker manually. & GOTO: EOF)

REM Launch Docker:
ECHO.
ECHO You will need to log out and log back in after launching Docker for the first time.
ECHO After you log back in and Docker starts, go to Docker Settings ^> Resources ^> Filesharing, and check enable the C drive.
ECHO Click "Apply & Restart", and then make sure Docker has COMPLETELY finished starting.
ECHO.
ECHO When Docker has completely finished starting, run this same script with the --docker-installed parameter.
SET /P Continue=Hit [Enter] to continue...
@START %DOCKER%
GOTO :EOF

:DOCKERINSTALLED
ECHO.
SET /P "VOLUME_ENABLED=Have you enabled the C drive under the Docker Resources Filesharing Settings? [y/n] "
IF [%VOLUME_ENABLED%]==[n] ECHO Enable the C drive under Docker ^> Resources ^> Filesharing & GOTO :EOF
ECHO.
ECHO When Docker maps the volume for the first time it will request access to the C drive, so please allow it.
ECHO.
SET /P "BOINC_GUI_RPC_PASSWORD=Please enter a value for the BOINC_GUI_RPC_PASSWORD: "
ECHO This can be changed at any time by changing the value in gui_rpc_auth.cfg.
ECHO.

REM Where the magic happens:
docker run -d --restart always --name boinc -p 31416:31416 -v "%VOLUME%:/var/lib/boinc" -e "BOINC_GUI_RPC_PASSWORD=%BOINC_GUI_RPC_PASSWORD%" -e "BOINC_CMD_LINE_OPTIONS=%BOINC_CMD_LINE_OPTIONS%" "%IMG%"

ECHO.
SET /P "ANS=Do you want to check the current status? [y/n] "
IF [%ANS%]==[y] (docker exec boinc boinccmd --get_state)

EXIT /B

 
