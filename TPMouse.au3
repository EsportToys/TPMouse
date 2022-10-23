#OnAutoItStartRegister SetProcessDPIAware
#include 'keybinds.au3'
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
     $struct.Target = $hWnd
     $struct.Flags = $enable ? 0x00000100 : 0x00000001
     $struct.UsagePage = 0x01 ; generic desktop
     $struct.Usage = 0x06 ; keyboard
     DllCall($user32, 'bool', 'RegisterRawInputDevices', 'struct*', $struct, 'uint', 1, 'uint', DllStructGetSize($struct))
EndFunc

Func ProcessKeypress($struct)
     Local Static $_ = SingletonKeybinds, $sks=SingletonKeyState
     If $struct.VKey>0 and $struct.VKey<256 Then SingletonKeyState($struct.VKey,$struct.MakeCode,$struct.Flags)
     Switch $struct.VKey
       Case 0x1B, 0x14 ; esc or caps
            If BitAnd(0x0001,$struct.Flags) Then 
               If 0x14 = $struct.VKey And Not ($sks(0xA0) And $sks(0xA1)) Then return
               SingletonOverlay('deactivate')
               SingletonInertia('deactivate')
               DllCall($user32, "bool", "SetSystemCursor", "handle", CopyIcon($hCursors[0]), "dword", 32512)
               TraySetIcon("%windir%\Cursors\aero_link_xl.cur")
               TraySetToolTip('TPMouse - Inactive')
            EndIf
       Case 0x47 ; G
            If BitAnd(0x0001,$struct.Flags) Then
               If $sks(0x14) Or ($sks(0xA0) And $sks(0xA1)) Then ; CapsLk+G or LShift+RShift+G
                  If SingletonInertia() Then SingletonInertia('deactivate')
                  SingletonOverlay('activate')
                  DllCall($user32, "bool", "SetSystemCursor", "handle", CopyIcon($hCursors[2]), "dword", 32512)
                  TraySetIcon("%windir%\Cursors\aero_pin_xl.cur")
                  TraySetToolTip('TPMouse - Grid')
               EndIf
            EndIf
       Case 0x43 ; C
            If BitAnd(0x0001,$struct.Flags) Then
               If $sks(0x14) Or ($sks(0xA0) And $sks(0xA1)) Then ; CapsLk+C or LShift+RShift+C
                  If SingletonOverlay() Then SingletonOverlay('deactivate')
                  SingletonInertia('activate')
                  DllCall($user32, "bool", "SetSystemCursor", "handle", CopyIcon($hCursors[1]), "dword", 32512)
                  TraySetIcon("%windir%\Cursors\aero_person_xl.cur")
                  TraySetToolTip('TPMouse - Inertia')
               EndIf
            EndIf
       Case $_('up')
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('up')
       Case $_('left')
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('left')
       Case $_('down')
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('down')
       Case $_('right')
            If BitAnd(0x0001,$struct.Flags) Then SingletonOverlay('right')
       Case $_('mb1')
            SingletonMoupress('mb1',Not BitAnd(0x0001,$struct.Flags))
       Case $_('mb2')
            SingletonMoupress('mb2',Not BitAnd(0x0001,$struct.Flags))
       Case $_('mb3')
            SingletonMoupress('mb3',Not BitAnd(0x0001,$struct.Flags))
       Case $_('brake')
            If BitAnd(1,$struct.Flags) Then SingletonInertia('clip',15)
       Case $_('scroll')
            SingletonInertia('lock',Not BitAnd(0x0001,$struct.Flags))
     EndSwitch
EndFunc

Func SingletonMoupress($msg=null,$arg=null)
     Local Static $self = DllStructCreate('bool active;bool mb1;bool mb2;bool mb3;bool mb4;bool mb5')
     Switch $msg
       Case 'reset'
            If $self.mb1 Then ClickMouse(1,False)
            If $self.mb2 Then ClickMouse(2,False)
            If $self.mb3 Then ClickMouse(3,False)
            If $self.mb4 Then ClickMouse(4,False)
            If $self.mb5 Then ClickMouse(5,False)
            $self.mb1 = False
            $self.mb2 = False
            $self.mb3 = False
            $self.mb4 = False
            $self.mb5 = False
       Case 'activate'
            SingletonMoupress('reset')
            EnableHotKeys()
            $self.active = True
       Case 'deactivate'
            $self.active = False
            DisableHotKeys()
            SingletonMoupress('reset')
       Case 'mb1'
            If $self.active Then
               If Not( $arg = $self.mb1 ) Then ClickMouse(1,$arg)
               $self.mb1 = $arg
            EndIf
       Case 'mb2'
            If $self.active Then
               If Not( $arg = $self.mb2 ) Then ClickMouse(2,$arg)
               $self.mb2 = $arg
            EndIf
       Case 'mb3'
            If $self.active Then
               If Not( $arg = $self.mb3 ) Then ClickMouse(3,$arg)
               $self.mb3 = $arg
            EndIf
       Case 'mb4'
            If $self.active Then
               If Not( $arg = $self.mb4 ) Then ClickMouse(4,$arg)
               $self.mb4 = $arg
            EndIf
       Case 'mb5'
            If $self.active Then
               If Not( $arg = $self.mb5 ) Then ClickMouse(5,$arg)
               $self.mb5 = $arg
            EndIf
     EndSwitch
     Return $self.active
