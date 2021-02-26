function [stg] = Nair_2018_optimized()
% stg means (settings)

%% Import

% True or false to decide whether to run import functions
% (Import)
stg.import = true;

% Name of the folder where everything related to the model is stored
% (Folder Model)
stg.folder_model = "Nair_2018";

% Name of the excel file with the sbtab
% (SBtab excel name)
stg.sbtab_excel_name = "SBtab_Nair_2018_optimized.xlsx";

% Name of the model
% (Name)
stg.name = "Nair_2018_optimized";

% Name of the default model compartment
% (Compartment name)
stg.cname = "Spine";

% Name of the sbtab saved in .mat format
% (SBtab name)
stg.sbtab_name = "sbtab_"+stg.name;

%% Analysis

% Experiments to run
% (Experiments to run)
stg.exprun = [1:10];

% Choice between 0,1,2 and 3 to change either and how to apply log10 to the
% scores (check documentation)
% (Use logarithm)
stg.useLog = 4;

% True or false to decide whether to use multicore everywhere it is available
% (Optimization Multicore)
stg.optmc = true;

% Choice of ramdom seed
% (Ramdom seed)
stg.rseed = 1;

% True or false to decide whether to use display simulation diagnostics in the
% console
% (Simulation Console)
stg.simcsl = false;

% True or false to decide whether to display optimization results on console 
% (Optimization console)
stg.optcsl = true;

% True or false to decide whether to display PLA results on console 
% (PLA console)
stg.placsl = true;

% True or false to decide whether to save results
% (Save results)
stg.save_results = true;

% True or false to decide whether to run detailed simulation for plots
stg.simdetail = false;

%% Simulation

% Maximum time for each individual function to run in seconds
% (Maximum time)
stg.maxt = 2;

% Equilibration time
% (Equilibration time)
stg.eqt  = 50000;

% True or false to decide whether to do Dimensional Analysis
% (Dimensional Analysis)
stg.dimenanal = true;

% True or false to decide whether to do Unit conversion
% (Unit conversion)
stg.UnitConversion = true;

% True or false to decide whether to do Absolute Tolerance Scaling
% (Absolute Tolerance Scaling)
stg.abstolscale = false;

% Value of Relative tolerance
% (Relative tolerance)
stg.reltol = 1.0E-4;

% Value of Absolute tolerance
% (Absolute tolerance)
stg.abstol = 1.0E-4;

% Time units for simulation
% (Simulation time)
stg.simtime = "second";

% True or false to decide whether to run sbioaccelerate (after changing this value
% you need to run "clear functions" to see an effect)
% (sbioaccelerate)
stg.sbioacc = true;

% Max step size in the simulation (if empty matlab decides whats best)
% (Maximum step)
stg.maxstep = [];

% Max step size in the equilibration (if empty matlab decides whats best)
% (Maximum step)
stg.maxstepeq = [];

% Max step size in the detailed plots (if empty matlab decides whats best)
% (Maximum step)
stg.maxstepdetail = [1];

%% Model

% Number of parameters to optimize
% (Parameter number)
stg.parnum = 6;

% Array with the lower bound of all parameters
% (Lower bound)
stg.lb = zeros(1,stg.parnum)-8;

% Array with the upper bound of all parameters
% (Upper bound)
stg.ub = zeros(1,stg.parnum)+1;

%% Diagnostics

% Choice of what parameters in the array to test, the indices correspond to
% the parameters in the model and the numbers correspond to the parameters
% in the optimization array, usually not all parameters are optimized so
% there needs to be a match between one and the other.
% (Parameters to test)
stg.partest([216:227],1) = [1:6,1:6];

% (Parameter array to test)
stg.pat = [1:1];

% All the parameter arrays, in this case there is only one
% (Parameter arrays)

stg.pa(1,:) = [-6.443697499,-1.638272164,-2.408935393,-5.958607315,-2.26760624,1];


% Best parameter array found so far for the model
% (Best parameter array)
stg.bestpa = [-6.443697499,-1.638272164,-2.408935393,-5.958607315,-2.26760624,1];

%% Plots

% True or false to decide whether to plot results
% (Plots)
stg.plot = true;

