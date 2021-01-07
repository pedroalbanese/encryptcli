#include-once

#comments-start
   CmdLine small UDF
   coder: Jefrey (jefrey[at]jefrey.ml)
#comments-end

Func _CmdLine_Get($sKey, $mDefault = Null)
   For $i = 1 To $CmdLine[0]
      If $CmdLine[$i] = "/" & $sKey OR $CmdLine[$i] = "-" & $sKey OR $CmdLine[$i] = "--" & $sKey Then
         If $CmdLine[0] >= $i+1 Then
            Return $CmdLine[$i+1]
         EndIf
      EndIf
   Next
   Return $mDefault
EndFunc

Func _CmdLine_KeyExists($sKey)
   For $i = 1 To $CmdLine[0]
      If $CmdLine[$i] = "/" & $sKey OR $CmdLine[$i] = "-" & $sKey OR $CmdLine[$i] = "--" & $sKey Then
         Return True
      EndIf
   Next
   Return False
EndFunc

Func _CmdLine_ValueExists($sValue)
   For $i = 1 To $CmdLine[0]
      If $CmdLine[$i] = $sValue Then
         Return True
      EndIf
   Next
   Return False
EndFunc

Func _CmdLine_FlagEnabled($sKey)
   For $i = 1 To $CmdLine[0]
      If StringRegExp($CmdLine[$i], "\+([a-zA-Z]*)" & $sKey & "([a-zA-Z]*)") Then
         Return True
      EndIf
   Next
   Return False
EndFunc

Func _CmdLine_FlagDisabled($sKey)
   For $i = 1 To $CmdLine[0]
      If StringRegExp($CmdLine[$i], "\-([a-zA-Z]*)" & $sKey & "([a-zA-Z]*)") Then
         Return True
      EndIf
   Next
   Return False
EndFunc

Func _CmdLine_FlagExists($sKey)
   For $i = 1 To $CmdLine[0]
      If StringRegExp($CmdLine[$i], "(\+|\-)([a-zA-Z]*)" & $sKey & "([a-zA-Z]*)") Then
         Return True
      EndIf
   Next
   Return False
EndFunc

Func _CmdLine_GetValByIndex($iIndex, $mDefault = Null)
   If $CmdLine[0] >= $iIndex Then
      Return $CmdLine[$iIndex]
   Else
      Return $mDefault
   EndIf
EndFunc