EndFunc

Func SingletonInertia($msg=null,$arg=null)
     Local Static $_=SingletonKeybinds, $sks=SingletonKeyState
     Local Static $lastTime = TimerInit(), $self = DllStructCreate('bool active;bool lock;bool up;bool down;bool left;bool right;bool brake;float rx;float ry;float vx;float vy;float vmax;float mu')
     Switch $msg
       Case 'reset'
            $self.up = False
            $self.down = False
            $self.left = False
            $self.right = False
            $self.brake = False
            $self.lock = False
            $self.vx = 0
            $self.vy = 0
            $self.vmax = 3200 ; ct/s, equals to a0/mu
            $self.mu = 6 ; s^-1
       Case 'activate'
            SingletonMoupress('activate')
            SingletonInertia('reset')
            $self.active = True
            $lastTime = TimerInit()
       Case 'deactivate'
            $self.active = False
            SingletonInertia('reset')
            SingletonMoupress('deactivate')
       Case 'lock'
            If $self.active Then
               If $self.lock <> $arg Then 
                  $self.lock=$arg
                  SingletonInertia('clip',15)
               EndIf
            EndIf
       Case 'clip'
            If $self.active Then
               If BitAnd(1,$arg) Then $self.vx=($self.vx>0?$self.vx:0)
               If BitAnd(2,$arg) Then $self.vx=($self.vx<0?$self.vx:0)
               If BitAnd(4,$arg) Then $self.vy=($self.vy>0?$self.vy:0)
               If BitAnd(8,$arg) Then $self.vy=($self.vy<0?$self.vy:0)
            EndIf
       Case 'sim'
            If $self.active Then
               Local $dt = TimerDiff($lastTime)/1000
               $lastTime = TimerInit()
               Local $mu = ( $self.brake ? $self.mu*10: $self.mu )
               Local $f0 = ( $mu = 0 ? 1     : exp(-$mu*$dt) )
               Local $f1 = ( $mu = 0 ? $dt   : (1-$f0)/$mu   )
               Local $f2 = ( $mu = 0 ? $dt^2 : ($dt-$f1)/$mu )
               Local $ax = ($self.left?-1:0)+($self.right?1:0), $ay = ($self.up?-1:0)+($self.down?1:0)
               Local $a0 = ( $ax*$ax+$ay*$ay ? $self.vmax*$self.mu/sqrt($ax*$ax+$ay*$ay) : 0 )
               Local $dx = $f2*$a0*$ax + $f1*$self.vx + $self.rx, $dy = $f2*$a0*$ay + $f1*$self.vy + $self.ry
               Local $vx = $f1*$a0*$ax + $f0*$self.vx           , $vy = $f1*$a0*$ay + $f0*$self.vy
               If (Round($dx)<>0 Or Round($dy)<>0) Then ($self.lock ? ScrollMouseXY(Round($dx),Round(-$dy)) : MoveMouseRel(Round($dx),Round($dy)) )
               $self.rx = $dx-Round($dx)
               $self.ry = $dy-Round($dy)
               $self.vx = ($vx*$vx+$vy*$vy<1?0:$vx)
               $self.vy = ($vx*$vx+$vy*$vy<1?0:$vy)
               $self.up    = $sks($_('up'))
               $self.left  = $sks($_('left'))
               $self.down  = $sks($_('down'))
               $self.right = $sks($_('right'))
               $self.brake = $sks($_('brake'))
               Local $cur=GetCursorPos()
               SingletonInertia('clip', 1*($cur.x=0) + 2*($cur.x=@DesktopWidth-1) + 4*($cur.y=0) + 8*($cur.y=@DesktopHeight-1))
            EndIf
       Case Else
     EndSwitch
     Return $self.active
EndFunc

