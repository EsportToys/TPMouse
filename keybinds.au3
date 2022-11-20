#include 'vkeys.au3'

Func SingletonKeybinds($action, $mode=0)
     ; mode 0 returns vkey, mode 1 returns hotkey, mode 2 returns function
     Local Static _
           $up     = [ $VK_I     , '{i}'     , callback_i     ] , _
           $left   = [ $VK_J     , '{j}'     , callback_j     ] , _
           $down   = [ $VK_K     , '{k}'     , callback_k     ] , _
           $right  = [ $VK_L     , '{l}'     , callback_l     ] , _
           $mb1    = [ $VK_F     , '{f}'     , callback_f     ] , _
           $mb2    = [ $VK_E     , '{e}'     , callback_e     ] , _
           $mb3    = [ $VK_R     , '{r}'     , callback_r     ] , _
           $brake  = [ $VK_S     , '{s}'     , callback_s     ] , _
           $scroll = [ $VK_SPACE , '{space}' , callback_space ]
     Local $i = $mode ? ( $mode=1 ? 1 : 2 ) : 0
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
         HotKeySet(       $_($cmd,1) , $_($cmd,2) )
         HotKeySet( '+' & $_($cmd,1) , $_($cmd,2) )
     Next
EndFunc
Func DisableHotKeys()
     Local Static $_ = SingletonKeybinds, $arr = ['up','left','down','right','mb1','mb2','mb3','brake','scroll']
     For $cmd in $arr
         HotKeySet(       $_($cmd,1) )
         HotKeySet( '+' & $_($cmd,1) )
     Next
EndFunc
Func callback_i()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',$VK_I)
     ProcessKeypress($struct)
EndFunc
Func callback_j()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',$VK_J)
     ProcessKeypress($struct)
EndFunc
Func callback_k()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',$VK_K)
     ProcessKeypress($struct)
EndFunc
Func callback_l()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',$VK_L)
     ProcessKeypress($struct)
EndFunc
Func callback_f()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',$VK_F)
     ProcessKeypress($struct)
EndFunc
Func callback_e()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',$VK_E)
     ProcessKeypress($struct)
EndFunc
Func callback_r()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',$VK_R)
     ProcessKeypress($struct)
EndFunc
Func callback_s()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',$VK_S)
     ProcessKeypress($struct)
EndFunc
Func callback_space()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',$VK_SPACE)
     ProcessKeypress($struct)
EndFunc
