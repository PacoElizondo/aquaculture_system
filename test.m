% RAS System Simulation
clear
close
% Time settings
delta_t = 10;                 % Time step [s]
t_max = 86400;                % Total simulation time [s] (1 day)
tspan = 0:delta_t:t_max;

% Initial state [Oxygen, pH, Temperature]
X0 = [2.0; 7.2; 24];          % [mg/L, -, C]

% Define parameters
params.k_a = 0.0045;              % Aeration transfer coefficient [1/s]
params.k_s = 0.02;                % Scrubber pH increase rate [pH/s]
params.k_c = 1e-4;                % Fish CO2 acidification rate [pH/(kg*s)]
params.alpha = 0.002;            % Buffer log-scaling coefficient [1/s]

params.r_f = 2.63e-6;            % Fish O2 consumption [mg/(L*s*kg)]
params.r_b = 0.0005;             % Biofilter O2 demand [mg/(L*s)]

params.k_h = 1e-6;               % Heat loss coefficient [1/(s*C^4)]
params.q_m = 3.6e-5;             % Metabolic heat [C/(kg*s)]
params.k_w = 0.001;              % Water cooling coefficient [1/s]

params.T_ext = 18;              % Ambient temperature [C]
params.T_in = 14;               % Inflow water temperature [C]
params.B = 5146;                % Biomass [kg]

params.scrubber_eff = 0.41;     % Scrubbing efficiency [0–1]
params.biofilter_alk = 0.00215; % Alkalinity pH contribution [pH/s]

% PID controller parameters
params.setpoint = 5.5;          % Target dissolved oxygen [mg/L]
params.Kp = 500;
params.Ki = 0.0;
params.Kd = 0.0;
params.dt = delta_t;            % Sampling interval for PID [s]

% Run simulation
[t, X] = ode45(@(t, X) ras_ode_system(t, X, params), tspan, X0);

% Plot results
figure;
subplot(3,1,1);
plot(t, X(:,1)); ylabel('O_2 [mg/L]'); title('Dissolved Oxygen');
subplot(3,1,2);
plot(t, X(:,2)); ylabel('pH'); title('pH');
subplot(3,1,3);
plot(t, X(:,3)); ylabel('Temp [C]'); xlabel('Time [s]'); title('Temperature');