% True or false to decide whether to use long names in the title of the outputs
% plots in f_plot_outputs.m
% (Plot outputs long names)
stg.plotoln = true;

%% Sensitivity analysis

% Number of samples to use in SA
% (Sensitivity analysis number of samples)
stg.sansamples = 1000;

% True or false to decide whether to subtract the mean before calculating SI and
% SIT
% (Sensitivity analysis subtract mean)
stg.sasubmean = true;

% Choose the way you want to obtain the samples of the parameters for 
% performing the SA;
% 0 Log uniform distribution truncated at the parameter bounds
% 1 Log normal distribution with mu as the best value for a parameter and
% sigma as stg.sasamplesigma truncated at the parameter bounds
% 2 same as 1 without truncation
% 3 Log normal distribution centered at the mean of the parameter bounds and
% sigma as stg.sasamplesigma truncated at the parameter bounds
% 4 same as 3 without truncation.
% (Sensitivity analysis sampling mode)
stg.sasamplemode = 2;

% Sigma for creating the normal distribution of parameters to perform
% sensitivity analysis
% (Sensitivity analysis sampling sigma)
stg.sasamplesigma = 0.1;

%% Profile Likelihood

% Parameter(optimization array) that is being worked on in a specific
% iteration of PL (if -1 no parameter is being worked in PL)
% (Profile Likelihood Index)
stg.PLind = -1;

% Which parameters to do PL on, it should be all parameters but can also be
% a subset for testing purposes
% (Profile Likelihood parameters to Test)
stg.pltest = (1:6);

% How many points to do for each parameter in the PL
% (Profile Likelihood Resolution)
stg.plres = 900;

% True or false to decide whether to do plots after calculating PL
% (Profile Likelihood Plots)
stg.plplot = true;

% True or false to decide whether to run simulated annealing
% (Profile Likelihood Simulated Annealing)
stg.plsa = true;

% Options for simulated annealing
stg.plsao = optimoptions(@simulannealbnd,'Display','off', ...
    'InitialTemperature',...
    ones(1,stg.parnum-1)*1,'MaxTime',60,'ReannealInterval',40);

% stg.plsao = optimoptions(@patternsearch,...
%     'MaxTime',25,'UseParallel',false,...
%     'UseCompletePoll',true,'UseCompleteSearch',true,...
%     'MaxMeshSize',2,'MaxFunctionEvaluations',2000);

% True or false to decide whether to run fmincon
% (Profile Likelihood FMincon)
stg.plfm = false;

% Options for fmincon
stg.plfmo = optimoptions('fmincon','Display','off',...
    'Algorithm','interior-point',...
    'MaxIterations',20,'OptimalityTolerance',0,...
    'StepTolerance',1e-6,'FiniteDifferenceType','central');


%% Optimization

%  Time for the optimization in seconds (fmincon does not respect this
% time!!)
% (Optimization time)
stg.optt = 60*30;

% Population size for the algorithms that use populations
% (Population size)
stg.popsize = 360;

% optimization start method, choose between:
% 1 Random starting point or group of starting points inside the bounds
% 2 Random starting point or group of starting points near the best point
% (Optimization start method)
stg.osm = 1;

% Distance from best parameter array to be used in stg.osm method 2
% (Distance from best parameter array)
stg.dbpa = 0.1;

% True or false to decide whether to use Multistart
% (Multistart)
stg.mst = false;

% Number of starting points for the optimizations
% (Multistart size)
stg.msts = 5;

% True or false to decide whether to display Plots (Plots doesn't work if using
% multicore)
% (Optimization plots)
stg.optplots = true;

% True or false to decide whether to run fmincon (no gradient so this doesn't work
% very well, no max time!!)
stg.fmincon = false;

% True or false to decide whether to run simulated annealing
% (Simulated annealing)
stg.sa = false;

% True or false to decide whether to run Pattern search
% (Pattern search)
stg.psearch = false;

% True or false to decide whether to run Genetic algorithm
% (Genetic algorithm)
stg.ga = true;

% True or false to decide whether to run Particle swarm
% (Particle swarm)
stg.pswarm = true;

% True or false to decide whether to run Surrogate optimization
% (Surrogate optimization)
stg.sopt = false;

end