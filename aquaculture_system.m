%% Aquaculture system


% initial values
oxygen_0 = 6.0; % mg/L
ph_0 = 7.2;
T_0 = 24; % Tank water temperature in celsius
T_in_0 = 20; % Incoming water temperature
T_ambt = 28; % Ambient temperature



% dynamics
o_dot = ca*aeration_input*(o_sat(temp)-oxygen) - fish_respiration - biofilter_demand;

ph_dot = cs*scrubbing + biofilter_alkalinity - fish_co2;

temp_dot = ambient_heat*(temp-temp_ext) + metabolic_heat - kw*water_cooling*(T-T_in);