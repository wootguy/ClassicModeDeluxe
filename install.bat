@echo off
cls

echo WARNING: Existing models/sounds/sprites/cfgs/scripts will be overwritten!
echo.

pause
echo.

echo Copying models...
xcopy /i/e/y/q models ..\..\..\models
echo.

echo Copying sounds...
xcopy /i/e/y/q sound ..\..\..\sound
echo.

echo Copying sprites...
xcopy /i/e/y/q sprites ..\..\..\sprites
echo.

echo Copying scripts...
xcopy /i/e/y/q scripts ..\..\..\scripts
echo.

echo Copying default_map_settings.cfg ...
copy default_map_settings.cfg ..\..\..\default_map_settings.cfg
echo.

pause