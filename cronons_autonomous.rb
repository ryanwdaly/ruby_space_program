
#NEED:  - clearscreen 
#       - heading directions (fixed at 90)

require 'krpc'
require 'pry'

class CronosAutonomous
    attr_reader :client, :vessel, :ctrl, :ap, :target_apoapsis, :target_periapsis, :target_inclination, 
        :first_twr, :second_twr, :final_twr, :end_alt, :final_pitch, :ship_altitude, :target_pitch,
        :target_heading, :flight, :surface_velocity

    def initialize
        @client = KRPC.connect(name: "Raiz Space Launch Script")
        @vessel = client.space_center.active_vessel
        @ctrl = vessel.control
        @ap = vessel.auto_pilot
        @flight = vessel.flight

        #Flight Constants
        @target_heading = 90.0
        @target_apoapsis = 210000
        @target_periapsis = 210000
        @target_inclination = 28.6
        @first_twr = 1.23
        @second_twr = 0.77
        @final_twr = 5.67
        @end_alt = (100000/first_twr)
        @final_pitch = (45/((second_twr+final_twr)/2))
        @fuel_type = #fuel_type #should be changed to whats in tank
        @given_percent = 0.15 #should be based on time until burnout
        
        update_flight_variables
    end 

    def update_flight_variables 
        @ship_altitude = vessel.flight.mean_altitude.round(2)
        @target_pitch = ([final_pitch, 90 * (1 - (ship_altitude / end_alt))].max).round(2)
        @surface_velocity = vessel.flight(vessel.orbit.body.reference_frame).vertical_speed
        # @current_acceleration = 

    end 

    def run 
        pre_launch_prep
        launch
        gravity_turn
    end 

    def pre_launch_prep
        puts "Pre launch preperation..."
        ctrl.sas = false
        ap.target_pitch_and_heading(0, 90.0)
        ctrl.throttle = 1
        vessel.auto_pilot.engage()
        
    end 

    def launch
        ctrl.activate_next_stage
        puts "Starting Engines..."
     
        # warming_up = true 
        # while warming_up
        #     warming_up = false

        # end 
        sleep(12.0)
        ctrl.activate_next_stage
        puts "Liftoff!"
    end 

    def gravity_turn
        
        while ship_altitude < 140000
            ap.target_pitch_and_heading(0.0, target_heading)
            sleep(0.001)
            ctrl.activate_next_stage if vessel.thrust < 1
            render_flight_variables
        end 


        # while ship_altitude <= 750 
        #     sleep(0.01)
        #     ap.target_pitch_and_heading(90, 90)
            
        #     render_flight_variables
        # end 

        # initial_pitch = 90
        # while initial_pitch > 85
        #     initial_pitch -= 1
        #     ap.target_pitch_and_heading(initial_pitch, target_heading)
        #     sleep(1)

        #     render_flight_variables #fix
        # end 

        # sleep(5)

        # while vessel.thrust > 1
        #     ctrl.sas = true
        #     ctrl.sas_mode = :prograde

        #     render_flight_variables #fix
        # end 

        # ctrl.activate_next_stage
        # ctrl.sas = false

        # while ship_altitude < 140000
        #     ap.target_pitch_and_heading(target_pitch, target_heading)

        #     render_flight_variables #fix
        # end 

        # puts 'Vacuum Reached.'
        # #toggle action group?
        

    end 

    def render_flight_variables
        update_flight_variables

        system ("clear")
        puts "############# Flight Variables ###############"
        puts "Altitude: #{ship_altitude}"
        puts "Target Pitch: #{target_pitch}"
        puts "Velocity: #{surface_velocity}"
    end 

  

    puts 'Loaded.'
end 



x = CronosAutonomous.new
x.run

##########################################################################
# clearscreen.
# lock throttle to 0.
# wait 5.

