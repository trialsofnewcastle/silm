#include "inc_decay"
#include "inc_pc_data"

void CancelResting(object oPC) {
	SetLocalInt(oPC, "Resting_State", 1);
	AssignCommand(oPC, ClearAllActions());
}

void CommitResting(object oPC) {
	SetLocalInt(oPC, "Resting_State", 1);
	SetLocalInt(oPC, "Resting_Start", GetTimeSecond());
	AssignCommand(oPC, ClearAllActions());
	AssignCommand(oPC, ActionRest());
	ApplyEffectToObject(
		DURATION_TYPE_INSTANT,
		EffectVisualEffect(VFX_IMP_SLEEP),
		oPC);
	FadeToBlack(oPC);
	DelayCommand(4.0f, FadeFromBlack(oPC));
}

void FinishedResting(object oPC) {
	SetLocalDecay(oPC, "Resting_Counter", gvGetInt("t_hours_between_rest") * 60, 60);
	save_player(oPC, FALSE);
	SendMessageToPC(oPC, "Charakter gespeichert.");
}

void CancelledResting(object oPC) {
	int iCurrent = GetTimeSecond();
	int iStart = GetLocalInt(oPC, "Resting_Start");
	int iTime = iCurrent - iStart;
	int iMax = StringToInt(Get2DAString("restduration", "DURATION", GetHitDice(oPC))) / 100;

	if ( iTime < 0 ) iTime += 60;

	//Time between rests is proportional to the time having rested until
	//disturbed
	int iMinutes = ( gvGetInt("t_hours_between_rest") * 450 * iTime ) / iMax;

	SetLocalDecay(oPC, "Resting_Counter", iMinutes, 60);
}

