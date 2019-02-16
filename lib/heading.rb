require 'krpc'
client = KRPC.connect(name: "sounding rocket script")

#setup
    sc = client.space_center
    vessel = sc.active_vessel
    ctrl = vessel.control