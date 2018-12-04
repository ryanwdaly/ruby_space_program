require 'krpc'
client = KRPC.connect(name: "sounding rocket script")

#setup
sc = client.space_center
vessel = sc.active_vessel
ctrl = vessel.control

require 'krpc'
client = KRPC.connect(name: "example")

#setup
    sc = client.space_center
    vessel = sc.active_vessel
    ctrl = vessel.control
    auto_pilot = vessel.auto_pilot

    vessel_pitch = ctrl.pitch 
    

    ctrl.activate_next_stage
    sleep(4)
    ctrl.activate_next_stage

    sleep until vessel.velocity >= 50

       
    auto_pilot.reference_frame = vessel.surface_velocity_reference_frame
    auto_pilot.target_direction = (0, 1, 0)
    auto_pilot.engage() until vessel.thrust == 0 
    


