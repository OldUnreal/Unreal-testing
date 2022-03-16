﻿[Public]
Object=(Name=OpenGLDrv.OpenGLRenderDevice,Class=Class,MetaClass=Engine.RenderDevice,Autodetect=opengl32.dll)
; EN: Preferences=(Caption="OpenGL Support",Parent="Rendering",Class=OpenGLDrv.OpenGLRenderDevice,Immediate=True)
Preferences=(Caption="Support OpenGL",Parent="Rendu",Class=OpenGLDrv.OpenGLRenderDevice,Immediate=True)

[Errors]
; EN: NoFindGL="Can't find OpenGL driver %ls"
NoFindGL="Impossible de trouver le driver OpenGL suivant: %ls"
; EN: MissingFunc="Missing OpenGL function %ls (%i)"
MissingFunc="Fonction OpenGL Manquante: %ls (%i)"
; EN: ResFailed="Failed to set resolution"
ResFailed="Impossible de changer la résolution"

[OpenGLRenderDevice]
; EN: ClassCaption="OpenGL Support"
ClassCaption="Support OpenGL"
; EN: AskInstalled="Do you have a OpenGL compatible 3D accelerator installed?"
AskInstalled="Votre carte graphique supporte-t-elle le mode OpenGL?"
; EN: AskUse="Do you want Unreal to use your OpenGL accelerator?"
AskUse="Souhaitez-vous qu'Unreal utilise votre carte OpenGL?"
