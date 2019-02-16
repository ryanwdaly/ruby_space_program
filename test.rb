require 'krpc'
require 'pry'

class SaturnV
    
    attr_reader :client, :vessel, :ctrl, :ap, :flight, :orbit, :current_stage, :target_heading, 
    :earth_mass, :earth_radius, :vertical_speed, :horizontal_speed, :time_to_apoapsis, 
    :ship_altitude, :time_to_periapsis, :current_acceleration
    



    def initialize
        @client = KRPC.connect(name: "Saturn V")
        @vessel = client.space_center.active_vessel
        @ctrl = vessel.control
        @ap = vessel.auto_pilot
        @flight = vessel.flight
        @orbit = vessel.orbit
        @current_stage = 0

        #Flight Constants
        @target_heading = 90
        @earth_mass = 5.972 * 10**24
        @earth_radius = 6371393 
        flight_variables
    end 

    def flight_variables 
        @ship_altitude = vessel.flight.mean_altitude
        @vertical_speed = (vessel.flight(vessel.orbit.body.reference_frame).vertical_speed)
        @horizontal_speed = (vessel.flight(vessel.orbit.body.reference_frame).horizontal_speed)
        @time_to_apoapsis = orbit.time_to_apoapsis
        @time_to_periapsis = orbit.time_to_periapsis
        @current_acceleration = vessel.thrust / vessel.mass


      

    end 

    def run 
        pre_launch_prep
        launch_protocol
        ascent
    end 

    def pre_launch_prep
        # system("clear")
        puts "Pre launch preperation..."

        ap.engage
        ap.target_pitch_and_heading(90, 90)
        ctrl.throttle = 1 
    end 

    def launch_protocol
        ctrl.activate_next_stage
        puts "Starting Engines..."
     
        sleep(1) until vessel.thrust > 33000000
        
        ctrl.activate_next_stage
        puts "Liftoff!"
        current_stage = 1
    end 

    def ascent
        puts "Gravity Turn Program."
        orbit_achieved = false 

        until orbit_achieved
            flight_variables

            pitch(90) if vertical_speed < 100 

            pitch(79) if vertical_speed >= 100 && vertical_speed < 175
            
            if vertical_speed >= 175 && orbit.apoapsis_altitude < 160000
                ap.reference_frame = vessel.surface_velocity_reference_frame
                ap.target_direction = [0, 1, 0]
            end 
            
            pitch(second_stage_pitch/3) if vertical_speed > 1 && orbit.apoapsis_altitude > 160000

            pitch(second_stage_pitch) if vertical_speed < 1 && orbit.apoapsis_altitude > 160000
 
            # stage(current_stage) if vessel.thrust < 1
            if vessel.thrust < 1
                puts "Staging..."
                ctrl.activate_next_stage
                sleep(5)
                ctrl.activate_next_stage
                sleep(1)
                puts "Second Stage Achieve"
                ctrl.activate_next_stage
            end


    
        end 

    end
    #################################

    def pitch(target_pitch) 
        ap.disengage
        ap.engage
        ap.target_pitch_and_heading(target_pitch, target_heading)
    end 

    def cross_product(u,v)
        return [
            u[1]*v[2] - u[2]*v[1],
            u[2]*v[0] - u[0]*v[2],
            u[0]*v[1] - u[1]*v[0]]
    end

    def dot_product(u,v)
        return u[0]*v[0]+u[1]*v[1]+u[2]*v[2]
    end 

    def prograde_pitch
         tr = 6371393  + ship_altitude
        fc = vessel.mass * orbit.speed**2/tr
        fg = (9.81 * vessel.mass * (5.972 * 10**24))/(tr**2)
        fs = fg-fc
        insin = [[fs/vessel.thrust, 0.01].max, Math.sin(45)].min
        vacuum_pitch = Math.asin(insin)

        puts "tr: " + tr
        puts "fc: " + fc
        puts "fg: " + fg
        puts "fs " + fs 
        puts "insin: " + insin
        puts "vacuum_pitch: " + vacuum_pitch

    end

    def second_stage_pitch
        tr = 6371393  + ship_altitude
        fc = vessel.mass * orbit.speed**2/tr
        fg = (9.81 * vessel.mass * (5.972 * 10**24))/(tr**2)
        fs = fg-fc

        insin = [[fs/vessel.thrust, 0.01].max, Math.sin(45)].min
        vacuum_pitch = Math.asin(insin)
        puts vacuum_pitch
    end 

    def stage(current_stage)
        if current_stage == 1
            puts "Staging..."
            ctrl.activate_next_stage
            sleep(6)
            ctrl.activate_next_stage
            sleep(1)
            puts "Second Stage Achieve"
            ctrl.activate_next_stage
            current_stage = 2
        elsif current_stage == 2
            ctrl.activate_next_stage
        end 
    end 
    binding.pry
end 

x = SaturnV.new
x.run
