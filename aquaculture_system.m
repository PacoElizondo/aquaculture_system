%% Aquaculture system
close all
clear
% we will consider a tank of 46.6m^3 (cylindrical 7m diameter and 1.2m
% depth as per the mid stage of fish growth. No fish growth is
% considered. Food feed is 109kg per day. Obtained from
% Eibeling et. al. doi:10.1002/9781118250105.ch11
% most constants are taken out from the same source. 
delta_t = 10; %s
sim_time = 864; % 10th of a day
tank_volume = 46.6e3;

% Initial values
oxygen_0 = 2.0; % mg/L
co2_0 = 10; % mg/L
ph_0 = 7.2;
T_0 = 18; % Tank water temperature in celsius
T_ext = 18; % Ambient temperature
T_in = 14; % Cooling device water temperature


% Constants
% from Eibeling et. al. doi:10.1002/9781118250105.ch11

biomass = 3000; % kg
oxygen_reference = 5.5; % Also mentioned in the assignment
aeration_efficiency = 0.9*0.005; 
co2_scrub = 0.05; % mg/L best possible result
base_k_a = 0.005;  % typical fine bubble baseline [1/s]
%co2_scrub_efficiency = 1; % percentage from
%doi.org/10.1016/j.aquaeng.2024.102407  this might have been usefull if
%modeling co2 as a part of the state
ph_increase = 0.01; % measurment; ignores the efficiency of the scrub efficiency
fish_oxygen_consumption = 630.7/(tank_volume*biomass); % mg per second considering 0.5kg of oxygen per kg of food fed.
fish_co2_excretion = 1.375*fish_oxygen_consumption; % mg 
biofilter_alkalinity = 0.02; % mg/L  of CaCO3 from doi.org/10.1016/j.aquaeng.2024.102407
alpha = 0.015; % Constant for buffer pH capacity

% Temperature
heat_constant = 1e-6; % Heat loss radiation rate from tank to ambient
 
metabolic_heat = 5e-7; % celsius /kg*s ( Properly, it would be around 1.52e-11) 

biofilter_demand = 0.02;
cool_water_flow = 1e-4; % m³/s ≈ 0.5 tank volume/day
rate_of_change_per_degree = 4186; % Joules/(kg * K)
cooling_rate = (cool_water_flow/tank_volume)*rate_of_change_per_degree*1000;

    

% PID gains
ox_kp = 0.6;
ox_kd = 0.01;
ox_ki = 0.0008;


%state init
oxygen = oxygen_0;
ph = ph_0;
T = T_0;
T_dot = 0;
ph_dot = 0;

error_oxygen_prev = - oxygen - oxygen_reference ;
integral_error_oxygen = 0;

water_cooling = 0;
scrubbing_input = 0;




% plot init

o2_plot = zeros(sim_time,1);
ph_plot = zeros(sim_time,1);
T_plot = zeros(sim_time,1);

for i = 1:sim_time
    
    error_oxygen = oxygen - oxygen_reference;
    derivative_error_oxygen = (error_oxygen - error_oxygen_prev) / delta_t;
    integral_error_oxygen = integral_error_oxygen + error_oxygen * delta_t;
    
    % PID control
    aeration_control = ox_kp * error_oxygen ...
                     + ox_kd * derivative_error_oxygen ...
                     + ox_ki * integral_error_oxygen;


    % Relay control
    
    if ph < 6.8 
        scrubbing_input = 1;
    elseif ph_dot > 0
        if ph > 7.2
            scrubbing_input = 0;
        end
    end
    if T > 22
        water_cooling = 1;
    elseif T_dot < 0
        if T < 21
            water_cooling = 0;
        end
    end

    % dynamics

    
    aeration_input = max(0,  aeration_efficiency*(o_sat(T)-oxygen)*aeration_control);
    o_dot = aeration_input - fish_oxygen_consumption - biofilter_demand;

    
    safe_ph = max(ph, 5e-3);    
    ph_dot = ph_increase*scrubbing_input + biofilter_alkalinity - fish_co2_excretion - alpha*log(safe_ph);
    
    T_dot = -heat_constant*(T-T_ext)^4 + metabolic_heat*biomass - cooling_rate*water_cooling*(T-T_in);


    % Update of the state
    oxygen = oxygen + o_dot*delta_t;
    ph = ph + ph_dot*delta_t;
    T = T + T_dot*delta_t;

    if oxygen < 0, oxygen = 0; end
    if ph < 0, ph = 0; end

    error_oxygen_prev = error_oxygen;

    %plotting
    o2_plot(i) = oxygen;
    ph_plot(i) = ph;
    T_plot(i) = T;

end

figure;
plot(o2_plot);

figure;
plot(T_plot)

figure;
plot(ph_plot)

