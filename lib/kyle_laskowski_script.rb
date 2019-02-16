# RUN lib_lazcalc.ks.
# CLEARSCREEN.

# 	LOCK booster to SHIP:PartsNamed("FASAGeminiLR87Twin")[0].
# 	LOCK boosterModule to booster:GetModule("ModuleEnginesRF").
# 	LOCK boosterstatus to boosterModule:GetField("status").
# 	LOCK XFer to SHIP:PartsNamed("FASAGeminiLR91")[0].
# 	LOCK XFerModule to XFer:GetModule("ModuleEnginesRF").
# 	LOCK XFerprop to XFerModule:GetField("propellant").
# 	LOCK XFerstatus to XFerModule:GetField("status").
	
	

# 	FUNCTION HUD {
# 		PARAMETER text.
# 		HUDTEXT(text, 10, 1, 25, white, false). 
# 	}
# 	FUNCTION ullage {
# 		PARAMETER Module.
# 		PARAMETER prop.
# 		Module:doaction("shutdown engine",true).
# 		LOCK throttle to 1.
# 		WAIT UNTIL prop = "Very Stable".
# 		Module:doaction("activate engine",true).
# 	}
	
	
# HUD("Frankencode2. launch3.ks"). WAIT 1.

# 	SET steeringmanager:pitchts to 5.
# 	SET steeringmanager:yawts to 5.

# 	SET Inc to 28.6.
# 	SET AZcalc to LAZcalc_init(300000,Inc). // This does not affect the final altitude says 1 test.
# 	SET launchAzimuth to LAZcalc(AZcalc).
# 	SET az to ROUND(launchAzimuth,2).
# 	SET Pa to 90.

# SAS Off.
# RCS Off.
# LOCK throttle to 1.

#  HUD("GO for Launch!").

#  FROM { LOCAL T to 4. } UNTIL T = 0 STEP { SET T to T-1. } DO {
# 	HUDTEXT("T - " + t + " Seconds to Launch!", 1, 2, 100, white, false).
# 	Wait 1. }

#  STAGE.
# WAIT 0.5.
#  HUD("BOOSTER: Engines Ignited!"). 

# LIST ENGINES IN myEngines.
# SET engineCount TO 0.
# FOR eng IN myEngines {
# 	IF eng:Ignition {
# 		SET engineCount TO (engineCount + 1).
# 		SET engFS TO eng.
# 	}
# }. // could easily be a subroutine
 
# SET catchCount TO 0.
# UNTIL 0 {
# 	LOCAL g IS SHIP:BODY:MU / SHIP:BODY:RADIUS^2.
# 	IF (engFS:thrust * engineCount) > (g * SHIP:MASS) {
# 		WAIT 0.1.
# 		STAGE.
# 		WAIT 0.1.
# 		BREAK.
# 		}
# 	ELSE IF catchCount > 50 {
# 		STAGE.
# 		BREAK.
# 		} // If 5 seconds, release stage anyway
# 	WAIT 0.1.
# 	SET catchCount TO (catchCount + 1).
	
	
# 	CLEARSCREEN.	
# 	PRINT ("g: " + SHIP:MASS * g) at(3,5).
# 	PRINT ("Actual Thrust: " + engFS:thrust * engineCount) at(3,6).
# 	PRINT ("Fuel Flow: " + engFS:fuelflow) at(3,7).
# 	PRINT ("catchCount: " + catchCount) at(3,8).
# 	PRINT ("engineCount: " + engineCount) at(3,9).
# 	}
 
# // (engFS:thrust * engineCount) > (g * SHIP:MASS)
 
# // WAIT 5.
# // (ship:availablethrust) > (SHIP:MASS * g)
 
#  // STAGE.		// Clamp Release

# 	LOCAL T0 is time:seconds.
# 	LOCK Te to time:seconds - T0.
# 	SET Launch to "Boost".
# 	SET Insertion to False.
	

# 	// Below simply appears to be messaging.
	
# WHEN Launch = "Turn" THEN {
# 	HUD("FIDO: Starting Gravity Turn."). }
# WHEN Launch = "Second Phase" THEN {
# 	HUD("FIDO: Pitch Currently " + Pa).
# 	HUD("Trajectory Nominal"). }
	
# UNTIL Insertion {

