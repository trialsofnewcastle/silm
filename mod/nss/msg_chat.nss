#include "inc_chat"
#include "_gen"
#include "inc_mnx"
#include "inc_cdb"
#include "inc_chat_lib"
#include "inc_chat_run"
#include "inc_chatlog"
#include "inc_planewalk"
#include "inc_telepathbond"



const string
USE_SL_MESSAGE =
	"Du darfst keine Nachrichten senden.  Benutze den SL-Channel, um diesen Sachverhalt zu klaeren.",
IGNORE_PLAYER_MESSAGE = "Dieser Spieler ignoriert dich, und kann deshalb deine Nachricht nicht empfangen.";


/* Note:
 * 	This code needs to be rock_bloody_stable.
 * 	Do NOT change unless you really, really
 * 	know what you are doing.
 * 	Bad Things will happen if you mess up.
 * 	Im serious. -- Elven
 */


/* Hooks:
 * 	You can use hooks to stop any text from appearing onscreen,
 * 	modify it, or act in whatever way you see fit.
 *
 * 	OnPre* gets executed before doing the core language parsing.
 * 	Returning 1 can stop the language parser from doing its work.
 * 	OnPost* gets executed after doing core parsing.
 * 	Returning 1 suppresses _unhandled_ core messages.
 * 	Messages the language parser handles get suppressed auto-
 * 	magically.
 */


/* hooks: return 1 to suppress message, 0 to chain thru */
int OnPreText(object oPC, string sText, int iMode, object oTo = OBJECT_INVALID);
int OnPreTalk(object oPC, string sText);
int OnPreWhisper(object oPC, string sText);
int OnPreParty(object oPC, string sText);
int OnPreShout(object oPC, string sText);
int OnPrePrivate(object oPC, string sText, object oTarget = OBJECT_INVALID);
int OnPreDM(object oPC, string sText);

int OnPostText(object oPC, string sText, int iMode, object oTo = OBJECT_INVALID);
int OnPostTalk(object oPC, string sText);
int OnPostWhisper(object oPC, string sText);
int OnPostParty(object oPC, string sText);
int OnPostShout(object oPC, string sText);
int OnPostPrivate(object oPC, string sText, object oTarget = OBJECT_INVALID);
int OnPostDM(object oPC, string sText);


int HandleDelegate(object oPC, string sText, int iMode, object oTo = OBJECT_INVALID);



