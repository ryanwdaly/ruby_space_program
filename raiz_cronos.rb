
#NEED:  - clearscreen 
#       - heading directions (fixed at 90)

require 'krpc'
require 'pry'

class CronosAutonomous
    attr_reader :client, :vessel, :ctrl, :ap, :target_apoapsis, :target_periapsis, :target_inclination, 
        :first_twr, :second_twr, :final_twr, :end_alt, :final_pitch, :ship_altitude, :target_pitch,
        :target_heading, :flight, :vertical_speed, :horizontal_speed, :orbit, :time_to_apoapsis, :time_to_periapsis, 
        :current_acceleration, :feed_ap, :vel_pot

    

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

        # feedAP to SHIP:APOAPSIS + (SHIP:VERTICALSPEED * TTA) + (0.5 * (currentAcc * sin(progradePitch) - 9.81) * (TTA ^ 2))

    end 

    def run 
        pre_launch_prep
        launch_protocol
        gravity_turn
    end 

    def pre_launch_prep
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
        
        
        while ship_altitude < 90000
            if vessel.thrust < 1
                ctrl.activate_next_stage
                sleep(5)
                ctrl.activate_next_stage
            end
            ap.target_pitch_and_heading(target_pitch, target_heading)
            sleep(0.001)
            render_flight_variables
        end 

        # Decouple escape tower
        ctrl.activate_next_stage
        adjusted_target_pitch = target_pitch

        while orbit.apoapsis_altitude < target_periapsis
            ctrl.activate_next_stage if vessel.thrust < 1

            if (feed_ap < target_periapsis || vel_pot < 7400) && adjusted_target_pitch < 20 
                adjusted_target_pitch += 0.05
                sleep(0.01)
            end 
            
            if (feed_ap > target_periapsis || vel_pot > 7400) && adjusted_target_pitch > -10
                adjusted_target_pitch -= 0.05
                sleep(0.01)
            end 
            ap.target_pitch_and_heading(adjusted_target_pitch, target_heading)
            render_flight_variables
        end 

        while (orbit.apoapsis_altitude < (target_apoapsis * 1.01)) && orbit.periapsis_altitude < 160000
            if vertical_speed > 20.0 && adjusted_target_pitch > -10
                adjusted_target_pitch -= 0.12
                ap.target_pitch_and_heading(adjusted_target_pitch, target_heading)
                sleep(0.01)
            elsif (vertical_speed < -20.0) && adjusted_target_pitch < 15
                adjusted_target_pitch += 0.12
                ap.target_pitch_and_heading(adjusted_target_pitch, target_heading)
                sleep(0.01)
            elsif (vertical_speed >= -20.0) && adjusted_target_pitch <= 20.0
                if adjusted_target_pitch > 0
                    adjusted_target_pitch -= 0.12
                    ap.target_pitch_and_heading(adjusted_target_pitch, target_heading)
                    sleep(0.01)
                end 
                if adjusted_target_pitch < 0
                    adjusted_target_pitch += 0.12
                    ap.target_pitch_and_heading(adjusted_target_pitch, target_heading)
                    sleep(0.01)
                end 
            end       
        end 

        

        # 	if mode = 8 {
# 		if SHIP:APOAPSIS > targetPeriapsis {
# 			lock throttle to 0.
# 			timetoAP().
# 			if TTA > 20{
# 				set warp to 2.
# 			}
# 			if TTA < 20{
# 				set warp to 0.
# 				lock steering to heading (90,0) + R(0,0,startRoll).
# 				wait 5.
# 				lock throttle to 1.
# 				set mode to 9.
# 			}
# 		}
			
# 		if SHIP:APOAPSIS < targetPeriapsis {
# 			lock steering to heading (90,0) + R(0,0,startRoll).
# 			wait 1.
# 			lock throttle to 0.2.
# 		}
# 	}

        ctrl.throttle = 0

        # while orbit.periapsis_altitude < target_apoapsis
        #     ctrl.activate_next_stage if vessel.thrust < 1
        #     ap.target_pitch_and_heading(0, target_heading)
        # end 
    end 

    def render_flight_variables
        update_flight_variables
        
        render_str = ""

        render_str << "############# Flight Variables ###############\n"
        # render_str << "Target Pitch: #{target_pitch}\n"
        render_str << "Angle of Attack: #{angle_of_attack}\n"
        render_str << "Orbital Prograde Pitch: #{prograde_pitch}\n"
        render_str << "Current Acceleration: #{current_acceleration}\n"
        system ("clear")
        puts render_str
        
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

##########################################################################
 
	

	
	
# 	if mode = 9 {
# 		lock throttle to 0.
# 		unlock steering.
# 		print "Launch Program Concluded".
# 		set mode to 0.

# 	}

# }

# function timetoAP{
# 	set TTA to ETA:APOAPSIS.

# 	if ETA:APOAPSIS > (SHIP:OBT:PERIOD / 2) {
# 		set TTA to ETA:APOAPSIS - SHIP:OBT:PERIOD.
# 	}
# }

# function proPitch {
	
# 	return 90 - vang(ship:up:vector, ship:velocity:surface).
# }