Func SingletonOverlay($msg=null,$arg=null)
     Local Static $hOverlay, $hFrame, $self = DllStructCreate('bool active;uint left;uint right;uint top;uint bottom')
     Switch $msg
       Case 'init'
             $hOverlay = GUICreate("Overlay",@DesktopWidth,@DesktopHeight,0,0,0x80000000,0x02080088)
             $hFrame = GUICtrlCreateButton("",0,0,@DesktopWidth,@DesktopHeight)
             GUISetBkColor(0xe1e1e1,$hOverlay)
             DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $hOverlay, "INT", 0x00e1e1e1, "byte", 255, "dword", 0x03)
             GUISetState(@SW_DISABLE)
       Case 'reset'
            $self.left = 0
            $self.top = 0
            $self.right = @DesktopWidth
            $self.bottom = @DesktopHeight
            GUICtrlSetPos($hFrame,$self.left,$self.top,$self.right-$self.left,$self.bottom-$self.top)
       Case 'activate'
            SingletonOverlay('reset')
            If Not $self.active Then
               $self.active = True
               GUISetState(@SW_SHOW,$hOverlay)
               GUISetState(@SW_RESTORE,$hOverlay)
               SetCursorPos(Int(($self.left+$self.right)/2),Int(($self.top+$self.bottom)/2))
               SingletonMoupress('activate')
            EndIf
       Case 'deactivate'
            SingletonOverlay('reset')
            If $self.active Then
               $self.active = False
               SingletonMoupress('deactivate')
               GUISetState(@SW_HIDE,$hOverlay)
            EndIf
       Case 'up'
            If $self.active Then
               $self.bottom = Int(($self.top+$self.bottom)/2)
               GUICtrlSetPos($hFrame,$self.left,$self.top,$self.right-$self.left,$self.bottom-$self.top)
               SetCursorPos( Int(($self.left+$self.right)/2), Int(($self.top+$self.bottom)/2) )
            EndIf
       Case 'left'
            If $self.active Then
               $self.right  = Int(($self.left+$self.right)/2)
               GUICtrlSetPos($hFrame,$self.left,$self.top,$self.right-$self.left,$self.bottom-$self.top)
               SetCursorPos( Int(($self.left+$self.right)/2), Int(($self.top+$self.bottom)/2) )
            EndIf
       Case 'down'
            If $self.active Then
               $self.top    = Int(($self.top+$self.bottom)/2)
               GUICtrlSetPos($hFrame,$self.left,$self.top,$self.right-$self.left,$self.bottom-$self.top)
               SetCursorPos( Int(($self.left+$self.right)/2), Int(($self.top+$self.bottom)/2) )
            EndIf
       Case 'right'
            If $self.active Then
               $self.left   = Int(($self.left+$self.right)/2)
               GUICtrlSetPos($hFrame,$self.left,$self.top,$self.right-$self.left,$self.bottom-$self.top)
               SetCursorPos(Int(($self.left+$self.right)/2), Int(($self.top+$self.bottom)/2))
            EndIf
       Case Else
     EndSwitch
     Return $self.active
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
     DllCall($user32, 'uint', 'GetRawInputData', 'handle', $lParam, 'uint', 0x10000003, 'struct*', $struct, 'uint*', $size, 'uint', $sizeHeader)
     ProcessKeypress($struct)
     If $wParam Then Return 0
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
     DllCall($user32,"uint","SendInput","uint",1,"struct*",$struct,"int",DllStructGetSize($struct))
EndFunc

Func MoveMouseRel($dx,$dy)
     Local $struct = DllStructCreate("dword type;struct;long dx;long dy;dword mouseData;dword dwFlags;dword time;ulong_ptr dwExtraInfo;endstruct;")
     $struct.dwFlags=0x0001
     $struct.dx=$dx
     $struct.dy=$dy
     $struct.type=0
     DllCall($user32,"uint","SendInput","uint",1,"struct*",$struct,"int",DllStructGetSize($struct))
EndFunc

Func ScrollMouseXY($dx,$dy)
     Local Static $SIZE = DllStructGetSize(DllStructCreate('dword;struct;long;long;dword;dword;dword;ulong_ptr;endstruct;'))
     Local $count = ($dx?1:0)+($dy?1:0)
     Local $struct, $arr = DllStructCreate('byte[' & $count*$SIZE & ']'), $ptr = DllStructGetPtr($arr)
     If $dx Then
        $struct = DllStructCreate('dword type;struct;long;long;dword data;dword flag;dword;ulong_ptr;endstruct;', $ptr)
        DllStructSetData($struct,'type',0)
        DllStructSetData($struct,'flag',0x1000)
        DllStructSetData($struct,'data',$dx)
     EndIf
     If $dy Then
        $struct = DllStructCreate('dword type;struct;long;long;dword data;dword flag;dword;ulong_ptr;endstruct;', $ptr+($dx?$SIZE:0))
        DllStructSetData($struct,'type',0)
        DllStructSetData($struct,'flag',0x0800)
        DllStructSetData($struct,'data',$dy)
     EndIf
     Local $aCall = DllCall( $user32, 'uint', 'SendInput', 'uint', $count, 'struct*', $ptr, 'int', $SIZE )
    Return $aCall[0]
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
     DllCall($user32,"bool","GetCursorPos","struct*",$struct)
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
