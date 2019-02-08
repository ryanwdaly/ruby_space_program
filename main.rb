require 'krpc'
require 'pry'

class GrassHopper
    attr_reader :client, :vessel, :ctrl, :ap, :fuel_type, :given_percent
    def initialize
        @client = KRPC.connect(name: "sounder II")
        @vessel = client.space_center.active_vessel
        @ctrl = vessel.control
        @fuel_type = #fuel_type #should be changed to whats in tank
        @given_percent = 0.12 #should be based on time until burnout
    end 

    def launch
        stage = ctrl.activate_next_stage
        puts "Start."
        stage
        sleep(4)
        stage
        puts "Launch."
        gravity_turn
        stage_by_thrust
        puts "Staged"
        

    end 

    ##############Helper_Methods####################
    def gravity_turn
        while flight.velocity < 75
            ap.target_pitch_and_heading(90, 90)
        end 
        
        ap.target_pitch_and_heading(85, 90)
        sleep(5)

        while flight.mean_altitude < 100000
            ctrl.sas_mode = :prograde
        end 

    end 

    #Stage when vessel thrust == 0 
    def stage_by_thrust
        loop do 
            if vessel.thrust == 0 
                ctrl.activate_next_stage
                sleep(0.1)
                break
            end 
        end 
    end 

    #-Assumes 2 tiered fairing stages
    # def stage_by_fuel_percent
    #     loop do 
    #         break if fuel_percent(vessel, fuel_type) <= given_percent
    #     end 
    #     ctrl.activate_next_stage
    #     stage_by_thrust
    # end 

    # def fuel_percent
    #     current_fuel = vessel.resources.amount(fuel_type)
    #     max_fuel = vessel.resources.max(fuel_type)

    #     return current_fuel/max_fuel
    # end 


    puts "Done."
    
    binding.pry

    def render_info
        system('cls')
        
    end 
    
end 