void main() {
	object oPC = OBJECT_SELF;

	// Do not trigger for self-sent messages!
	//if (GetLocalInt(GetModule(), "use_chatlock") && GetIsPC(oPC) && ChatLockCheck(oPC))
	//    return;

	// get text and stuff
	SetLocalString(oPC, "NWNX!CHAT!TEXT", ChatGetSpacer());
	string sText = GetLocalString(oPC, "NWNX!CHAT!TEXT");

	if ( sText == "" ) {
		WriteTimestampedLogEntry("msg_chat: 1# no text.");
		return;
	}

	int iMode = StringToInt(GetStringLeft(sText, 2));

	int nDM = iMode > MSG_MODE_DM ? 1 : 0;
	if ( nDM )
		iMode -= MSG_MODE_DM;

	iMode = ChatMsgToMode(iMode);
	if ( iMode == 0 )
		return;


	//if (nDM)
	//    iMode |= MODE_DM_MODE;

	int nTo = StringToInt(GetSubString(sText, 2, 10));
	object oTo = ( iMode == MODE_PRIVATE ? GetPC(nTo) : OBJECT_INVALID );

	// chompchomp
	sText = GetSubString(sText, 12, GetStringLength(sText));

	if ( sText == "" ) {
		WriteTimestampedLogEntry("msg_chat: 2# no text.");
		return;
	}

	int bIsCommand = ( !( iMode & MODE_PRIVATE ) && ( GetStringLeft(sText, 1) == "/" ) );
	int bIsForceTalk = ( !( iMode & MODE_PRIVATE )
						&& ( GetStringLeft(sText, 1) == "." ) && ( GetStringLeft(sText, 2) != ".." ) );
	int bIsTelepathicBond = ( !( iMode & MODE_PRIVATE ) && GetStringLeft(sText, 1) == "$" );
	int bIsGo = ( !( iMode & MODE_PRIVATE ) && ( GetStringLeft(sText, 1) == "," ) );
	int bIsFamiliarSpeech = ( !(iMode & MODE_PRIVATE) && GetStringLeft(sText, 1) == ":" );

	if ( bIsCommand )
		iMode |= MODE_COMMAND;
	if ( bIsForceTalk )
		iMode |= MODE_FORCETALK;
	if ( bIsTelepathicBond )
		iMode |= MODE_TELEPATHICBOND;
	if ( bIsGo )
		iMode |= MODE_QUICKJUMP;


	if (
		OnPreText(oPC, sText, iMode, oTo)
		|| ( ( MODE_TALK & iMode ) && OnPreTalk(oPC, sText) )
		|| ( ( MODE_WHISPER & iMode ) && OnPreWhisper(oPC, sText) )
		|| ( ( MODE_PARTY & iMode ) && OnPreParty(oPC, sText) )
		|| ( ( MODE_SHOUT & iMode ) && OnPreShout(oPC, sText) )
		|| ( ( MODE_PRIVATE & iMode ) && OnPrePrivate(oPC, sText, oTo) )
		|| ( ( MODE_DM & iMode ) && OnPreDM(oPC, sText) )
	) {
		Suppress();
		DeleteLocalString(oPC, "NWNX!CHAT!TEXT");
		DeleteLocalString(oPC, "NWNX!CHAT!SUPRESS");
		return;
	}


	// Do not process NPCs below this line!
	if ( !GetIsPC(oPC) ) {
		return;
	}
	
	
	// Hehe, hack. But works.
	if ( bIsGo && (GetIsDM(oPC) || amask(oPC, AMASK_GM | AMASK_GLOBAL_GM)) ) {
		sText = "/go " + GetSubString(sText, 1, 1024);
		bIsCommand = 1;
		iMode |= MODE_COMMAND;
	}

	if ( bIsTelepathicBond && !GetIsDM(oPC) && !bIsGo && !bIsFamiliarSpeech ) {
		Suppress();
		sText = GetSubString(sText, 1, 2048);

		if ( "off" == sText ) {
			SetBondsActive(oPC, 0);
			ToPC("TB aus.");

		} else if ( "on" == sText ) {
			SetBondsActive(oPC, 1);
			ToPC("TB an.");
		} else {
			int nCount = DelegateTelepathicMessageToPartners(oPC, sText);

			if ( !nCount )
				SendMessageToPC(oPC, "Keine aktiven Telepathie-Bunde.");

			/*DeleteLocalString( oPC, "NWNX!CHAT!TEXT" );
			 * DeleteLocalString( oPC, "NWNX!CHAT!SUPRESS" );
			 * return;*/
		}
	}

	/*if ( bIsFamiliarSpeech && FAMILIAR_CREATURE_TYPE_NONE != GetAnimalCompanionCreatureType(oPC)) {
		Suppress();

		string sFamText = GetSubString(sText, 1, 1024 * 2);
		sFamText = ColourisePlayerText(oPC, iMode, sFamText, cWhite); 

		object oAssoc = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);
		if (!GetIsObjectValid(oAssoc)) {
			ToPC("Derzeit ist euer Vertrauter nicht in Reichweite.");
		} else {
			AssignCommand(oAssoc, SpeakString(sFamText));
		}
		
	}*/

	if ( bIsForceTalk && ( GetIsDM(oPC) || amask(oPC, AMASK_FORCETALK | AMASK_GLOBAL_FORCETALK) ) ) {
		Suppress();

		// Chomp off the ft character first
		sText = GetSubString(sText, 1, 1024);

		int nTarget = StringToInt(GetSubString(sText, 0, 1));
		object oTarget = GetTarget(nTarget);

		if ( nTarget < 1 || nTarget > TARGET_MAX || !GetIsObjectValid(oTarget) || (
				!amask(oPC, AMASK_GLOBAL_GM) && ( GetIsPC(oTarget) || !GetIsCreature(oTarget) ) )
		) {
			ToPC("Kein gueltiges Ziel.");

		} else {
			// Chomp of target number
			sText = GetSubString(sText, 1, 1024);

			// strip leading ws
			sText = GetStringTrim(sText);

			int nOurMode = iMode - MODE_FORCETALK;
			if ( nOurMode & MODE_DM )
				nOurMode = MODE_TALK;

			// now make the target forcetalk it
			sText = ColourisePlayerText(oPC, nOurMode, sText, cWhite);
			SpeakToMode(oTarget, sText, nOurMode);

			// Log the junk
			ChatLog(oTarget, iMode, sText, oPC);

			// And make any active telepathic bonds manage the thing.
			// Beware, bloody bleedin ugly hack :D
			if ( !GetIsCreature(oTarget) && !GetLocalInt(GetModule(), "dont_use_tb_noncreature_echo") )
				OnPreText(oTarget, sText, nOurMode);
		}



	}

	if ( bIsCommand ) {
		Suppress();

		// Chomp off the command character first
		sText = GetSubString(sText, 1, 1024);

		// Now do all sorts of commands, but only for PCs.
		if ( GetIsPC(oPC) )
			CommandEval(oPC, iMode, sText, TRUE, TRUE, gvGetInt("s_modlevel"));


	}


	if ( !bIsCommand && !bIsForceTalk && !bIsTelepathicBond && (
			OnPostText(oPC, sText, iMode, oTo)
			|| ( ( MODE_TALK & iMode ) && OnPostTalk(oPC, sText) )
			|| ( ( MODE_WHISPER & iMode ) && OnPostWhisper(oPC, sText) )
			|| ( ( MODE_PARTY & iMode ) && OnPostParty(oPC, sText) )
			|| ( ( MODE_SHOUT & iMode ) && OnPostShout(oPC, sText) )
			|| ( ( MODE_PRIVATE & iMode ) && OnPostPrivate(oPC, sText, oTo) )
			|| ( ( MODE_DM & iMode ) && OnPostDM(oPC, sText) )
		) ) {
		Suppress();
	}

	// cleanup
	DeleteLocalString(oPC, "NWNX!CHAT!TEXT");
	DeleteLocalString(oPC, "NWNX!CHAT!SUPRESS");
}


