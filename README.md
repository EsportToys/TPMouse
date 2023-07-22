# TPMouse
Control the cursor with your hand staying on the keyboard's homerow, even if you don't have a ThinkPad. 

Inspired by [rvaiya/warpd](https://github.com/rvaiya/warpd).

## Inertia Mode
![image](https://user-images.githubusercontent.com/98432183/197381484-b4e669f0-c5bd-42af-a469-f21f5191a6a3.png)


1. To activate, press `CapsLk` `C` or `LShift` `RShift` `C`. You'll see your main cursor switched to a crosshair.
2. Press `I`/`J`/`K`/`L` to move the cursor. Hold `S` to brake for more precise movement, hold `Space` to scroll vertically/horizontally.
3. Press `F`/`E`/`R` to left/right/middle click at the cursor position.
4. To quit, press `CapsLk` `Q` or `LShift` `RShift` `Q` or just `Esc`.


## Grid Mode
![image](https://user-images.githubusercontent.com/98432183/197323322-09607efb-c940-4add-95e8-660c94c18306.png)

1. To activate, press `CapsLk` `G` or `LShift` `RShift` `G`. You'll see your main cursor switched to a crosshair, and a thin red border surrounding your screen.
2. Press `I`/`J`/`K`/`L` to narrow down the search border.
3. Press `F`/`E`/`R` to left/right/middle click at the cursor position.
4. To quit, press `CapsLk` `Q` or `LShift` `RShift` `Q` or just `Esc`.


## Demonstration

### Inertia Mode

https://user-images.githubusercontent.com/98432183/198895264-45823df6-8e8e-4135-9e7d-4ea9c5408c43.mp4



### Grid Mode

https://user-images.githubusercontent.com/98432183/198895269-4a5b7266-f662-491c-810e-5a2d87ddfc47.mp4

## Configuration

Edit the `options.ini` file to modify the inertia parameters or keybinds. If not present, the script uses the following defaults:

```
[Inertia]
DampingCoef=6
BrakingCoef=60
NormalSensitivity=1
ScrollSensitivity=1

[Bindings]
up=VK_I
left=VK_J
down=VK_K
right=VK_L
mb1=VK_F
mb2=VK_E
mb3=VK_R
brake=VK_S
scroll=VK_SPACE
```

The keybinds will require the script to be restarted to take effect, whereas the inertia parameters are reloaded upon activation of Inertia Mode.
