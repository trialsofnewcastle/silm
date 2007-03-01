/*
 * File: _area_udef
 * A tag-execution based event system.
 * Copyright Bernard 'elven' Stoeckner.
 *
 * This code is licenced under the
 *  GNU/GPLv2 General Public Licence.
 */
#include "inc_events"

/*
 * This is a generic event distribution
 * script. Do not modify.
 */

void main() {
	RunEventScript(OBJECT_SELF, EVENT_AREA_UDEF, EVENT_PREFIX_AREA);
}
