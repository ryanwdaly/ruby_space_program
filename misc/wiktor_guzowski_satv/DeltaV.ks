CLEARSCREEN.
PARAMETER impulse.

SET nd TO NEXTNODE.
SET dV TO nd:DELTAV:MAG.
LIST ENGINES IN shipEngines.
SET Ve TO impulse * 9.80665.
PRINT "Exhaust velocity = " + ROUND(Ve) + "m/s".
SET F TO SHIP:MAXTHRUST * 1000.
PRINT "Thrust = " + ROUND(F) + "N".
SET m0 TO SHIP:MASS * 1000.
PRINT "Mass = " + ROUND(m0) +"kg".
SET e TO CONSTANT:E.

LOCK t TO Ve*m0 *(1-e^(- dV/Ve))/F.
PRINT "Manouver time = " + ROUND(t) + "s".

LOCK ttb TO nd:ETA - t/2.
PRINT "Time to burn = " + ROUND(ttb) + "s".