/* PRE hooks below */

int OnPreText(object oPC, string sText, int iMode, object oTo = OBJECT_INVALID) {
	int nTS = GetUnixTimestamp();

	string sReturn = mnxCommand("chat", GetPCName(oPC), GetName(oPC), IntToString(GetAccountID(oPC)),
						 IntToString(GetCharacterID(oPC)), IntToString(iMode), sText);
	int nReturn = StringToInt(sReturn);

	if ( !GetIsDMOnline() ) {
		if ( !GetIsDM(oPC) && iMode & MODE_DM && nReturn > 0 )
			SendMessageToPC(oPC,
				"Derzeit ist kein SL im Spiel online. Deine Nachricht wurde jedoch an SLs ausserhalb dem Spiele weitergeleitet.");
		if ( !GetIsDM(oPC) && iMode & MODE_DM && nReturn == 0 )
			SendMessageToPC(oPC,
				"Derzeit ist kein SL im Spiel online, und es trat ein Fehler bei der Weiterleitung auf. Sende deine Nachricht ueber die Moeglichkeiten auf der Website.");
	}


	if ( GetIsPC(oPC) )
		HandleDelegate(oPC, sText, iMode, oTo);


	if ( GetIsPC(oPC) && GetLocalInt(oPC, "shunned") == 1 && !( iMode & MODE_DM ) ) {
		SendMessageToPC(oPC, USE_SL_MESSAGE);
		return 1;
	}

	// Chatlog the stuff
	if ( GetIsPC(oPC)
		&& !( iMode & MODE_COMMAND ) 
		&& !( iMode & MODE_FORCETALK ) 
		&& !( iMode & MODE_TELEPATHICBOND )
		&& !( iMode & MODE_QUICKJUMP )
	)
		ChatLog(oPC, iMode, sText, oTo);

	SetLocalInt(oPC, "last_message", nTS);
	int nTotal = GetLocalInt(oPC, "message_count");
	SetLocalInt(oPC, "message_count", nTotal + 1);

	// Condition A: It was a player who said something
	// Condition B: It was a NPC who said something
	// Condition C: It was a channel that wants to be broadcasted

	if ( ( iMode & MODE_TALK || iMode & MODE_WHISPER )
		&& !( iMode & MODE_COMMAND ) 
		&& !( iMode & MODE_FORCETALK ) 
		&& !( iMode & MODE_TELEPATHICBOND )
		&& !( iMode & MODE_QUICKJUMP )
	) {


		// If it was ourselves and we are not possessing something, send message to all bond partners
		// DMs do not have bond partners
		if ( GetIsPC(oPC) && !GetIsDM(oPC) && !GetIsDMPossessed(oPC) && !GetIsPossessedFamiliar(oPC) ) {
			//SendMessageToAllActiveBondPartners(oPC, sMessage);
			DelegateOwnToPartners(oPC, iMode, sText);
		}



		// Now iterate through all _players_ nearby and send to all bond partners that be
		int nNth = 1;
		object oI = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oPC, nNth);
		while ( GetIsObjectValid(oI) ) {
			// if its too far off drop out
			if ( iMode & MODE_WHISPER && GetDistanceBetween(oPC, oI) > 8.0 )  // 8 == TALKVOLUME_WHISPER
				break;

			if ( iMode & MODE_TALK && GetDistanceBetween(oPC, oI) > 20.0 )  // 20 == TALKVOLUME_TALK
				break;

			if ( oPC != oI && !GetIsDM(oI) && GetObjectHeard(oPC, oI) ) {
				// Iterate all bond partners and send a text message
				// SendMessageToAllActiveBondPartners(oI, sMessage, iMode & MODE_TALK ? TALKVOLUME_TALK : TALKVOLUME_WHISPER, FALSE, oPC);
				DelegateHeardToPartners(oI, oPC, iMode, sText);

			}

			nNth++;
			oI = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oPC, nNth);
		}
	}


	//if (iMode & MODE_TALK || iMode & MODE_WHISPER)
	//    if (!(iMode && MODE_COMMAND) && !(iMode && MODE_DM_MODE) && !(iMode && MODE_FORCETALK))
	//        PlaneWalkTextHook(oPC, iMode, sText);

	return 0;
}

