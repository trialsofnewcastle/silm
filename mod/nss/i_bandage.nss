/* deprecated */

#include "inc_events"
#include "inc_healerkit"

void main() {
	if ( EVENT_ITEM_ACTIVATE != GetEvent() )
		return;

	object oPC = GetItemActivator();
	object oTarget = GetItemActivatedTarget();
	object oItem = GetItemActivated();

	AddBandage(oPC, oTarget, oItem);
}
