#OnAutoItStartRegister SetProcessDPIAware
_Singleton("ShittyWarpd",0)
Opt('GUICloseOnESC',False)
Global $user32 = DllOpen("user32.dll")     
Global $hInputWnd = GUICreate("")
Global $hCursors = [CopyIcon(GetSystemCursor("NORMAL")),CopyIcon(GetSystemCursor("CROSS"))]
GUIRegisterMsg(0x00ff,WM_INPUT)
SetRawinput($hInputWnd, True)
SingletonOverlay('init')
SingletonInertia('init')
OnAutoItExitRegister(Cleanup)
ProgramLoop()

Func ProgramLoop()
     While 1
        If SingletonInertia() Then 
           Sleep(10)
        Else
           Sleep(100)
        EndIf
     WEnd
EndFunc

Func Cleanup()
     DllCall( $user32 , "bool","SetSystemCursor" , "handle",$hCursors[0], "dword",32512 )
     DllClose($user32)
EndFunc

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

Func ProcessKeypress($struct)
     If $struct.VKey>0 and $struct.VKey<256 Then SingletonKeyState($struct.VKey,BitAnd(0x0001,$struct.Flags)?-1:1)
     Switch $struct.VKey
       Case 0x1B ; esc
            If BitAnd(0x0001,$struct.Flags) Then 
               SingletonOverlay('deactivate')
               SingletonInertia('deactivate')
               DllCall( "user32.dll" , "bool","SetSystemCursor" , "handle",CopyIcon($hCursors[0]) , "dword",32512 )
            EndIf
       Case 0x47 ; G
            If BitAnd(0x0001,$struct.Flags) Then ; on keyup so I don't need to check repeat
               If SingletonKeyState(0x12) And SingletonKeyState(0x10) Then ; alt shift g
                  SingletonInertia('deactivate')
                  SingletonOverlay('activate')
                  DllCall( "user32.dll" , "bool","SetSystemCursor" , "handle",CopyIcon($hCursors[1]) , "dword",32512 )
               EndIf
            EndIf
       Case 0x43 ; C
            If BitAnd(0x0001,$struct.Flags) Then ; on keyup so I don't need to check repeat
               If SingletonKeyState(0x12) And SingletonKeyState(0x10) Then ; alt shift c
                  SingletonOverlay('deactivate')
                  SingletonInertia('activate')
                  DllCall( "user32.dll" , "bool","SetSystemCursor" , "handle",CopyIcon($hCursors[1]) , "dword",32512 )
               EndIf
            EndIf
       Case 0x55 ; U
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('U')
       Case 0x49 ; I
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('I')
       Case 0x4A ; J
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('J')
       Case 0x4B ; K
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('K')
       Case 0x4D ; M
            SingletonMoupress('mb1',Not BitAnd(0x0001,$struct.Flags))
       Case 0xBC ; comma
            SingletonMoupress('mb3',Not BitAnd(0x0001,$struct.Flags))
       Case 0xBE ; period
            SingletonMoupress('mb2',Not BitAnd(0x0001,$struct.Flags))
       Case 0x10 ; shift
           If BitAnd(0x0001,$struct.Flags) Then SingletonInertia('reset')
     EndSwitch
EndFunc

