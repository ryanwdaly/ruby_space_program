require 'krpc'

class RedTailHeavy
    def initialize
        @client = KRPC.connect(name: "sounder II")
        @vessel = client.space_center.active_vessel
        @ctrl = vessel.control
        @fuel_type = #fuel_type #should be changed to whats in tank
        @given_percent = 0.12 #should be based on time until burnout
        run
    end 

    def run
        stage = ctrl.activate_next_stage
        
   
        ctrl.throttle = 1
        stage
        sleep(0.7)
        stage
        stage_by_fuel_percent
        

    end 

    ##############Helper_Methods####################

    def stage_launch
        ctrl.activate_next_stage
        sleep(3)
        ctrl.activate_next_stage
    end 

    #Stage when vessel thrust == 0 
    def stage_by_thrust
        ctrl.activate_next_stage if vessel.thrust == 0 
    end 

    #-Stage when fuel is less than 12%
    #-Stage when thrust == 0 
    #-Assumes 2 tiered fairing stages
    def stage_by_fuel_percent(vessel, ctrl, fuel_type, given_percent)
        ctrl.activate_next_stage  fuel_percent(vessel, fuel_type) <= given_percent
    end 

    def fuel_percent(vessel, fuel_type)
        current_fuel = vessel.resources.amount(fuel_type)
        max_fuel = vessel.resources.max(fuel_type)

        return current_fuel/max_fuel
    end 


end 
