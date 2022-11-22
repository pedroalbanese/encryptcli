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
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <String.au3>
#include <WindowsConstants.au3>
#include <GUIEdit.au3>
#include <WinAPI.au3>

#include <StaticConstants.au3>
#include <Crypt.au3>

Global Const $KP_MODE = 4
Global Const $CRYPT_MODE_CBC = 2

; Creates window
GUICreate('AES Text Crypt 1.0 - ALBANESE Research Lab ' & Chr(169) & ' 2017-2023', 590, 400, -1, -1, -1, $WS_EX_ACCEPTFILES)
GUISetFont(9, 400, 1, "Consolas")


; Creates main edit
Local $idEditText = GUICtrlCreateEdit('', 5, 5, 580, 350, $ES_AUTOVSCROLL + $WS_VSCROLL)
GUICtrlSetState($idEditText, $GUI_DROPACCEPTED)

; Creates the key box with blured/centered input
Local $idInputPass = GUICtrlCreateInput('', 5, 360, 250, 20, $ES_PASSWORD)
GUICtrlSetState($idInputPass, $GUI_DROPACCEPTED)

; Cretae the combo to select the crypting algorithm
Local $idCombo = GUICtrlCreateCombo("", 260, 360, 115, 20, $CBS_DROPDOWNLIST)
GUICtrlSetData($idCombo, "3DES|AES (128bit)|AES (192bit)|AES (256bit)|DES|RC2|RC4", "AES (128bit)")

; Encryption/Decryption buttons
Local $idEncryptButton = GUICtrlCreateButton('Encrypt', 410, 360, 85, 35)
Local $idDecryptButton = GUICtrlCreateButton('Decrypt', 500, 360, 85, 35)

GUICtrlCreateLabel('Key', 5, 385)

; Create dummy for accelerator key to activate
$hSelAll = GUICtrlCreateDummy()

; Shows window
GUISetState()

; Set accelerators for Ctrl+a
Dim $AccelKeys[1][2]=[["^a", $hSelAll]]
GUISetAccelerators($AccelKeys)

Local $iAlgorithm = $CALG_AES_128
Local $dEncrypted

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ExitLoop

		Case $idCombo ; Check when the combobox is selected and retrieve the correct algorithm.
			Switch GUICtrlRead($idCombo) ; Read the combobox selection.
				Case "3DES"
					$iAlgorithm = $CALG_3DES
				Case "AES (128bit)"
					$iAlgorithm = $CALG_AES_128
				Case "AES (192bit)"
					$iAlgorithm = $CALG_AES_192
				Case "AES (256bit)"
					$iAlgorithm = $CALG_AES_256
				Case "DES"
					$iAlgorithm = $CALG_DES
				Case "RC2"
					$iAlgorithm = $CALG_RC2
				Case "RC4"
					$iAlgorithm = $CALG_RC4
				EndSwitch

		Case $idEncryptButton
			; When you press Encrypt
			_Crypt_Startup()
			$key = GUICtrlRead($idInputPass)
			$key = _Crypt_ImportKey($iAlgorithm, $key)
			_Crypt_SetKeyParam($key, $KP_MODE, $CRYPT_MODE_CBC)
			; Calls the encryption. Sets the data of editbox with the encrypted string
			$dEncrypted = _Crypt_EncryptData(GUICtrlRead($idEditText), $key, $CALG_USERKEY)     ; Encrypt the text with the new cryptographic key.
			GUICtrlSetData($idEditText, StringReplace($dEncrypted, "0x", ""))
			_Crypt_DestroyKey($key)
			_Crypt_Shutdown()

		Case $idDecryptButton
			; When you press Decrypt
			_Crypt_Startup()
			$key = GUICtrlRead($idInputPass)
			$key = _Crypt_ImportKey($iAlgorithm, $key)
			_Crypt_SetKeyParam($key, $KP_MODE, $CRYPT_MODE_CBC)
			; Calls the decryption. Sets the data of editbox with the decrypted string
			$dDecrypted = _Crypt_DecryptData('0x' & StringReplace(GUICtrlRead($idEditText), @CRLF, ""), $key, $CALG_USERKEY)     ; Decrypt the data using the generic password string. The return value is a binary string.
			If _HexToString($dDecrypted) = "0x-1" Then
				GUICtrlSetData($idEditText, "Bad decrypt.")
			Else
				GUICtrlSetData($idEditText, _HexToString($dDecrypted))
			EndIf
			_Crypt_DestroyKey($key)
			_Crypt_Shutdown()
       Case $hSelAll
            _SelAll()
	EndSwitch
WEnd

Func _SelAll()
    $hWnd = _WinAPI_GetFocus()
    $class = _WinAPI_GetClassName($hWnd)
    If $class = 'Edit' Then _GUICtrlEdit_SetSel($hWnd, 0, -1)
EndFunc   ;==>_SelAll

Func _Crypt_ImportKey($iALG_ID, $sKey)
     Local Const $PLAINTEXTKEYBLOB = 0x8 ;The key is a session key.
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