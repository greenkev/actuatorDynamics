function [F, r_des, dr_des, ddr_des] = PDTrajectoryController(t,X,c)
% This is a PD + feed forward controller function to track a circle.
% It supports being called in batch mode for retreiving commands after
% simulation (n dimensional input).
% Given:
%   t: current time
%       1xn
%   X: current state [position_x position_y velocity_x velocity_y]
%       4xn or 4x1
%   c.Kp:  position error feedback gain (N/m)
%   c.Kd:  velocity error feedback gain (N/(m/s))
%   c.Kff: feedforward acceleration gain (N/(m/s^2))
%   c.center: center point of the circle [position_x position_y] (m)
%       2x1
%   c.radius: radius of the circle to trace (m)
%   c.frequency: angular velocity of the circle (rad/sec)
%
% Returns:
%   F: Force Command
%       2xn
%   r_des: Desired Position from Trajectory
%       2xn
%   dr_des: Desired Velocity from Trajectory
%       2xn
%   ddr_des: Desired Acceleration from Trajectory
%       2xn
%
% Kevin Green 2021
assert( isfield(c,'Kp'))
assert( isfield(c,'Kd'))
assert( isfield(c,'Kff'))
assert( isfield(c,'center'))
assert( isfield(c,'radius'))
assert( isfield(c,'frequency'))

%Get the desired position, velocity and acceleration of the circular path
[r_des, dr_des, ddr_des] = circularTrajectory(t, c.center, c.radius, ...
                                              c.frequency);
% Get the actual position and velocity of the mass 
r = X(1:2);
dr = X(3:4);
% Calculate control force
F = c.Kp.*(r_des - r) + ...
    c.Kd.*(dr_des - dr) + ...
    c.Kff.*ddr_des;

end


function [r, dr, ddr] = circularTrajectory(t, center, radius, frequency)
% This function returns the 2D position, velocity and accleration of a
% circular trajectory defined by the center, radius and frequency inputs.
r = center + radius.*[sin(t.*frequency); cos(t.*frequency)];
dr = radius.*frequency.*[cos(t.*frequency); -sin(t.*frequency)];
ddr = radius.*frequency.^2.*[-sin(t.*frequency); -cos(t.*frequency)];

end