# set targetApoapsis to 35786000. 
# set targetPeriapsis to 210000. 
# set targetInclination to 28.6.
# set firstTWR to 1.25.
# set secondTWR to 0.80.
# set finalTWR to 6.8.
# set endAlt to (100000/firstTWR).
# set finalPitch to (45/((secondTWR+finalTWR)/2)).
# set startRoll to 270.

# set mode to 1.


# until mode = 0{

                
                ##########   PRE LAUNCH PREP  #################
# 	if mode = 1 {
# 		lock throttle to 1.
# 		stage.
# 		wait 4.
# 		stage.

# 		lock steering to heading (90,90) + R(0,0,startRoll).
# 		wait 2.
# 		set mode to 2.
# 	}


###########  INITIAL TREGECTORY  ##################
# - Runs until ship altitude == 140,000km 
# - If thrust < 1, stage
# - set target pitch to either final pitch or 1 - 	
###################################################
    #if mode = 2 {
	
# 		set targetPitch to (max(finalPitch,90 * (1 - (SHIP:ALTITUDE / endAlt)))).
# 		wait 0.001.
# 		lock steering to heading (90,targetPitch) + R(0,0,startRoll).
		
# 		if SHIP:MAXTHRUST < 1{
# 			stage.
# 			wait 1.
# 		}
		
# 		if SHIP:ALTITUDE > 140000 {
# 			toggle ag1.
# 			set mode to 3.
# 		}	
# 	}
    
############  
# 	if mode = 3 {
# 		timetoAP().
		
# 		if SHIP:MAXTHRUST > 1 {
# 			set currentAcc to SHIP:MAXTHRUST / SHIP:MASS.
# 		}
		
# 		set progradePitch to proPitch().
		
# 		set feedAP to SHIP:APOAPSIS + (SHIP:VERTICALSPEED * TTA) + (0.5 * (currentAcc * sin(progradePitch) - 9.81) * (TTA ^ 2)).
# 		set velPot to (2 * currentAcc * TTA) + SHIP:GROUNDSPEED.
		
# 		if (feedAP < targetPeriapsis OR velPot < 7400) AND targetPitch < 20{
# 			set targetPitch to targetPitch + 0.05.
# 			wait 0.01.
# 		}
		
# 		if (feedAP > targetPeriapsis OR velPot > 7400) AND targetPitch > -10{
# 			set targetPitch to targetPitch - 0.05.
# 			wait 0.01.
# 		}
		
# 		if SHIP:APOAPSIS > targetPeriapsis {
# 			set mode to 4.
# 		}
# 	}
	
# 	if mode = 4{
# 		if SHIP:VERTICALSPEED > 20.0 and targetPitch > -10{
# 			set targetPitch to targetPitch - 0.12.
# 			lock steering to heading (90,targetPitch) + R(0,0,startRoll).
# 			wait 0.01.
# 		}

# 		else if SHIP:VERTICALSPEED < -20.0 and targetPitch < 15{
# 			set targetPitch to targetPitch + 0.12.
# 			lock steering to heading (90,targetPitch) + R(0,0,startRoll).
# 			wait 0.01.
# 		}

# 		else if SHIP:VERTICALSPEED >= -20.0 and SHIP:VERTICALSPEED <= 20.0 {
# 			if targetPitch > 0 {
# 				set targetPitch to targetPitch - 0.12.
# 				lock steering to heading (90,targetPitch) + R(0,0,startRoll).
# 				wait 0.01.
# 			}
# 			if targetPitch < 0 {
# 				set targetPitch to targetPitch + 0.12.
# 				lock steering to heading (90,targetPitch) + R(0,0,startRoll).
# 				wait 0.01.
# 			}
# 		}
	
# 		if SHIP:APOAPSIS > targetApoapsis * 1.01 and SHIP:PERIAPSIS > 160000{
# 			lock throttle to 0.
# 			wait 2.
# 			set mode to 9.
# 		}
# 	}
	
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
