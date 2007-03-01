#include "inc_events"
#include "inc_cdb"
#include "_const"
#include "inc_spelltools"
#include "inc_blackboard"

void OnActivate(object oItem, object oActivator);

int OnSpellCastAt(object oItem, object oSpellCaster);




void main() {

	switch ( GetEvent() ) {
		case EVENT_ITEM_ACTIVATE:
			FloatingTextStringOnCreature("Ihr rollt das Pergament auf ..", GetItemActivator(), 1);
			AssignCommand(GetItemActivator(), PlayAnimation(ANIMATION_FIREFORGET_READ));

			DelayCommand(2.0, OnActivate(GetItemActivated(), GetItemActivator()));
			break;

		case EVENT_ITEM_SPELLCAST_AT:
			if ( OnSpellCastAt(GetSpellTargetObject(), GetLastSpellCaster()) ) {
				SetEventScriptReturnValue();
			}
			break;
	}
}



void OnActivate(object oItem, object oActivator) {
	object oTarget = GetItemActivatedTarget();

	if ( oTarget != oActivator && !GetIsBlackBoard(oTarget) ) {
		Floaty("Benutzt das Pergament auf Euch selbst, oder auf ein schwarzes Brett.", oActivator, 0);
		return;
	}


	int nSave = d20() + GetReflexSavingThrow(oActivator);


	// Check if something is written on it
	int nWriteCycles = GetLocalInt(oItem, "paper_writecycles");
	string sText;
	int nWriter = 0, nOldWriter = 0;

	int nSigil = GetLocalInt(oItem, "paper_sigil");
	int nSigilBroken = GetLocalInt(oItem, "paper_sigil_broken");

	if ( !GetIsDM(oActivator) ) {
		if ( nSigil && !nSigilBroken ) {
			Floaty(".. dabei brecht Ihr das Siegel ..", oActivator, 1);
			SetLocalInt(oItem, "paper_sigil_broken", 1);
		}
	}


	if ( GetIsBlackBoard(oTarget) ) {
		// Pin note to blackboard
		struct BlackboardEntry bbE;
		bbE.cid = GetLocalInt(oItem, "paper_cid_0");
		bbE.title = GetStringLeft(GetLocalString(oItem, "paper_text_0"), 15);
		bbE.text = GetAllText(oItem); // GetLocalString(oItem, "paper_text_1");
		bbE.sigil = GetLocalInt(oItem, "paper_sigil");
		bbE.sigil_text = GetLocalString(oItem, "paper_sigil_name");
		bbE.sigil_label = GetLocalString(oItem, "paper_sigil_label");
		bbE.explosive_runes = GetLocalInt(oItem, "explosive_runes_dc");
		bbE.sepia_snake_sigil = GetLocalInt(oItem, "sepia_snake_sigil_dc");

		Floaty(".. und haengt es an das schwarze Brett.", oActivator, 1);
		AddBlackBoardEntry(oTarget, bbE);
		DestroyObject(oItem);
		return;
	}



	int nTotalSize = GetTotalTextLength(oItem);
	int nPrint = nTotalSize;
	// Print 1/3rd of the Letters

	if ( HasExplosiveRunes(oItem) )
		nPrint /= 2;

	int nPrinted = 0;


	if ( 0 == nWriteCycles ) {
		FloatingTextStringOnCreature("Das Pergament ist leer.", oActivator, 0);

	} else {

		int i = 0;
		for ( i = 0; i < nWriteCycles; i++ ) {
			sText = GetLocalString(oItem, "paper_text_" + IntToString(i));
			nWriter = GetLocalInt(oItem, "paper_cid_" + IntToString(i));

			if ( 0 == i ) {
				FloatingTextStringOnCreature("Es steht geschrieben: ", oActivator, 0);
			} else {
				if ( nWriter != nOldWriter )
					FloatingTextStringOnCreature("Spaeter fuegte eine andere Handschrift hinzu:", oActivator,
						0);

			}

			int nDiff = ( GetStringLength(sText) + nPrinted - nPrint );

			if ( nDiff > 0 )
				sText = GetStringLeft(sText, GetStringLength(sText) - nDiff);

			if ( nDiff > 0 && HasExplosiveRunes(oItem) )
				sText += " Explosive Runen Explosive Runen Explosive Runen.";

			FloatingTextStringOnCreature(sText, oActivator, 0);

			if ( nDiff > 0 )
				break;

			nPrinted += GetStringLength(sText);


			nOldWriter = nWriter;
		}
	}

	if ( DoExplosiveRunes(oItem, oActivator) )
		return;

	if ( nSave < 15 ) {
		if ( DoSepiaSnakeSigil(oItem, oActivator) )
			return;
	}


	FixPergamentName(oItem);
}




int OnSpellCastAt(object oItem, object oSpellCaster) {
	// If spell = explosive runes - add it.
	int nSpell = GetSpellId(); // returns the SPELL_* constant of the spell cast
	int nClass = GetLastSpellCastClass(); // gets the class the PC cast the spell as
	int nDC = GetSpellSaveDC(); // gets the DC required to save against the effects of the spell
	int nLevel = GetCasterLevel(oSpellCaster); // gets the level the PC cast the spell as

	if ( SPELL_DISPEL_MAGIC == nSpell
		|| SPELL_MORDENKAINENS_DISJUNCTION == nSpell || SPELL_GREATER_DISPELLING == nSpell ) {
		// Allow dispel of runes if DC works out
		if ( HasExplosiveRunes(oItem) ) {
			int nRunesDC = GetLocalInt(oItem, "explosive_runes_dc");
			// Make some throw
			int nThrow = d20();
			if ( nRunesDC > nThrow + nDC ) {
				DoExplosiveRunes(oItem, oSpellCaster);
			} else {
				FloatingTextStringOnCreature("Ihr entfernt die Explosiven Runen auf diesem Pergament.",
					oSpellCaster, 0);
				RemoveExplosiveRunes(oItem);
			}

		}

		if ( HasSepiaSnakeSigil(oItem) ) {
			int nRunesDC = GetLocalInt(oItem, "sepia_snake_sigil_dc");
			// Make some throw
			int nThrow = d20();
			if ( nRunesDC > nThrow + nDC ) {
				DoSepiaSnakeSigil(oItem, oSpellCaster);
			} else {
				FloatingTextStringOnCreature("Ihr entfernt das Sepia-Schlangensiegel auf diesem Pergament.",
					oSpellCaster, 0);
				RemoveSepiaSnakeSigil(oItem);
			}

		}

		return 0;
	}

	return 0;
}
