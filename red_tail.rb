require 'krpc'
require 'pry'

class RedTail
    attr_reader :client, :vessel, :ctrl, :ap, :fuel_type, :given_percent
    
    def initialize
        @client = KRPC.connect(name: "Red Tail Heavy")
        @vessel = client.space_center.active_vessel
        @ctrl = vessel.control
        @ap = vessel.auto_pilot
        @fuel_type = #fuel_type #should be changed to whats in tank
        @given_percent = 0.15 #should be based on time until burnout
    end 

    def script
        
        pre_launch_prep
        stage_launch_pad            #0
        gravity_turn            
        stage_by_fuel_percent       #1
     
    end 

    def pre_launch_prep
        puts "Pre launch preperation..."
        ctrl.sas = true
        ctrl.sas_mode = :stability_assist
        ap.target_pitch_and_heading(90, 90)
        ctrl.throttle = 1
    end 

    def stage_launch_pad
        ctrl.activate_next_stage
        puts "Starting Engines..."
        sleep(4)
        ctrl.activate_next_stage
        puts "Liftoff!"
    end 

    def gravity_turn
        turn_angle = 0 

        case vessel.flight.velocity
        when  75
            puts "Beginning gravity turn..."
            5.times do 
                turn_angle += 1
                ap.target_pitch_and_heading(90-turn_angle, 90)
                sleep(1)
            end 
        end 

        case vessel.flight.prograde
        when 85
            ctrl.sas_mode = :prograde 
            puts "Locking AA to vessel prograde"
        end 
    end 

    #Stage when vessel thrust == 0 
    def stage_by_thrust
        case vessel.thrust 
        when vessel.thrust == 0 
            ctrl.activate_next_stage 
        end 
    end 

    #-Stage when fuel is less than 12%
    #-Stage when thrust == 0 
    #-Assumes 2 tiered fairing stages
    def stage_by_fuel_percent
        return 0
        #ctrl.activate_next_stage when fuel_percent(vessel, fuel_type) <= given_percent
    end 

    def fuel_percent
        current_fuel = vessel.resources.amount(fuel_type)
        max_fuel = vessel.resources.max(fuel_type)

        return current_fuel/max_fuel
    end 

    def decent
        puts "I need more code"
    end

    binding.pry
    puts "Done."
end 

x = "hello World"
