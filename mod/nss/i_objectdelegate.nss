#include "inc_cdb"
#include "inc_events"


void main() {
	if ( GetEvent() != EVENT_ITEM_ACTIVATE )
		return;

	object oSelf = GetItemActivated();
	object oPC = GetItemActivator();
	object oTarget = GetItemActivatedTarget();
	location lTarget = GetItemActivatedTargetLocation();

	if ( !CheckMask(oPC, AMASK_GM) ) {
		SendMessageToPC(oPC, "Ich mag dich nicht.  PAFF!");
		DestroyObject(oSelf);
		return;
	}

	if ( !GetIsPC(oTarget) ) {
		SendMessageToPC(oPC, "Dies ist kein Spieler, you nit.");
		return;
	}

	string sO = ObjectToString(oTarget);


	int old = GetLocalInt(oPC, "d_" + sO) == 1;

	SetLocalInt(oPC, "d_" + sO, old == 1 ? 0 : 1);
	ToPC(sO + ": " + IntToString(old == 1 ? 0 : 1), oPC);
}


