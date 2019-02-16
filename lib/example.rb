
    radius = 200000
    ship_altitude = 140000
    vessel_mass = 500000
    vessel_velocity = 3500
    body_mass = 5972000000000000000000000
    vessel_thrust = 3000000
    tr = radius + ship_altitude
    fc = vessel_mass * vessel_velocity**2/tr
    fg = (9.81 * vessel_mass * body_mass)/(tr**2)

    fs = fg-fc

    insin = [[fs/vessel_thrust, 0.01].max, Math.sin(45)].min

    vacuum_pitch = Math.asin(insin)
puts vacuum_pitch