int OnPreTalk(object oPC, string sText) {
	return 0;
}

int OnPreWhisper(object oPC, string sText) {
	if ( !GetIsPC(oPC) )
		return 0;

	if ( GetLocalInt(oPC, "shunned") == 1 ) {
		SendMessageToPC(oPC, USE_SL_MESSAGE);
		return 1;
	}
	return 0;
}

int OnPreParty(object oPC, string sText) {
	if ( !GetIsPC(oPC) )
		return 0;

	if ( GetLocalInt(oPC, "shunned") == 1 ) {
		SendMessageToPC(oPC, USE_SL_MESSAGE);
		return 1;
	}
	return 0;
}

int OnPreShout(object oPC, string sText) {
	if ( !GetIsPC(oPC) )
		return 0;


	if ( GetLocalInt(oPC, "shunned") == 1 ) {
		SendMessageToPC(oPC, USE_SL_MESSAGE);
		return 1;
	}

	if ( GetIsDM(oPC) )
		return 0;

	// Other hooks ..

	return 0;
}

int OnPrePrivate(object oPC, string sText, object oTarget = OBJECT_INVALID) {
	if ( !GetIsPC(oPC) )
		return 0;


	/* shunned players may not babble other players */
	if ( !GetIsDM(oPC) && !GetIsDM(oTarget) && GetLocalInt(oPC, "shunned") == 1 ) {
		SendMessageToPC(oPC, USE_SL_MESSAGE);
		return 1;
	}

	if ( !GetIsDM(oPC)
		&& GetIsObjectValid(oTarget) && GetLocalInt(oTarget, "ignore_" + GetPCPlayerName(oPC)) ) {
		SendMessageToPC(oPC, IGNORE_PLAYER_MESSAGE);
		return 1;
	}

	if ( oPC == oTarget ) {
		SendMessageToPC(oPC, "Warnung: Diese PM ging an dich selbst.");
	}

	if ( GetLocalInt(oTarget, "afk") )
		SendMessageToPC(oPC, "Dieser Spieler ist AFK.");

	return 0;
}

int OnPreDM(object oPC, string sText) {
	if ( !GetIsPC(oPC) )
		return 0;

	return 0;
}


/* POST hooks below */

