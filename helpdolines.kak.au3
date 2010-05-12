#comments-start
; ----------------------------------------------------------------------------
helpdolines.kak.au3

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

; Declare variables
Global $statapath, $statawin, $commands, $tempfile, $tempfile2

;Location of the init file
$init = @ScriptDir & "\Send2Stata.ini"

;Stata Paths and Window Text
$statawin =  IniRead($init,"Stata","StataWin","Stata/SE 10.0")
$statapath = IniRead($init,"Stata","StataExe","C:\Program Files\Stata10\wsestata.exe")

;Behavior
$shortWait = IniRead($init,"Behaviour","ShortWait",10)
$focus =  IniRead($init,"Behavior","ReturnFocus",0)
$stataloadup =  IniRead($init,"Behavior","StataLoadWait",500)
Opt("SendKeyDelay", 1)
Opt("WinWaitDelay", 200)
Opt("WinTitleMatchMode",2)

; Clear clipboard
ClipPut("")
; Copy selected lines from editor to clipboard
Send("^c")
; Pause avoids problem with clipboard, may be AutoIt or Windows bug
Sleep(100)
$commands = ClipGet()

; Copy the current line if nothing selected
If $commands = "" Then 
  ; Go to beginning of line, select first word in line
  Send("{HOME}" & "^+{RIGHT}")
  ; Copy selected lines from editor to clipboard
  Send("^c")
  ; Pause avoids problem with clipboard, may be AutoIt or Windows bug
  Sleep(100)
  $commands = ClipGet()
EndIf

; Terminate script if (still) nothing selected
If $commands = "" Then 
  Exit
EndIf

; Create file name in system temporary directory
$tempfile = EnvGet("TEMP") & "\statacmd.tmp"

; Open file for writing and check that it worked
$tempfile2 = FileOpen($tempfile,2)
If $tempfile2 = -1 Then
  MsgBox(0,"Error: Cannot open temporary file","at [" & $tempfile & "]")
  Exit
EndIf

; Write commands to temporary file, add CR-LF at end
; to ensure last line is executed by Stata
FileWrite($tempfile2,"help " )
FileWrite($tempfile2,$commands & @CRLF)
FileClose($tempfile2)


; Get the handle of the currently active window, i.e. gvim
; this will be used to return focus later
Opt("WinTitleMatchMode",4)
$handle = WinGetHandle("active","")

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
	  ; Run temporary file
	  ; Double quotes around $dofile needed in case path contains blanks
	  ClipPut("include " & '"' & $tempfile & '"')
    Send("^v" & "{Enter}")
Else
  Run($statapath)
  WinWaitActive($statawin)
  ; Activate Stata Command Window
  Send("^4")
  ; Run temporary file
  ; Double quotes around $dofile needed in case path contains blanks
  ClipPut("include " & '"' & $tempfile & '"')
  ; Pause avoids problem with clipboard, may be AutoIt or Windows bug
  Sleep(100)
  Send("^v" & "{Enter}")
EndIf

; Return focus to text editor
If $focus=1 Then
    ; will not return focus to gvim unless paused to let Stata load
    Sleep($stataloadup)
    WinActivate($handle)
EndIf
