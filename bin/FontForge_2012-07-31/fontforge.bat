@echo OFF
set FF=%~dp0
set PATH=%FF%\bin;%FF%\bin\Xming-6.9.0.31;%PATH%
set DISPLAY=:9.0
set XLOCALEDIR=%FF%\bin\Xming-6.9.0.31\locale
set AUTOTRACE=potrace
set HOME=%FF%

start /B "" "%FF%\bin\Xming-6.9.0.31\Xming.exe" :9 -multiwindow -clipboard -silent-dup-error -notrayicon

"%FF%\bin\Xming_close.exe" -wait

"%FF%\bin\fontforge.exe" -nosplash %*

"%FF%\bin\Xming_close.exe" -close
