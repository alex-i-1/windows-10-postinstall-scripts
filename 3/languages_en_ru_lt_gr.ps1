# check if has administrator privileges
#requires -version 4.0
#requires –runasadministrator

## I don't see how to make it return any possible error, - it exits without reporting error always
$lang_list = New-WinUserLanguageList en-US
$lang_list.Add("ru-RU")
$lang_list.Add("lt-LT")
$lang_list.Add("el-GR")
Set-WinUserLanguageList $lang_list -Force