int OnPostText(object oPC, string sText, int iMode, object oTo = OBJECT_INVALID) {
	if ( !( iMode & MODE_PRIVATE ) && !( iMode & MODE_DM_MODE ) && !GetIsDM(oPC) ) {
		struct mnxRet r = mnxCmd("ontext", sText, IntToString(iMode));
		if ( !r.error ) {
			string sR = GetStringLeft(r.ret, 1);

			// Accept the text
			if ( "a" == sR ) {
				sText = r.ret;
				sText = GetStringRight(sText, GetStringLength(sText) - 1);
			}

			// Drop the text completely
			if ( "d" == sR ) {
				return 1;
			}

			// Ignore
			if ( "i" == sR ) {
				// Do nothing
			}


		} else {
			SendMessageToAllDMs("Error in chathook, not processing this one: " + r.ret);
		}
	}

	if ( !GetIsDM(oPC)
		&& !GetLocalInt(GetModule(), "dont_use_colours") && ( iMode & MODE_TALK || iMode & MODE_WHISPER ) ) {

		sText = ColourisePlayerText(oPC, iMode, sText, cWhite);
		SpeakString(sText, iMode & MODE_TALK ? TALKVOLUME_TALK : TALKVOLUME_WHISPER);
		return 1;
	}

	return 0;
}

int OnPostTalk(object oPC, string sText) {
	return 0;
}

int OnPostWhisper(object oPC, string sText) {
	return 0;
}

int OnPostParty(object oPC, string sText) {
	return 0;
}

int OnPostShout(object oPC, string sText) {

	//if (CheckMask(oPC, AMASK_GM))
	//    return 0; // DMs are allowed to shout global-area

	/*float fSize = GetListeningDistance( TALKVOLUME_SHOUT );
	 *
	 * if ( fSize > 0.0 ) {
	 * 	object oListen = GetFirstObjectInShape( SHAPE_SPHERE, fSize, GetLocation( oPC ),
	 * 											FALSE, OBJECT_TYPE_CREATURE );
	 * 	while ( GetIsObjectValid( oListen ) ) {
	 * 		if ( GetIsPC( oListen ) ) {
	 * 			if ( oPC == oListen )
	 * 				continue;
	 *
	 * 			SendMessageToPC( oListen, GetName( oPC ) + " RUFT: "  + sText );
	 *
	 * 		}
	 *
	 * 		oListen = GetNextObjectInShape( SHAPE_SPHERE, fSize, GetLocation( oPC ),
	 * 										FALSE, OBJECT_TYPE_CREATURE );
	 * 	}
	 * }
	 *
	 * AssignCommand(oPC, SpeakString("[Ruft] " + sText));*/

	return 0; //1;
}

int OnPostPrivate(object oPC, string sText, object oTarget = OBJECT_INVALID) {
	return 0;
}

int OnPostDM(object oPC, string sText) {
	return 0;
}



int HandleDelegate(object oPC, string sText, int iMode, object oTo = OBJECT_INVALID) {
	if ( !GetIsPC(oPC) )
		return 0;

	// Do not allow listening in on private conversations
	if ( iMode & MODE_PRIVATE )
		return 0;

	if ( GetLocalInt(oPC, "do_not_delegate") )
		return 1;

	int c = 0;

	// We dont care if a DM sent it, just push it through.
	if ( MODE_DM_MODE & iMode )
		iMode -= MODE_DM_MODE;

	string sMode = IntToString(iMode);
	string sChan = "d_" + sMode;

	string sOPCId = ObjectToString(oPC);

	object o = GetFirstPC();
	while ( GetIsObjectValid(o) ) {

		if ( oPC != o/* TODO && !GetHeard() */ ) {
			// Dont delegate to ourselves, eh?

			if ( iMode & MODE_COMMAND ) {
				if ( GetLocalInt(o, "d_" + IntToString(MODE_COMMAND)) || GetLocalInt(o, "d_" + sOPCId) ) {
					c += 1;
					SendMessageToPC(o, "D[" +
						IntToString(MODE_COMMAND) + "/" + sMode + "] " + PCToString(oPC, 1) + ": " + sText);
				}
			} else {
				if ( GetLocalInt(o, "d_all") || GetLocalInt(o, sChan) || GetLocalInt(o, "d_" + sOPCId) ) {
					if ( !(GetIsDM(oPC) && iMode & MODE_DM) ) {
						c += 1;
						SendMessageToPC(o, "D[" + sMode + "] " + PCToString(oPC, 1) + ": " + sText);
					}
				}
			}
		}

		o = GetNextPC();
	}

	return c;
}
