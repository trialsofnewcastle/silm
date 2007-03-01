#include "_gen"
#include "inc_events"



void RemoveEff(object oItem, object oPC) {
	effect e = GetFirstEffect(oPC);
	while ( GetIsEffectValid(e) ) {
		if ( GetEffectCreator(e) == oItem && SUBTYPE_SUPERNATURAL == GetEffectSubType(e) )
			RemoveEffect(oPC, e);
		e = GetNextEffect(oPC);
	}
}


void main() {
	if ( GetEvent() != EVENT_ITEM_ACTIVATE )
		return;

	object oPC = GetItemActivator();
	object oItem = GetItemActivated();

	if ( !GetIsPC(oPC) || GetIsDM(oPC) )
		return;

	int iWalk = GetLocalInt(oPC, "walkspeed");
	int nSpeed = 0;
	string sNtc = "";

	RemoveEff(oItem, oPC);

	switch ( iWalk ) {
		case 0:
			iWalk = 1;
			nSpeed = 20;
			sNtc = "Gehen";
			break;
		case 1:
			iWalk = 2;
			nSpeed = 45;
			sNtc = "Langsamer gehen";
			break;

		default:
		case 2:
			iWalk = 0;
			nSpeed = 0;
			sNtc = "Normal";
			break;
	}

	SetLocalInt(oPC, "walkspeed", iWalk);
	FloatingTextStringOnCreature("Geschwindigkeit: " + sNtc, oPC, 0);

	if ( nSpeed != 0 ) {
		effect e = SupernaturalEffect(EffectMovementSpeedDecrease(nSpeed));
		ApplyEffectToObject(DURATION_TYPE_PERMANENT, e, oPC);
	}
}
