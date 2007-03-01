#include "inc_torches"
#include "inc_clothing"

//Destroy the work-in-progress items if it's unequipped during
//manufacturing and clear the conversation
void _StopCustomizing(object oPC, object oItem) {
	if ( GetIsObjectValid(oItem) ) {
		DestroyObject(oItem);
		AssignCommand(oPC, ClearAllActions());
		AssignCommand(oPC, ActionStartConversation(oPC, "invalid", TRUE, FALSE));
	}
}

void ClothUnequip();

void main() {
	object oPC = GetPCItemLastUnequippedBy();
	object oItem = GetPCItemLastUnequipped();

	if ( GetLocalInt(oItem, "CUST_COPY") ) {
		DelayCommand(0.5f, _StopCustomizing(oPC, oItem));
		return;
	}

	if ( GetTag(oItem) == "NW_IT_TORCH001" )
		UnequippedTorch(oPC, oItem);


	ClothUnequip();
}

void ClothUnequip() {
	if ( !GetLocalInt(GetModule(), "clothchange") )
		return;

	object oItem = GetPCItemLastUnequipped();
	object oPC   = GetPCItemLastUnequippedBy();

	if ( GetLocalInt(oPC, "noclothchange") )
		return;


	if ( !GetIsPC(oPC) || GetIsDM(oPC) )
		return;

	int iType = GetBaseItemType(oItem);

	// AssignCommand(oPC, ClearAllActions());

	//SetCommandable(FALSE, oPC);

	if ( ( iType == BASE_ITEM_CLOAK ) && ( GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC)) ) ) {
		QuitCloak(oPC, GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
	} else if ( ( iType == BASE_ITEM_BELT )
			   && ( GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC)) ) ) {
		QuitBelt(oPC, GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
	} else if ( iType == BASE_ITEM_GLOVES
			   && ( GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC)) ) ) {
		QuitGloBra(oPC, GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
	} else if ( iType == BASE_ITEM_BRACER
			   && ( GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC)) ) ) {
		QuitGloBra(oPC, GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
	} else if ( iType == BASE_ITEM_BOOTS
			   && ( GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC)) ) ) {
		QuitBoots(oPC, GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
	}

	//DelayCommand(COMMANDABLEFUDGE, SetCommandable(TRUE, oPC));
}
