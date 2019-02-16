
#NEED:  - clearscreen 
#       - heading directions (fixed at 90)

require 'krpc'
require 'pry'

class CronosAutonomous
    attr_reader :client, :vessel, :ctrl, :ap, :target_apoapsis, :target_periapsis, :target_inclination, 
        :first_twr, :second_twr, :final_twr, :end_alt, :final_pitch, :ship_altitude, :target_pitch,
        :target_heading, :flight, :vertical_speed, :horizontal_speed, :orbit, :time_to_apoapsis, :time_to_periapsis, 
        :current_acceleration, :feed_ap, :vel_pot, :ut

    

    def initialize
        @client = KRPC.connect(name: "Cronos Autonomous")
        @vessel = client.space_center.active_vessel
        @ctrl = vessel.control
        @ap = vessel.auto_pilot
        @flight = vessel.flight
        @orbit = vessel.orbit

        #Flight Constants
        @target_heading = 90
        @target_apoapsis = 210000
        @target_periapsis = 210000
        @target_inclination = 0
        @first_twr = 1.21
        @second_twr = 0.81
        @final_twr = 4.64
        @end_alt = (100000/first_twr)
        # @final_pitch = (45/((second_twr+final_twr)/2))
        @final_pitch = 5


        update_flight_variables
    end 

    def update_flight_variables 
       
        @ship_altitude = vessel.flight.mean_altitude.round(2)
        @target_pitch = ([final_pitch, 90 * (1 - (ship_altitude / end_alt))].max).round(2)
        @vertical_speed = (vessel.flight(vessel.orbit.body.reference_frame).vertical_speed).round(2)
        @horizontal_speed = (vessel.flight(vessel.orbit.body.reference_frame).horizontal_speed).round(2)
        @time_to_apoapsis = orbit.time_to_apoapsis
        @time_to_periapsis = orbit.time_to_periapsis
        @current_acceleration = vessel.thrust / vessel.mass
        @feed_ap = orbit.apoapsis_altitude + (vertical_speed * time_to_apoapsis) + 
                    (0.5 * (current_acceleration * Math.sin(prograde_pitch) - 9.81) * (time_to_apoapsis ** 2))
        @vel_pot = (2 * current_acceleration * time_to_apoapsis) + horizontal_speed 
        @ut = client.space_center.ut
        # feedAP to SHIP:APOAPSIS + (SHIP:VERTICALSPEED * TTA) + (0.5 * (currentAcc * sin(progradePitch) - 9.81) * (TTA ^ 2))

    end 

    def run 
        pre_launch_prep
        launch_protocol
        gravity_turn
    end 

    def pre_launch_prep
        # system("clear")
        puts "Pre launch preperation..."
        ctrl.sas = false
        ap.engage
        ap.target_pitch_and_heading(90, 90)
        ctrl.throttle = 1
        
    end 

    def launch_protocol
        ctrl.activate_next_stage
        puts "Starting Engines..."
     
        warming_up = true 
        while warming_up
            warming_up = false if vessel.thrust > 33000000
        end 
        
        ctrl.activate_next_stage
        puts "Liftoff!"
        
    end 

    def gravity_turn
        gravity_turn_complete = false 
        pitch_started = false
        launch_tower_jettisoned = false 
        stage = 1
        update_flight_variables
        vessel_pitch = 90

        until gravity_turn_complete
            
            if ship_altitude < 600
                ap.target_pitch_and_heading(vessel_pitch, 90)
               
            elsif !pitch_started 
                puts "Starting Pitch"
                time_of_launch = ut
                pitch_started = true 

            elsif vessel_pitch > 30 && stage == 1
                pitch_rate = 0.6
                pitch_subtraction = ((ut - time_of_launch) * pitch_rate)
                vessel_pitch = 90 - pitch_subtraction
                ap.target_pitch_and_heading(vessel_pitch, target_heading)

            elsif vessel_pitch <= 30 && stage == 1 && vessel.thrust > 1
                ap.target_pitch_and_heading(30, target_heading)
            
            elsif stage == 1 && vessel.thrust < 1
                vessel_pitch = 30
                puts "Staging..."
                ap.target_pitch_and_heading(vessel_pitch, target_heading)
                ctrl.activate_next_stage
                stage += 1
                sleep(5)
                ctrl.activate_next_stage
                sleep(1)
                puts "Second Stage Achieved"
                time_of_launch = ut


   
            elsif vessel_pitch > 0 && stage == 2
                pitch_rate = 0.07
                starting_pitch = 35
                pitch_subtraction = (ut - time_of_launch) * 0.065
                vessel_pitch = starting_pitch - pitch_subtraction
                ap.target_pitch_and_heading(vessel_pitch, target_heading)

                if ship_altitude >= 70000 && !launch_tower_jettisoned
                    ctrl.activate_next_stage
                    launch_tower_jettisoned = true 
                end     
            
            elsif vessel.thrust < 1 && stage == 2 && launch_tower_jettisoned == true 
                puts "here"
                ctrl.activate_next_stage
                ap.target_pitch_and_heading(0, target_heading)
                if orbit.periapsis_altitude >= 250000
                    ctrl.throttle = 0 
                    puts "Orbit Achieved"
                    gravity_turn_complete = true
                end 
            end 

            render_flight_variables
            sleep(0.01)
        end 
        
 
        puts "Finished"

    end 

    def render_flight_variables
        update_flight_variables
        
        # render_str = ""

        # render_str << "############# Flight Variables ###############\n"
        # # render_str << "Target Pitch: #{target_pitch}\n"
      
        
        
        
        # puts render_str
        
    end 

    def cross_product(u,v)
        return [
            u[1]*v[2] - u[2]*v[1],
            u[2]*v[0] - u[0]*v[2],
            u[0]*v[1] - u[1]*v[0]]
        
    end

    
    # PROBLEMS!!!!!!!!!!!
    def pitch_heading_roll
        # Compute the pitch - the angle between the vesssels direction and the direction
        # in the horizon plane 
        vessel_direction = vessel.direction(vessel.surface_velocity_reference_frame)
        horizontal_direction = [0, vessel_direction[1], vessel_direction[2]]
        pitch = angle_between_vectors(vessel_direction, horizontal_direction)
        pitch = -pitch if vessel_direction[0] < 0
        
        # Compute the heading - the angle between north and the direction in the 
        # horizon plane
        north = [0, 1, 0]
        heading = angle_between_vectors(north, horizontal_direction)
        heading = 360 - heading if horizontal_direction[2] < 0 
        
        # Compute the roll
        # Compute the plane running through the vessels direction and upward direction
        up = [1, 0 , 0]
        plane_normal = cross_product(vessel_direction, up)
        
        # Compute the upwards direction of the vessel
        vessel_up = client.space_center.transform_direction([0, 0, -1], vessel.reference_frame, vessel.surface_reference_frame)
        
        # Compute the angle between the upwards direction of the vessel and the plane normal
        roll = angle_between_vectors(vessel_up, plane_normal)
        
        # Adjust so that the angle is between -180 and 180 and rolling right is +ve and left is -ve
        if vessel_up[0] > 0
            roll *= -1
        elsif roll < 0
            roll += 180
        else 
            roll -= 180
        end 
        
        return "pitch = #{pitch}, heading = #{heading}, roll = #{roll}"
        sleep(1)
    end 
    ##############################################################################################################
    def angle_of_attack
        d = vessel.direction(vessel.orbit.body.reference_frame)
        v = vessel.velocity(vessel.orbit.body.reference_frame)
        
        # Compute the dot product of d and v
        dot_prod = d[0]*v[0] + d[1]*v[1] + d[2]*v[2]
        
        # Compute the magnitude of v
        vmag = Math.sqrt(v[0]**2 + v[1]**2 + v[2]**2)
        # Note: don't need to magnitude of d as it is a unit vector

        # Compute the angle between the vectors
        angle = 0 
        if dot_prod > 0 
           angle = (Math.acos(dot_prod / vmag)).abs * (180.0 / Math::PI)
        end

        return angle
    end 
    ##############################################################################################################
    def prograde_pitch
        north = [0, 1, 0]
        east = [0, 0, 1]
        prograde = vessel.flight(vessel.surface_reference_frame).prograde

        plane_normal = cross_product(north, east)

        return Math.asin(dot_product(plane_normal, prograde)) * (180.0/Math::PI)

    end
    ##############################################################################################################
    def dot_product(u,v)
        return u[0]*v[0]+u[1]*v[1]+u[2]*v[2]
    end 
    ##############################################################################################################
    def magnitude(v)
        return Math.sqrt(dot_product(v, v))
    end 
    ##############################################################################################################
    #computes the angle between vector u and v
    def angle_between_vectors(u, v)
        dp = dot_product(u, v)
        return 0 if dp == 0
        um = magnitude(u)
        vm = magnitude(v)
        return Math.acos(dp / (um*vm)) * (180.0 / Math::PI)
    end 
  

    puts 'Loaded.'
end 

x = CronosAutonomous.new
x.run
