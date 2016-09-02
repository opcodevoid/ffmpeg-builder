@ECHO OFF

:: Opens Visual Studio x86 Native Command Prompt.

:: Get Visual Studio version.
for /F "skip=2" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\SxS\VS7" /s') do (
	set VS_VERSION=%%a
)

:: Get Visual Studio install path.
for /F "tokens=1,2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\SxS\VS7" /v "%VS_VERSION%"') do (	
	set VS_DIR=%%c
)

TITLE VS-%VS_VERSION% x86 Native Tools

cd "%VS_DIR%VC\"
%comspec% /k vcvarsall.bat x86