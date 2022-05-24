
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(AXParticleForces);
IMPLEMENT_CLASS(AKillParticleForce);
IMPLEMENT_CLASS(AParticleConcentrateForce);
IMPLEMENT_CLASS(AVelocityForce);

/* 227: Render forces info */
void AXParticleForces::RenderSelectInfo( FSceneNode* Frame )
{
	if( bUseBoxForcePosition )
		Frame->Level->Engine->Render->DrawBox(Frame,FPlane(0,0,0.8,1),0,Location+EffectingBox.Min,Location+EffectingBox.Max);
	else Frame->Level->Engine->Render->DrawCircle(Frame,FPlane(0,0,0.8,1),0,Location,EffectingRadius*0.265,1);
}

// First check if this force should handle this actor.
bool AXParticleForces::UpdateForceOn( AActor* PartActor, const float& LifeTimeScale )
{
	if( bUseBoxForcePosition )
	{
		FVector M=EffectingBox.Min+Location;
		FVector X=EffectingBox.Max+Location;
		FVector* AL=&PartActor->Location;
		return (AL->X>M.X && AL->Y>M.Y && AL->Z>M.Z && AL->X<X.X && AL->Y<X.Y && AL->Z<X.Z
		 && LifeTimeScale>EffectPartLifeTime.Min && LifeTimeScale<EffectPartLifeTime.Max );
	}
	return ((PartActor->Location-Location).SizeSquared()<Square(EffectingRadius));
}

void AVelocityForce::HandleForce(xParticle* A, FLOAT Delta)
{
	if( bChangeAcceleration )
	{
		if( bInstantChange )
			A->Acceleration = VelocityToAdd;
		else A->Acceleration+=VelocityToAdd*Delta;
	}
	else if( bInstantChange )
		A->Velocity = VelocityToAdd;
	else A->Velocity+=VelocityToAdd*Delta;
}

void AKillParticleForce::HandleForce(xParticle* A, FLOAT Delta)
{
	A->LifeTime-=(LifeTimeDrainAmount*Delta);
}

void AParticleConcentrateForce::HandleForce(xParticle* A, FLOAT Delta)
{
	FVector Dir = (Location + CenterPointOffset - A->Location);
	if( bSetsAcceleration )
	{
		if( bActorDistanceSuckIn )
			A->Acceleration+=Dir*(1.f-Clamp(Dir.Size()/MaxDistance,0.f,1.f))*DrainSpeed*Delta;
		else
		{
			Dir.Normalize();
			A->Acceleration+=Dir*DrainSpeed*Delta;
		}
	}
	else if( bActorDistanceSuckIn )
		A->Velocity+=Dir*(1.f-Clamp(Dir.Size()/MaxDistance,0.f,1.f))*DrainSpeed*Delta;
	else
	{
		Dir.Normalize();
		A->Velocity+=Dir*DrainSpeed*Delta;
	}
}

void AXParticleForces::Modify()
{
	Super::Modify();
	if( !GIsEditor || OldTagName==Tag )
		return;
	guard(AXParticleForces::Modify);
	OldTagName = Tag;
	INT i,j;
	for( TActorIterator<AXEmitter> It(XLevel); It; ++It )
	{
		AXEmitter* EM = *It;
		if( EM->IsPendingKill() )
			continue;
		bool bFoundIt=false;
		if( Tag!=NAME_None )
		{
			for( j=0; j<4; j++ )
			{
				if( EM->ForcesTags[j]==Tag )
				{
					bFoundIt = true;
					break;
				}
			}
		}
		j = EM->ForcesList.Num();
		if( bFoundIt )
		{
			bool bResult=false;
			for( i=0; i<j; i++ )
			{
				if( EM->ForcesList(i)==this )
				{
					bResult = true;
					break;
				}
				else if( !EM->ForcesList(i) )
				{
					EM->ForcesList.Remove(i);
					i--;
					j--;
				}
			}
			if( bResult )
				continue;
			EM->ForcesList.AddItem(this);
		}
		else
		{
			for( i=0; i<j; i++ )
			{
				if( !EM->ForcesList(i) || EM->ForcesList(i)==this )
				{
					EM->ForcesList.Remove(i);
					i--;
					j--;
				}
			}
		}
	}
	unguard;
}

void AXParticleForces::PostScriptDestroyed()
{
	if( GIsEditor ) /* Make sure we NULL out any emitter forces to this actor */
	{
		guard(AXParticleForces::PostScriptDestroyed);
		INT i,j;
		for (TActorIterator<AXEmitter> It(XLevel); It; ++It)
		{
			AXEmitter* EM = *It;
			if( EM->IsPendingKill() )
				continue;
			j = EM->ForcesList.Num();
			for( i=0; i<j; i++ )
			{
				if( !EM->ForcesList(i) || EM->ForcesList(i)==this )
				{
					EM->ForcesList.Remove(i--);
					j--;
				}
			}
		}
		unguard;
	}
	Super::PostScriptDestroyed();
}
