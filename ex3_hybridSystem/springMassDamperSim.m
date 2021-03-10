function sol = springMassDamperSim(X0,p)
% Simulates the time response of a spring mass damper
% Given
%   X0:  initial state [position velocity]
%   p.m: mass (kg)
%   p.c: damping coefficient (N*s/m)
%   p.k: spring coefficient (N/m)
%   p.F: constant force (N)
% Returns
%   sol: Solution as a "Structure for evaluation", use deval to sample
% Author: Andrew Peekema
% Modified: Kevin Green 2021

% Check necessary parameters exist
assert( isfield(p,'m'))
assert( isfield(p,'k'))
assert( isfield(p,'F'))
assert( isfield(p,'c'))

% Simulation tolerances
options = odeset(...
    'RelTol', 1e-9, ...
    'AbsTol', 1e-9);

% Bind the dynamics function
param_dyn = @(t,X)dynamics(t,X,p);

% Simulate the dynamics over a time interval
sol = ode45(param_dyn, [0,5], X0, options);

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
    dX(2) = (p.F - p.c*dx - p.k*x)/p.m; % Acceleration
end % dynamics