Func SingletonMoupress($msg=null,$arg=null)
     Local Static $self = DllStructCreate('bool active;bool mb1;bool mb2;bool mb3;bool mb4;bool mb5')
     With $self
          Switch $msg
            Case 'reset'
                 If .mb1 Then ClickMouse(1,False)
                 If .mb2 Then ClickMouse(2,False)
                 If .mb3 Then ClickMouse(3,False)
                 If .mb4 Then ClickMouse(4,False)
                 If .mb5 Then ClickMouse(5,False)
                 .mb1 = False
                 .mb2 = False
                 .mb3 = False
                 .mb4 = False
                 .mb5 = False
            Case 'activate'
                 SingletonMoupress('reset')
                 .active = True
            Case 'deactivate'
                 .active = False
                 SingletonMoupress('reset')
            Case 'mb1'
                 If .active Then
                    If Not( $arg = .mb1 ) Then ClickMouse(1,$arg)
                    .mb1 = $arg
                 EndIf
            Case 'mb2'
                 If .active Then
                    If Not( $arg = .mb2 ) Then ClickMouse(2,$arg)
                    .mb2 = $arg
                 EndIf
            Case 'mb3'
                 If .active Then
                    If Not( $arg = .mb3 ) Then ClickMouse(3,$arg)
                    .mb3 = $arg
                 EndIf
            Case 'mb4'
                 If .active Then
                    If Not( $arg = .mb4 ) Then ClickMouse(4,$arg)
                    .mb4 = $arg
                 EndIf
            Case 'mb5'
                 If .active Then
                    If Not( $arg = .mb5 ) Then ClickMouse(5,$arg)
                    .mb5 = $arg
                 EndIf
            Case 'vscroll'
                 If .active Then ScrollMouse($arg,False)
            Case 'hscroll'
                 If .active Then ScrollMouse($arg,True)
          EndSwitch
          Return .active
     EndWith
EndFunc

Func SingletonInertia($msg=null,$arg=null)
     Local Static $lastTime = TimerInit(), $self = DllStructCreate('bool active;bool up;bool down;bool left;bool right;bool brake;float rx;float ry;float vx;float vy;float vmax;float mu')
     With $self
          Switch $msg
            Case 'reset'
                 .up = False
                 .down = False
                 .left = False
                 .right = False
                 .brake = False
                 .vx = 0
                 .vy = 0
                 .vmax = 3200 ; ct/s, equals to a0/mu
                 .mu = 6 ; s^-1
            Case 'activate'
                 SingletonMoupress('activate')
                 SingletonInertia('reset')
                 .active = True
                 $lastTime = TimerInit()
            Case 'deactivate'
                 .active = False
                 SingletonInertia('reset')
                 SingletonMoupress('deactivate')
            Case 'clip'
                 If BitAnd(1,$arg) Then .vx=(.vx>0?.vx:0)
                 If BitAnd(2,$arg) Then .vx=(.vx<0?.vx:0)
                 If BitAnd(4,$arg) Then .vy=(.vy>0?.vy:0)
                 If BitAnd(8,$arg) Then .vy=(.vy<0?.vy:0)
            Case Else
                 If .active Then
                    Local $dt = TimerDiff($lastTime)/1000
                    $lastTime = TimerInit()
                    Local $mu = ( .brake  ? .mu*10: .mu           )
                    Local $f0 = ( $mu = 0 ? 1     : exp(-$mu*$dt) )
                    Local $f1 = ( $mu = 0 ? $dt   : (1-$f0)/$mu   )
                    Local $f2 = ( $mu = 0 ? $dt^2 : ($dt-$f1)/$mu )
                    Local $ax = (.left?-1:0)+(.right?1:0), $ay = (.up?-1:0)+(.down?1:0)
                    Local $a0 = ( $ax*$ax+$ay*$ay ? .vmax*.mu/sqrt($ax*$ax+$ay*$ay) : 0 )
                    Local $dx = $f2*$a0*$ax + $f1*.vx + .rx, $dy = $f2*$a0*$ay + $f1*.vy + .ry
                    Local $vx = $f1*$a0*$ax + $f0*.vx      , $vy = $f1*$a0*$ay + $f0*.vy
                    If (Round($dx)<>0 Or Round($dy)<>0) Then MoveMouseRel(Round($dx),Round($dy))
                    .rx = $dx-Round($dx)
                    .ry = $dy-Round($dy)
                    .vx = ($vx*$vx+$vy*$vy<1?0:$vx)
                    .vy = ($vx*$vx+$vy*$vy<1?0:$vy)
                    .up    = SingletonKeyState(0x49)
                    .left  = SingletonKeyState(0x4A)
                    .down  = SingletonKeyState(0x4B)
                    .right = SingletonKeyState(0x4C)
                    .brake = SingletonKeyState(0x10)
                    Local $cur=GetCursorPos()
                    SingletonInertia('clip', 1*($cur.x=0) + 2*($cur.x=@DesktopWidth-1) + 4*($cur.y=0) + 8*($cur.y=@DesktopHeight-1))
                 EndIf
          EndSwitch
          Return .active
     EndWith
