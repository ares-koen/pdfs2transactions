@echo off

cd /d "%~dp0"

rem env_ruby=__env\ruby\bin\ruby.exe
for /f "delims== tokens=1,2" %%G in (config\env.parameters) do set %%G=%%H

start /max "pdf2txt" %env_ruby% src\pdf2txt.rb
rem %env_ruby% src\pdf2txt.rb
rem pause
