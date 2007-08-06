#include "_gen"
#include "inc_cdb"
#include "inc_pgsql"

void main() {
	object oPC = GetFirstPC();
	
	
	pQ("truncate online;");

	if ( !GetIsObjectValid(oPC) ) {
		return;
	}

	string q =
		"insert into online (aid, cid, account, character, dm, area, area_s, x, y, z, f) values";

	while ( GetIsObjectValid(oPC) ) {
		vector p = GetPosition(oPC);
		float f = GetFacing(oPC);
		
		q += "(" +
			 pSi(GetAccountID(oPC), TRUE) + "," +
			 pSi(GetCharacterID(oPC), TRUE) + "," +
			 pSs( GetPCName(oPC) ) + "," + 
			 pSs(GetName(oPC)) + "," + 
			 pSb(GetIsDM(oPC)) + "," + 
			 pSs(GetResRef(GetArea(oPC))) + "," + 
			 pSs(GetName(GetArea(oPC))) + "," + 
			 pSf(p.x, FALSE) + "," + 
			 pSf(p.y, FALSE) + "," + 
			 pSf(p.z, FALSE) + "," + 
			 pSf(f, FALSE) + "),";

		oPC = GetNextPC();
	}

	q = GetStringLeft(q, GetStringLength(q) - 1); // chomp off last ,
	q += ";";
	
	pQ(q);

//	pC();
}