EndFunc

Func SingletonOverlay($msg=null,$arg=null)
     Local Static $hOverlay, $hFrame, $self = DllStructCreate('bool active;uint left;uint right;uint top;uint bottom')
     With $self
          Switch $msg
            Case 'init'
                  $hOverlay = GUICreate("Overlay",@DesktopWidth,@DesktopHeight,0,0,0x80000000,0x02080088)
                  $hFrame = GUICtrlCreateButton("",0,0,@DesktopWidth,@DesktopHeight)
                  GUISetBkColor(0xe1e1e1,$hOverlay)
                  DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $hOverlay, "INT", 0x00e1e1e1, "byte", 255, "dword", 0x03)
                  GUISetState(@SW_DISABLE)
            Case 'reset'
                 .left = 0
                 .top = 0
                 .right = @DesktopWidth
                 .bottom = @DesktopHeight
                 GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
            Case 'activate'
                 SingletonOverlay('reset')
                 If Not .active Then
                    .active = True
                    GUISetState(@SW_SHOW,$hOverlay)
                    GUISetState(@SW_RESTORE,$hOverlay)
		    SetCursorPos(Int((.left+.right)/2),Int((.top+.bottom)/2))
                    SingletonMoupress('activate')
                 EndIf
            Case 'deactivate'
                 If Not .active Then Return .active
                 SingletonOverlay('reset')
                 .active = False
                 GUISetState(@SW_HIDE,$hOverlay)
            Case 'U'
                 If .active Then
                    .bottom = Int((.top+.bottom)/2)
                    .right  = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
		    SetCursorPos(Int((.left+.right)/2), Int((.top+.bottom)/2))
                 EndIf
            Case 'I'
                 If .active Then
                    .bottom = Int((.top+.bottom)/2)
                    .left   = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    SetCursorPos( Int((.left+.right)/2), Int((.top+.bottom)/2) )
                 EndIf
            Case 'J'
                 If .active Then
                    .top    = Int((.top+.bottom)/2)
                    .right  = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    SetCursorPos( Int((.left+.right)/2), Int((.top+.bottom)/2) )
                 EndIf
            Case 'K'
                 If .active Then
                    .top    = Int((.top+.bottom)/2)
                    .left   = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    SetCursorPos( Int((.left+.right)/2), Int((.top+.bottom)/2) )
                 EndIf
          EndSwitch
          Return .active
     EndWith
EndFunc

Func SingletonKeyState($vKey=Null, $change=0)
     Local Static $self[256]
     If $vKey Then
        Local $i = $vKey-1
        Local $after = ( $change>0 ? True : False ) 
        If $change Then $self[$i]=$after
        Return $self[$i]
     ElseIf $vKey=Null Then
        $self = []
        ReDim $self[256]
        Return False
     EndIf
EndFunc

Func WM_INPUT($hWnd, $iMsg, $wParam, $lParam)
     ; only registered for keyboard so no need to check header for device type
     Local Static $tagHeader = 'dword dwType;dword dwSize;handle hDevice;wparam wParam;'
     Local Static $tag = $tagHeader & 'ushort MakeCode;ushort Flags;ushort Reserved;ushort VKey;uint Message;ulong ExtraInformation'
     Local Static $sizeHeader = DllStructGetSize(DllStructCreate($tagHeader)), $size = DllStructGetSize(DllStructCreate($tag))
     Local $struct = DllStructCreate($tag)
     DllCall($user32, 'uint', 'GetRawInputData', 'handle', $lParam, 'uint', 0x10000003, 'struct*', DllStructGetPtr($struct), 'uint*', $size, 'uint', $sizeHeader)
     ProcessKeypress($struct)
     Return 0
