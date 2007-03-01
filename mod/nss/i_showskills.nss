#include "inc_events"
#include "inc_persist"
#include "inc_craft"

/*reg_cs (35):   Register_Skill("M","Bergbau"           ,1);
 * reg_cs (38):   Register_Skill("W","Holzfaellerei"     ,1);
 * reg_cs (41):   Register_Skill("O","Erzverarbeitung"   ,1);
 * reg_cs (44):   Register_Skill("L","Gerberei"          ,1);
 * reg_cs (47):   Register_Skill("S","Schmiedekunst"     ,2);
 * reg_cs (116):   Register_Skill("B","Bognerei"          ,2);
 * reg_cs (129):   Register_Skill("T","Schneiderei"       ,2);
 * reg_cs (133):   Register_Skill("A","Alchimie"          ,2);*/

void main() {
	if ( EVENT_ITEM_ACTIVATE != GetEvent() )
		return;

	object oPC = GetItemActivator();
	object oItem = GetItemActivated();
	object oTarget = GetItemActivatedTarget();

	if ( !GetIsPC(oTarget) ) {
		SendMessageToPC(oPC, "Das ist kein Spielerchen.");
		return;
	}


	struct PlayerSkill s;

	int iSkill;

	iSkill = GetLegacyPersistentInt(oTarget, "CS_Skill_M");
	if ( iSkill > 0 )
		SendMessageToPC(oPC, "M - Bergbau: " + IntToString(iSkill));

	iSkill = GetLegacyPersistentInt(oTarget, "CS_Skill_W");
	if ( iSkill > 0 )
		SendMessageToPC(oPC, "W - Holzfaellerei: " + IntToString(iSkill));

	iSkill = GetLegacyPersistentInt(oTarget, "CS_Skill_O");
	/*s = GetPlayerSkill(oTarget, CSKILL_SMELTER);
	 * if (iSkill > s.practical && iSkill > 0 && s.practical == 0) {
	 * 	s.practical = iSkill;
	 * 	SetPlayerSkill(oTarget, s);
	 * 	SendMessageToPC(oPC, "Updated smelter.");
	 * }*/
	if ( iSkill > 0 )
		SendMessageToPC(oPC, "O - Erzverarb.: " + IntToString(iSkill));

	iSkill = GetLegacyPersistentInt(oTarget, "CS_Skill_L");
	if ( iSkill > 0 )
		SendMessageToPC(oPC, "L - Gerberei: " + IntToString(iSkill));

	iSkill = GetLegacyPersistentInt(oTarget, "CS_Skill_S");
	/*s = GetPlayerSkill(oTarget, CSKILL_SMITH);
	 * if (iSkill > s.practical && iSkill > 0 && s.practical == 0) {
	 * 	s.practical = iSkill;
	 * 	SetPlayerSkill(oTarget, s);
	 * 	SendMessageToPC(oPC, "Updated smith.");
	 *
	 * }*/
	if ( iSkill > 0 )
		SendMessageToPC(oPC, "S - Schmiedekunst: " + IntToString(iSkill));

	iSkill = GetLegacyPersistentInt(oTarget, "CS_Skill_B");
	if ( iSkill > 0 )
		SendMessageToPC(oPC, "B - Bognerei: " + IntToString(iSkill));

	iSkill = GetLegacyPersistentInt(oTarget, "CS_Skill_T");
	/*s = GetPlayerSkill(oTarget, CSKILL_TAILOR);
	 * if (iSkill > s.practical && iSkill > 0 && s.practical == 0) {
	 * 	s.practical = iSkill;
	 * 	SetPlayerSkill(oTarget, s);
	 * 	SendMessageToPC(oPC, "Updated tailor.");
	 *
	 * }*/

	if ( iSkill > 0 )
		SendMessageToPC(oPC, "T - Schneiderei: " + IntToString(iSkill));

	iSkill = GetLegacyPersistentInt(oTarget, "CS_Skill_A");
	/*s = GetPlayerSkill(oTarget, CSKILL_ALCHEMY);
	 * if (iSkill > s.practical && iSkill > 0 && s.practical == 0) {
	 * 	s.practical = iSkill;
	 * 	SetPlayerSkill(oTarget, s);
	 * 	SendMessageToPC(oPC, "Updated alchemy.");
	 * }*/

	if ( iSkill > 0 )
		SendMessageToPC(oPC, "A - Alchemie: " + IntToString(iSkill));
}
