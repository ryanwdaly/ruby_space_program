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
        launch           #0
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

    def launch
        ctrl.activate_next_stage
        puts "Starting Engines..."
        sleep(4)
        ctrl.activate_next_stage
        puts "Liftoff!"
    end 

    def gravity_turn
        turn_angle = 0 

        loop do 
            sleep(0.5)
            break if vessel.flight.velocity >=75
        end 

        puts "Beginning gravity turn..."
        5.times do 
            turn_angle += 1
            ap.target_pitch_and_heading(90-turn_angle, 90)
            sleep(1)
        end 

        loop do 
            sleep(1)
            break if vessel.flight.prograde >= 85
        end 

        ctrl.sas_mode = :prograde
        puts "Locking AA to vessel prograde"
    end 

    #Stage when vessel thrust == 0 
    def stage_by_thrust
        loop do 
            if vessel.thrust == 0 
                ctrl.activate_next_stage
                break
            end 
        end 
    end 

    #-Assumes 2 tiered fairing stages
    def stage_by_fuel_percent
        loop do 
            break if fuel_percent(vessel, fuel_type) <= given_percent
        end 
        ctrl.activate_next_stage
        stage_by_thrust
    end 

    def fuel_percent
        current_fuel = vessel.resources.amount(fuel_type)
        max_fuel = vessel.resources.max(fuel_type)

        return current_fuel/max_fuel
    end 

    def decent
        loop do 
            sleep(1.0)
            ctr.sas_mode = :prograde if vessel.flight.mean_altitude <= 125000
        end 
    end

    binding.pry
    puts "Done."
end 

x = "hello World"

