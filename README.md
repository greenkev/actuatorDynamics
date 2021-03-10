# actuatorDynamics
This is the repository for example MATLAB code to simulate a spring mass damper. It was created for Oregon State University's ME 536 (Actuator Dynamics) class. It is based off Andrew Peekmea's code but is heavily modified and extended.

This repo contains some basic utilities (groupTheory and visualization) and three examples of simulating dynamic systems.
More information on each example can be found in the readme in their respective folder.

## Example 1: Spring Mass
This example simulated a damped spring mass in the presence of an external force. 

![springMass](https://user-images.githubusercontent.com/31672703/110690996-6d613a80-8199-11eb-88a4-de6cb397bd76.gif)

This example illustrates:
- Basic usage of ODE45().
- Use of the solution results structure and deval() function to sample the resulting solution.
- Binding parameters to an autonomous function for use as the dynamics.
- Use of a structure for dynamics parameters.
- Animation using our visualization interfaces and transformations.
- Exporting a video file using MATLAB's VideoWriter().

## Example 2: Control
This example simulated a point mass with viscous friction moving in 2D under the influence of a 2D control force.

![controlledMass](https://user-images.githubusercontent.com/31672703/110691031-77833900-8199-11eb-844a-515e47ab14c7.gif)

This example illustrates:
- An approach to seperate command trajectory, controller and system dynamics into seperate functions.

## Example 3: Hybrid Simulation
This example simulated a puck under the influence of a constant force that bounces between a moving paddle and a stationary ceiling. The paddle moves with prescribed sinusoidal motion, which can be thought of as having infinite mass and a infinitely strong actuator moving it. 

![Paddle](https://user-images.githubusercontent.com/31672703/110691057-7fdb7400-8199-11eb-8688-e6eb1dfb8ae8.gif)

This example illustrates:
- Use of event functions to halt ODE45().
- Differentiating between different events.
- Use of sampled results from ODE45() instead of the solution structure.
- Application of hybrid jump maps for impact events.
- Interpolating sampled results for animation.
