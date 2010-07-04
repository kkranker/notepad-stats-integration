#comments-start
; -------------------------------------------------------------------------------
Author: Kyle Foreman
Contact: kfor@u.washington.edu
Date: June 28, 2010
Purpose: Pass lines from Notepad++ into PyLab/IPython
Adapted from http://code.google.com/p/notepad-stats-integration/ by Keith Kranker
; -------------------------------------------------------------------------------
#comments-end

; Declare variables
Global $commands, $tempfile, $tempfile2, $single_line, $clip_buffer

; Behavior variables
; shortWait = number of ms to wait when doing clipboard operations
$shortWait = 10
; focus: 1 means to bring focus back to Np++ after running file, 0 keeps it in PuTTY
$focus = 1
; ipythonloadup = how long to wait before bringing focus back
$ipythonloadup =  10
Opt("SendKeyDelay", 1)
Opt("WinWaitDelay", 100)

; Copy clipboard temporarily
$clip_buffer = ClipGet()
; Clear clipboard
ClipPut("")
; Copy selected lines from editor to clipboard
Send("^c")
; Pause avoids problem with clipboard, may be AutoIt or Windows bug
Sleep(100)
$commands = ClipGet()

; Copy the current line if nothing selected
If $commands = "" Then 
  ; Copy single line from editor to clipboard
  Send("{HOME}" & "{HOME}" & "+{END}")
  Send("^c")
  Send("{DOWN}" & "{HOME}" & "{HOME}")
  ; Pause avoids problem with clipboard, may be AutoIt or Windows bug
  Sleep(100)
  $commands = ClipGet()
  $single_line = 1
EndIf

; Terminate script if (still) nothing selected
If $commands = "" Then 
  Exit
EndIf

; Get the handle of the currently active window, i.e. gvim
; this will be used to return focus later
Opt("WinTitleMatchMode",4)
$handle = WinGetHandle("active","")

; Run the temporary file in IPython
If WinExists("[CLASS:PuTTY]", "") Then
	; WinActivate("[CLASS:PuTTY]", "")
    ; WinWaitActive("[CLASS:PuTTY]", "")
	ClipPut($commands)
	WinActivate("[CLASS:PuTTY]", "")
    ControlClick("[CLASS:PuTTY]", "", "", "right")
	Send("{ENTER}")
Else
	MsgBox(0,"Notepad++ to PuTTY Error","Error: Cannot find an open PuTTY window.")
	Exit
EndIf

; Restore the clipboard
ClipPut($clip_buffer)

; Return focus to text editor
Sleep($ipythonloadup)
WinActivate($handle)
