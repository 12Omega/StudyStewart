@echo off
echo Migrating Figma design assets to Flutter project...

REM Create asset directories
mkdir assets\images 2>nul
mkdir assets\icons 2>nul  
mkdir assets\screens 2>nul

echo Created asset directories

REM Copy screen references for development comparison
copy "..\..\design\StudyStewart\Home Screen.png" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\Dashboard.png" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\Learning.png" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\Converter.png" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\Settings Light Mode.jpg" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\login.png" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\Sign up.png" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\forgot.png" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\audio.png" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\kinestic.png" "assets\screens\" >nul 2>&1
copy "..\..\design\StudyStewart\wordle.png" "assets\screens\" >nul 2>&1

echo Copied screen reference images

REM Copy icons
copy "..\..\design\StudyStewart\arrow-left.svg" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\star.svg" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\star*.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\notification*.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\profile*.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\toggle*.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\dark-mode*.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\logout*.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\feedback*.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\privacy*.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\share*.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\setting.png" "assets\icons\" >nul 2>&1
copy "..\..\design\StudyStewart\edit.png" "assets\icons\" >nul 2>&1

echo Copied UI icons

REM Copy visual elements
copy "..\..\design\StudyStewart\76*.png" "assets\images\" >nul 2>&1
copy "..\..\design\StudyStewart\Rectangle*.png" "assets\images\" >nul 2>&1
copy "..\..\design\StudyStewart\dp.png" "assets\images\" >nul 2>&1
copy "..\..\design\StudyStewart\Ellipse 7.png" "assets\images\" >nul 2>&1
copy "..\..\design\StudyStewart\back*.png" "assets\images\" >nul 2>&1

echo Copied visual elements

echo.
echo Asset migration complete!
echo.
echo Next steps:
echo 1. Run: flutter pub get
echo 2. Import assets in your Dart files: import '../constants/assets.dart';
echo 3. Use AppAssets.iconName to reference assets
echo 4. Compare your screens with reference images in assets/screens/
echo.
echo Example usage:
echo   Image.asset(AppAssets.arrowLeft, width: 30, height: 29)
echo   Image.asset(AppAssets.notification, width: 24, height: 24)
echo.

pause