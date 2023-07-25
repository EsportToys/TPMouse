#NoTrayIcon
#OnAutoItStartRegister SetProcessDPIAware
#include 'singleton.au3'
#include 'vkeys.au3'
If IsAdmin() Then Sleep(100)
_Singleton('TPMouse',0)

Global $HOTKEY_STR_MAP

Opt('TrayAutoPause',0)
Opt('TrayOnEventMode',1)
Opt('GUIOnEventMode',1)
Opt('TrayMenuMode',1+2)
If Not IsAdmin() Then TrayItemSetOnEvent(TrayCreateItem('Restart as admin'),Elevate)
TrayItemSetOnEvent(TrayCreateItem('Reload config'),ReloadKeybinds)
TrayItemSetOnEvent(TrayCreateItem('Quit TPMouse'),Quit)
TraySetIcon('%windir%\Cursors\aero_link_xl.cur')
TraySetToolTip('TPMouse - Inactive')
Global $user32 = DllOpen('user32.dll')     
Global $hInputWnd = GUICreate('')
GUISetOnEvent(-3,Quit)
Global $hCursors = [CopyIcon(GetSystemCursor('NORMAL')),CopyIcon(GetSystemCursor('CROSS')),CopyIcon(GetSystemCursor('SIZEALL'))]
GUIRegisterMsg(0x00ff,WM_INPUT)
GUIRegisterMsg(0x0400,ReloadKeybinds)
SetRawinput($hInputWnd, True)
SingletonOverlay('init')
SingletonInertia('init')
OnAutoItExitRegister(Cleanup)
ProgramLoop()

Func Elevate()
     ShellExecute( @AutoItExe , @Compiled ? '' : @ScriptFullPath , '' , 'runas' )
     Exit
EndFunc

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

Func ReloadKeybinds()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     Local Static $_1 = DllStructSetData($struct,'VKey',$VK_ESC)
     Local Static $_2 = DllStructSetData($struct,'Flags',1)
     ProcessKeypress($struct)
     SingletonKeybinds('reload')
EndFunc

