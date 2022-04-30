[Public]
Object=(Name=OldOpenGLDrv.OpenGLRenderDevice,Class=Class,MetaClass=Engine.RenderDevice,Autodetect=opengl32.dll)
Preferences=(Caption="OldOpenGL Support",Parent="Rendering",Class=OldOpenGLDrv.OpenGLRenderDevice,Immediate=True)

[OpenGLRenderDevice]
; EN: ClassCaption="OldOpenGL Support"
ClassCaption="Obsługa OldOpenGL"
; EN: AskInstalled="Do you have a OldOpenGL compatible 3D accelerator installed?"
AskInstalled="Czy na komputerze znajduje się karta zgodna ze standardem OldOpenGL?"
; EN: AskUse="Do you want Unreal to use your OldOpenGL accelerator?"
AskUse="Włączyć obsługę kart zgodnych ze standardem OldOpenGL?"

[Errors]
; EN: NoFindGL="Can't find OldOpenGL driver %ls"
NoFindGL="Nie znaleziono sterownika OldOpenGL %ls"
; EN: MissingFunc="Missing OldOpenGL function %ls (%i)"
MissingFunc="Niedostępna funkcja OldOpenGL %ls (%i)"
; EN: ResFailed="Failed to set resolution"
ResFailed="Nie udało się wyświetlić rozdzielczości"
