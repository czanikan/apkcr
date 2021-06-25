@echo off
:menu
mode con lines=16 cols=76
title RPG Maker MV to Android exporter tool by MBTY v4.2 (dzzb.ru)
cls
echo *-------------------------------------------------------------------------*
echo *  RPG Maker MV to Android exporter tool by MBTY v4.2 (dzzb.ru)           *
echo *-------------------------------------------------------------------------*
echo *  Choose your destiny...                                                 *
echo *-------------------------------------------------------------------------*
echo *     1) Make APK.                                                        *
echo *     2) Make APK + insane optimization.                                  *
echo *     3) My APK already created. Optimize it INSANELY!                    *
echo *     4) Create application sign key. (Do it at most once).               *
echo *                                                                         *
echo *     0) Exit.                                                            *
echo *-------------------------------------------------------------------------*
echo * Place your WWW folder into !RPGMV folder and we are ready to go!        *
echo.
set /p menu_ch=*   Your choice is: 
cls
if "%menu_ch%"=="1" set steps=4& goto crapk
if "%menu_ch%"=="2" set steps=5& goto crapk
if "%menu_ch%"=="3" goto insane
if "%menu_ch%"=="4" goto crkey
exit
cls
:crapk
if not exist !RPGMV\icon.png echo Place icon.png to [!RPGMV] folder! & pause & goto menu
if not exist z_Tools\mykeys.keystore echo You should create application sign key first & pause & goto menu
title Set parameters
echo.
mode con lines=5 cols=85
set /p app_name= Type application name (ex: The Game): 
set /p app_pack=Type application PACKAGE name (ex: id.application.rpg): 
set /p ver_code=Type version code (ex: 1): 
set /p vers=Type version (ex: 2.0.6): 
cls
mode con lines=16 cols=76
del /f /q *.apk
rmdir /S /Q z_Tools\tmpAPK\assets\www
rmdir /S /Q z_Tools\tmpAPK\build
rmdir /S /Q z_Tools\tmpAPK\dist
cls
title Preparing files (1/%steps%)
xcopy !RPGMV\www\* z_Tools\tmpAPK\assets\www /e /i /h /y > nul
z_Tools\nconvert -quiet -out png -resize 512 512 -o !RPGMV\icon192.png !RPGMV\icon.png > nul
move /Y !RPGMV\icon192.png z_Tools\tmpAPK\res\mipmap-xxxhdpi\app_icon.png > nul
z_Tools\nconvert -quiet -out png -resize 144 144 -o !RPGMV\icon144.png !RPGMV\icon.png > nul
move /Y !RPGMV\icon144.png z_Tools\tmpAPK\res\mipmap-xxhdpi\app_icon.png > nul
z_Tools\nconvert -quiet -out png -resize 96 96 -o !RPGMV\icon96.png !RPGMV\icon.png > nul
move /Y !RPGMV\icon96.png z_Tools\tmpAPK\res\mipmap-xhdpi\app_icon.png > nul
z_Tools\nconvert -quiet -out png -resize 72 72 -o !RPGMV\icon72.png !RPGMV\icon.png > nul
move /Y !RPGMV\icon72.png z_Tools\tmpAPK\res\mipmap-hdpi\app_icon.png > nul
z_Tools\nconvert -quiet -out png -resize 48 48 -o !RPGMV\icon48.png !RPGMV\icon.png > nul
move /Y !RPGMV\icon48.png z_Tools\tmpAPK\res\mipmap-mdpi\app_icon.png > nul
cls
z_Tools\rxrepl -s id.application.rpgmakermv -r "%app_pack%" -f z_Tools\z_AndroidManifest.xml -o z_Tools\tmpAPK\AndroidManifest.xml -e utf8 --output-encoding utf8
z_Tools\rxrepl -s RPGMakerMV -r "%app_name%" -f z_Tools\z_strings.xml -o z_Tools\tmpAPK\res\values\strings.xml -e utf8 --output-encoding utf8
z_Tools\rxrepl -s 9000 -r "%ver_code%" -f z_Tools\z_apktool.yml -o z_Tools\t_apktool.yml -e utf8 --output-encoding utf8
z_Tools\rxrepl -s 1.0 -r "%vers%" -f z_Tools\t_apktool.yml -o z_Tools\tmpAPK\apktool.yml -e utf8 --output-encoding utf8
cls
title Making an application (2/%steps%)
cd z_Tools
java\bin\java.exe -Xmx1024m -jar at.jar b tmpAPK
cd ..
move z_Tools\tmpAPK\dist\tmpAPK.apk 0_app.unsigned.apk > nul
cls
title Signing the application (3/%steps%)
copy 0_app.unsigned.apk 1_app.signed.apk > nul
z_Tools\java\bin\jarsigner -keystore z_Tools\mykeys.keystore 1_app.signed.apk mykey
rmdir /S /Q z_Tools\tmpAPK\assets\www
rmdir /S /Q z_Tools\tmpAPK\build
rmdir /S /Q z_Tools\tmpAPK\dist
del /q z_Tools\tmpAPK\res\values\strings.xml
del /q z_Tools\tmpAPK\apktool.yml
del /q z_Tools\tmpAPK\AndroidManifest.xml
del /q z_Tools\t_apktool.yml
cls
title Light optimization (4/%steps%)
z_Tools\zipalign -f 4 "1_app.signed.apk" "2_app.signed.aligned.apk"
cls
if "%menu_ch%"=="1" goto menu
:insane
title MAX optimization (5/%steps%) (It takes a LOT of time!)
del /Q "3_app.signed.tmpmax-optimized.apk"
del /Q "3_app.signed.max-optimized.apk"
del /Q "4_app.signed.max-optimized.aligned.apk"
cls
if "%menu_ch%"=="3" title MAX optimization (It takes a LOT of time!)
copy "1_app.signed.apk" "3_app.signed.tmpmax-optimized.apk"
cls
z_Tools\leanify.exe -i 30 "3_app.signed.tmpmax-optimized.apk"
ren "3_app.signed.tmpmax-optimized.apk" "3_app.signed.max-optimized.apk"
cls
z_Tools\zipalign -f 4 "3_app.signed.max-optimized.apk" "4_app.signed.max-optimized.aligned.apk"
cls
echo Done!
pause
goto menu
:crkey
cls
title Application sign key creating
if exist z_Tools\mykeys.keystore goto ask
:crkeyprocess
cd z_Tools
del /q mykeys.keystore > nul
cls
java\bin\keytool -genkey -keystore mykeys.keystore -alias mykey -validity 10000
set day=%date:~-10,2%&set mon=%date:~-7,2%&set year=%date:~-4,4%&set hour=%time:~-11,2%&set min=%time:~-8,2%&set sec=%time:~-5,2%
set thedatetemp=%year%-%mon%-%day%_%hour%-%min%-%sec% 
set "thedate=%thedatetemp: =0%"
copy mykeys.keystore key_%thedate%.backup
cd ..
echo Done!
pause
goto menu
:ask
echo Sign key file already exist. Do you really want destroy old one?
echo.
echo  1=No
echo  2=No
echo  3=No
echo  4=No
echo  5=No
echo  6=No
echo  7=Yes
echo  8=No
echo  9=No
echo  0=No
echo.
set /p answer=
cls
if "%answer%"=="7" goto crkeyprocess
goto menu