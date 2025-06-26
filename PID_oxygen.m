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