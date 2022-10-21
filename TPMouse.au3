#OnAutoItStartRegister SetProcessDPIAware
_Singleton('TPMouse',0)
Opt('GUICloseOnESC',False)
Opt('TrayMenuMode',3)
Opt('TrayOnEventMode',1)
TrayItemSetOnEvent(TrayCreateItem('Quit TPMouse'),Quit)
TraySetIcon('%windir%\Cursors\aero_link_xl.cur')
TraySetToolTip('TPMouse - Inactive')
Global $user32 = DllOpen('user32.dll')     
Global $hInputWnd = GUICreate('')
Global $hCursors = [CopyIcon(GetSystemCursor('NORMAL')),CopyIcon(GetSystemCursor('CROSS')),CopyIcon(GetSystemCursor('SIZEALL'))]
GUIRegisterMsg(0x00ff,WM_INPUT)
SetRawinput($hInputWnd, True)
SingletonOverlay('init')
SingletonInertia('init')
OnAutoItExitRegister(Cleanup)
ProgramLoop()

Func Quit()
     Exit
EndFunc

Func ProgramLoop()
     While 1
        If SingletonInertia('sim') Then 
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
     If $struct.VKey>0 and $struct.VKey<256 Then SingletonKeyState($struct.VKey,$struct.MakeCode,$struct.Flags)
     Switch $struct.VKey
       Case 0x1B ; esc
            If BitAnd(0x0001,$struct.Flags) Then 
               SingletonOverlay('deactivate')
               SingletonInertia('deactivate')
               DllCall($user32, "bool", "SetSystemCursor", "handle", CopyIcon($hCursors[0]), "dword", 32512)
               TraySetIcon("%windir%\Cursors\aero_link_xl.cur")
               TraySetToolTip('TPMouse - Inactive')
            EndIf
       Case 0x47 ; G
            If BitAnd(0x0001,$struct.Flags) Then
               If SingletonKeyState(0xA0) And SingletonKeyState(0xA1) Then ; LShift RShift G
                  If SingletonInertia() Then SingletonInertia('deactivate')
                  SingletonOverlay('activate')
                  DllCall($user32, "bool", "SetSystemCursor", "handle", CopyIcon($hCursors[2]), "dword", 32512)
                  TraySetIcon("%windir%\Cursors\aero_pin_xl.cur")
                  TraySetToolTip('TPMouse - Grid')
               EndIf
            EndIf
       Case 0x43 ; C
            If BitAnd(0x0001,$struct.Flags) Then
               If SingletonKeyState(0xA0) And SingletonKeyState(0xA1) Then ; LShift RShift C
                  If SingletonOverlay() Then SingletonOverlay('deactivate')
                  SingletonInertia('activate')
                  DllCall($user32, "bool", "SetSystemCursor", "handle", CopyIcon($hCursors[1]), "dword", 32512)
                  TraySetIcon("%windir%\Cursors\aero_person_xl.cur")
                  TraySetToolTip('TPMouse - Inertia')
               EndIf
            EndIf
       Case 0x49 ; I
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('I')
       Case 0x4A ; J
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('J')
       Case 0x4B ; K
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('K')
       Case 0x4C ; L
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('L')
       Case 0x46 ; F
            SingletonMoupress('mb1',Not BitAnd(0x0001,$struct.Flags))
       Case 0x45 ; E
            SingletonMoupress('mb2',Not BitAnd(0x0001,$struct.Flags))
       Case 0x52 ; R
            SingletonMoupress('mb3',Not BitAnd(0x0001,$struct.Flags))
       Case 0x10 ; shift
            If BitAnd(1,$struct.Flags) Then SingletonInertia('clip',15)
       Case 0x14 ; caps
            SingletonInertia('lock',Not BitAnd(0x0001,$struct.Flags))
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
                 EnableHotKeys()
                 .active = True
            Case 'deactivate'
                 .active = False
                 DisableHotKeys()
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
          EndSwitch
          Return .active
     EndWith
EndFunc

