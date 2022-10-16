#OnAutoItStartRegister SetProcessDPIAware
_Singleton("ShittyWarpd",0)
Opt('GUICloseOnESC',False)
Global $user32 = DllOpen("user32.dll")     
Global $hInputWnd = GUICreate("")
GUIRegisterMsg(0x00ff,WM_INPUT)
SetRawinput($hInputWnd, True)
SingletonOverlay('init')


Do
Until GuiGetMsg()=-3

Func SetProcessDPIAware()
     GUICreate("")
     DllCall("user32.dll", "bool", "SetProcessDPIAware")
     GUIDelete()
EndFunc

Func SetRawinput($hWnd, $enable)
     Local $struct = DllStructCreate('struct;ushort UsagePage;ushort Usage;dword Flags;hwnd Target;endstruct')
     With  $struct
           .Target = $hWnd
           .Flags = $enable ? 0x00000100 : 0x00000001
           .UsagePage = 0x01 ; generic desktop
           .Usage = 0x06 ; keyboard
           DllCall($user32, 'bool', 'RegisterRawInputDevices', 'struct*', $struct, 'uint', 1, 'uint', DllStructGetSize($struct))
     EndWith
EndFunc

Func SingletonOverlay($msg=null,$arg=null)
     Local Static $hOverlay, $hFrame, $state = DllStructCreate('boolean active;uint left;uint right;uint top;uint bottom')
     With $state
          Switch $msg
            Case 'init'
                  $hOverlay = GUICreate("Overlay",@DesktopWidth,@DesktopHeight,0,0,0x80000000,0x02080080)
                  $hFrame = GUICtrlCreateButton("",0,0,@DesktopWidth,@DesktopHeight)
                  GUISetBkColor(0xe1e1e1,$hOverlay)
                  DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $hOverlay, "INT", 0x00e1e1e1, "byte", 255, "dword", 0x03)
                  GUISetState(@SW_DISABLE)
            Case 'reset'
                 .active = False
                 .left = 0
                 .top = 0
                 .right = @DesktopWidth
                 .bottom = @DesktopHeight
                 GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
            Case 'activate'
                 SingletonOverlay('reset')
                 .active = True
                 GUISetState(@SW_SHOW,$hOverlay)
                 GUISetState(@SW_RESTORE,$hOverlay)
            Case 'deactivate'
                 SingletonOverlay('reset')
                 GUISetState(@SW_HIDE,$hOverlay)
            Case 'U'
                 If .active Then
                    .bottom = Int((.top+.bottom)/2)
                    .right  = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    MouseMove( Int((.left+.right)/2), Int((.top+.bottom)/2), 0 )
                    GUISetState(@SW_RESTORE,$hOverlay)
                 EndIf
            Case 'I'
                 If .active Then
                    .bottom = Int((.top+.bottom)/2)
                    .left   = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    MouseMove( Int((.left+.right)/2), Int((.top+.bottom)/2), 0 )
                    GUISetState(@SW_RESTORE,$hOverlay)
                 EndIf
            Case 'J'
                 If .active Then
                    .top    = Int((.top+.bottom)/2)
                    .right  = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    MouseMove( Int((.left+.right)/2), Int((.top+.bottom)/2), 0 )
                    GUISetState(@SW_RESTORE,$hOverlay)
                 EndIf
            Case 'K'
                 If .active Then
                    .top    = Int((.top+.bottom)/2)
                    .left   = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    MouseMove( Int((.left+.right)/2), Int((.top+.bottom)/2), 0 )
                    GUISetState(@SW_RESTORE,$hOverlay)
                 EndIf
            Case 'M'
                 If .active Then 
                    MouseClick( 'left',   Int((.left+.right)/2), Int((.top+.bottom)/2), 1, 0 )
                    SingletonOverlay('deactivate')
                 EndIf
            Case ','
                 If .active Then 
                    MouseClick( 'middle', Int((.left+.right)/2), Int((.top+.bottom)/2), 1, 0 )
                    SingletonOverlay('deactivate')
                 EndIf
            Case '.'
                 If .active Then 
                    MouseClick( 'right',  Int((.left+.right)/2), Int((.top+.bottom)/2), 1, 0 )
                    SingletonOverlay('deactivate')
                 EndIf
          EndSwitch
     EndWith
EndFunc

Func SingletonKeyState($vKey=Null, $change=0)
     Local Static $state[256]
     If $vKey Then
        Local $i = $vKey-1
        Local $stateBefore = $state[$i]
        $state[$i] = Int(Max(-1,Min(1,$state[$i]+2*$change)))
        Return $stateBefore
     Else
        $state = []
        ReDim $state[256]
        Return 0
     EndIf
