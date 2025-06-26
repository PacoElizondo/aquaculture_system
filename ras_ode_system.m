function dXdt = ras_ode_system(t, X, params)
% State vector
O = X(1);   % Dissolved Oxygen [mg/L]
P = X(2);   % pH [-]
T = X(3);   % Temperature [Celsius]

% Unpack parameters
k_a = params.k_a;         % Aeration coefficient [1/s]
k_s = params.k_s;         % Scrubber pH boost rate [pH/s]
k_c = params.k_c;         % CO2 acidification rate [pH/(kg*s)]
alpha = params.alpha;     % Buffer log coefficient [1/s]

r_f = params.r_f;         % Fish O2 demand [mg/(L*s*kg)]
r_b = params.r_b;         % Biofilter O2 demand [mg/(L*s)]

k_h = params.k_h;         % Heat loss coefficient [1/(s*C^4)]
q_m = params.q_m;         % Metabolic heat [C/(kg*s)]
k_w = params.k_w;         % Cooling from water [1/s]

T_ext = params.T_ext;     % Ambient temp [C]
T_in = params.T_in;       % Inflow temp [C]
B = params.B;             % Biomass [kg]

scrubber_eff = params.scrubber_eff;         % Scrubber efficiency [0–1]
biofilter_alk = params.biofilter_alk;       % Alkalinity effect [pH/s]

% Control inputs
u_a = PID_oxygen(O, params);     % Aeration on/off [0-1]
u_s = double(P < 6.8);            % Scrubber trigger
u_w = double(T > 22);            % Cooling trigger

% Saturation DO (Weiss 1970)
O_sat = O_sat_weiss(T);

% Differential equations
dOdt = k_a * (O_sat - O) * u_a - r_f * B - r_b;
dPdt = k_s * scrubber_eff * u_s + biofilter_alk - k_c * B - alpha * log(max(P, 1e-3));
dTdt = -k_h * (T - T_ext)^4 + q_m * B - k_w * u_w * (T - T_in);

% Output derivative vector
dXdt = [dOdt; dPdt; dTdt];
end


function O_sat = O_sat_weiss(T)
% Saturation DO from Weiss 1970 in mg/L
T_K = T + 273.15;
A1 = -173.4292; A2 = 249.6339;
A3 = 143.3483;  A4 = -21.8492;
ln_O = A1 + A2 * (100 ./ T_K) + A3 * log(T_K / 100) + A4 * (T_K / 100).^2;
O_molkg = exp(ln_O);           % mol/kg
O_sat = O_molkg * 32 * 1000;   % mg/L
end


function u_a = PID_oxygen(O, params)
% PID control for dissolved oxygen
persistent integral prev_error
if isempty(integral), integral = 0; prev_error = 0; end

setpoint = params.setpoint;
error = setpoint - O;
integral = integral + error * params.dt;
derivative = (error - prev_error) / params.dt;

u = params.Kp * error + params.Ki * integral + params.Kd * derivative;
u_a = max(0, min(1, u));

prev_error = error;
end
