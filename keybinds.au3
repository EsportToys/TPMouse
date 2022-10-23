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
Func SingletonKeybinds($action, $mode=0)
     ; mode 0 returns vkey, mode 1 returns hotkey, mode 2 returns function
     Switch $action
       Case 'up'
            If $mode Then 
               Return ( $mode=1 ? '{i}' : callback_i )
            Else 
               Return 0x49
            EndIf
       Case 'left'
            If $mode Then 
               Return ( $mode=1 ? '{j}' : callback_j )
            Else 
               Return 0x4A
            EndIf
       Case 'down'
            If $mode Then 
               Return ( $mode=1 ? '{k}' : callback_k )
            Else 
               Return 0x4B
            EndIf
       Case 'right'
            If $mode Then 
               Return ( $mode=1 ? '{l}' : callback_l )
            Else 
               Return 0x4C
            EndIf
       Case 'mb1'
            If $mode Then 
               Return ( $mode=1 ? '{f}' : callback_f )
            Else 
               Return 0x46
            EndIf
       Case 'mb2'
            If $mode Then 
               Return ( $mode=1 ? '{e}' : callback_e )
            Else 
               Return 0x45
            EndIf
       Case 'mb3'
            If $mode Then 
               Return ( $mode=1 ? '{r}' : callback_r )
            Else 
               Return 0x52
            EndIf
       Case 'brake'
            If $mode Then 
               Return ( $mode=1 ? '{s}' : callback_s )
            Else 
               Return 0x53
            EndIf
       Case 'scroll'
            If $mode Then 
               Return ( $mode=1 ? '{space}' : callback_space )
            Else 
               Return 0x20
            EndIf
     EndSwitch
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