# 		CLEARSCREEN.
# 		LOCK steering to HEADING(az, Pa).	
# 		PRINT ("Mode Set: " + Launch + "           ") at(3,5).
# 		PRINT (az + ", " + ROUND(Pa,1) + "    ") at(3,6).
# 		PRINT ("Radar: " + ROUND(alt:Radar/1000,1) + "         ") at(3,8).
# 		PRINT ("Velocity: " + ROUND(ship:velocity:Surface:Mag,1) + "         ") at(3,9).
# 		PRINT ("Q: " + ROUND(100*ship:Dynamicpressure,1) + "         ") at(3,10).
# 		PRINT ("Vert V: " + ROUND(ship:Verticalspeed,1) + "         ") at(3,11).
# 		//kyle
		
# 		IF Launch = "Boost" {
# 			WHEN ship:velocity:Surface:Mag < 80 THEN { SET Pa to 90. }
# 			WHEN ship:velocity:Surface:Mag > 80 THEN { SET Launch to "Turn". }
# 		}

# 		IF Launch = "Turn" {
			
# 			SET Pa to (90 - 1.4*SQRT( ship:velocity:Surface:Mag - 50 )). // interesting equation						
# 			// WHEN ship:velocity:Surface:Mag > 2000 THEN { SET Launch to "Second Phase". }
# 			WHEN ship:velocity:Surface:Mag > 350 THEN {
# 				WHEN 100*ship:Dynamicpressure < 6 THEN { SET Launch to "Second Phase". }
# 			}
# 			// possibly a second AND condition so we catch it on the way down.
# 		}
		
# 		IF Launch = "Second Phase" {
# 			// WHEN ship:velocity:Surface:Mag > 2700 THEN { SET Pa to 5. SET Insertion to True. }
# 			WHEN 100*ship:Dynamicpressure < 4 THEN {SET Insertion to True. }
# 			//kyle
# 		}
# 		WAIT 0.1.
# 	}
	
# 	// vel-1 is a warning, then vel-2 trips a pitch to 5, and to the next portion of the program.

# HUD("Second Phase Entered."). Wait 0.5.
# SET Ballistic to "Boost Finalization".
# // might just skip the above, or use it to tune to target AP?

# SET Ballistic to "Orbital Insertion".

# Set FinMode to "Init".
# // Set StageTime to 0.
# // Set CurrentThrust to 0. //  variables not yet used

# Set pitchMod to 0. // init
	
# UNTIL alt:Apoapsis  > 200000 AND alt:Periapsis > 160000 {

# 		// Set CurrentThrust to eng:THRUST. // or ship:availablethrust ? // not yet used

# 		CLEARSCREEN.
# 		PRINT ("Mode Set: " + Ballistic + "           ") at(3,5).
# 		PRINT (az + ", " + ROUND(Pa,1) + "    ") at(3,6).
# 		PRINT ("velocity: " + ROUND(ship:velocity:Surface:Mag,1) + "         ") at(3,8).
# 		PRINT ("ETA:A: " + ROUND(eta:Apoapsis,1) + "     ") at(3,10).
# 		PRINT ("Apoapsis: " + ROUND((alt:Apoapsis/1000),1) + " km   ") at(3,12).
# 		PRINT ("Periapsis: " + ROUND((alt:Periapsis/1000),1) + " km   ") at(3,13).
# 		PRINT ("Inclination: " + ROUND((ship:orbit:Inclination),1) + "    ") at(3,15).
# 		PRINT ("FinMode: " + FinMode) at(3,16).
# 		PRINT ("Pitch mod " + ROUND(pitchMod,1)) at (3,17). // to see what a continuous function would suggest
# 		// PRINT ("Time to stage burnout (s): " + StageTime) at(3,15).
# 		PRINT ("ETA:P: " + ROUND(eta:Periapsis,1) + "     ") at(3,18).
	
# 		IF Ballistic = "Boost Finalization" {
# 			Set FinMode to "One".
			
# 			WHEN ship:velocity:Surface:Mag > 4000 THEN {
# 				SET Ballistic to "Orbital Insertion".
# 			}
# 			// attempt to set a sane condition to bump from BF to OI
# 			// IN launch3 might be skipped entirely
# 		}
		
# 		IF Ballistic = "Orbital Insertion" {
# 			IF ship:velocity:Surface:Mag < 4000 {
# 				Set FinMode to "Two pitchMod".
				
