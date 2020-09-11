@echo off

cd /d "%~dp0"

rem env_ruby=__env\ruby\bin\ruby.exe
for /f "delims== tokens=1,2" %%G in (config\env.parameters) do set %%G=%%H

start /max "parse data" %env_ruby% src\parse.rb
rem %env_ruby% src\parse.rb
rem pause
