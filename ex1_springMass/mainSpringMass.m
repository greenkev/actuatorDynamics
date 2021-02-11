% Simulate, plot, and animate a spring mass damper
% Author: Andrew Peekema
% Modified: Kevin Green 2021

% Initial state conditions
X0 = [1 ... % position (m)
      0];   % velocity (m/s)

% Constants
p.m  = 1;  % mass (kg)
p.c  = 1;  % damper (N*s/m)
p.k  = 20; % spring (N/m)
p.F  = 0;  % force (N)
p.l0 = 1;  % Spring rest length (m)

% Simulate the system
sol = springMassDamperSim(X0,p);

% Plot the position of the mass
figure;
t_plot = linspace( sol.x(1), sol.x(end),500);
% This evaluated the solution at the "t_plot" times. The 1 refers to the
% first component of the state vector which is position.
x_plot = deval(sol,t_plot,1); 
plot(t_plot,x_plot,'-');
title('Mass Response')
xlabel('Time (s)')
ylabel('Position (m)')

% Animate the mass
exportVideo = false;
playbackRate = 1;
springMassAnimation(p,sol,exportVideo,playbackRate);
