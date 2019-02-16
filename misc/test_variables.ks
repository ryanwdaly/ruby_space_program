	LOCK Tr TO BODY:RADIUS + SHIP:ALTITUDE.
	LOCK Fc TO SHIP:MASS * SHIP:VELOCITY:ORBIT:MAG^2/Tr.
	LOCK Fg TO (CONSTANT:G * SHIP:MASS * BODY:MASS)/(Tr^2).
	LOCK Fs TO Fg - Fc.
	LOCK insin TO MIN(MAX(Fs/SHIP:MAXTHRUST,0.01),SIN(45)).
	LOCK vacuum_pitch TO ARCSIN(insin).

    print "TR: " + Tr.
    print "Fc: " + Fc.
    print "Fg: " + Fg.
    print "Fs: " + Fs.
    print "insine: " + insin.
    print "vacuum_pitch: " + vacuum_pitch.

    print "ship mass: " + SHIP:MASS.
    print "contang g: " + CONSTANT:G.
    print "body mass: " + BODY:MASS.
    print "max thrust: " + SHIP:MAXTHRUST.
    print "orbit speed: " + SHIP:VELOCITY:ORBIT:MAG.
    print "earth radius: " + BODY:RADIUS.
    print "sin 45: " + SIN(45).
    
    