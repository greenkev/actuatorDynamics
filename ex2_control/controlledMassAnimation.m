function controlledMassAnimation(p,sol,controller_fun,exportVideo,playbackRate)
% Controlled Mass Animation Template
% Input
%   p: Simulation constants
%   sol: Simulation solution
%   exportVideo: Should the video be exported? (True/False)
% Output
%   An animation
% 
%  Kevin Green 2021

% FPS for playback and video export
FPS = 60; % If your computer cannot plot in realtime lower this.
Force_arrow_scale = 20; %Visual scaling, m/N

% For SE3
addpath(fullfile(pwd,'..', 'groupTheory'))
% For CubeClass and SpringClass
addpath(fullfile(pwd,'..', 'visualization'))

% Create objects
massSide = 0.1; % m
targetRadius = 0.025; % m
massObj = CubeClass(massSide);
targetObj = SphereClass(targetRadius);

% Create a figure handle
h.figure = figure;
%This sets figure dimension which will dictate video dimensions
h.figure.Position(3:4) = [1280 720];
movegui(h.figure)

% Put the shapes into a plot
massObj.plot
targetObj.plot

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
   v = VideoWriter('controlledMass.mp4', 'MPEG-4');
   v.FrameRate = FPS;
   open(v)
end

%Plot the trajectory
tspan = sol.x(1):playbackRate*1.0/FPS:sol.x(end);
[~, r_des, ~, ~] = controller_fun(tspan, [0;0;0;0]);
plot3(r_des(1,:), r_des(2,:), -0.1*ones(size(r_des(1,:))))
% Plot a force Vector
force_arrow = quiver3(0,0,1,0.1,0.1,0.1,0,'color',[0.3922, 0.7020, 0.4235]);
force_arrow.LineWidth = 2;

% Iterate over state data
tic;
for t_plt = sol.x(1):playbackRate*1.0/FPS:sol.x(end)
    
    x_state = deval(sol,t_plt);
    x_pos = x_state(1);
    y_pos = x_state(2);
    
    [F, r_des, ~, ~] = controller_fun(t_plt, x_state);

    % Set axis limits (These will respect the aspect ratio set above)
    axis([0 2 ... % x
          0 2 ... % y
          -1.0 1.0]);  % z

    % Mass position
    massObj.resetFrame
    massObj.globalMove(SE3([x_pos y_pos 0]));
    targetObj.resetFrame
    targetObj.globalMove(SE3([r_des(1) r_des(2) 0.1]));

    % Update data
    massObj.updatePlotData
    targetObj.updatePlotData
    
    %Update Force Vector
    force_arrow.XData = x_pos;
    force_arrow.YData = y_pos;
    force_arrow.UData = Force_arrow_scale*F(1);
    force_arrow.VData = Force_arrow_scale*F(2);
   
    
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
