[Public]
Object=(Name=OGLDrv.OpenGLRenderDevice,Class=Class,MetaClass=Engine.RenderDevice,Autodetect=opengl32.dll)
Preferences=(Caption="OGLDrv Support",Parent="Rendering",Class=OGLDrv.OpenGLRenderDevice,Immediate=True)

[OpenGLRenderDevice]
; EN: ClassCaption="OGLDrv Support"
ClassCaption="Support OGLDrv"
; EN: AskInstalled="Do you have a OGLDrv compatible 3D accelerator installed?"
AskInstalled="Votre carte graphique supporte-t-elle le mode OGLDrv?"
; EN: AskUse="Do you want Unreal to use your OGLDrv accelerator?"
AskUse="Souhaitez-vous qu'Unreal utilise votre carte OGLDrv?"

[Errors]
; EN: NoFindGL="Can't find OGLDrv driver %ls"
NoFindGL="Impossible de trouver le driver OGLDrv suivant: %ls"
; EN: MissingFunc="Missing OGLDrv function %ls (%i)"
MissingFunc="Fonction OGLDrv Manquante: %ls (%i)"
; EN: ResFailed="Failed to set resolution"
ResFailed="Impossible de changer la résolution"
