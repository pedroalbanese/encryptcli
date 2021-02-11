#NoTrayIcon
#include <Crypt.au3>
#include <cmdline.au3>

If Not StringInStr($CmdLineRaw, "in") Or Not StringInStr($CmdLineRaw, "psw") Or $CmdLineRaw == "" Then
	ConsoleWrite("File Encryption Tool - ALBANESE Lab " & Chr(184) & " 2018-2020" & @CRLF & @CRLF) ;
	ConsoleWrite("Usage: " & @CRLF) ;
	ConsoleWrite("   " & @ScriptName & " -e|d --in <file.ext> --alg <algorithm> --psw <password>" & @CRLF & @CRLF) ;
	ConsoleWrite("Commands: " & @CRLF) ;
	ConsoleWrite("   -e: Encrypt " & @CRLF) ;
	ConsoleWrite("   -d: Decrypt" & @CRLF & @CRLF) ;
	ConsoleWrite("Parameters: " & @CRLF) ;
	ConsoleWrite("   /alg: Algorithm" & @CRLF) ;
	ConsoleWrite("   /in : Input file" & @CRLF) ;
	ConsoleWrite("   /out: Output file (Optional [*])" & @CRLF) ;
	ConsoleWrite("   /psw: Password" & @CRLF & @CRLF) ;
	ConsoleWrite("   [*] If no output is specified, the input file will be overwritten." & @CRLF & @CRLF) ;
	ConsoleWrite("Algorithms:" & @CRLF) ;
	ConsoleWrite("   3DES, AES-128 (Default), AES-192, AES-256, DES, RC2, RC4" & @CRLF) ;
	Exit
Else
	If _CmdLine_KeyExists('alg') Then
		Local $algo = _CmdLine_Get('alg')
		If $algo = "3DES" Then
			$alg = $CALG_3DES
		ElseIf $algo = "AES-128" Then
			$alg = $CALG_AES_128
		ElseIf $algo = "AES-192" Then
			$alg = $CALG_AES_192
		ElseIf $algo = "AES-256" Then
			$alg = $CALG_AES_256
		ElseIf $algo = "DES" Then
			$alg = $CALG_DES
		ElseIf $algo = "RC2" Then
			$alg = $CALG_RC2
		ElseIf $algo = "RC4" Then
			$alg = $CALG_RC4
		Else
			ConsoleWrite("Error: Unknown Algorithm." & @CRLF) ;
			Exit
		EndIf
	Else
		$alg = $CALG_AES_128
	EndIf
	Local $file = _CmdLine_Get('in')
	Local $file2 = _CmdLine_Get('out')
	Local $psw = _CmdLine_Get('psw')
EndIf

If _CmdLine_KeyExists('out') Then
	Local $file2 = _CmdLine_Get('out')
Else
	Local $file2 = $file
EndIf

If FileExists($file) Then
	If $CmdLine[0] > 1 And $CmdLine[1] == "-e" Or $CmdLine[1] == "-d" Then
		$full = FileRead($file)
		If $CmdLine[1] == "-e" Then
			FileOpen($file2, 2)
			FileWrite($file2, StringEncrypt(True, $full, $psw))
		ElseIf $CmdLine[1] == "-d" Then
			FileOpen($file2, 2)
			FileWrite($file2, StringEncrypt(False, $full, $psw))
		EndIf
	EndIf
Else
	ConsoleWrite("Error: """ & $file & """ not found." & @CRLF)  ;
EndIf

Func StringEncrypt($bEncrypt, $sData, $sPassword)
	_Crypt_Startup() ; Start the Crypt library.
	Local $vReturn = ''
	If $bEncrypt Then ; If the flag is set to True then encrypt, otherwise decrypt.
		$vReturn = _Crypt_EncryptData($sData, $sPassword, $alg)
	Else
		$vReturn = _Crypt_DecryptData($sData, $sPassword, $alg)
	EndIf
	_Crypt_Shutdown() ; Shutdown the Crypt library.
	Return $vReturn
EndFunc   ;==>StringEncrypt
