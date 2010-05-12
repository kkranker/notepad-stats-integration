/* to add Notepad++ to your Stata menu, add the following files to your profile.do file */

window menu append separator "stUser"
window menu append item "stUser" "Notepad++        F9" "npp"   /* npp is a program I wrote, contains filename of Notepad++ executable */
window menu append item "stUser" "Stat Transfer (help)" "help stcmd"
global F9 npp;
