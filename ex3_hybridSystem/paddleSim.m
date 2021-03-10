function [t_vec,X_vec] = paddleSim(X0,p,paddleFun)
% Simulates the time response of a spring mass damper
% Given
%   X0:  initial state [position velocity]
%   p.m: mass (kg)
%   p.F: constant force (N)
%   p.e: Coefficient of restitution (0,1]
%   p.d_wall: Distance to the wall (m)
%   paddleMotion: function that returns the pos and vel of the paddle
% Returns
%   t_vec: vector of time
%   X_vec: vector of states
% Author: Kevin Green 2021

% Check necessary parameters exist
assert( isfield(p,'m'))
assert( isfield(p,'e'))
assert( isfield(p,'F'))
t_start = 0;    % Initial time
t_end = 8;     % Ending time 
dt = 0.01;      % Timestep of the return

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

% Loop simulation until we reach t_end
while isempty(t_vec) || t_vec(end) < t_end - dt
    % Run the simulation until t_end or a contact event
    % te, ye and ie describe time, state and ID of the events that occur
    [t,X,te,ye,ie] = ode45(param_dyn, t_start:dt:t_end, X0, options);
    % Setup t_start for the next ode45 call so it is a small time ahead of 
    % the end of the last call's data so  
    t_start = t(end) + dt*1e-10;
    % Concatenate the last ode45 result onto the return vars
    t_vec = [t_vec; t];
    X_vec = [X_vec; X];
    
    % Apply the hybrid map, calculate the post impact velocity
    if ~isempty(ie) && ie(end) == 1 % first event ceiling contact
        X0 = ceilingContactMap(t(end),X(end,:),p);
    end
    if ~isempty(ie) && ie(end) == 2 % second event paddle contact
        X0 = paddleContactMap(t(end),X(end,:),p,paddleFun);
    end
end % simulation while loop

end % paddleSim

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
    % halting event function for ODE simulation. Events are distance to
    % ceiling and distance to paddle
    % Inputs
    % t: time, X: the state, p: parameters structure
    % paddleFun: paddle motion function
    % Outputs
    % eventVal: Vector of event functions that halt at zero crossings
    % isterminal: if the simulation should halt (yes for both)
    % direction: which direction of crossing should the sim halt (positive)
    pos_paddle = paddleFun(t);
    
    dist_wall = X(1) - p.d_wall;
    dist_paddle = pos_paddle - X(1);
    
    eventVal = [dist_wall, dist_paddle];
    isterminal = [1, 1];
    direction = [1, 1];
end % contactEvent

function X_post = ceilingContactMap(t,X_pre,p)
    %The hybrid map to calculate the post impact velocity after ceiling
    %contact
    % t: time
    % X_pre: the state
    % p: parameters structure
    v_post = -p.e*X_pre(2);   
    X_post = [X_pre(1), v_post];
end % ceilingContactMap

function X_post = paddleContactMap(t,X_pre,p,paddleFun)
    %The hybrid map to calculate the post impact velocity after paddle
    %contact
    % t: time
    % X_pre: the state
    % p: parameters structure
    % paddleFun: paddle motion function
    [~, vel_paddle] = paddleFun(t);
    v_post = vel_paddle - p.e*(X_pre(2) - vel_paddle);
    X_post = [X_pre(1), v_post];
end % paddleContactMap
