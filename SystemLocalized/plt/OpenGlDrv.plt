[Public]
Object=(Name=OpenGLDrv.OpenGLRenderDevice,Class=Class,MetaClass=Engine.RenderDevice,Autodetect=opengl32.dll)
Preferences=(Caption="OpenGL Support",Parent="Rendering",Class=OpenGLDrv.OpenGLRenderDevice,Immediate=True)

[Errors]
; EN: NoFindGL="Can't find OpenGL driver %ls"
NoFindGL="Nie znaleziono sterownika OpenGL %ls"
; EN: MissingFunc="Missing OpenGL function %ls (%i)"
MissingFunc="Niedostępna funkcja OpenGL %ls (%i)"
; EN: ResFailed="Failed to set resolution"
ResFailed="Nie udało się wyświetlić rozdzielczości."

[OpenGLRenderDevice]
; EN: ClassCaption="OpenGL Support"
ClassCaption="Obsługa OpenGL"
; EN: AskInstalled="Do you have a OpenGL compatible 3D accelerator installed?"
AskInstalled="Czy na komputerze znajduje się karta zgodna ze standardem OpenGL?"
; EN: AskUse="Do you want Unreal to use your OpenGL accelerator?"
AskUse="Włączyć obsługę kart zgodnych ze standardem OpenGL?"
