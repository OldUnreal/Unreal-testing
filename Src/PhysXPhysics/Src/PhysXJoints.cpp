
#include "PhysXPhysics.h"

FPhysXJoint::FPhysXJoint(PX_JointObject* Obj, physx::PxJoint* JO)
	: PX_JointBase(Obj), JointObj(JO), NextBroken(nullptr), bPendingBroken(FALSE)
{
	STAT(++GPhysXStats.JointObjCount.Count);
	JointObj->userData = this;
}
FPhysXJoint::~FPhysXJoint()
{
	guard(FPhysXJoint::~FPhysXJoint);
	STAT(--GPhysXStats.JointObjCount.Count);
	FINISH_PHYSX_THREAD;
	if (JointObj)
		JointObj->release();
	unguard;
}

void FPhysXJoint::NoteJointBroken()
{
	if (!bPendingBroken)
	{
		bPendingBroken = TRUE;
		NextBroken = FPhysXScene::BrokenJoints;
		FPhysXScene::BrokenJoints = this;
		GetOwnerObject()->OnJointBreak();
	}
}

void FPhysXJoint::UpdateCoords(const FCoords& A, const FCoords& B)
{
	guard(FPhysXJoint::UpdateCoords);
	if (JointObj)
	{
		FINISH_PHYSX_THREAD;
		JointObj->setLocalPose(physx::PxJointActorIndex::eACTOR0, UECoordsToPX(A));
		JointObj->setLocalPose(physx::PxJointActorIndex::eACTOR1, UECoordsToPX(B));
	}
	unguard;
}

#define GET_ACTORA(parms) reinterpret_cast<FPhysXActorBase*>(parms.Owner->GetActorA())
#define GET_ACTORB(parms) reinterpret_cast<FPhysXActorBase*>(parms.Owner->GetActorB())

static UBOOL GetBaseProperties(const FJointBaseProps& P, physx::PxRigidActor*& A, physx::PxRigidActor*& B, physx::PxTransform& TA, physx::PxTransform& TB)
{
	if (P.Owner->GetActorA()->GetType() != PX_PhysicsObject::RBTYPE_RigidBody && P.Owner->GetActorA()->GetType() != PX_PhysicsObject::RBTYPE_ArticulationLink)
	{
		GWarn->Logf(TEXT("Tried to create joint for a non-rigidbody actor (%ls)!"), P.Owner->GetActorA()->GetActor()->GetFullName());
		return FALSE;
	}
	A = GetRigidActor(P.Owner->GetActorA());
	B = GetRigidActor(P.Owner->GetActorB());

	TA = UECoordsToPX(*P.AxisA);
	TB = UECoordsToPX(*P.AxisB);
	return TRUE;
}

#define CONSTRUCT_JOINT(jntType) \
	new jntType(Props.Owner, J); \
	return TRUE;