# 				SET pitchMod to (-7.25*ln(ETA:Apoapsis)+30.6).
# 				SET Pa to ((90 - 1.4*SQRT( ship:velocity:Surface:Mag - 49 ))+pitchMod). // try using pitchMod as a modifier
				
# 			}
			
# 			ELSE IF ship:velocity:Surface:Mag < 5600 {
# 				Set FinMode to "TwoPointFive w/pitchMod". // normally < 6600, testing wider range
				
# 				IF ETA:Apoapsis > ETA:Periapsis {
# 					SET pitchMod to (-6.05*ln(ETA:Apoapsis)+60). // LOG basic excel fit of the above, to test continuous function handling
# 					SET Pa to pitchMod.
# 				}
				
# 				ELSE {
# 					// SET pitchMod to (-7.25*ln(ETA:Apoapsis)+30.6). // LOG basic excel fit of the above, to test continuous function handling. // not agressive enough to Titan2
# 					SET pitchMod to (-9.16*ln(ETA:Apoapsis)+37.55).
# 					If pitchMod < 0 {SET pitchMod to 0.}
# 					SET Pa to pitchMod.
# 				}
				
# 				// thought: this is at low vel, set it so minimize out at Pa 0
# 			}
			
# 			ELSE IF ship:velocity:Surface:Mag < 6900 {
# 				// Set FinMode to "Three LOGMODE".
					
# 				IF ETA:Apoapsis > ETA:Periapsis { 
# 					Set FinMode to "Three LOGMODE 1".
					
# 					SET etaNeg to ((2*ETA:Periapsis)-ETA:Apoapsis).
# 					SET pitchMod to (0.008*(etaNeg)^2-0.4*(etaNeg)).
# 					// above stolen from line 235 in next segment			
# 					SET Pa to pitchMod.
# 					// SET Pa to 5. 
# 					} // REPLACE THIS. problem is discontinuitey causing wobble.
# 				ELSE IF  ETA:Apoapsis < ETA:Periapsis {
# 					Set FinMode to "Three LOGMODE 2".
					
# 					SET pitchMod to (-0.182*ETA:Apoapsis+1.521). // Linear basic excel fit of the above, to test continuous function handling
# 					SET Pa to pitchMod.
# 				}
# 			}
			
# 			ELSE IF ship:velocity:Surface:Mag < 7700 {
# 				// Set FinMode to "Four".
				
# 				IF ETA:Apoapsis > ETA:Periapsis {
# 					Set FinMode to "Four A".
					
# 					SET etaNeg to ((2*ETA:Periapsis)-ETA:Apoapsis).
# 					SET pitchMod to (0.004*(etaNeg)^2-0.453*(etaNeg)).
# 					SET Pa to pitchMod.
# 				}
# 				ELSE {
# 					Set FinMode to "Four B".
					
# 					SET pitchMod to (0.004*(ETA:Apoapsis)^2-0.453*(ETA:Apoapsis)).
# 					SET Pa to pitchMod.
# 				}
# 				// ELSE IF  ETA:Apoapsis < 45 { SET Pa to 0. }
# 				// ELSE IF ETA:Apoapsis < 90 { SET Pa to -15. }
# 				// ELSE IF ETA:Apoapsis < 240 { SET Pa to -25. }
# 				// ELSE { SET Pa to -35. }
# 			}
			
# 			ELSE {
# 				Set FinMode to "Five". // not really used
				
# 				IF ETA:Apoapsis > ETA:Periapsis { SET Pa to 70. }
# 				ELSE {
# 					IF ETA:Apoapsis < 240 { SET Pa to 0. }
# 					ELSE IF ETA:Apoapsis < 900 { SET Pa to -35. }
# 					ELSE { SET Pa to -70. }
# 				}
# 			}
# 		}
# 	WAIT 0.10.
# 	}

	
# LOCK throttle to 0.
# HUD("FLIGHT: WOOT We are in Orbit!!! *I hope* =D"). WAIT 2.
# HUD("BOOSTER: XFer Stage Engines Shutdown and ready for Lunar Transfer."). WAIT 2.
# HUD("FIDO: Dang it BOOSTER, does that mean I have to do more planning?").  WAIT 4.
# HUD("GUIDO: Apoapsis is " + ROUND((alt:Apoapsis/1000),1) + " km   "). WAIT 1.
# HUD("GUIDO: Periapsis is " + ROUND((alt:Periapsis/1000),1) + " km   "). WAIT 5.
# WAIT Until False.