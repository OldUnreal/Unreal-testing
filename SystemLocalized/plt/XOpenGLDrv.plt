[Public]
Object=(Name=XOpenGLDrv.XOpenGLRenderDevice,Class=Class,MetaClass=Engine.RenderDevice,Autodetect=opengl32.dll)
Preferences=(Caption="XOpenGL",Parent="Rendering",LangCaption="XOpenGL",Class=XOpenGLDrv.XOpenGLRenderDevice,Immediate=True,Category="Options")
Preferences=(Caption="Debug Options",Parent="XOpenGL",LangCaption="Opcje Rozwoju",Class=XOpenGLDrv.XOpenGLRenderDevice,Immediate=True,Category="DebugOptions")
Preferences=(Caption="Render Options",Parent="XOpenGL",LangCaption="Opcje Renderowania",Class=XOpenGLDrv.XOpenGLRenderDevice,Immediate=True,Category="Client")

[Errors]
; EN: NoFindGL="Can't find OpenGL driver %ls"
NoFindGL="Nie można znaleźć sterownika OpenGL %ls"
; EN: MissingFunc="Missing OpenGL function %ls (%i)"
MissingFunc="Nie znaleziono funkcji OpenGL %ls (%i)"
; EN: ResFailed="Failed to set resolution"
ResFailed="Nie udało się ustawić rozdzielczości"

[XOpenGLRenderDevice]
; EN: ClassCaption="XOpenGL"
ClassCaption="XOpenGL"
; EN: AskInstalled="Do you have a graphics card supporting at least OpenGL version 3.3 or greater installed?"
AskInstalled="Czy masz zainstalowaną kartę graficzną obsługującą co najmniej OpenGL w wersji 3.3 lub nowszej?"
; EN: AskUse="Do you want Unreal to use your XOpenGL accelerator?"
AskUse="Czy chcesz, aby Unreal używał twojego akceleratora XOpenGL?"