UBOOL UPhysXPhysics::CreateJointFixed(const FJointBaseProps& Props)
{
	guard(UPhysXPhysics::CreateJointFixed);
	physx::PxRigidActor* A, * B;
	physx::PxTransform TA, TB;
	if (!GetBaseProperties(Props, A, B, TA, TB))
		return NULL;

	FINISH_PHYSX_THREAD;
	physx::PxFixedJoint* J = physx::PxFixedJointCreate(PxGetPhysics(), A, TA, B, TB);

	if (J)
	{
		J->setBreakForce((Props.MaxForce>=0.f) ? Props.MaxForce : PX_MAX_REAL, (Props.MaxTorque >= 0.f) ? Props.MaxTorque : PX_MAX_REAL);
		CONSTRUCT_JOINT(FPhysXJoint);
	}
	GWarn->Log(TEXT("CreateFixedJoint FAILED!"));
	return FALSE;
	unguard;
}
UBOOL UPhysXPhysics::CreateJointHinge(const FJointHingeProps& Props)
{
	guard(UPhysXPhysics::CreateJointHinge);
	physx::PxRigidActor* A, * B;
	physx::PxTransform TA, TB;
	if (!GetBaseProperties(Props, A, B, TA, TB))
		return NULL;

	FINISH_PHYSX_THREAD;
	physx::PxRevoluteJoint* J = physx::PxRevoluteJointCreate(PxGetPhysics(), A, TA, B, TB);

	if (J)
	{
		J->setBreakForce((Props.MaxForce >= 0.f) ? Props.MaxForce : PX_MAX_REAL, (Props.MaxTorque >= 0.f) ? Props.MaxTorque : PX_MAX_REAL);

		if (Props.bLimitMovement)
		{
			physx::PxJointAngularLimitPair Limit(0, 1);
			if (Props.bHardLimit)
				Limit = physx::PxJointAngularLimitPair(Props.LimitRangeLow * (PI / 180.f), Props.LimitRangeHigh * (PI / 180.f));
			else Limit = physx::PxJointAngularLimitPair(Props.LimitRangeLow * (PI / 180.f), Props.LimitRangeHigh * (PI / 180.f), physx::PxSpring(Props.LimitStiffness, Props.LimitDamping));

			if (!Limit.isValid())
				GWarn->Logf(TEXT("Couldn't set joint limit to hinge joint (%ls): Invalid limitation params!"), Props.Owner->GetActorA()->GetActor()->GetFullName());
			else
			{
				J->setRevoluteJointFlag(physx::PxRevoluteJointFlag::eLIMIT_ENABLED, true);
				J->setLimit(Limit);
			}
		}
		if (Props.bMotor)
		{
			J->setDriveForceLimit(Props.MotorMaxSpeed);
			J->setDriveVelocity(Props.MotorSpeed);
			J->setRevoluteJointFlag(physx::PxRevoluteJointFlag::eDRIVE_ENABLED, true);
			J->setRevoluteJointFlag(physx::PxRevoluteJointFlag::eDRIVE_FREESPIN, (Props.bMotorFreeDrive != 0));
		}
		CONSTRUCT_JOINT(FPhysXJoint);
	}
	GWarn->Log(TEXT("CreateJointHinge FAILED!"));
	return FALSE;
	unguard;
}
UBOOL UPhysXPhysics::CreateJointSocket(const FJointSocketProps& Props)
{
	guard(UPhysXPhysics::CreateJointSocket);
	physx::PxRigidActor* A, * B;
	physx::PxTransform TA, TB;
	if (!GetBaseProperties(Props, A, B, TA, TB))
		return NULL;

	FINISH_PHYSX_THREAD;
	physx::PxSphericalJoint* J = physx::PxSphericalJointCreate(PxGetPhysics(), A, TA, B, TB);

	if (J)
	{
		J->setBreakForce((Props.MaxForce >= 0.f) ? Props.MaxForce : PX_MAX_REAL, (Props.MaxTorque >= 0.f) ? Props.MaxTorque : PX_MAX_REAL);

		if (Props.bLimitMovement)
		{
			physx::PxJointLimitCone Limit(Props.MovementLimit.X * (PI / 180.f), Props.MovementLimit.Y * (PI / 180.f));

			if (!Limit.isValid())
				GWarn->Logf(TEXT("Couldn't set joint limit to socket joint (%ls): Invalid limitation params!"), Props.Owner->GetActorA()->GetActor()->GetFullName());
			else
			{
				J->setSphericalJointFlag(physx::PxSphericalJointFlag::eLIMIT_ENABLED, true);
				J->setLimitCone(Limit);
			}
		}
		//J->getConstraint()->setMinResponseThreshold(KINDA_SMALL_NUMBER);
		//J->getConstraint()->setFlag(physx::PxConstraintFlag::eDISABLE_PREPROCESSING, true);

		CONSTRUCT_JOINT(FPhysXJoint);
	}
	GWarn->Log(TEXT("CreateJointSocket FAILED!"));
	return FALSE;
	unguard;
}

struct FPhysD6Joint : public FPhysXJoint
{
	FPhysD6Joint(PX_JointObject* Obj, physx::PxJoint* JO)
		: FPhysXJoint(Obj, JO)
	{}

	void UpdateCoords(const FCoords& A, const FCoords& B)
	{
		if (JointObj)
		{
			FINISH_PHYSX_THREAD;
			JointObj->setLocalPose(physx::PxJointActorIndex::eACTOR0, UECoordsToPX(A));
			JointObj->setLocalPose(physx::PxJointActorIndex::eACTOR1, UECoordsToPX(B));
			reinterpret_cast<physx::PxD6Joint*>(JointObj)->setDrivePosition(physx::PxTransform(physx::PxIDENTITY::PxIdentity));
		}
	}
};

