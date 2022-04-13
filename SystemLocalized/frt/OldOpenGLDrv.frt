[Public]
Object=(Name=OldOpenGLDrv.OpenGLRenderDevice,Class=Class,MetaClass=Engine.RenderDevice,Autodetect=opengl32.dll)
Preferences=(Caption="OldOpenGL Support",Parent="Rendering",Class=OldOpenGLDrv.OpenGLRenderDevice,Immediate=True)

[OpenGLRenderDevice]
; EN: ClassCaption="OldOpenGL Support"
ClassCaption="Support OldOpenGL"
; EN: AskInstalled="Do you have a OldOpenGL compatible 3D accelerator installed?"
AskInstalled="Votre carte graphique supporte-t-elle le mode OldOpenGL?"
; EN: AskUse="Do you want Unreal to use your OldOpenGL accelerator?"
AskUse="Souhaitez-vous qu'Unreal utilise votre carte OldOpenGL?"

[Errors]
; EN: NoFindGL="Can't find OldOpenGL driver %ls"
NoFindGL="Impossible de trouver le driver OldOpenGL suivant: %ls"
; EN: MissingFunc="Missing OldOpenGL function %ls (%i)"
MissingFunc="Fonction OldOpenGL Manquante: %ls (%i)"
; EN: ResFailed="Failed to set resolution"
ResFailed="Impossible de changer la résolution"
