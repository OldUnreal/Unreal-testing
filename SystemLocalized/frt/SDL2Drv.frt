[Public]
Class=(Class=SDL2Drv.SDL2Client,SuperClass=Engine.Client,Compat="Lin32,Lin64,LinARM")
Preferences=(Caption="SDL2",Parent="Display",Class=SDL2Drv.SDL2Client,Immediate=True,Category=Display)
Preferences=(Caption="SDL2",Parent="Joystick",Class=SDL2Drv.SDL2Client,Immediate=True,Category=Joystick)

[Errors]
; EN: Failed3D="3D hardware initialization failed"
Failed3D="Echec d'initialisation de la fenêtre 3D"

[General]
; EN: ViewPersp="Perspective map"
ViewPersp="Carte en perspective"
; EN: ViewXY="Overhead map"
ViewXY="Carte aérienne"
; EN: ViewXZ="XZ map"
ViewXZ="Carte XZ"
; EN: ViewYZ="YZ map"
ViewYZ="Carte YZ"
; EN: ViewOther="Viewport"
ViewOther="Point de vue"
; EN: Color16="&16-bit color"
Color16="Couleurs &16 bits"
; EN: Color32="&32-bit color"
Color32="Couleurs &32 bits"
; EN: AdvancedOptions="Advanced Options"
AdvancedOptions="Options Avancées"

[SDL2Client]
; EN: ClassCaption="Standard SDL2 Linux Manager"
ClassCaption="Gestionnaire SDL2 Linux standard"