Func ProcessKeypress($struct)
     Local Static $_ = SingletonKeybinds, $sks=SingletonKeyState, $functionlist = [SingletonInertia,SingletonOverlay]
     Local Static $shiftprimed = False, $capsprimed = False
     If 0<$struct.VKey and $struct.VKey<255 Then SingletonKeyState($struct.VKey,$struct.MakeCode,$struct.Flags)
     Switch $struct.VKey
       Case $VK_SHIFT ; only set priming here because user might still press other keys before releasing
            If BitAnd(0x0001,$struct.Flags) Then 
               If $shiftprimed Then
                  HotKeySet('+{c}')
                  HotKeySet('+{g}')
                  HotKeySet('+{q}')
               EndIf
               $shiftprimed = False
            ElseIf (Not $shiftprimed) And ($sks($VK_LSHIFT) And $sks($VK_RSHIFT)) Then
               HotKeySet('+{c}',UnsetSelf)
               HotKeySet('+{g}',UnsetSelf)
               HotKeySet('+{q}',UnsetSelf)
               $shiftprimed = True
            EndIf
       Case $VK_CAPS ; only set priming here because user might still press other keys before releasing
            If BitAnd(0x0001,$struct.Flags) Then 
               If $capsprimed Then
                  HotKeySet('{c}')
                  HotKeySet('{g}')
                  HotKeySet('{q}')
               EndIf
               $capsprimed = False
            ElseIf Not $capsprimed Then
               HotKeySet('{c}',UnsetSelf)
               HotKeySet('{g}',UnsetSelf)
               HotKeySet('{q}',UnsetSelf)
               $capsprimed = True
            EndIf
       Case $VK_ESC, $VK_Q
            If BitAnd(0x0001,$struct.Flags) Then 
               If $VK_Q = $struct.VKey And Not ( $sks($VK_CAPS) Or ($sks($VK_LSHIFT) And $sks($VK_RSHIFT)) ) Then Return
               For $func in $functionlist
                   If $func() Then $func('deactivate')
               Next
               DllCall($user32, "bool", "SetSystemCursor", "handle", CopyIcon($hCursors[0]), "dword", 32512)
               TraySetIcon("%windir%\Cursors\aero_link_xl.cur")
               TraySetToolTip('TPMouse - Inactive')
            EndIf
       Case $VK_C, $VK_G
            If BitAnd(0x0001,$struct.Flags) Then
               If $sks($VK_CAPS) Or ($sks($VK_LSHIFT) And $sks($VK_RSHIFT)) Then
                  Local $act = ( $VK_C=$struct.VKey ? SingletonInertia       : SingletonOverlay )       , _
                        $ico = ( $VK_C=$struct.VKey ? 'aero_person_xl.cur'   : 'aero_pin_xl.cur' )      , _
                        $cur = ( $VK_C=$struct.VKey ? CopyIcon($hCursors[1]) : CopyIcon($hCursors[2]) ) , _
                        $tip = ( $VK_C=$struct.VKey ? 'TPMouse - Inertia'    : 'TPMouse - Grid')
                  For $func in $functionlist
                      If $func() and not ($func=$act) Then $func('deactivate')
                  Next
                  $act('activate')
                  DllCall($user32, "bool", "SetSystemCursor", "handle", $cur, "dword", 32512)
                  TraySetIcon('%windir%\Cursors\' & $ico)
                  TraySetToolTip($tip)
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
     Local Static $lastTime = TimerInit()
     Local Static $self = DllStructCreate( 'bool active;' & _
                                           'bool lock;' & _
                                           'bool up;' & _ 
                                           'bool down;' & _
                                           'bool left;' & _
                                           'bool right;' & _
                                           'bool brake;' & _
                                           'float rx;' & _
                                           'float ry;' & _
                                           'float vx;' & _
                                           'float vy;' & _
                                           'float a0;' & _
                                           'float mu;' & _
                                           'float br;' & _
                                           'float dm;' & _
                                           'float ds;' )
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
            $self.a0 = 3200*6 ; top speed is 3200 ct/s when damping is 6 and sens is 1
            Local $damp = IniRead('options.ini','Inertia','DampingCoef',6)
            Local $brak = IniRead('options.ini','Inertia','BrakingCoef',60)
            Local $norm = IniRead('options.ini','Inertia','NormalSensitivity',1)
            Local $scro = IniRead('options.ini','Inertia','ScrollSensitivity',1)
            $self.mu = ( 0 <= $damp ? $damp : 6  )
            $self.br = ( 0 <= $brak ? $brak : 60 )
            $self.dm = ( 0 <  $norm ? $norm : 1  )
            $self.ds = ( 0 <  $scro ? $scro : 1  )
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
               Local $ds = ( $self.lock  ? $self.ds : $self.dm )
               Local $mu = ( $self.brake ? $self.br : $self.mu )
               Local $f0 = ( $mu = 0 ? 1     : exp(-$mu*$dt) )
               Local $f1 = ( $mu = 0 ? $dt   : (1-$f0)/$mu   )
               Local $f2 = ( $mu = 0 ? $dt^2 : ($dt-$f1)/$mu )
               Local $ax = ($self.left?-1:0)+($self.right?1:0), $ay = ($self.up?-1:0)+($self.down?1:0)
               Local $a0 = ( $ax*$ax+$ay*$ay ? $self.a0/sqrt($ax*$ax+$ay*$ay) : 0 )
               Local $dx = $f2*$a0*$ax + $f1*$self.vx, $dy = $f2*$a0*$ay + $f1*$self.vy
               Local $vx = $f1*$a0*$ax + $f0*$self.vx, $vy = $f1*$a0*$ay + $f0*$self.vy
               $dx = $dx*$ds + $self.rx
               $dy = $dy*$ds + $self.ry
               If (Round($dx)<>0 Or Round($dy)<>0) Then ($self.lock ? ScrollMouseXY(Round($dx),Round(-$dy)) : MoveMouseRel(Round($dx),Round($dy)) )
               $self.rx = $dx-Round($dx)
               $self.ry = $dy-Round($dy)
               $self.vx = ( 0=$a0 And 1/$ds>$vx*$vx+$vy*$vy ) ? 0 : $vx
               $self.vy = ( 0=$a0 And 1/$ds>$vx*$vx+$vy*$vy ) ? 0 : $vy
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
             $hFrame = GUICtrlCreateGraphic(0,0,@DesktopWidth,@DesktopHeight)
             GUISetBkColor(0xe1e1e1,$hOverlay)   ; sets window color
             GUICtrlSetColor($hFrame,0xff0000)   ; sets border color
             GUICtrlSetBkColor($hFrame,0xe1e1e1) ; sets canvas color
             DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $hOverlay, "INT", 0x00e1e1e1, "byte", 255, "dword", 0x03)
             GUISetState(@SW_DISABLE)
       Case 'set'
            GUICtrlSetPos($hFrame,$self.left,$self.top,$self.right-$self.left,$self.bottom-$self.top)
       Case 'reset'
            $self.left = 0
            $self.top = 0
            $self.right = @DesktopWidth
            $self.bottom = @DesktopHeight
            SingletonOverlay('set')
       Case 'activate'
            SingletonOverlay('reset')
            If Not $self.active Then
               $self.active = True
               GUISetState(@SW_SHOW,$hOverlay)
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
               SingletonOverlay('set')
               SetCursorPos( Int(($self.left+$self.right)/2), Int(($self.top+$self.bottom)/2) )
            EndIf
       Case 'left'
            If $self.active Then
               $self.right  = Int(($self.left+$self.right)/2)
               SingletonOverlay('set')
               SetCursorPos( Int(($self.left+$self.right)/2), Int(($self.top+$self.bottom)/2) )
            EndIf
       Case 'down'
            If $self.active Then
               $self.top    = Int(($self.top+$self.bottom)/2)
               SingletonOverlay('set')
               SetCursorPos( Int(($self.left+$self.right)/2), Int(($self.top+$self.bottom)/2) )
            EndIf
       Case 'right'
            If $self.active Then
               $self.left   = Int(($self.left+$self.right)/2)
               SingletonOverlay('set')
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
       Case $VK_SHIFT
            If $change Then $self[ ( $make = 0x36    ? $VK_RSHIFT : $VK_LSHIFT )] = $after ; (vkey,e0,mk) of lshift is (0xA0,0x00,0x2A), of rshift is (0xA1,0x00,0x36)
            Return ( $self[$VK_LSHIFT] or $self[$VK_RSHIFT] )
       Case $VK_CTRL
            If $change Then $self[ ( BitAnd(2,$flag) ? $VK_RCTRL  : $VK_LCTRL)  ] = $after ; (vkey,e0,mk) of lctrl  is (0xA2,0x00,0x1D), of rctrl  is (0xA3,0xE0,0x1D)
            Return ( $self[$VK_LCTRL] or $self[$VK_RCTRL] )
       Case $VK_ALT
            If $change Then $self[ ( BitAnd(2,$flag) ? $VK_RALT   : $VK_LALT)   ] = $after ; (vkey,e0,mk) of lalt   is (0xA4,0x00,0x38), of ralt   is (0xA5,0xE0,0x38)
            Return ( $self[$VK_LALT] or $self[$VK_RALT] )
       Case $VK_NONE, $VK_CANCEL, $VK_PRTSCN ; keys that don't deactivate normally
            Return False
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
     If $dy Then
        $struct = DllStructCreate('dword type;struct;long;long;dword data;dword flag;dword;ulong_ptr;endstruct;', $ptr)
        DllStructSetData($struct,'type',0)
        DllStructSetData($struct,'flag',0x0800)
        DllStructSetData($struct,'data',$dy)
     EndIf
     If $dx Then
        $struct = DllStructCreate('dword type;struct;long;long;dword data;dword flag;dword;ulong_ptr;endstruct;', $ptr+($dy?$SIZE:0))
        DllStructSetData($struct,'type',0)
        DllStructSetData($struct,'flag',0x1000)
        DllStructSetData($struct,'data',$dx)
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

