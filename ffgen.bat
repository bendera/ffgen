@echo OFF

set EXT=%~x1
set BASENAME=%~n1
set FULLPATH=%~f1
set CSSNAME=stylesheet.css
set WORKDIR=%~d1%~p1
set FFGENDIR=%~dp0

rem echo EXT: %EXT%
rem echo BASENAME: %BASENAME%
rem echo FULLPATH: %FULLPATH%
rem echo WORKDIR: %WORKDIR%

rem goto End

if "%1" == "" (
	echo Usage: %0 ^<filename^> [fontname]
	goto End
)

if not exist %1 (
	echo %1: file not found
	goto End
)

if "%2" == "" (
	set FONTNAME=%BASENAME%
) else (
	set FONTNAME=%2
)

set DIRNAME=%FONTNAME%

if exist %WORKDIR%%DIRNAME% (
	rmdir /S /Q %WORKDIR%%DIRNAME%
)

mkdir %WORKDIR%%DIRNAME%

rem ############################################################################
rem svg, ttf, woff file generation with FontForge:
rem ############################################################################

set FF=%~dp0bin\FontForge_2012-07-31
set PATH=%FF%\bin;%FF%\bin\Xming-6.9.0.31;%PATH%

set DISPLAY=:9.0
set XLOCALEDIR=%FF%\bin\Xming-6.9.0.31\locale
set AUTOTRACE=potrace
set HOME=%FF%

start /B "" "%FF%\bin\Xming-6.9.0.31\Xming.exe" :9 -multiwindow -clipboard -silent-dup-error -notrayicon

"%FF%\bin\Xming_close.exe" -wait

if %EXT% == .ttf (
	echo [ffgen] Generate "%FONTNAME%.svg"
	"%FF%\bin\fontforge.exe" -script %FFGENDIR%bin\convert.pe %FULLPATH% %WORKDIR%%DIRNAME% %FONTNAME%.svg %FONTNAME%.woff
	echo [ffgen] Copy "%FULLPATH%" to "%WORKDIR%%DIRNAME%\%FONTNAME%.ttf"
	copy %FULLPATH% %WORKDIR%%DIRNAME%\%FONTNAME%.ttf
) else (
	echo [ffgen] Generate "%FONTNAME%.svg %FONTNAME%.ttf"
	"%FF%\bin\fontforge.exe" -script %FFGENDIR%bin\convert.pe %FULLPATH% %WORKDIR%%DIRNAME% %FONTNAME%.svg %FONTNAME%.ttf %FONTNAME%.woff
)

"%FF%\bin\Xming_close.exe" -close

rem ############################################################################
rem eot font file generation
rem ############################################################################

echo [ffgen] Generate "%FONTNAME%.eot"
%FFGENDIR%bin\ttf2eot.exe %FULLPATH% > %WORKDIR%%DIRNAME%\%FONTNAME%.eot

rem ############################################################################
rem css, html file generation
rem ############################################################################

echo [ffgen] Generate "stylesheet.css"

set /p ORIGINAL_FONTNAME=<%WORKDIR%%DIRNAME%\originalfontname.txt
del %WORKDIR%%DIRNAME%\originalfontname.txt

echo ^@font-face ^{ > %WORKDIR%%DIRNAME%\%CSSNAME%
echo     font-family: '%FONTNAME%'; >> %WORKDIR%%DIRNAME%\%CSSNAME%
echo     src: url('%FONTNAME%.eot'); >> %WORKDIR%%DIRNAME%\%CSSNAME%
echo     src: url('%FONTNAME%.eot?#iefix') format('embedded-opentype'), >> %WORKDIR%%DIRNAME%\%CSSNAME%
echo          url('%FONTNAME%.woff') format('woff'), >> %WORKDIR%%DIRNAME%\%CSSNAME%
echo          url('%FONTNAME%.ttf') format('truetype'), >> %WORKDIR%%DIRNAME%\%CSSNAME%
echo          url('%FONTNAME%.svg#%ORIGINAL_FONTNAME%') format('svg'); >> %WORKDIR%%DIRNAME%\%CSSNAME%
echo     font-weight: normal; >> %WORKDIR%%DIRNAME%\%CSSNAME%
echo     font-style: normal; >> %WORKDIR%%DIRNAME%\%CSSNAME%
echo ^} >> %WORKDIR%%DIRNAME%\%CSSNAME%

echo [ffgen] Generate "preview.html"

echo ^<!DOCTYPE html^> > %WORKDIR%%DIRNAME%\preview.html
echo ^<html^> >> %WORKDIR%%DIRNAME%\preview.html
echo ^<head^> >> %WORKDIR%%DIRNAME%\preview.html
echo ^<link rel="stylesheet" href="%CSSNAME%"^> >> %WORKDIR%%DIRNAME%\preview.html
echo ^<style type="text/css"^>.customfont{font-family: '%FONTNAME%';}^</style^> >> %WORKDIR%%DIRNAME%\preview.html
copy %WORKDIR%%DIRNAME%\preview.html+%FFGENDIR%tpl_styles.txt %WORKDIR%%DIRNAME%\preview.html
echo ^<title^>%FONTNAME%^</title^> >> %WORKDIR%%DIRNAME%\preview.html
echo ^</head^> >> %WORKDIR%%DIRNAME%\preview.html
copy %WORKDIR%%DIRNAME%\preview.html+%FFGENDIR%tpl_body.txt %WORKDIR%%DIRNAME%\preview.html
echo ^</body^> >> %WORKDIR%%DIRNAME%\preview.html
echo ^</html^> >> %WORKDIR%%DIRNAME%\preview.html

echo [ffgen] Done.

:End
