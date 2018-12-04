require 'krpc'
client = KRPC.connect(name: "sounding rocket script")

#setup
sc = client.space_center
vessel = sc.active_vessel
ctrl = vessel.control

require 'krpc'
client = KRPC.connect(name: "sounding rocket script")

#setup
    sc = client.space_center
    vessel = sc.active_vessel
    ctrl = vessel.control

    vessel_pitch = ctrl.pitch 
    

    ctrl.activate_next_stage
    sleep(5)
    ctrl.activate_next_stage

    sleep until vessel.velocity >= 50

       vessel.control.activate_next_stage ();
        vessel.auto_pilot.engage ();
        vessel.AutoPilot.TargetPitchAndHeading (90, 90);

