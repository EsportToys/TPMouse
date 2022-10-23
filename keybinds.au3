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
               Return ( $mode=1 ? '{i}' : i )
            Else 
               Return 0x49
            EndIf
       Case 'left'
            If $mode Then 
               Return ( $mode=1 ? '{j}' : j )
            Else 
               Return 0x4A
            EndIf
       Case 'down'
            If $mode Then 
               Return ( $mode=1 ? '{k}' : k )
            Else 
               Return 0x4B
            EndIf
       Case 'right'
            If $mode Then 
               Return ( $mode=1 ? '{l}' : l )
            Else 
               Return 0x4C
            EndIf
       Case 'mb1'
            If $mode Then 
               Return ( $mode=1 ? '{f}' : f )
            Else 
               Return 0x46
            EndIf
       Case 'mb2'
            If $mode Then 
               Return ( $mode=1 ? '{e}' : e )
            Else 
               Return 0x45
            EndIf
       Case 'mb3'
            If $mode Then 
               Return ( $mode=1 ? '{r}' : r )
            Else 
               Return 0x52
            EndIf
       Case 'brake'
            If $mode Then 
               Return ( $mode=1 ? '{s}' : s )
            Else 
               Return 0x53
            EndIf
       Case 'scroll'
            If $mode Then 
               Return ( $mode=1 ? '{space}' : space )
            Else 
               Return 0x20
            EndIf
     EndSwitch
EndFunc
Func i()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x49
     ProcessKeypress($struct)
EndFunc
Func j()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x4A
     ProcessKeypress($struct)
EndFunc
Func k()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x4B
     ProcessKeypress($struct)
EndFunc
Func l()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x4C
     ProcessKeypress($struct)
EndFunc
Func f()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x46
     ProcessKeypress($struct)
EndFunc
Func e()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x45
     ProcessKeypress($struct)
EndFunc
Func r()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x52
     ProcessKeypress($struct)
EndFunc
Func s()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x53
     ProcessKeypress($struct)
EndFunc
Func space()
     Local $struct = DllStructCreate('ushort MakeCode;ushort Flags;ushort VKey;')
     $struct.Vkey = 0x20
     ProcessKeypress($struct)
EndFunc
