/*
 * ZoneShotTrigger
 * ===============
 *
 * Trigger events when a (shock rifle) shot lands anywhere within a zone.
 * Essentially turns whole rooms into giant triggers.
 * 
 * Author:  Dizzy <dizzy@bunnytrack.net>
 * GitHub:  github.com/bunnytrack
 * License: Creative Commons Attribution-NonCommercial-ShareAlike
 *
 */

class ZoneShotTrigger expands SpawnNotify;

var() bool bShowDebugMessages;
var() name NoZoneEvent;

/*
 * This function is called when a SuperShockRifle's impact effect (`ut_SuperRing2`)
 * is spawned in the level. This effectively allows you to pinpoint the exact
 * location where a SuperShockRifle shot has impacted, as well as the owner
 * of the rifle who fired it, without having to subclass the weapon as a 
 * custom weapon.
 */
simulated event Actor SpawnNotification(Actor A) {

	// Was the spawned actor a shock rifle ring?
	if (ut_SuperRing2(A) != None) {
		ShotFired(A);
	}

	return A;

}

simulated function ShotFired(Actor SpawnedRing) {

	local name  ZoneTag;
	local name  EventName;

	ZoneTag   = SpawnedRing.Region.Zone.Tag;
	EventName = SpawnedRing.Region.Zone.Event;
	
	if (bShowDebugMessages) {
		PlayerPawn(SpawnedRing.Instigator).ClientMessage("Shot landed in zone: " $ ZoneTag $ ". Triggering actor with tag: " $ SpawnedRing.Region.Zone.Event);
	}
	
	// If player shoots outside a defined zone, the tag will be "LevelInfo" so ignore those
	if (SpawnedRing.Region.Zone.Tag != 'LevelInfo')	{

		/* 
		 * Trigger any actors with a tag which matches the "Event" property
		 * of the ZoneInfo in which the shot landed
		 */
		TriggerEvent(EventName, SpawnedRing.Instigator);

	} else {

		// Player shot outside a defined zone
		
		// If the `NoZoneEvent` property is configured, trigger that event
		if (NoZoneEvent != 'None') {
				
		}
		
		if (bShowDebugMessages) {
			BroadcastMessage("You shot outside a defined zone. Your name is " $ PlayerPawn(SpawnedRing.Instigator).PlayerReplicationInfo.PlayerName, true, 'CriticalEvent');
		}

	}

}

simulated function TriggerEvent(name EventName, Pawn EventInstigator) {

	local Actor MatchingActor;

	if (EventName != 'None') {
		foreach AllActors(class 'Actor', MatchingActor, EventName) {
			MatchingActor.Trigger(Self, EventInstigator);
		}
	}
	
}
