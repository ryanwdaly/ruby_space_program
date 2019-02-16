// === Saturn V launch script === 

// action groups
// 1 - life support systems
// 2 - CSM/S-IVB decouple
// 3 - LM/S-IVB decouple
// 4 - CM descent mode
// 7 - S-II/S-IVB all engine shutdown
// 8 - S-II engine shutdown
// 9 - S-I engine shutdown
// 10 - S-IVB RCS thrusters

CLEARSCREEN.

//orbit parameters
SET target_heading TO 90. 

IF SHIP:VERTICALSPEED < 1 {
	// lift off sequence
	PRINT "T minus".
	PRINT "15".
	WAIT 5.
	PRINT "10".
	PRINT "Autosequence launch in progress".
	WAIT 1.
	STAGE. // crew tower
	PRINT "9".
	PRINT "Crew tower jettisoned".
	WAIT 3.
	PRINT "6".
	LOCK THROTTLE TO 1.
	STAGE. // main engines ignition
	PRINT "Ignition sequence start".
	WAIT 1.
	PRINT "5".
	WAIT 1.
	PRINT "4".
	WAIT 1.
	PRINT "3".
	WAIT 1.
	PRINT "2".
	WAIT 1.
	STAGE. //umbilical
	PRINT "1".
	PRINT "Umbillicals jettisoned".
	WAIT 1.
	STAGE. //launch clamps
	PRINT "Lift off".
}

SAS OFF.
LOCK STEERING TO HEADING(90,90).
PRINT "Steering mode 1 engaged".

//atmospheric ascent phase 1, above 100m/s verticalspeed, below 200m/s verticalspeed
WAIT UNTIL SHIP:VERTICALSPEED > 100.
LOCK STEERING TO HEADING(target_heading,81).
PRINT "Steering mode 2 engaged".
PRINT "Pitching to 81 degrees".

//atmospheric ascent phase 2, above 175m/s verticalspeed, below 50000m altitude
WAIT UNTIL SHIP:VERTICALSPEED > 175.
LOCK STEERING TO SRFPROGRADE.
PRINT "Steering mode 3 engaged".
PRINT "Gravity turn in progress".

WAIT UNTIL STAGE:KEROSENE < 80000.
TOGGLE AG9.
PRINT "Shuting down central engine".

//1st stage sep
WAIT UNTIL STAGE:KEROSENE < 10000.
SET situation TO "staging".
WAIT UNTIL SHIP:MAXTHRUST < 1. //MECO
WAIT 2.
RCS ON.
STAGE. //first stage sep, ullage ignition
WAIT 2.
STAGE. //J-2 ignition
PRINT "J-2 engines ignition".
SET SHIP:CONTROL:FORE TO 0.
SET rstage TO 2.
WAIT 5.
RCS OFF.
STAGE. //interstage sep
PRINT "Interstage jettisoned".
WAIT 5.
STAGE. //LES
PRINT "LES jettisoned".
WAIT 2.
SET situation TO "not_staging".

PRINT "Steering mode 4 engaged".
WHEN SHIP:APOAPSIS > 159000 AND situation = "not_staging" THEN {
	LOCK Tr TO BODY:RADIUS + SHIP:ALTITUDE.
	LOCK Fc TO SHIP:MASS * SHIP:VELOCITY:ORBIT:MAG^2/Tr.
	LOCK Fg TO (CONSTANT:G * SHIP:MASS * BODY:MASS)/(Tr^2).
	
	LOCK Fs TO Fg - Fc.
	LOCK insin TO MIN(MAX(Fs/SHIP:MAXTHRUST,0.01),SIN(45)).
	LOCK vacuum_pitch TO ARCSIN(insin).	
	
	PRESERVE.
}

WAIT UNTIL SHIP:APOAPSIS > 160000.
LOCK STEERING TO HEADING(target_heading,(vacuum_pitch/3)).
WAIT UNTIL SHIP:VERTICALSPEED < 1.
LOCK STEERING TO HEADING(target_heading,vacuum_pitch).

WAIT UNTIL STAGE:LQDHYDROGEN < 101000.
PRINT "Shutting down middle engine".
TOGGLE AG8.

WAIT UNTIL STAGE:LQDHYDROGEN < 10000.
SET staging_pitch TO vacuum_pitch.
SET situation TO "staging".
LOCK STEERING TO HEADING(target_heading,staging_pitch).
PRINT "Preparing to stage".

WAIT UNTIL SHIP:MAXTHRUST < 1.
WAIT 2.
RCS ON.
STAGE.
PRINT "Second stage jettisoned".
SET SHIP:CONTROL:FORE TO 1.
WAIT 5.
STAGE.
PRINT "J-2 engine ignition".
SET SHIP:CONTROL:FORE TO 0.
SET rstage TO 2.
WAIT 5.
RCS OFF.
TOGGLE AG10.
WAIT 1.
SET situation TO "not_staging".
WAIT 1.

LOCK STEERING TO HEADING(target_heading,(vacuum_pitch*1.5)).
WAIT UNTIL SHIP:VERTICALSPEED > 0.
LOCK STEERING TO HEADING(target_heading,vacuum_pitch).

WAIT UNTIL SHIP:PERIAPSIS > 140000 AND SHIP:PERIAPSIS > SHIP:ALTITUDE * 0.95.
LOCK THROTTLE TO 0.
PRINT "J-2 engines shutdown".
PRINT "Saturn V in orbit".
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.