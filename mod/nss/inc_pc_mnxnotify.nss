#include "inc_mnx"


void notify_pc_login(object oPC) {}

void notify_pc_logout(object oPC) {}


/*void notify_pc_login(object oPC) {
 * int i;
 * string sString = GetPCIPAddress(oPC)+"/"+
 * GetPCPlayerName(oPC)+"/"+GetPCPublicCDKey(oPC)+"/"+GetName(oPC)+"/";
 *
 * sString += GetStringByStrRef(
 * 	StringToInt(Get2DAString("racialtypes","Name",GetRacialType(oPC))));
 *
 * sString += "/";
 * if(GetIsDM(oPC))
 * {
 * 	sString += "SL";
 * } else {
 * 	for(i=0;i<3;i++)
 * 	 {
 * 	  int iClass = GetClassByPosition(i,oPC);
 * 	  int iLevel = GetLevelByPosition(i,oPC);
 *
 * 	  if(iLevel > 0)
 * 	   {
 * 		sString += GetStringByStrRef(
 * 		   StringToInt(Get2DAString("classes","Name",iClass))) + "-" +
 * 		  IntToString(iLevel);
 * 	   }
 * 	  if(i < 2 && GetLevelByPosition(i+1) > 0) sString += ";";
 * 	 }
 * }
 * mnxGetString("LOGIN",sString);
 * }
 *
 *
 * void notify_pc_logout(object oPC) {
 * mnxGetString("LOGOUT",GetName(oPC));
 * }  */