EndFunc

Func WM_INPUT($hWnd, $iMsg, $wParam, $lParam)
     ; only registered for keyboard so no need to check header for device type
     Local Static $tagHeader = 'dword dwType;dword dwSize;handle hDevice;wparam wParam;'
     Local Static $tag = $tagHeader & 'ushort MakeCode;ushort Flags;ushort Reserved;ushort VKey;uint Message;ulong ExtraInformation'
     Local Static $sizeHeader = DllStructGetSize(DllStructCreate($tagHeader)), $size = DllStructGetSize(DllStructCreate($tag))
     Local $struct = DllStructCreate($tag)
     DllCall($user32, 'uint', 'GetRawInputData', 'handle', $lParam, 'uint', 0x10000003, 'struct*', DllStructGetPtr($struct), 'uint*', $size, 'uint', $sizeHeader)
     Switch $struct.VKey
       Case 0x11,0x12 ; ctrl,alt
            SingletonKeyState($struct.VKey,BitAnd(0x0001,$struct.Flags)?-1:1)
       Case 0x1B ; esc
            If BitAnd(0x0001,$struct.Flags) Then 
               SingletonOverlay('deactivate')
            EndIf
       Case 0x47 ; G
            If BitAnd(0x0001,$struct.Flags) Then ; on keyup so I don't need to check repeat
               If SingletonKeyState(0x11) + SingletonKeyState(0x12) = 2 Then 
                  SingletonOverlay('activate')
               EndIf
            EndIf
       Case 0x55 ; U
            If Not BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('U')
       Case 0x49 ; I
            If Not BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('I')
       Case 0x4A ; J
            If Not BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('J')
       Case 0x4B ; K
            If Not BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('K')
       Case 0x4D ; M
            If Not BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('M')
       Case 0xBC ; comma
            If Not BitAnd(0x0001,$struct.Flags) Then SingletonOverlay(',')
       Case 0xBE ; period
            If Not BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('.')
     EndSwitch
     Return 0
EndFunc

Func Min($a,$b)
     Return $a<$b?$a:$b
EndFunc
Func Max($a,$b)
     Return $a>$b?$a:$b
EndFunc



; #FUNCTION# ====================================================================================================================
; Author ........: Valik
; Modified.......:
; ===============================================================================================================================
Func _Singleton($sOccurrenceName, $iFlag = 0)
	Local Const $ERROR_ALREADY_EXISTS = 183
	Local Const $SECURITY_DESCRIPTOR_REVISION = 1
	Local $tSecurityAttributes = 0

	If BitAND($iFlag, 2) Then
		; The size of SECURITY_DESCRIPTOR is 20 bytes.  We just
		; need a block of memory the right size, we aren't going to
		; access any members directly so it's not important what
		; the members are, just that the total size is correct.
		Local $tSecurityDescriptor = DllStructCreate("byte;byte;word;ptr[4]")
		; Initialize the security descriptor.
		Local $aCall = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", _
				"struct*", $tSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
		If @error Then Return SetError(@error, @extended, 0)
		If $aCall[0] Then
			; Add the NULL DACL specifying access to everybody.
			$aCall = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", _
					"struct*", $tSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
			If @error Then Return SetError(@error, @extended, 0)
			If $aCall[0] Then
				; Create a SECURITY_ATTRIBUTES structure.
				$tSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
				; Assign the members.
				DllStructSetData($tSecurityAttributes, 1, DllStructGetSize($tSecurityAttributes))
				DllStructSetData($tSecurityAttributes, 2, DllStructGetPtr($tSecurityDescriptor))
				DllStructSetData($tSecurityAttributes, 3, 0)
			EndIf
		EndIf
	EndIf

	Local $aHandle = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $tSecurityAttributes, "bool", 1, "wstr", $sOccurrenceName)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aLastError = DllCall("kernel32.dll", "dword", "GetLastError")
	If @error Then Return SetError(@error, @extended, 0)
	If $aLastError[0] = $ERROR_ALREADY_EXISTS Then
		If BitAND($iFlag, 1) Then
			DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $aHandle[0])
			If @error Then Return SetError(@error, @extended, 0)
			Return SetError($aLastError[0], $aLastError[0], 0)
		Else
			Exit -1
		EndIf
	EndIf
	Return $aHandle[0]
EndFunc   ;==>_Singleton
