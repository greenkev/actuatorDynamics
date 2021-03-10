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




