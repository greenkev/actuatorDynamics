% Simulate, plot, and animate a puck bouncing between a wall and a moving
% paddle
% Author:  Kevin Green 2021

% Initial state conditions
X0 = [ 0.7 ... % position (m)
       0.0];   % velocity (m/s)

% Simulation System Constants
p.m  = 1;  % mass (kg)
p.F = -2; % Constant external force (N)
p.e = 0.9; % Coefficient of restitution (0,1]
p.d_wall = 1.0; % Distance to the wall (m)

% Paddle Trajectory Constants
c.freq = 10;
c.amp = 0.1;

% Bind the paddle motion function
paddleFun = @(t) paddleMotion(t,c);

% Simulate the system
[t_vec,X_vec] = paddleSim(X0,p,paddleFun);

% Plot the position of the mass
figure;
plot(t_vec,X_vec(:,1),'-');
hold on
plot(t_vec,X_vec(:,2),'-');
title('Mass Response')
xlabel('Time (s)')
ylabel('Position (m)')

% Animate the mass
exportVideo = true;
playbackRate = 1;
paddleAnimation(p,t_vec,X_vec,paddleFun,exportVideo,playbackRate);
