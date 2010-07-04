#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.12.1
 Website:        http://www.ucl.ac.uk/~uctpjyy/
 Date:           July 4th 2010
 
 Script Function:
	Run selected lines in program. Program path, window title and commands to
	run a script and to run one line have to be defined in RunLines.ini. 
	
	Notepad++ run (F5) command:
		RunLines.exe "$(EXT_PART)"
	
	Code adapted from rundo.au3 version3 by Friedrich Huebler, 
	fhuebler@gmail.com, www.huebler.info, 27 April 2008
	And from code in runpython.au3 by Kyle Foreman, 
	kfor@u.washington.edu, June 28, 2010
	
#ce ----------------------------------------------------------------------------

#include <File.au3>

; Declare variables
Local $extension, $InfoArray, $ProgramName, $path, $WinTitle
Local $TmpScriptName, $TmpScriptHandle 
Local $RunScriptCommand, $SingleLineCommand
Local $OldClipBuffer, $LinesContent, $BoolSingleLine

; get extension, $(EXT_PART), from command line
$extension = StringTrimLeft($CmdLine[1], 1) ; remove leading . from extension; i.e. '.txt' > 'txt'

; Path to INI file
Local Const $ini = @ScriptDir & "\RunLines.ini" 

; Determine RunLines script corresponding to extension
$ProgramName = IniRead($ini, "Extensions", $extension, "DEFAULT")
If ( $ProgramName == "DEFAULT" ) Then
    ; could not find extension
	MsgBox(64, "Error", "Missing extension " & $extension & " under section [Extensions] in " & $ini)	
	Exit
EndIf

; Path to program executable
$path = IniRead($ini, $ProgramName, "path", "")

; Title of program window
$WinTitle = IniRead($ini, $ProgramName, "wintitle", "")

; Command that needs to be sent (with default as last argument)
$RunScriptCommand = IniRead($ini, $ProgramName, "run_script_command", "%%ScriptName%% {Enter}")
$SingleLineCommand = IniRead($ini, $ProgramName, "single_line_command", "^v {Enter}")

; Determine what we need to send to program
$OldClipBuffer = ClipGet()				; Copy clipboard temporarily
ClipPut("")								; Clear clipboard
Send("^c")								; Copy selected lines from editor to clipboard
Sleep(100)								; Pause avoids problem with clipboard, may be AutoIt or Windows bug
$LinesContent = ClipGet()

; Copy the current line if nothing selected
If $LinesContent = "" Then
  ; Copy single line from editor to clipboard
  Send("{HOME}" & "{HOME}" & "+{END}")
  Send("^c")
  Send("{DOWN}" & "{HOME}" & "{HOME}")
  ; Pause avoids problem with clipboard, may be AutoIt or Windows bug
  Sleep(100)
  $LinesContent = ClipGet()
  $BoolSingleLine = 1
EndIf


; Let the program know only to paste in the command (not make a tmp file) if there is only 1 or less lines
; Use LF (\n) to check if a new lines exists instead of CR (\r) 
If Not StringinStr( $LinesContent, @LF ) Then
  $BoolSingleLine = 1
EndIf

; Terminate script if (still) nothing selected
If $LinesContent = "" Then
  Exit
EndIf


If $BoolSingleLine = 0 Then
  ; Create file name in system temporary directory with the correct extension
  $TmpScriptName = EnvGet( "TEMP" ) & "\NppRunLines_tmp." & $extension

  ; Open file for writing and check that it worked
  $TmpScriptHandle = FileOpen( $TmpScriptName, 2 )
  If $TmpScriptHandle = -1 Then
    MsgBox( 0, "Error: Cannot open temporary file","at [" & $TmpScriptName & "]" )
    Exit
  EndIf

  ; Write LinesContent to temporary file, add CR-LF at end
  FileWrite( $TmpScriptHandle, $LinesContent & @CRLF )
  FileClose( $TmpScriptHandle )

  ; Replace '\' to '/' in TmpScriptName, so this works in R as well
  $TmpScriptName = StringReplace( $TmpScriptName, "\", "/" )
  ; Replace the scriptname placeholder in the command we send to the program
  $RunScriptCommand = StringReplace( $RunScriptCommand, "%%ScriptName%%", $TmpScriptName )
  
EndIf

; Get the handle of the currently active window, i.e. gvim
; this will be used to return focus later
; Opt("WinTitleMatchMode",4)
; $handle = WinGetHandle("active","")


; If more than one program window is open, the window 
; that was most recently active will be matched
Opt( "SendKeyDelay", 1 )
Opt( "WinWaitDelay", 100 )
Opt( "WinTitleMatchMode", 2 )


; Check if program is already open, start program if not
If WinExists( $WinTitle ) Then
  WinActivate( $WinTitle )
  WinWaitActive( $WinTitle )
  
  If $BoolSingleLine = 1 Then
    Send( $SingleLineCommand )
  Else
    Send( $RunScriptCommand )
  Endif
Else
  Run( $path )
  WinWaitActive( $WinTitle )

  If $BoolSingleLine = 1 Then
    Send( $SingleLineCommand )
  Else
    Send( $RunScriptCommand )
  Endif
EndIf



; Restore the clipboard
ClipPut( $OldClipBuffer )

; Return focus to text editor
; If $focus = 1 Then
;   Sleep($ipythonloadup)
;   WinActivate($handle)
; EndIf



; End of script
