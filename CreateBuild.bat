REM Script created by csoe (WastedStudios) inspired by the book "Mastering CryENGINE" by Sasha Gundlach and Michelle K. Martin

@echo off
setlocal ENABLEEXTENSIONS
cls
echo.
echo Creating a new full project build
echo ------------------------------------
echo New build started at: %date% %time%


REM Path settings
REM Path where build scripts are stored
set BuildBotPath=D:\CryEngineBuild\BuildScripts
REM Build is processed in that folder (temporary, will be deleted afterwards)
set BuildWorkPath=D:\CryEngineBuild\BuildArchive\Build_InProgress
REM Source folder (files will be fetched from here)
set BuildSourcePath=D:\CryEngineBuild\SVN\yourprojectname
REM Finished build path
set BuildTargetPath=D:\CryEngineBuild\BuildArchive\yourprojectname_%date:~-0,4%_%date:~5,2%_%date:~8,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
set BuildProjectCFG=D:\CryEngineBuild\SVN\yourprojectname\project.cfg
set RCExecutablePath=Tools\rc\rc.exe
set RCTempPath="%BuildWorkPath%\Temp\rc"

REM Program settings
set RCToolPath=D:\Program Files\Crytek\CRYENGINE_5.1\Tools\rc\rc.exe
set BeyondComparePath=C:\Program Files\Beyond Compare 4\BComp.com
set WinRarPath=C:\Program Files\WinRAR\Winrar.exe

REM Setup variables
if not exist "%BuildProjectCFG%" (
    1>&2 echo "Error: %BuildProjectCFG% not found!"
	pause
    exit /b 1
)

for /F "tokens=*" %%I in (%BuildProjectCFG%) do set %%I

if not defined engine_version (
	1>&2 echo "Error: no engine_version entry found in %BuildProjectCFG%!"
	pause
    exit /b 1
)

for /F "usebackq tokens=2,* skip=2" %%L in (
	`reg query "HKEY_CURRENT_USER\Software\Crytek\CryEngine" /v %engine_version%`	
) do set "engine_root=%%M"

if not defined engine_root (
	for /F "usebackq tokens=2,* skip=2" %%L in (
		`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Crytek\CryEngine" /v %engine_version%`
	) do set "engine_root=%%M"
)

REM Get latest from the Version Control (Subversion - TortoiseSVN)
echo.
echo Retrieving the latest from the version control
TortoiseProc.exe /command:update /path:"%BuildSourcePath%" /closeonend:1
echo Done.

REM Clear out/Create working path for the build and copy the relevant data
if exist "%BuildWorkPath%" (
echo.
echo Clearing out temporary Work Folder
echo %BuildWorkPath%
rmdir /S /Q "%BuildWorkPath%"
)
echo.
echo Copy build relevant data
echo to %BuildWorkPath%
mkdir "%BuildWorkPath%"
cd %BuildBotPath%
"%BeyondComparePath%" /closescript "@CopyBuildScript.txt" 
xcopy /s "%engine_root%\engine" "%BuildWorkPath%\Engine\"
echo Done.

mkdir "%BuildWorkPath%\Logfiles"

echo.
echo Removing temporary files from Code Build
cd %BuildWorkPath%\bin\win_x86
del *.lib
del *.pdb
del *.exp
del CryAction.map
cd %BuildWorkPath%\bin\win_x64
del *.lib
del *.pdb
del *.exp
del CryAction.map
cd %BuildWorkPath%
echo Done.

REM Asset Compilation
echo.
echo Processing Asset-Compilation
if defined engine_root (
	if not exist "%engine_root%\%RCExecutablePath%" (
		1>&2 echo "Error: %engine_root%\%RCExecutablePath% not found!"
		pause
		exit /b 1
	)
	
	"%engine_root%\%RCExecutablePath%" /threads=processors /p=PC /job="%BuildBotPath%\rcjob_all.xml" /src="%cd%" /trg="%RCTempPath%" /pak_root="%cd%\Temp" /game="Assets" /verbose=0 /TargetHasEditor=1 > ".\Logfiles\AssetCompilationLog_Complete.txt"
) else (
    1>&2 echo "Error: Engine version %engine_version% not found!"
	pause
    exit /b 1
)
echo Done.

cd %BuildWorkPath%\Assets

REM Move Compiled Assets
echo.
echo Moving compiled assets to right directory
del game.cfg
for /f "delims=" %%d in ('dir /ad /b') do @rd /q /s "%%d"
xcopy /E "%BuildWorkPath%\Temp\Assets" "%BuildWorkPath%\Assets\"
echo Done.

echo.
echo Cleaning up directories
cd %BuildWorkPath%
rmdir /S /Q Temp
rmdir /S /Q Logfiles
echo Done.

REM Move build to target folder
echo.
echo -- Rename Build folder --
cd %BuildWorkPath%
cd..
move "%BuildWorkPath%" "%BuildTargetPath%"
echo Done.



echo.
echo Build Finished: %date% %time%
echo ====================
echo Build Done.
echo.