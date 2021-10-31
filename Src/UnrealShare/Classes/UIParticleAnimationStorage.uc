//================================================================
// class: ParticleAnimationStorage
// file: ParticleAnimationStorage.uc
// author: Raven
// www: http://turniej.unreal.pl/rp
// description:
// stores info about animations
//================================================================
/*
    usage:
    just make a subclass and create a preset. Then in ParticleEmitter fill ParticleTemplate(group)->ParticleAnimation(structure)->ParticleAnimationStorage
*/
class UIParticleAnimationStorage extends UIParticleSystem abstract;

var() texture ParticleAnimation[60];   //animation (textures)
var() int NumOfTextures;               //number of textures