UBOOL UPhysXPhysics::CreateConstriant(const FJointConstProps& Props)
{
	guard(UPhysXPhysics::CreateJointSocket);
	physx::PxRigidActor* A, * B;
	physx::PxTransform TA, TB;
	if (!GetBaseProperties(Props, A, B, TA, TB))
		return NULL;

	FINISH_PHYSX_THREAD;
	physx::PxD6Joint* J = physx::PxD6JointCreate(PxGetPhysics(), A, TA, B, TB);
	if (J)
	{
		J->setDrive(physx::PxD6Drive::eX, physx::PxD6JointDrive(Props.LinearStiffness * Props.LinearStiffnessScale3D->X, Props.LinearDamping * Props.LinearDampingScale3D->X, FLT_MAX));
		if (Props.XAxis && Props.XAxis->Limit != MOTION_Locked)
		{
			if (Props.XAxis->Limit == MOTION_Limited)
			{
				J->setMotion(physx::PxD6Axis::eX, physx::PxD6Motion::eLIMITED);
				J->setLinearLimit(physx::PxD6Axis::eX, physx::PxJointLinearLimitPair(UPhysXPhysics::physXScene->getTolerancesScale(), Props.XAxis->Limit1 * UEScaleToPX, Props.XAxis->Limit2 * UEScaleToPX));
			}
			else J->setMotion(physx::PxD6Axis::eX, physx::PxD6Motion::eFREE);
		}
		J->setDrive(physx::PxD6Drive::eY, physx::PxD6JointDrive(Props.LinearStiffness * Props.LinearStiffnessScale3D->Y, Props.LinearDamping * Props.LinearDampingScale3D->Y, FLT_MAX));
		if (Props.YAxis && Props.YAxis->Limit != MOTION_Locked)
		{
			if (Props.YAxis->Limit == MOTION_Limited)
			{
				J->setMotion(physx::PxD6Axis::eY, physx::PxD6Motion::eLIMITED);
				J->setLinearLimit(physx::PxD6Axis::eY, physx::PxJointLinearLimitPair(UPhysXPhysics::physXScene->getTolerancesScale(), Props.YAxis->Limit1 * UEScaleToPX, Props.YAxis->Limit2 * UEScaleToPX));
			}
			else J->setMotion(physx::PxD6Axis::eY, physx::PxD6Motion::eFREE);
		}
		J->setDrive(physx::PxD6Drive::eZ, physx::PxD6JointDrive(Props.LinearStiffness * Props.LinearStiffnessScale3D->Z, Props.LinearDamping * Props.LinearDampingScale3D->Z, FLT_MAX));
		if (Props.ZAxis && Props.ZAxis->Limit != MOTION_Locked)
		{
			if (Props.ZAxis->Limit == MOTION_Limited)
			{
				J->setMotion(physx::PxD6Axis::eZ, physx::PxD6Motion::eLIMITED);
				J->setLinearLimit(physx::PxD6Axis::eZ, physx::PxJointLinearLimitPair(UPhysXPhysics::physXScene->getTolerancesScale(), Props.ZAxis->Limit1 * UEScaleToPX, Props.ZAxis->Limit2 * UEScaleToPX));
			}
			else J->setMotion(physx::PxD6Axis::eZ, physx::PxD6Motion::eFREE);
		}
		J->setDrive(physx::PxD6Drive::eSWING, physx::PxD6JointDrive(Props.AngularStiffness, Props.AngularDamping, FLT_MAX));
		if (Props.ConeLimit && Props.ConeLimit->Limit != MOTION_Locked)
		{
			if (Props.ConeLimit->Limit == MOTION_Limited)
			{
				J->setMotion(physx::PxD6Axis::eSWING1, physx::PxD6Motion::eLIMITED);
				J->setMotion(physx::PxD6Axis::eSWING2, physx::PxD6Motion::eLIMITED);
				J->setSwingLimit(physx::PxJointLimitCone(Props.ConeLimit->Limit2 * (PI / 180.f), Props.ConeLimit->Limit1 * (PI / 180.f)));
			}
			else
			{
				J->setMotion(physx::PxD6Axis::eSWING1, physx::PxD6Motion::eFREE);
				J->setMotion(physx::PxD6Axis::eSWING2, physx::PxD6Motion::eFREE);
			}
		}
		J->setDrive(physx::PxD6Drive::eTWIST, physx::PxD6JointDrive(Props.AngularStiffness, Props.AngularDamping, FLT_MAX));
		if (Props.TwistLimit && Props.TwistLimit->Limit != MOTION_Locked)
		{
			if (Props.TwistLimit->Limit == MOTION_Limited)
			{
				J->setMotion(physx::PxD6Axis::eTWIST, physx::PxD6Motion::eLIMITED);
				J->setTwistLimit(physx::PxJointAngularLimitPair(Props.TwistLimit->Limit1 * (PI / 180.f), Props.TwistLimit->Limit2 * (PI / 180.f)));
			}
			else J->setMotion(physx::PxD6Axis::eTWIST, physx::PxD6Motion::eFREE);
		}
		if (Props.DistanceLimit && Props.DistanceLimit->bLimitDistance)
			J->setDistanceLimit(physx::PxJointLinearLimit(UPhysXPhysics::physXScene->getTolerancesScale(), Props.DistanceLimit->MaxDistance * UEScaleToPX));
		CONSTRUCT_JOINT(FPhysD6Joint);
	}
	GWarn->Log(TEXT("CreateConstriant FAILED!"));
	return FALSE;
	unguard;
}
