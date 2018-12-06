require 'krpc'
require 'pry'

class RedTail
    
    def initialize
        @client = KRPC.connect(name: "Red Tail Heavy")
        @vessel = client.space_center.active_vessel
        @ctrl = vessel.control
        @ap = vessel.auto_pilot
        @fuel_type = #fuel_type #should be changed to whats in tank
        @given_percent = 0.15 #should be based on time until burnout
    end 

    def launch_script
        pre_launch_prep
        stage_launch_pad            #0
        gravity_turn            
        stage_by_fuel_percent   #1
     
    end 

    def pre_launch_prep
        ctrl.sas = true
        ctrl.sas_mode = :stability_assist
        ap.target_pitch_and_heading(90, 90)
        ctrl.throttle = 1
    end 

    def stage_launch_pad
        ctrl.activate_next_stage
        sleep(4)
        ctrl.activate_next_stage
    end 

    def gravity_turn
        turn_angle = 0 

        when vessel.velocity >= 75
            5.times do 
                turn_angle += 1
                ap.target_pitch_and_heading(90-turn_angle, 90)
                sleep(1)
            end 
        end 

        ctrl.sas_mode = :prograde when vessel.flight.prograde <= 85
    end 

    #Stage when vessel thrust == 0 
    def stage_by_thrust
        ctrl.activate_next_stage when vessel.thrust == 0 
    end 

    #-Stage when fuel is less than 12%
    #-Stage when thrust == 0 
    #-Assumes 2 tiered fairing stages
    def stage_by_fuel_percent
        ctrl.activate_next_stage when fuel_percent(vessel, fuel_type) <= given_percent
    end 

    def fuel_percent
        current_fuel = vessel.resources.amount(fuel_type)
        max_fuel = vessel.resources.max(fuel_type)

        return current_fuel/max_fuel
    end 

    def decent

    end 
end 
