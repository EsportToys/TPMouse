#include 'vkeys.au3'

Global $HOTKEY_STR_MAP

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
