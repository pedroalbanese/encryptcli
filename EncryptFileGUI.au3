; ====================================================
; ============= Encryption Tool With GUI =============
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
#include <ComboConstants.au3>
#include <Crypt.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <String.au3>
#include <WindowsConstants.au3>

#include <GUIEdit.au3>
#include <WinAPI.au3>

Global Const $KP_MODE = 4
Global Const $CRYPT_MODE_CBC = 2

Main()

Func Main()
	$iAlgorithm = $CALG_AES_128
	$keySize = 16
	Local $hGUI = GUICreate('AES File Crypter 1.0 - ALBANESE Research Lab ' & Chr(169) & ' 2017-2023', 490, 100)
	GUISetFont(9, 400, 1, "Consolas")
	Local $idSourceInput = GUICtrlCreateInput("", 5, 5, 400, 20)
	Local $idSourceBrowse = GUICtrlCreateButton("...", 410, 5, 35, 20)

	Local $idDestinationInput = GUICtrlCreateInput("", 5, 30, 400, 20)
	Local $idDestinationBrowse = GUICtrlCreateButton("...", 410, 30, 35, 20)

	GUICtrlCreateLabel("Key:", 5, 55, 200, 20)
	Local $idPasswordInput = GUICtrlCreateInput("", 5, 70, 225, 20)

	Local $idCombo = GUICtrlCreateCombo("", 235, 70, 100, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData($idCombo, "3DES (192bit)|AES (128bit)|AES (192bit)|AES (256bit)|DES (64bit)|RC2 (128bit)|RC4 (128bit)", "AES (128bit)")

	Local $idEncrypt = GUICtrlCreateButton("Encrypt", 343, 68, 70, 25)
	Local $idDecrypt = GUICtrlCreateButton("Decrypt", 415, 68, 70, 25)
	GUISetState(@SW_SHOW, $hGUI)

	Local $sDestinationRead = "", $sFilePath = "", $sPasswordRead = "", $sSourceRead = ""
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idCombo ; Check when the combobox is selected and retrieve the correct algorithm.
				Switch GUICtrlRead($idCombo) ; Read the combobox selection.
					Case "3DES (168bit)"
						$iAlgorithm = $CALG_3DES
						$keySize = 24
					Case "AES (128bit)"
						$iAlgorithm = $CALG_AES_128
						$keySize = 16
					Case "AES (192bit)"
						$iAlgorithm = $CALG_AES_192
						$keySize = 24
					Case "AES (256bit)"
						$iAlgorithm = $CALG_AES_256
						$keySize = 32
					Case "DES (64bit)"
						$iAlgorithm = $CALG_DES
						$keySize = 8
					Case "RC2 (128bit)"
						$iAlgorithm = $CALG_RC2
						$keySize = 16
					Case "RC4 (128bit)"
						$iAlgorithm = $CALG_RC4
						$keySize = 16
				EndSwitch

			Case $idSourceBrowse
				$sFilePath = FileOpenDialog("Select a file to encrypt.", "", "All files (*.*)") ; Select a file to encrypt.
				If @error Then
					ContinueLoop
				EndIf
				GUICtrlSetData($idSourceInput, $sFilePath) ; Set the inputbox with the filepath.

			Case $idDestinationBrowse
				$sFilePath = FileSaveDialog("Save the file as ...", "", "All files (*.*)") ; Select a file to save the encrypted data to.
				If @error Then
					ContinueLoop
				EndIf
				GUICtrlSetData($idDestinationInput, $sFilePath) ; Set the inputbox with the filepath.

			Case $idEncrypt
				$sSourceRead = GUICtrlRead($idSourceInput) ; Read the source filepath input.
				$sDestinationRead = GUICtrlRead($idDestinationInput) ; Read the destination filepath input.
				$sPasswordRead = GUICtrlRead($idPasswordInput) ; Read the password input.
				$key = $sPasswordRead
				If StringLen($key) <> $keySize Then
					MsgBox($MB_SYSTEMMODAL, "", GUICtrlRead($idCombo) & " key must be " & $keySize & "-byte long.")
					ContinueLoop
				EndIf
				_Crypt_Startup()
				$key = _Crypt_ImportKey($iAlgorithm, $key)
				_Crypt_SetKeyParam($key, $KP_MODE, $CRYPT_MODE_CBC)
				If StringStripWS($sSourceRead, $STR_STRIPALL) <> "" And StringStripWS($sDestinationRead, $STR_STRIPALL) <> "" And StringStripWS($sPasswordRead, $STR_STRIPALL) <> "" And FileExists($sSourceRead) Then ; Check there is a file available to encrypt and a password has been set.
					$full = FileRead($sSourceRead, 300000000)
					FileOpen($sDestinationRead, 2)
					FileWrite($sDestinationRead, _Crypt_EncryptData($full, $key, $CALG_USERKEY))
					FileClose($sDestinationRead)
					MsgBox($MB_SYSTEMMODAL, "Success", "Operation succeeded.")
				Else
					MsgBox($MB_SYSTEMMODAL, "Error", "Please ensure the relevant information has been entered correctly.")
				EndIf
				_Crypt_DestroyKey($key)
				_Crypt_Shutdown()
			Case $idDecrypt
				$sSourceRead = GUICtrlRead($idSourceInput) ; Read the source filepath input.
				$sDestinationRead = GUICtrlRead($idDestinationInput) ; Read the destination filepath input.
				$sPasswordRead = GUICtrlRead($idPasswordInput) ; Read the password input.
				$key = $sPasswordRead
				If StringLen($key) <> $keySize Then
					MsgBox($MB_SYSTEMMODAL, "", GUICtrlRead($idCombo) & " key must be " & $keySize & "-byte long.")
					ContinueLoop
				EndIf
				_Crypt_Startup()
				$key = _Crypt_ImportKey($iAlgorithm, $key)
				_Crypt_SetKeyParam($key, $KP_MODE, $CRYPT_MODE_CBC)
				If StringStripWS($sSourceRead, $STR_STRIPALL) <> "" And StringStripWS($sDestinationRead, $STR_STRIPALL) <> "" And StringStripWS($sPasswordRead, $STR_STRIPALL) <> "" And FileExists($sSourceRead) Then ; Check there is a file available to encrypt and a password has been set.
					$full = FileRead($sSourceRead, 300000000)
					FileOpen($sDestinationRead, 2)
					FileWrite($sDestinationRead, _Crypt_DecryptData($full, $key, $CALG_USERKEY))
					FileClose($sDestinationRead)
					MsgBox($MB_SYSTEMMODAL, "Success", "Operation succeeded.")
				Else
					MsgBox($MB_SYSTEMMODAL, "Error", "Please ensure the relevant information has been entered correctly.")
				EndIf
				_Crypt_DestroyKey($key)
				_Crypt_Shutdown()
		EndSwitch
	WEnd

	GUIDelete($hGUI) ; Delete the previous GUI and all controls.
EndFunc   ;==>Main

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
