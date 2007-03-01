#include "inc_currency"
#include "nw_i0_plotwizard"
#include "inc_events"


// Returns the nearest herbal bag that still has capacity
object GetHerbalBag(object oPC) {
	return GetItemPossessedBy(oPC, "herbal_bag");
}


void _TransformMoney(object oPC, int iValue) {
	struct Money New;
	TakeGoldFromCreature(iValue, oPC, TRUE);
	New = Value2Money(iValue, TRUE);
	GiveMoneyToCreature(oPC, New);
}

void main() {
	// PLOT WIZARD MANAGED CODE BEGINS
	// PLOT WIZARD MANAGED CODE ENDS

	object oPC = GetModuleItemAcquiredBy();
	object oFrom = GetModuleItemAcquiredFrom();
	object oItem = GetModuleItemAcquired();
	int iStack = GetModuleItemAcquiredStackSize();
	string sResRef = GetResRef(oItem);

	//Got Engine gold coins, transpose into own currency
	if ( !GetIsObjectValid(oItem) ) {
		int iValue = GetGold(oPC);
		AssignCommand(oPC, _TransformMoney(oPC, iValue));
		return;
	}


	// Put into herbal thingummy

	if ( GetStringLeft(sResRef, 4) == "herb" ) {
		object oBag = GetHerbalBag(oPC);
		if ( GetIsObjectValid(oBag) ) {
			AssignCommand(oPC, ActionGiveItem(oItem, oBag));
		}
	}

	// Run the event script, if available.
	RunEventScript(oItem, EVENT_ITEM_ACQUIRE, EVENT_PREFIX_ITEM);
}
