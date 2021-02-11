function springMassAnimation(p,sol,exportVideo,playbackRate)
% Spring Mass Animation Template
% Input
%   p: Simulation constants
%   sol: Simulation solution
%   exportVideo: Should the video be exported? (True/False)
% Output
%   An animation
% By Andrew Peekema
% Modified Kevin Green 2021

% FPS for playback and video export
FPS = 60; % If your computer cannot plot in realtime lower this.

% For SE3
addpath(fullfile(pwd,'..', 'groupTheory'))
% For CubeClass and SpringClass
addpath(fullfile(pwd,'..', 'visualization'))

% Create objects
massSide = 0.1; % m
massObj = CubeClass(massSide);
wallObj = CubeClass(100);
springObj = SpringClass;

% Create a figure handle
h.figure = figure;
%This sets figure dimension which will dictate video dimensions
h.figure.Position(3:4) = [1280 720];
movegui(h.figure)

% Put the shapes into a plot
massObj.plot
wallObj.plot
springObj.plot

% The wall doesn't move over time
wallObj.globalMove(SE3([-50 0 0]));
wallObj.updatePlotData

% Figure properties
view(2)
title('Simulation')
xlabel('x Position (m)')
ylabel('y Position (m)')
zlabel('z Position (m)')
% These commands set the aspect ratio of the figure so x scale = y scale
% "Children(1)" selects the axes that contains the animation objects
h.figure.Children(1).DataAspectRatioMode = 'manual';
h.figure.Children(1).DataAspectRatio = [1 1 1];

% Setup videowriter object
if exportVideo
   v = VideoWriter('springMass.mp4', 'MPEG-4');
   v.FrameRate = FPS;
   open(v)
end

% Iterate over state data
tic;
for t_plt = sol.x(1):playbackRate*1.0/FPS:sol.x(end)
    
    x_state = deval(sol,t_plt);
    x_pos = x_state(1);

    % Set axis limits (These will respect the aspect ratio set above)
    axis([-0.1 1.9 ... % x
          -1.0 1.0 ... % y
          -1.0 1.0]);  % z

    % Mass position
    massObj.resetFrame
    massObj.globalMove(SE3([p.l0+x_pos+massSide/2 0 0]));

    % Spring position
    springObj.updateState(SE3,p.l0+x_pos);

    % Update data
    massObj.updatePlotData
    springObj.updatePlotData
   
    
    if exportVideo %Draw as fast as possible for video export
        drawnow
        frame = getframe(h.figure);
        writeVideo(v,frame);
    else % pause until 1/FPS of a second has passed then draw
        while( toc < 1.0/FPS)
            pause(0.002)
        end
        drawnow
        tic;
    end % if exportvideo
end % t_plt it = ...

end % springMassAnimation
