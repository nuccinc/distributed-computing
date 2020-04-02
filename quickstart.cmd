@ECHO OFF&& SETLOCAL&& PUSHD "%~dp0"&& SETLOCAL ENABLEDELAYEDEXPANSION&& SETLOCAL ENABLEEXTENSIONS&& SET V=5&& IF NOT "!V!"=="5" (ECHO DelayedExpansion Failed&& GOTO :EOF)

REM ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REM ++
REM ++   SCRIPT VARIABLES
REM ++
REM ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SET "PROJECT_URL=http://boinc.bakerlab.org/rosetta/"
SET "WEAK_KEY=2108683_fdd846588bee255b50901b8b678d52ec"
REM %VOLUME% folder will be created by Docker.
SET "VOLUME=C:\Users\%USERNAME%\.boinc"
SET DOCKER=C:\PROGRA~1\Docker\Docker\"Docker Desktop.exe"
SET "BOINC_HOME=C:\PROGRA~1\BOINC"
SET "BOINC=C:\PROGRA~1\BOINC\boinc.exe"
SET "BOINC_MGR=C:\PROGRA~1\BOINC\boincmgr.exe"
SET "BOINC_CMD=C:\PROGRA~1\BOINC\boinccmd.exe"
SET "BOINC_DIR=C:\ProgramData\BOINC"
IF [%~1]==[--docker] SET "BOINC_CMD_LINE_OPTIONS=--allow_remote_gui_rpc --attach_project %PROJECT_URL% %WEAK_KEY%"
IF [%~1]==[--native] SET "BOINC_CMD_LINE_OPTIONS=--allow_remote_gui_rpc --detach_console --dir %BOINC_DIR% --attach_project %PROJECT_URL% %WEAK_KEY%"
SET "IMG_ALPINE=boinc/client:baseimage-alpine"
SET "IMG_UBUNTU=boinc/client:latest"
REM Select Default Docker image:
SET IMG=%IMG_ALPINE%

REM ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REM ++                                                            
REM ++   MAIN PROGRAM EXECUTION                                        
REM ++                                                            
REM ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

REM GET HELP!
IF [%1]==[] (CALL :USAGE && EXIT /B)
IF [%1]==[/?] (CALL :USAGE && EXIT /B)
IF [%1]==[/h] (CALL :USAGE && EXIT /B)
IF [%1]==[/help] (CALL :USAGE && EXIT /B)
IF [%1]==[help] (CALL :USAGE && EXIT /B)
IF [%1]==[-h] (CALL :USAGE && EXIT /B)
IF [%1]==[-help] (CALL :USAGE && EXIT /B)
IF [%1]==[--help] (CALL :USAGE && EXIT /B)

REM Set gui_rpc_auth.cfg
ECHO.
SET /P "BOINC_GUI_RPC_PASSWORD=Please enter a value for the BOINC_GUI_RPC_PASSWORD: "
ECHO This can be changed at any time by changing the value in gui_rpc_auth.cfg.

REM Main script arguments:
IF [%2]==[--image] (CALL :DOCKERINSTALL %~1 %~2 %~3 & EXIT /B)
IF [%1]==[--docker] (CALL :DOCKERINSTALL %~1 %~2 %~3 & EXIT /B)
IF [%1]==[--native] (CALL :NATIVEINSTALL %~1 %~2 %~3 & EXIT /B)

REM ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REM ++                                                            
REM ++   SCRIPT FUNCTIONS                                        
REM ++                                                            
REM ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

REM ========================================================================================================================================
REM =   USAGE - shows script usage info and returns to caller.
REM ========================================================================================================================================
:USAGE
ECHO.
ECHO USAGE: %~nx0 [--native ^<--attach^> ^| --docker ^<IMAGE NAME^> ^| --help]
ECHO.
ECHO --native  ^<--attach^>      installs BOINC natively without using Docker and attaches to project.
ECHO                           if --attach is specified, BOINC will natively attach to the NUCC project.
ECHO.
ECHO --docker  ^<IMAGE NAME^>    installs Docker Desktop.
ECHO                           if Docker is already installed, it will download the image and attach to the project.
ECHO                           if an optional image name is given as the 2nd argument, docker will use that image instead.
ECHO.
ECHO --help                    displays this text dialog.
ECHO.
EXIT /B

REM ========================================================================================================================================
REM =   NATIVEINSTALL - Installs Chocolatey, BOINC, and launches BOINC.
REM ========================================================================================================================================
:NATIVEINSTALL
IF EXIST %BOINC_MGR% GOTO :LAUNCHNATIVE

REM Install Chocolatey:
CALL :INSTALLCHOCOLATEY

REM Install BOINC:
ECHO.
ECHO Installing BOINC...
cinst /y boinc
IF ERRORLEVEL 1 (ECHO BOINC failed to install. Please run "%~nx0 --native" from a new elevated command prompt. & GOTO:EOF)

REM Configure BOINC:
CALL :CONFIGURE %~1 %~2 %~3 & EXIT /B
::IF ERRORLEVEL 1 (ECHO BOINC configuration failed. & GOTO:EOF)
EXIT /B

