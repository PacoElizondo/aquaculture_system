%% Aquaculture system

% we will consider a tank of 46.6m^3 (cylindrical 7m diameter and 1.2m
% depth as per the mid stage of fish growth. No fish growth is
% considered. Food feed is 109kg per day. Obtained from
% Eibeling et. al. doi:10.1002/9781118250105.ch11
% most constants are taken out from the same source. 
delta_t = 10; %s
sim_time = 8640; % day

% Initial values
oxygen_0 = 2.0; % mg/L
co2_0 = 10; % mg/L
ph_0 = 7.2;
T_0 = 24; % Tank water temperature in celsius
T_in_0 = 21.5; % Incoming water temperature
T_ext = 18; % Ambient temperature
T_in = 14;


% Constants
% from Eibeling et. al. doi:10.1002/9781118250105.ch11
biomass = 5146; % kg
oxygen_reference = 5.5; % Also mentioned in the assignment
aeration_efficiency = 0.9*0.005; 
co2_scrub = 0.5; % mg/L best possible result
base_k_a = 0.005;  % typical fine bubble baseline [1/s]
co2_scrub_efficiency = 0.41; % percentage from doi.org/10.1016/j.aquaeng.2024.102407
ph_increase = 0.02; % per second
fish_oxygen_consumption = 630.7e-6; % mg per second considering 0.5kg of oxygen per kg of food fed.
fish_co2_excretion = 1.375*fish_oxygen_consumption; % mg 
biofilter_alkalinity = 0.002; % mg/L  of CaCO3 from doi.org/10.1016/j.aquaeng.2024.102407
alpha = 0.002; % Constant for buffer pH capacity
heat_constant = 1e-6;
metabolic_heat = 3.6e-5; % celsius /kg*s
cooling_rate = 0.001;
biofilter_demand = 0.02;
tank_volume = 46.6e3;

% PID gains
ox_kp = 0.1;
ox_kd = 10;
ox_ki = 0.1;


%state init
oxygen = oxygen_0;
ph = ph_0;
T = T_0;

error_oxygen_prev = oxygen_reference - oxygen;
integral_error_oxygen = 0;




% plot init

o2_plot = zeros(sim_time,1);
ph_plot = zeros(sim_time,1);
T_plot = zeros(sim_time,1);

for i = 1:sim_time
    
    error_oxygen = oxygen_reference - oxygen;
    derivative_error_oxygen = error_oxygen_prev - error_oxygen;
    integral_error_oxygen = integral_error_oxygen + error_oxygen*delta_t;

    if ph < 6.8 
        scrubbing_input = 1;
    else
        scrubbing_input = 0;
    end
    if T > 22
        water_cooling = 1;
    else
        water_cooling = 0;
    end

    % dynamics
    aeration_control = ox_kp*error_oxygen + ox_kd*derivative_error_oxygen + ox_ki*integral_error_oxygen;
    aeration_input = max(0, min(1, aeration_efficiency*(o_sat(T)-oxygen)*aeration_control));
    % o_dot = aeration_input - biomass*fish_oxygen_consumption/(biomass*tank_volume) - biofilter_demand; % fish respiration depends on food intake (metabolism) considered constant
    o_dot = aeration_input - biomass*fish_oxygen_consumption/(biomass*tank_volume) - biofilter_demand;
    me = aeration_input
    
    
    safe_ph = max(ph, 1e-3);
    ph_dot = ph_increase*co2_scrub_efficiency*scrubbing_input + biofilter_alkalinity - fish_co2_excretion - alpha*log(safe_ph)
    
    T_dot = heat_constant*(T-T_ext)^4 + metabolic_heat*biomass - cooling_rate*water_cooling*(T-T_in);

    oxygen = oxygen+o_dot*delta_t;
    ph = ph + ph_dot*delta_t;
    T = T + T_dot*delta_t;

    error_oxygen_prev = oxygen_reference - oxygen;

    %plotting

    o2_plot(i) = oxygen;
    ph_plot(i) = ph;
    T_plot(i) = T;

end

plot(o2_plot);

