% Simulate, plot, and animate a controlled planar mass w/ viscous damping
% Kevin Green 2021

% Initial state conditions
X0 = [0, 0 ...  % position x, position y (m)
      0, 0];    % velocity x, velocity y (m/s)

% Simulation System Constants
p.m  = 1;  % mass (kg)
p.c  = 1;  % damping (N*s/m) Note that this is in both x and y directions

% Controller/Trajectory Constants
c.Kp = 15;          % position error feedback gain (N/m)
c.Kd = 5;           % velocity error feedback gain (N/(m/s))
c.Kff = 1;          % feedforward acceleration gain (N/(m/s^2))
c.center = [1; 1];  % center point of the circle [position_x position_y](m)
c.radius = 0.6;     % radius of the circle to trace (m)
c.frequency = 4;    % angular velocity of the circle (rad/sec)

% Bind the control constants (c) to the controller function
controller_fun = @(t,X) PDTrajectoryController(t,X,c);

% Simulate the system
sol = controlledMassSim(X0,p,controller_fun);

% Plot the position and position error of the mass
figure;
t_plot = linspace( sol.x(1), sol.x(end),500);
r_sim = deval(sol,t_plot); % Get simulated state
[~, r_des, ~, ~] = controller_fun(t_plot, [0;0;0;0]); % Get cmd trajectory

subplot(2,1,1)
plot(t_plot,r_sim(1,:),'-');
hold on
plot(t_plot,r_sim(2,:),'-');
plot(t_plot,r_des(1,:),'--');
plot(t_plot,r_des(2,:),'--');
title('Mass Response')
xlabel('Time (s)')
ylabel('Position (m)')
legend('X Position','Y Position','X Desired','Y Desired')

subplot(2,1,2)
plot(t_plot, r_des(1,:) - r_sim(1,:))
hold on
plot(t_plot, r_des(2,:) - r_sim(2,:))
xlabel('Time (s)')
ylabel('Position Error (m)')
legend('X Error','Y Error')


% Animate the mass
exportVideo = false;
playbackRate = 1.0;
controlledMassAnimation(p,sol,controller_fun,exportVideo,playbackRate);
