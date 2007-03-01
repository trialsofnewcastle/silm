#include "inc_events"

void main() {
	object oPC = GetItemActivator();
	location lTarget = GetItemActivatedTargetLocation();
	object oTarget = GetItemActivatedTarget();
	object oComp = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
	if ( !GetIsObjectValid(oComp) )
		oComp = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);

	switch ( GetEvent() ) {
		case EVENT_ITEM_ACTIVATE:
			if ( !GetIsObjectValid(oComp) ) {
				SendMessageToPC(oPC,
					"Ihr ben�tigt einen anwesenden Tiergef�hrten oder Vertauten, um diesen Stab benutzen zu k�nnen.");
				return;
			}

			SetLocalLocation(oPC, "animalstaff_targetl", lTarget);
			SetLocalObject(oPC, "animalstaff_target", oTarget);
			SetLocalObject(oPC, "animalstaff_comp", oComp);
			SendMessageToPC(oPC, "Starting conversation.");
			SetCustomToken(1338, GetName(oComp));

			AssignCommand(oPC, ClearAllActions());
			AssignCommand(oPC, ActionStartConversation(OBJECT_SELF, "animalstaff", TRUE, FALSE));
			break;
		case EVENT_ITEM_EQUIP:
			break;
		case EVENT_ITEM_UNEQUIP:
			break;
		case EVENT_ITEM_ONHITCAST:
			break;
		case EVENT_ITEM_ACQUIRE:
			break;
		case EVENT_ITEM_UNACQUIRE:
			break;
		case EVENT_ITEM_SPELLCAST_AT:
			break;

		default: /* You might want to leave this stub intact,
				  *   for debugging purposes. */
			SendMessageToAllDMs("Warning in event system: Unhandled event.");
			SendMessageToAllDMs(" Script: " + GetTag(OBJECT_SELF));
			SendMessageToAllDMs(" Event : " + IntToString(GetEvent()));
			break;
	}

}
