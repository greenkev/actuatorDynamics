function [t_vec,X_vec] = paddleSim(X0,p,paddleFun)
% Simulates the time response of a spring mass damper
% Given
%   X0:  initial state [position velocity]
%   p.m: mass (kg)
%   p.c: damping coefficient (N*s/m)
%   p.k: spring coefficient (N/m)
%   p.F: constant force (N)
%   paddleMotion: function that maps time to pos and vel of the paddle
% Returns
%   t: vector of time
%   x: vector of states
% Author: Kevin Green 2021

% Check necessary parameters exist
assert( isfield(p,'m'))
assert( isfield(p,'e'))
assert( isfield(p,'F'))
t_start = 0;
t_end = 5;
dt = 0.01;

% Bind the dynamics function
param_dyn = @(t,X)dynamics(t,X,p);
% Bind the event function
event_fun = @(t,X)contactEvent(t,X,p,paddleFun);

% Simulation tolerances
options = odeset(...
    'RelTol', 1e-9, ...
    'AbsTol', 1e-9, ...
    'Events',event_fun);
% Simulate the dynamics over a time interval
t_vec = [];
X_vec = [];

while isempty(t_vec) || t_vec(end) < t_end - dt
    [t,X,te,ye,ie] = ode45(param_dyn, [t_start:dt:t_end], X0, options);
    t_start = t(end) + 128*eps;
    t_vec = [t_vec; t];
    X_vec = [X_vec; X];
    if ~isempty(te) 
        X0 = hybridMap(t(end),X(end,:),p,paddleFun);
    end
end

end % springMassDamperSim

function dX = dynamics(t,X,p)
    % t == time
    % X == the state
    % p == parameters structure
    
    x  = X(1); % Position
    dx = X(2); % Velocity

    % Return the state derivative
    dX = zeros(2,1);
    dX(1) = dx;                 % Velocity
    dX(2) = (p.F)/p.m; % Acceleration
end % dynamics

function [eventVal,isterminal,direction] = contactEvent(t,X,p,paddleFun)
    % t == time
    % X == the state
    % p == parameters structure
    % paddleFun == paddle motion function
    pos_paddle = paddleFun(t);
    
    dist_wall = X(1) - p.d_wall;
    dist_paddle = pos_paddle - X(1);
    
    eventVal = [dist_wall, dist_paddle];
    isterminal = [1, 1];
    direction = [1, 1];
end

function X_post = hybridMap(t,X_pre,p,paddleFun)
    [pos_paddle, vel_paddle] = paddleFun(t);
    
    dist_wall = X_pre(1) - p.d_wall;
    dist_paddle = pos_paddle - X_pre(1); 
    
    if abs(dist_wall) < 0.1
        v_post = -p.e*X_pre(2);
    elseif abs(dist_paddle) < 0.1
        v_post = vel_paddle - p.e*(X_pre(2) - vel_paddle);
    else
       v_post = X_pre(2);
%        warning('Contact Event has been triggered incorrectly'); 
    end
    
    X_post = [X_pre(1), v_post];
end



