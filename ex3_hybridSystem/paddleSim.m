function [t_vec,X_vec,sol_set] = paddleSim(X0,p,paddleFun)
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
% Setup data structures
t_vec = t_start:dt:t_end;
X_vec = zeros(length(X0), length(t_vec));
sol_set = {};

% Loop simulation until we reach t_end
while t_start < t_end
    % Run the simulation until t_end or a contact event
    sol = ode45(param_dyn, [t_start,t_end], X0, options);
    % Concatenate the last ode45 result onto the sol_set cell array. We
    % can't preallocate because we have no idea how many hybrid transitions
    % will occur
    sol_set = [sol_set, {sol}];
    % Setup t_start for the next ode45 call so it is at the end of the 
    % last call 
    t_start = sol.x(end);    
    % Apply the hybrid map, calculate the post impact velocity
    if ~isempty(sol.ie) && sol.ie(end) == 1 % first event ceiling contact
        X0 = ceilingContactMap(sol.xe(end),sol.ye(:,end),p);
    end
    if ~isempty(sol.ie) && sol.ie(end) == 2 % second event paddle contact
        X0 = paddleContactMap(sol.xe(end),sol.ye(:,end),p,paddleFun);
    end
end % simulation while loop


% Loop to sample the solution structures and built X_vec
for idx = 1:length(sol_set)
    % This sets up a logical vector so we can perform logical indexing
    t_sample_mask = t_vec >= sol_set{idx}.x(1) & t_vec <= sol_set{idx}.x(end);
    % Evaluate the idx solution structure only at the applicable times
    X_eval = deval(sol_set{idx}, t_vec(t_sample_mask));
    % Assign the result to the correct indicies of the return state array
    X_vec(:,t_sample_mask) = X_eval;
end

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