Func UnsetSelf()
     HotKeySet(@HotKeyPressed)
EndFunc


#Region keybinds


Func SingletonKeybinds($action, $mode=0)
     ; mode 0 returns vkey, mode 1 returns hotkey
     Local Static _
           $up     = [ $VK_I     , '{i}'     ] , _
           $left   = [ $VK_J     , '{j}'     ] , _
           $down   = [ $VK_K     , '{k}'     ] , _
           $right  = [ $VK_L     , '{l}'     ] , _
           $mb1    = [ $VK_F     , '{f}'     ] , _
           $mb2    = [ $VK_E     , '{e}'     ] , _
           $mb3    = [ $VK_R     , '{r}'     ] , _
           $brake  = [ $VK_S     , '{s}'     ] , _
           $scroll = [ $VK_SPACE , '{space}' ]
     Local Static $map = InitializeKeybinds($up,$left,$down,$right,$mb1,$mb2,$mb3,$brake,$scroll)
     Local $i = $mode ? 1 : 0
     Switch $action
       Case 'up'
            Return $up[$i]
       Case 'left'
            Return $left[$i]
       Case 'down'
            Return $down[$i]
       Case 'right'
            Return $right[$i]
       Case 'mb1'
            Return $mb1[$i]
       Case 'mb2'
            Return $mb2[$i]
       Case 'mb3'
            Return $mb3[$i]
       Case 'brake'
            Return $brake[$i]
       Case 'scroll'
            Return $scroll[$i]
       Case 'reload'
            $map = InitializeKeybinds($up,$left,$down,$right,$mb1,$mb2,$mb3,$brake,$scroll)
     EndSwitch