EndFunc

Func ClickMouse($button, $state)
     Local $struct = DllStructCreate("dword type;struct;long dx;long dy;dword mouseData;dword dwFlags;dword time;ulong_ptr dwExtraInfo;endstruct;")
     Switch $button
       Case 1
            $struct.dwFlags=($state?0x0002:0x0004)
       Case 2
            $struct.dwFlags=($state?0x0008:0x0010)
       Case 3
            $struct.dwFlags=($state?0x0020:0x0040)
       Case 4
            $struct.dwFlags=($state?0x0080:0x0100)
            $struct.mouseData=1
       Case 5
            $struct.dwFlags=($state?0x0080:0x0100)
            $struct.mouseData=2
       Case Else
            Return
     EndSwitch
     $struct.type=0
     DllCall($user32,"uint","SendInput","uint",1,"struct*",DllStructGetPtr($struct),"int",DllStructGetSize($struct))
EndFunc

Func MoveMouseRel($dx,$dy)
     Local $struct = DllStructCreate("dword type;struct;long dx;long dy;dword mouseData;dword dwFlags;dword time;ulong_ptr dwExtraInfo;endstruct;")
     $struct.dwFlags=0x0001
     $struct.dx=$dx
     $struct.dy=$dy
     $struct.type=0
     DllCall($user32,"uint","SendInput","uint",1,"struct*",DllStructGetPtr($struct),"int",DllStructGetSize($struct))
EndFunc

Func ScrollMouse($steps,$hor=False)
     Local $struct = DllStructCreate("dword type;struct;long dx;long dy;dword mouseData;dword dwFlags;dword time;ulong_ptr dwExtraInfo;endstruct;")
     $struct.dwFlags=($hor?0x1000:0x0800)
     $struct.mouseData=Round($steps)
     $struct.type=0
     DllCall($user32,"uint","SendInput","uint",1,"struct*",DllStructGetPtr($struct),"int",DllStructGetSize($struct))
EndFunc

Func GetSystemCursor($name)
     Local $id
     Switch $name
       Case "ARROW", "NORMAL"
            $id=32512
       Case "IBEAM"
            $id=32513
       Case "WAIT"
            $id=32514
       Case "CROSS"
            $id=32515
       Case "UPARROW"
            $id=32516
       Case "SIZE" ; doesn't seem to work
            $id=32640
       Case "ICON" ; doesn't seem to work
            $id=32641
       Case "SIZENWSE"
            $id=32642
       Case "SIZENESW"
            $id=32643
       Case "SIZEWE"
            $id=32644
       Case "SIZENS"
            $id=32645
       Case "SIZEALL"
            $id=32646
       Case "NO"
            $id=32648
       Case "HAND"
            $id=32649
       Case "APPSTARTING"
            $id=32650
       Case "HELP"
            $id=32651
       Case Else
            Return Null
     EndSwitch
     Local $aCall = DllCall("user32.dll","handle","LoadCursor","handle",Null,"int",$id)
     Return $aCall[0]
EndFunc

Func CopyIcon($handle)
     Local $aCall = DllCall("user32.dll", "handle", "CopyIcon", "handle", $handle )
     Return $aCall[0]
EndFunc

Func GetCursorPos()
     Local $struct = DllStructCreate("long x;long y")
     DllCall($user32,"bool","GetCursorPos","struct*",DllStructGetPtr($struct))
     Return $struct
EndFunc

Func SetCursorPos($x,$y)
     DllCall($user32,"bool","SetCursorPos","int",$x,"int",$y)
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