REM ========================================================================================================================================
REM =   CONFIGURE - Automatically attaches native BOINC client to NUCC project and start processing workloads.
REM ========================================================================================================================================
:CONFIGURE
IF [%~1]==[--docker] SET CONFIG_DIR=%VOLUME%
IF [%~1]==[--native] SET CONFIG_DIR=%BOINC_DIR%
::IF EXIST %CONFIG_DIR%\cc_config.xml CALL :DOCKERRUN %~1 %~2 %~3 & EXIT /B
ECHO.
ECHO Configuring BOINC...
RM %CONFIG_DIR%\gui_rpc_auth.cfg 2>NUL
RM %CONFIG_DIR%\cc_config.xml 2>NUL
RM %CONFIG_DIR%\remote_hosts.cfg 2>NUL
ECHO %BOINC_GUI_RPC_PASSWORD% > %CONFIG_DIR%\gui_rpc_auth.cfg
ECHO ^<cc_config^> > %CONFIG_DIR%\cc_config.xml
ECHO   ^<options^> >> %CONFIG_DIR%\cc_config.xml
ECHO       ^<allow_remote_gui_rpc^>1^</allow_remote_gui_rpc^> >> %CONFIG_DIR%\cc_config.xml
ECHO   ^</options^> >> %CONFIG_DIR%\cc_config.xml
ECHO ^</cc_config^> >> %CONFIG_DIR%\cc_config.xml
ECHO 127.0.0.1 > %CONFIG_DIR%\remote_hosts.cfg

IF [%~1]==[--docker] CALL :DOCKERINSTALL %~1 %~2 %~3 & EXIT /B
IF [%~1]==[--native] CALL :LAUNCHNATIVE %~1 %~2 %~3 & EXIT /B
EXIT /B

REM ========================================================================================================================================
REM =   LAUNCHNATIVE - Automatically attaches native BOINC client to NUCC project and start processing workloads.
REM ========================================================================================================================================
:LAUNCHNATIVE
REM Attach to project:
ECHO.
ECHO Attaching to Project...
%BOINC% %BOINC_CMD_LINE_OPTIONS%
IF ERRORLEVEL 1 (ECHO Failed to attach to project. Please run "boinccmd %ATTACH%" after BOINC is running. & GOTO :EOF)

SLEEP 5

REM Launch BOINC:
ECHO.
ECHO Launching BOINC Manager...
@START %BOINC_MGR% /n 127.0.0.1 /g 31416 /p %BOINC_GUI_RPC_PASSWORD% --boincargs="%BOINC_CMD_LINE_OPTIONS%"

ECHO.
ECHO Setting up scheduled task...
SCHTASKS /Create /TN "BOINC" /TR "%BOINC_MGR% /s /n 127.0.0.1 /g 31416 /p %BOINC_GUI_RPC_PASSWORD%" /SC onlogon /F
EXIT /B

REM ========================================================================================================================================
REM =   DOCKERINSTALL - Installs and Launches Docker Desktop.
REM =   Script will need to be run a second time with --docker to pull and run the Docker image.
REM ========================================================================================================================================
:DOCKERINSTALL
IF EXIST %VOLUME%\cc_config.xml CALL :DOCKERRUN  %~1 %~2 %~3 & EXIT /B
IF EXIST %DOCKER% CALL :DOCKERINSTALLED %~1 %~2 %~3 & EXIT /B

REM Install Chocolatey:
CALL :INSTALLCHOCOLATEY

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
ECHO When Docker has completely finished starting, run %~nx0 again with the --docker parameter.
PAUSE
@START %DOCKER%
EXIT /B

REM ========================================================================================================================================
REM =   INSTALLCHOCOLATEY - Installs the Chocolatey package manager for Windows.
REM ========================================================================================================================================
:INSTALLCHOCOLATEY
ECHO.
IF EXIST C:\ProgramData\chocolatey\choco.exe EXIT /B
ECHO Installing Chocolatey...
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
EXIT /B

REM ========================================================================================================================================
REM =   DOCKERINSTALLED - Downloads image specified with %IMG% and runs it in a Docker container
REM ========================================================================================================================================
:DOCKERINSTALLED
ECHO.
ECHO Making sure Docker Desktop is started...
@START %DOCKER%
ECHO Please wait until Docker Desktop has COMPLETELY finished starting before continuing.
PAUSE
ECHO.
SET /P "VOLUME_ENABLED=Have you enabled the C drive under the Docker Resources Filesharing Settings? [y/n] "
IF [%VOLUME_ENABLED%]==[n] ECHO Enable the C drive under Docker ^> Resources ^> Filesharing, and run ~%nx0 --docker again. & GOTO :EOF
ECHO.
ECHO When Docker maps the volume for the first time it will request access to the C drive, so please allow it.

REM Configure BOINC:
CALL :CONFIGURE %~1 %~2 %~3

REM Run Docker
CALL :DOCKERRUN %~1 %~2 %~3 & EXIT /B
EXIT /B

REM ========================================================================================================================================
REM =   DOCKERRUN - Downloads image specified with %IMG% and runs it in a Docker container
REM ========================================================================================================================================
:DOCKERRUN
IF [%~2]==[--image] SET IMG=%~3

REM Where the magic happens:
ECHO.
IF [%~2]==[--image] (docker stop boinc 2>NUL & docker rm boinc 2>NUL)
docker run -d --restart always --name boinc -p 31416:31416 -v "%VOLUME%:/var/lib/boinc" -e "BOINC_GUI_RPC_PASSWORD=%BOINC_GUI_RPC_PASSWORD%" -e "BOINC_CMD_LINE_OPTIONS=%BOINC_CMD_LINE_OPTIONS%" "%IMG%"

ECHO.
SET /P "ANS=Do you want to check the current status? [y/n] "
IF [%ANS%]==[y] (docker exec boinc boinccmd --get_state)

EXIT /B

 
