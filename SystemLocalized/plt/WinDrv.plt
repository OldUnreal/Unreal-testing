[Public]
Class=(Class=WinDrv.WindowsClient,SuperClass=Engine.Client,Compat="Win32,Win64")
Preferences=(Caption="Windows",Parent="Display",Class=WinDrv.WindowsClient,Immediate=True,Category=Display)
Preferences=(Caption="Windows",Parent="Joystick",Class=WinDrv.WindowsClient,Immediate=True,Category=Joystick)

[Errors]
; EN: Failed3D="3D hardware initialization failed"
Failed3D="Inicjalizacja sprzętu 3D nieudana"
; EN: DDrawMode="DirectDraw was unable to set the requested video mode."
DDrawMode="Nie udało się ustawić wybranego trybu wyświetlania DirectDraw."

[General]
; EN: ViewPersp="Perspective map"
ViewPersp="Perspektywa"
; EN: ViewXY="Overhead map"
ViewXY="Widok z góry"
; EN: ViewXZ="XZ map"
ViewXZ="Widok X-Z"
; EN: ViewYZ="YZ map"
ViewYZ="Widok Y-Z"
; EN: ViewOther="Viewport"
ViewOther="Okno"
; EN: Color16="&16-bit color"
Color16="&16 bity"
; EN: Color32="&32-bit color"
Color32="&32 bity"
; EN: AdvancedOptions="Advanced Options"
AdvancedOptions="Opcje zaawansowane"

[WindowsClient]
; EN: ClassCaption="Standard Windows Manager"
ClassCaption="Domyślna obsługa Windows"
