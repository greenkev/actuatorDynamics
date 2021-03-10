function paddleAnimation(p,t,X,paddleFun,exportVideo,playbackRate)
% Spring Mass Animation Template
% Input
%   p: Simulation constants
%   sol: Simulation solution
%   exportVideo: Should the video be exported? (True/False)
% Output
%   An animation
% By Kevin Green 2021

% FPS for playback and video export
FPS = 60; % If your computer cannot plot in realtime lower this.

% For SE3
addpath(fullfile(pwd,'..', 'groupTheory'))
% For CubeClass and SpringClass
addpath(fullfile(pwd,'..', 'visualization'))

% Create objects
puck_r = 0.05;
paddle_h = 0.1;
puckObj = SphereClass(puck_r);
wallObj = CubeClass([100,100,0.2]);
paddleObj = CubeClass([0.3, paddle_h]);

% Create a figure handle
h.figure = figure;
%This sets figure dimension which will dictate video dimensions
h.figure.Position(3:4) = [1280 720];
movegui(h.figure)

% Put the shapes into a plot
puckObj.plot
wallObj.plot
paddleObj.plot

% The wall doesn't move over time
wallObj.globalMove(SE3([0 50+p.d_wall+puck_r 0]));
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
   v = VideoWriter('puckAnimation.mp4', 'MPEG-4');
   v.FrameRate = FPS;
   open(v)
end

% Iterate over state data
tic;
for t_plt = t(1):playbackRate*1.0/FPS:t(end)
    
    x_state = interp1(t,X,t_plt);
    x_pos = x_state(1);

    % Set axis limits (These will respect the aspect ratio set above)
    axis([-.6 0.6 ... % x
          -.5 1.3 ... % y
          -1.0 1.0]);  % z

    % Mass position
    puckObj.resetFrame
    puckObj.globalMove(SE3([0, x_pos, 0]));
    
    paddle_pos = paddleFun(t_plt);
    paddleObj.resetFrame
    paddleObj.globalMove(SE3([0, paddle_pos - puck_r - paddle_h/2, 0]))

    % Update data
    puckObj.updatePlotData
    paddleObj.updatePlotData
   
    
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