Func SingletonInertia($msg=null,$arg=null)
     Local Static $lastTime = TimerInit(), $self = DllStructCreate('bool active;bool lock;bool up;bool down;bool left;bool right;bool brake;float rx;float ry;float vx;float vy;float vmax;float mu')
     With $self
          Switch $msg
            Case 'reset'
                 .up = False
                 .down = False
                 .left = False
                 .right = False
                 .brake = False
                 .lock = False
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
            Case 'lock'
                 If .active Then
                    If .lock <> $arg Then 
                       .lock=$arg
                       SingletonInertia('clip',15)
                    EndIf
                 EndIf
            Case 'clip'
                 If .active Then
                    If BitAnd(1,$arg) Then .vx=(.vx>0?.vx:0)
                    If BitAnd(2,$arg) Then .vx=(.vx<0?.vx:0)
                    If BitAnd(4,$arg) Then .vy=(.vy>0?.vy:0)
                    If BitAnd(8,$arg) Then .vy=(.vy<0?.vy:0)
                 EndIf
            Case 'sim'
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
                    If (Round($dx)<>0 Or Round($dy)<>0) Then (.lock ? ScrollMouseXY(Round($dx),Round(-$dy)) : MoveMouseRel(Round($dx),Round($dy)) )
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
            Case Else
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
                 SingletonOverlay('reset')
                 If .active Then
                    .active = False
                    SingletonMoupress('deactivate')
                    GUISetState(@SW_HIDE,$hOverlay)
                 EndIf
            Case 'I'
                 If .active Then
                    .bottom = Int((.top+.bottom)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    SetCursorPos( Int((.left+.right)/2), Int((.top+.bottom)/2) )
                 EndIf
            Case 'J'
                 If .active Then
                    .right  = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    SetCursorPos( Int((.left+.right)/2), Int((.top+.bottom)/2) )
                 EndIf
            Case 'K'
                 If .active Then
                    .top    = Int((.top+.bottom)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
                    SetCursorPos( Int((.left+.right)/2), Int((.top+.bottom)/2) )
                 EndIf
            Case 'L'
                 If .active Then
                    .left   = Int((.left+.right)/2)
                    GUICtrlSetPos($hFrame,.left,.top,.right-.left,.bottom-.top)
		    SetCursorPos(Int((.left+.right)/2), Int((.top+.bottom)/2))
                 EndIf
            Case Else
          EndSwitch
          Return .active
     EndWith
EndFunc

Func SingletonKeyState($vKey=Null, $make=Null, $flag=Null)
     Local Static $self[256] ; vkey range from 0 to 255
     Local $change = Not ( ($flag=Null) or ($make=Null) )
     Local $after = Not BitAnd(1,$flag)
     Switch $vKey
       Case 0x10 ; shift
            If $change Then $self[($make=0x36?0xA1:0xA0)]=$after      ; (vkey,e0,mk) of lshift is (0xA0,0x00,0x2A), of rshift is (0xA1,0x00,0x36)
            Return ( $self[0xA0] or $self[0xA1] )
       Case 0x11 ; ctrl
            If $change Then $self[(BitAnd(2,$flag)?0xA3:0xA2)]=$after ; (vkey,e0,mk) of lctrl  is (0xA2,0x00,0x1D), of rctrl  is (0xA3,0xE0,0x1D)
            Return ( $self[0xA2] or $self[0xA3] )
       Case 0x12 ; alt
            If $change Then $self[(BitAnd(2,$flag)?0xA5:0xA4)]=$after ; (vkey,e0,mk) of lalt   is (0xA4,0x00,0x38), of ralt   is (0xA5,0xE0,0x38)
            Return ( $self[0xA4] or $self[0xA5] )
       Case Else
         If $vKey Then
            If $change Then $self[$vKey]=$after
            Return $self[$vKey]
         ElseIf $vKey=Null Then
            $self = []
            ReDim $self[256]
            Return False
         EndIf
     EndSwitch
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

Func ScrollMouseXY($dx,$dy)
     Local Static $size = DllStructGetSize(DllStructCreate("dword type;struct;long dx;long dy;dword mouseData;dword dwFlags;dword time;ulong_ptr dwExtraInfo;endstruct;"))
     Local Static $arr = DllStructCreate("dword type1;struct;long dx1;long dy1;dword mouseData1;dword dwFlags1;dword time1;ulong_ptr dwExtraInfo1;endstruct;" & _
                                         "dword type2;struct;long dx2;long dy2;dword mouseData2;dword dwFlags2;dword time2;ulong_ptr dwExtraInfo2;endstruct;" )
     $arr.dwFlags1=0x1000
     $arr.dwFlags2=0x0800
     $arr.mouseData1=$dx
     $arr.mouseData2=$dy
     DllCall($user32,"uint","SendInput","uint",2,"struct*",DllStructGetPtr($arr),"int",$size)
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
     Local $aCall = DllCall($user32,"handle","LoadCursor","handle",Null,"int",$id)
     Return $aCall[0]
EndFunc

Func CopyIcon($handle)
     Local $aCall = DllCall($user32,"handle","CopyIcon","handle",$handle)
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

Func EnableHotKeys()
     HotKeySet('i',i)
     HotKeySet('j',j)
     HotKeySet('k',k)
     HotKeySet('l',l)
     HotKeySet('f',f)
     HotKeySet('e',e)
     HotKeySet('r',r)
     HotKeySet('+i',i)
     HotKeySet('+j',j)
     HotKeySet('+k',k)
     HotKeySet('+l',l)
     HotKeySet('+f',f)
     HotKeySet('+e',e)
     HotKeySet('+r',r)
EndFunc
Func DisableHotKeys()
     HotKeySet('i')
     HotKeySet('j')
     HotKeySet('k')
     HotKeySet('l')
     HotKeySet('f')
     HotKeySet('e')
     HotKeySet('r')
     HotKeySet('+i')
     HotKeySet('+j')
     HotKeySet('+k')
     HotKeySet('+l')
     HotKeySet('+f')
     HotKeySet('+e')
     HotKeySet('+r')
EndFunc
func i()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x49
     ProcessKeypress($struct)
endfunc
func j()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x4A
     ProcessKeypress($struct)
endfunc
func k()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x4B
     ProcessKeypress($struct)
endfunc
func l()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x4C
     ProcessKeypress($struct)
endfunc
func f()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x46
     ProcessKeypress($struct)
endfunc
func e()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x45
     ProcessKeypress($struct)
endfunc
func r()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x52
     ProcessKeypress($struct)
endfunc
