function [pos, vel] = paddleMotion(t,c)
% This is a PD + feed forward controller function to track a circle.
% It supports being called in batch mode for retreiving commands after
% simulation (n dimensional input).
% Given:
%   t: current time
%       1xn
%   c.Kp:  position error feedback gain (N/m)
%   c.Kd:  velocity error feedback gain (N/(m/s))
%
% Returns:
%   pos: Current Position of the paddle
%       2xn
%   vel: Current Velocity of the paddle
%       2xn
%
% Kevin Green 2021
assert( isfield(c,'freq'))
assert( isfield(c,'amp'));

pos = c.amp.*sin(t.*c.freq);
vel = c.amp.*c.freq.*cos(t.*c.freq);

end