EndFunc
Func EnableHotKeys()
     Local Static $_ = SingletonKeybinds, $arr = ['up','left','down','right','mb1','mb2','mb3','brake','scroll']
     For $cmd in $arr
         HotKeySet( $_($cmd,1) , TranslateHotKeys )
     Next
EndFunc
Func DisableHotKeys()
     Local Static $_ = SingletonKeybinds, $arr = ['up','left','down','right','mb1','mb2','mb3','brake','scroll']
     For $cmd in $arr
         HotKeySet( $_($cmd,1) )
     Next
EndFunc
Func TranslateHotKeys()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     Local $vk = $HOTKEY_STR_MAP[@HotKeyPressed]
     If 0<$vk and $vk<255 Then
        $struct.VKey = $vk
        ProcessKeypress($struct)
     EndIf
EndFunc
Func InitializeKeybinds(ByRef $up,ByRef $left,ByRef $down,ByRef $right,ByRef $mb1,ByRef $mb2,ByRef $mb3,ByRef $brake,ByRef $scroll)
     Local $upKey     = IniRead('options.ini','Bindings','up'    , 'VK_I')
     Local $leftKey   = IniRead('options.ini','Bindings','left'  , 'VK_J')
     Local $downKey   = IniRead('options.ini','Bindings','down'  , 'VK_K')
     Local $rightKey  = IniRead('options.ini','Bindings','right' , 'VK_L')
     Local $mb1Key    = IniRead('options.ini','Bindings','mb1'   , 'VK_F')
     Local $mb2Key    = IniRead('options.ini','Bindings','mb2'   , 'VK_E')
     Local $mb3Key    = IniRead('options.ini','Bindings','mb3'   , 'VK_R')
     Local $brakeKey  = IniRead('options.ini','Bindings','brake' , 'VK_S')
     Local $scrollKey = IniRead('options.ini','Bindings','scroll', 'VK_SPACE')
     $up[0]     = Eval($upKey)
     $left[0]   = Eval($leftKey)
     $down[0]   = Eval($downKey)
     $right[0]  = Eval($rightKey)
     $mb1[0]    = Eval($mb1Key)
     $mb2[0]    = Eval($mb2Key)
     $mb3[0]    = Eval($mb3Key)
     $brake[0]  = Eval($brakeKey)
     $scroll[0] = Eval($scrollKey)
     $up[1]     = '{' & StringLower(StringReplace($upKey,'VK_','')) & '}'
     $left[1]   = '{' & StringLower(StringReplace($leftKey,'VK_','')) & '}'
     $down[1]   = '{' & StringLower(StringReplace($downKey,'VK_','')) & '}'
     $right[1]  = '{' & StringLower(StringReplace($rightKey,'VK_','')) & '}'
     $mb1[1]    = '{' & StringLower(StringReplace($mb1Key,'VK_','')) & '}'
     $mb2[1]    = '{' & StringLower(StringReplace($mb2Key,'VK_','')) & '}'
     $mb3[1]    = '{' & StringLower(StringReplace($mb3Key,'VK_','')) & '}'
     $brake[1]  = '{' & StringLower(StringReplace($brakeKey,'VK_','')) & '}'
     $scroll[1] = '{' & StringLower(StringReplace($scrollKey,'VK_','')) & '}'
     Local $map[]
     $map[$up[1]]=$up[0]
     $map[$left[1]]=$left[0]
     $map[$down[1]]=$down[0]
     $map[$right[1]]=$right[0]
     $map[$mb1[1]]=$mb1[0]
     $map[$mb2[1]]=$mb2[0]
     $map[$mb3[1]]=$mb3[0]
     $map[$brake[1]]=$brake[0]
     $map[$scroll[1]]=$scroll[0]
     $HOTKEY_STR_MAP = $map
     Return $map
EndFunc

#EndRegion
