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
Global $ipython_win, $commands, $tempfile, $tempfile2, $single_line, $clip_buffer

; IPython Window Text
; Put the name of the window used for IPython (e.g. PyLab) here
$ipython_win =  "PyLab"

; Behavior variables
; shortWait = number of ms to wait when doing clipboard operations
$shortWait = 10
; focus: 1 means to bring focus back to Np++ after running file, 0 keeps it in IPython
$focus = 1
; ipythonloadup = how long to wait before bringing focus back
$ipythonloadup =  10
Opt("SendKeyDelay", 1)
Opt("WinWaitDelay", 100)
Opt("WinTitleMatchMode",2)

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

; Let the program know only to paste in the command (not make a tmp file) if there is only 1 or less lines
If Not StringinStr($commands,Chr(13)) Then
  $single_line = 1
EndIf

; Terminate script if (still) nothing selected
If $commands = "" Then 
  Exit
EndIf

; Create file name in system temporary directory
$tempfile = EnvGet("TEMP") & "\npp2ipy_tmp.py"

; Open file for writing and check that it worked
$tempfile2 = FileOpen($tempfile,2)
If $tempfile2 = -1 Then
  MsgBox(0,"Error: Cannot open temporary file","at [" & $tempfile & "]")
  Exit
EndIf

; Write commands to temporary file, add CR-LF at end
FileWrite($tempfile2,$commands & @CRLF)
FileClose($tempfile2)


; Get the handle of the currently active window, i.e. gvim
; this will be used to return focus later
Opt("WinTitleMatchMode",4)
$handle = WinGetHandle("active","")

; If more than one IPython window is open, the window
; that was most recently active will be matched
Opt("WinTitleMatchMode",2)

; Run the temporary file in IPython
If WinExists($ipython_win) Then
	WinActivate($ipython_win)
    WinWaitActive($ipython_win)
    ; Clear any typed text
    Send("{ESC}")
	; Run temporary file if there's multiple lines
	If $single_line = 0 Then
		ClipPut("run -i " & '"' & $tempfile & '"')
	Else
		ClipPut($commands)
	EndIf
    Send("^v{Enter}")
Else
	MsgBox(0,"Notepad++ to IPython Error","Error: Cannot find an open " & $ipython_win & " window.")
	Exit
EndIf

; Restore the clipboard
ClipPut($clip_buffer)

; Return focus to text editor
If $focus = 1 Then
    Sleep($ipythonloadup)
    WinActivate($handle)
EndIf
