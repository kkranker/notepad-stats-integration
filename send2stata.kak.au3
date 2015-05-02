#comments-start
; ----------------------------------------------------------------------------
send2stata.kak.au3

By Keith Kranker
Last update Aug 18 2008

Website & Instructions
at http://www.econ.umd.edu/~kranker/code/notepad_to_stata.php

Credits:

Jeffrey Arnold's Send2Stata.au3 script and .ini files posted
at http://www.hsph.harvard.edu/cgi-bin/lwgate/STATALIST/archives/statalist.0608/date/article-886.html

and Friedrich Huebler's  rundo.au3 rundolines.au3 scripts posted
at http://huebler.info/2005/20050310_Stata_editor.html
; ----------------------------------------------------------------------------
#comments-end


;Location of the init file
$init = @ScriptDir & "\Send2Stata.ini"

;Stata Paths and Window Text
$statawin =  IniRead($init,"Stata","StataWin","Stata/SE 10.0")
$statapath = IniRead($init,"Stata","StataExe","C:\Program Files\Stata10\wsestata.exe")

;Behavior
$shortWait = IniRead($init,"Behavior","ShortWait",10)
$focus =  IniRead($init,"Behavior","ReturnFocus",0)
$savefile =  IniRead($init,"Behavior","SaveFile",1)
$stataloadup =  IniRead($init,"Behavior","StataLoadWait",500)
Opt("SendKeyDelay", 1)
Opt("WinWaitDelay", $shortWait)

; Parsing arguments
$command = $CmdLineRaw

; Get the handle of the currently active window, i.e. notepad++
; this will be used to return focus later
Opt("WinTitleMatchMode",4)
$handle = WinGetHandle("active","")

; Save file in Notepad++ before running this program
If $savefile = 1 Then
	Send("^s")
EndIf

; If more than one Stata window is open, the window
; that was most recently active will be matched
Opt("WinTitleMatchMode",2)

; Check if Stata is already open, run it if not
If WinExists($statawin) Then
    ; Closing Data browser and editor before sending stuff
    If WinExists("Data Browser") Then
        WinClose("Data Browser")
        WinWaitClose("Data Browser")
    ElseIf WinExists("Data Editor") Then
        WinClose("Data Editor")
        WinWaitClose("Data Editor")
    EndIf
    WinActivate($statawin)
    WinWaitActive($statawin)
    ; Activate Stata Command Window and select text (if any)
    Send("^4")
    ; Ctl-A was giving me problems so I used ESC instead
    Send("{ESC}")
    ; Run saved do-file
    ; Putting it in clipboard and copying is faster than sending key strokes
    ClipPut($command)
    Send("^v{Enter}")
Else
    ; if no window open
    If FileExists($statapath) Then
        ; open stata from the command line
        Run($statapath & ' ' & $command)
    Else
        MsgBox(0+16,"", $statapath & " not found")
    EndIf
EndIf

If $focus = 1 Then
    ; will not return focus to unless paused to let Stata load
	Sleep($stataloadup)
    WinActivate($handle)
EndIf
