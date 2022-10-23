Func SingletonKeybinds($action, $mode=0)
     ; mode 0 returns vkey, mode 1 returns hotkey, mode 2 returns function
     Local Static _
           $up     = [ 0x49 , '{i}'     , callback_i     ] , _
           $left   = [ 0x4A , '{j}'     , callback_j     ] , _
           $down   = [ 0x4B , '{k}'     , callback_k     ] , _
           $right  = [ 0x4C , '{l}'     , callback_l     ] , _
           $mb1    = [ 0x46 , '{f}'     , callback_f     ] , _
           $mb2    = [ 0x45 , '{e}'     , callback_e     ] , _
           $mb3    = [ 0x52 , '{r}'     , callback_r     ] , _
           $brake  = [ 0x53 , '{s}'     , callback_s     ] , _
           $scroll = [ 0x20 , '{space}' , callback_space ]
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
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',0x49)
     ProcessKeypress($struct)
EndFunc
Func callback_j()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',0x4A)
     ProcessKeypress($struct)
EndFunc
Func callback_k()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',0x4B)
     ProcessKeypress($struct)
EndFunc
Func callback_l()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',0x4C)
     ProcessKeypress($struct)
EndFunc
Func callback_f()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',0x46)
     ProcessKeypress($struct)
EndFunc
Func callback_e()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',0x45)
     ProcessKeypress($struct)
EndFunc
Func callback_r()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',0x52)
     ProcessKeypress($struct)
EndFunc
Func callback_s()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',0x53)
     ProcessKeypress($struct)
EndFunc
Func callback_space()
     Local Static $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;'), $vkey = DllStructSetData($struct,'VKey',0x20)
     ProcessKeypress($struct)
EndFunc
