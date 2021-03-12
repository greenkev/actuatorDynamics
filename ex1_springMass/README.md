# Example 1: Spring Mass

This example illustrates basic usage of ODE45( ) along with some good practices.

**Basic ode45 Usage**

ode45 when called will forward simulate the dynamic system provided to it using an explicit Runge-Kutta (4,5) formula. 
More info on the exact algorithm and other options can be found on its [MATLAB reference page](https://www.mathworks.com/help/matlab/ref/ode45.html).

The relevant commands in this example are in `springMassDamperSim.m`:
```MATLAB
% Simulation tolerances
options = odeset(...
    'RelTol', 1e-9, ...
    'AbsTol', 1e-9);
```
Most of the time we would like to configure the settings of the simulation we are running. 
To keep the actual ODE call simpler we use a settings structure (`options`) which is created using `odeset( )`.
Here we just set the relative and absolute tolerances for the numeric integration.
```MATLAB
% Simulate the dynamics over a time interval
sol = ode45(param_dyn, [0,5], X0, options);
```
This is the actual command that runs the simulation. 
The first entry is the dynamics function (more on this below).
The second is the timespan which can either be the start and end time or a list of times that you want the solution sampled.
When you use the start and end time function will return a solution structure which offers some advantages (more on this below).
The third entry is the starting state (position and velocity in this example). 
It is very important that this is the correct size or you will get kind of tricky errors in your dynamics function.

**Dynamics Structure**

Often our dynamics are parameterized and it is very useful to be able to adjust these parameters quickly. 
For example, maybe we want to experimentally adjust the damping of our spring to get a certain behavior.
It is best practice to have these user adjustable parameter at the top level script.
We do this in a clean and simple way by using a parameter structure ('p')that gets passed to the simulation and the dynamics function.
The definition of this structure is in the `mainSpringMass.m` script:
```MATLAB
% Constants
p.m  = 1;  % mass (kg)
p.c  = 1;  % damper (N*s/m)
p.k  = 20; % spring (N/m)
p.F  = 0;  % force (N)
p.l0 = 1;  % Spring rest length (m)
```
Matlab is quite flexible with structures so we can simply define the fields we want in our structure and assign them a value immediately.
This parameter structure is then passed to the simulation function,
```MATLAB
% Simulate the system
sol = springMassDamperSim(X0,p);
```
and later to the dynamics function.

**Binding Parameters to an Anonymous Function**

ode45 requires a very specific format for the dynamics function. 
The dynamics function must take exactly 2 inputs (current time, current state) and return the rate of change of the state.
This restriction stops us from including any sort of parameter definition without a little extra work.
We get around this by using an Anonymous Function Handle.
The idea is that we can define a function that we can use elsewhere.

As a simple example we can create a function then immediately use it:
```MATLAB
C = 10;
myFun = @(x) C + x + x^2;
disp(myFun(2))
C = 0;
disp(myFun(2))
```
When we run this it displays "16" followed by "16".
What is happening is that we have defined a function handle and stored it in `myFun`.
The `@(x)` is what tells MATLAB that this is a function, that it has one input, and this input will be refered to as `x` in the function definition.
This function handle uses the local variable `C` in its definition.
When we define the function, we can say we have bound the value of the variable to the function.
You can picture that the value of variable `C` at this point in time is copied to the function definition.
This explains why when we change the value of `C`, we get the same result.

In our simulation code, this is how we pass the parameters to the dynamics function.
This is done in `springMassDamperSim.m` immediately before the ode45 call.
```MATLAB
% Bind the dynamics function
param_dyn = @(t,X)dynamics(t,X,p);
```
We setup `param_dyn` to be a function handle that takes in only `(t,X)`, as ode45 requires.
The definition of this new function handle is simply the dynamics function we define below in the file but using the `p` structure from the local scope.
When ode45 called this `param_dyn` function it will instead call `dynamics` using the parameter structure as it existed when this handle was defined.

**The Solution Results Structure**

MATLAB ODE solvers can return results in two ways, either as a sampled vector array of times and states or as a structure.
The solution structure has some key advantages that make it a good choice in many situations.
It stores the actual integration steps that ode45 took as well as information about the integration method.
This means that later when we sample points it uses the interpolation method connected to the actual integrator.
It also means that we store and pass the minimal ammount of information necessary to describe the trajectory.
To get the solution structure we have to use a timespan that consists of only the start and end points (e.g. `[t0 tf]`) instead of an array of sample times (e.g. `t0:dt:tf`).

To sample the solution so we can plot the results we use the `deval( )` function.
This code from `mainSpringMass.m` shows how to sample 500 points and plot them
```MATLAB
% Plot the position of the mass
figure;
t_plot = linspace( sol.x(1), sol.x(end), 500);
% This evaluated the solution at the "t_plot" times. The 1 refers to the
% first component of the state vector which is position.
x_plot = deval(sol,t_plot,1); 
plot(t_plot,x_plot,'-');
```
First we generate a list of 500 evenly spaced points over the timespan of the simulation results.
In the `sol` structure, `sol.x` is the array of independent variables at the integration steps which in our problem is the time.
We then call `deval( )` which will apply the correct interpolation method from the ode solver function.
As a point of comparison we can look at what would happen if we used a naive linear interpolation between sample points.
To make the difference clearer, we lower the ode45 absolute and relative tolerance to `1e-2`.
The result is shown in the figure below

![Comaprison between native interpolation using deval and naive linear interpolation](https://user-images.githubusercontent.com/31672703/110877590-75e76d00-828e-11eb-82be-b3811bb1aaee.png)

We can see how the integrator took very large steps from to the roughness of the linear interpolation (`interp1( )`).
However, the interpolation using `deval( )` is still quite smooth and shows the underdamped behavior we expect from this example.
There are places where it makes more sense to sample the solution when we call the ode45 function, such as in example 3 where we work with a hybrid system.
