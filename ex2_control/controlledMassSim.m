function sol = controlledMassSim(X0,p,controller_fun)
% Simulates the time response of a spring mass damper
% Given
%   X0:  initial state [position_x position_y velocity_x velocity_y]
%   p.m: mass (kg)
%   p.c: damping coefficient (N*s/m)
%   controller_fun: controller function, which takes (t,X) and returns 2D
%                   force
% Returns
%   sol: Solution as a "Structure for evaluation", use deval to sample
% Author: Kevin Green 2021

% Check necessary parameters exist
assert( isfield(p,'m'))
assert( isfield(p,'c'))

% Simulation tolerances
options = odeset(...
    'RelTol', 1e-9, ...
    'AbsTol', 1e-9);

% Bind the dynamics function
param_dyn = @(t,X)dynamics(t,X,p,controller_fun);

% Simulate the dynamics over a time interval
sol = ode45(param_dyn, [0,5], X0, options);

end % springMassDamperSim

function dX = dynamics(t,X,p,controller_fun)
    % t == time
    % X == the state
    % p == parameters structure
    % controller_fun == function that takes (t,X) and returns 2D force
    
    r = X(1:2); % Position vector
    v = X(3:4); % Velocity
    % Calculate the vector forces on the mass
    F_ctrl = controller_fun(t,X);
    F_damping = -p.c*v;
    
    % Return the state derivative
    dX = zeros(4,1);
    dX(1:2) = v;                 % Velocity
    dX(3:4) = (F_ctrl + F_damping)./p.m; % Acceleration
end % dynamics
