CLEARSCREEN.
PARAMETER impulse.
SET shipstatus TO "before_manouver".
SET nd TO NEXTNODE.

SET dV TO nd:DELTAV:MAG.
LIST ENGINES IN shipEngines.
SET Ve TO impulse * 9.80665. //comverting isp in s to exhaust velocity in m/s
SET F TO SHIP:MAXTHRUST * 1000. //converting thrust in kiloNewtons to thrust in Newtones
SET m0 TO SHIP:MASS * 1000.  //converting mass in tons to mass in kg
SET e TO CONSTANT:E.  //eulers number

PRINT "Exhaust velocity = " + ROUND(Ve) + "m/s" AT(0,20).

LOCK t TO Ve*m0 *(1-e^(- dV/Ve))/F.
LOCK ttb TO nd:ETA - t/2.

WHEN shipstatus <> "after_manouver" THEN {
	PRINT "Maxthrust = " + ROUND(F) + "N" AT(0,21).
	PRINT "Mass = " + ROUND(m0) +"kg" AT(0,22).
	PRINT "Burn time = " + ROUND(t) + "s" AT(0,23).
	PRINT "Time to manouver = " + ROUND(ttb) + "s" AT(0,24).
	WAIT 1.
	PRESERVE.
}

WAIT UNTIL ttb < 150.
PRINT "Starting manouver".
SET shipstatus TO "during_manouver".
SAS ON.
RCS ON.
SET SASMODE TO "MANEUVER".

WAIT UNTIL ttb < 15.
PRINT "Ullage ignition".
SET SHIP:CONTROL:FORE TO 1.   //firing RCS to provide ullage thrust
WAIT 15.
PRINT "Engine ignition, executing maneuver node".
LOCK THROTTLE TO 1.
SET SHIP:CONTROL:FORE TO 0.

WHEN THROTTLE > 0.01 THEN   //calculating, if node dv is decreasing or increasing
{
	SET dv0 TO nd:DELTAV:MAG.
	WAIT 0.1.
	SET dv1 TO nd:DELTAV:MAG.
	SET ddv TO dv0 - dv1.
	PRESERVE.
}

WAIT UNTIL ddv < 0 OR nd:DELTAV:MAG < 1.   //wait until node dv start to increase or node dv is less than 3m/s
LOCK THROTTLE TO 0.
SET shipstatus TO "after_manouver".
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
PRINT "Node executed, engine shutdown".