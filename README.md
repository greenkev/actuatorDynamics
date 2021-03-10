# actuatorDynamics
This is the repository for example MATLAB code to simulate a spring mass damper. It was created for Oregon State University's ME 536 (Actuator Dynamics) class. It is based off Andrew Peekmea's code but is heavily modified and extended.

This repo contains some basic utilities (groupTheory and visualization) and three examples of simulating dynamic systems.
More information on each example can be found in the readme in their respective folder.

## Example 1: Spring Mass
This example simulated a damped spring mass in the presence of an external force. 

https://user-images.githubusercontent.com/31672703/110689775-f2e3eb00-8197-11eb-9f48-023c00abd432.mp4

This example illustrates:
- Basic usage of ODE45().
- Use of the solution results structure and deval() function to sample the resulting solution.
- Binding parameters to an autonomous function for use as the dynamics.
- Use of a structure for dynamics parameters.
- Animation using our visualization interfaces and transformations.
- Exporting a video file using MATLAB's VideoWriter().

## Example 2: Control
This example simulated a point mass with viscous friction moving in 2D under the influence of a 2D control force.

https://user-images.githubusercontent.com/31672703/110690045-4c4c1a00-8198-11eb-9ca0-8ff68f031652.mp4

This example illustrates:
- An approach to seperate command trajectory, controller and system dynamics into seperate functions.

## Example 3: Hybrid Simulation
This example simulated a puck under the influence of a constant force that bounces between a moving paddle and a stationary ceiling. The paddle moves with prescribed sinusoidal motion, which can be thought of as having infinite mass and a infinitely strong actuator moving it. 

https://user-images.githubusercontent.com/31672703/110690173-76054100-8198-11eb-8da1-b2fc7c0f8194.mp4

This example illustrates:
- Use of event functions to halt ODE45().
- Differentiating between different events.
- Use of sampled results from ODE45() instead of the solution structure.
- Application of hybrid jump maps for impact events.
- Interpolating sampled results for animation.


