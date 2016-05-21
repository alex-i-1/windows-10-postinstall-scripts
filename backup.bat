del _.zip
"C:\Program Files\7-Zip\7z.exe" a -tzip _.zip -mx9 -r "*.bat" "*.cmd" "*.txt" "*.reg" "*.xml" "*.ini" "*.vbs" "*.ps1" "privacy\www.mcgearytech.com\windows10scripts.zip" ".gitignore" "LICENSE"
if %errorlevel% neq 0 pause
