; ====================================================
; ============= Encryption Tool With CLI =============
; ====================================================
; AutoIt version: 3.3.12.0
; Language:       English
; Author:         Pedro F. Albanese
; Modified:       -
;
; ----------------------------------------------------------------------------
; Script Start
; ----------------------------------------------------------------------------

#NoTrayIcon
#include <Crypt.au3>
#include <cmdline.au3>

Global Const $KP_MODE = 4
Global Const $CRYPT_MODE_CBC = 2

_Crypt_Startup()

If not StringInStr($CmdLineRaw, "in") or not StringInStr($CmdLineRaw, "key") or  $CmdLineRaw == "" Then
   ConsoleWrite("Advanced Encryption Standard Tool - ALBANESE Research Lab " & Chr(184) & " 2017-2023" & @CRLF & @CRLF);
   ConsoleWrite("Usage: " & @CRLF & '   ' & @ScriptName & " -e|d --in <file.ext> --alg <algorithm> --key <key>" & @CRLF & @CRLF);
   ConsoleWrite("Commands: " & @CRLF);
   ConsoleWrite("   -e: Encrypt " & @CRLF);
   ConsoleWrite("   -d: Decrypt" & @CRLF & @CRLF);
   ConsoleWrite("Parameters: " & @CRLF);
   ConsoleWrite("   /alg: Algorithm" & @CRLF);
   ConsoleWrite("   /in : Input file" & @CRLF);
   ConsoleWrite("   /out: Output file (Optional [*])" & @CRLF);
   ConsoleWrite("   /key: Symmetric key" & @CRLF & @CRLF);
   ConsoleWrite("   [*] If no output is specified, the input file will be overwritten." & @CRLF & @CRLF);
   ConsoleWrite("Algorithms:" & @CRLF);
   ConsoleWrite("   3DES, AES-128 (Default), AES-192, AES-256, DES, RC2, RC4" & @CRLF);
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
	   ConsoleWrite("Error: Unknown Algorithm." & @CRLF);
       Exit
	  Endif
  Else
   $alg = $CALG_AES_128
  Endif
   Local $file = _CmdLine_Get('in')
   Local $file2 = _CmdLine_Get('out')
   Local $key = _CmdLine_Get('key')
EndIf

If _CmdLine_KeyExists('out') Then
	Local $outfile = _CmdLine_Get('out')
Else
	Local $outfile = $file
EndIf

If FileExists($file) Then
	If $CmdLine[0] > 1 And $CmdLine[1] == "-e" Or $CmdLine[1] == "-d" Then
		$full = FileRead($file)
		If $CmdLine[1] == "-e" Then
			_Crypt_Startup()
			$key = _Crypt_ImportKey($alg, $key)
			_Crypt_SetKeyParam($key, $KP_MODE, $CRYPT_MODE_CBC)
			FileOpen($outfile, 2)
			FileWrite($outfile, StringEncrypt(True, $full, $key))
		ElseIf $CmdLine[1] == "-d" Then
			_Crypt_Startup()
			$key = _Crypt_ImportKey($alg, $psw)
			_Crypt_SetKeyParam($key, $KP_MODE, $CRYPT_MODE_CBC)
			FileOpen($outfile, 2)
			FileWrite($outfile, StringEncrypt(False, $full, $key))
		EndIf
	EndIf
Else
	ConsoleWrite("Error: """ & $file & """ not found." & @CRLF)  ;
EndIf

Func StringEncrypt($bEncrypt, $sData, $sPassword)
	_Crypt_Startup() ; Start the Crypt library.
	Local $vReturn = ''
	If $bEncrypt Then ; If the flag is set to True then encrypt, otherwise decrypt.
		$vReturn = _Crypt_EncryptData($sData, $sPassword, $CALG_USERKEY)
	Else
		$vReturn = _Crypt_DecryptData($sData, $sPassword, $CALG_USERKEY)
	EndIf
	_Crypt_Shutdown() ; Shutdown the Crypt library.
	Return $vReturn
EndFunc   ;==>StringEncrypt

Func _Crypt_ImportKey($iALG_ID, $sKey)
	Local Const $PLAINTEXTKEYBLOB = 0x8  ;The key is a session key.
	Local Const $CUR_BLOB_VERSION = 2

	Local $bKey = Binary($sKey), $iKeyLen = BinaryLen($bKey)

	Local $tagPUBLICKEYBLOB = "struct; BYTE bType; BYTE bVersion; WORD reserved; dword aiKeyAlg; dword keysize; byte key[" & $iKeyLen & "]; endstruct;"

	Local $tBLOB = DllStructCreate($tagPUBLICKEYBLOB)
	DllStructSetData($tBLOB, "bType", $PLAINTEXTKEYBLOB)
	DllStructSetData($tBLOB, "bVersion", $CUR_BLOB_VERSION)
	DllStructSetData($tBLOB, "aiKeyAlg", $iALG_ID)
	DllStructSetData($tBLOB, "keysize", $iKeyLen)
	DllStructSetData($tBLOB, "key", Binary($bKey))

	Local $aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptImportKey", "handle", __Crypt_Context(), "ptr", DllStructGetPtr($tBLOB), "dword", DllStructGetSize($tBLOB), "ptr", 0, "dword", 0, "ptr*", 0)
	If @error Then Return SetError(2, @error)

	Return SetError(Not $aRet[0], 0, $aRet[6])
EndFunc   ;==>_Crypt_ImportKey

Func _Crypt_SetKeyParam($hKey, $iParam, $vData, $iFlags = 0, $sDataType = Default)
	If Not $sDataType Or $sDataType = Default Then $sDataType = "ptr"

	Local $aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptSetKeyParam", "handle", $hKey, "dword", $iParam, $sDataType, $vData, "dword", $iFlags)
	If @error Then Return SetError(2, @error)

	Return SetError(Not $aRet[0], 0, $aRet[0])
EndFunc   ;==>_Crypt_SetKeyParam
