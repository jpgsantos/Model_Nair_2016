function [stg] = f_settings_all_TW()
% stg means (settings)

%% Import

% True or false to decide whether to run import functions
% (Import)
stg.import = true;

% Name of the folder where everything related to the model is stored
% (Folder Model)
stg.folder_model = "Model_D1_LTP_time_window";

% Name of the excel file with the sbtab
% (SBtab excel name)
stg.sbtab_excel_name = "D1_LTP_time_window_SBtab.xlsx";

% Name of the model
% (Name)
stg.name = "D1_LTP_time_window";

% Name of the default model compartment
% (Compartment name)
stg.cname = "Spine";

% Name of the sbtab saved in .mat format
% (SBtab name)
stg.sbtab_name = "sbtab_"+stg.name;

%% Analysis

% String with the analysis to be run, the options are "diag",
% "opt", "SA"
% and can be combined as for example "RS,diag", to not run any analysis set
% stg.analysis to equal to ""
% (Analysis)
stg.analysis = "diag";

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
stg.simdetail = true;

%% Simulation

% Maximum time for each individual function to run in seconds
% (Maximum time)
stg.maxt = 10;

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
stg.sbioacc = false;

% Max step size in the simulation (if empty matlab decides whats best)
% (Maximum step)
stg.maxstep = 0.01;

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

% Index for the parameters that have thermodynamic constrains
% (Termodiamic Constrains Index)
stg.tci = [];

% Parameters to multiply to the first parameter (in Stg.partest to get
% to the correct thermodynamic constrain formula)
% (Termodiamic Constrains multipliers)
stg.tcm = [];

% Parameters to divide to the first parameter (in Stg.partest to get to
% the correct thermodynamic constrain formula)
% (Termodiamic Constrains divisors)
stg.tcd = [];

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
stg.partest([216:227],1) =  [1:6,1:6];
%stg.partest([216:227],1) =  [1:12];
% (Parameter array to test)
stg.pat = 1;

% All the parameter arrays, in this case there is only one
% (Parameter arrays)
stg.pa(1,:) = [-6.443697499,-1.638272164,-2.408935393,-5.958607315,-2.26760624,1];
% stg.pa(2,:) = [-7.06271648505259,-0.911947483777705,0.921584010145175,-5.87732329604158,1.01000000000000,1.01000000000000];
% stg.pa(3,:) = [-7.20085458817241,-8.01000000000000,1.01000000000000,-6.06793538748130,-7.94246951614422,0.943872863402740];
% stg.pa(4,:) = [-7.20338699458001,-7.97887371785114,1.01000000000000,-6.03020948484545,-0.229483601794052,0.836382322445649];
% stg.pa(5,:) = [-6.76251722269612,-4.07563169528588,1.01000000000000,-8.01000000000000,1.01000000000000,-7.72901478233823];


% stg.pa(2,:) = [-6.73035061178964,-7.04380022646225,0.569005110183267,-6.19877949677366,0.996597348227969,-7.68326809496575];
% stg.pa(1,:) = [-7.01852509901175,-7.75936616075045,0.343274398885203,-7.03109392578718,-7.84762750313721,-4.14926433212899];

% % Example code to test more than one parameter array
% stg.pat = [1,2];
% stg.pa(2,:) = zeros(1,6);

% Best parameter array found so far for the model
% (Best parameter array)
stg.bestpa = [-6.443697499,-1.638272164,-2.408935393,-5.958607315,-2.26760624,1];
% stg.bestpa = [-7.20085458817241,-8.01000000000000,1.01000000000000,-6.06793538748130,-7.94246951614422,0.943872863402740];
%stg.bestpa = [-6.443697499,-1.638272164,-2.408935393,-5.958607315,-2.26760624,1,-6.443697499,-1.638272164,-2.408935393,-5.958607315,-2.26760624,1];


% Bestpa Experiment E0
% stg.bestpa = [-7.01852509901175,-7.75936616075045,0.343274398885203,-7.03109392578718,-7.84762750313721,-4.14926433212899];

% Bestpa Experiment E2
% stg.bestpa = [-6.98228195008346,-2.82239974076244,0.954773916825491,-7.45258900825495,-7.25760190022186,-4.18225853360734];

% Bestpa Experiment E4
% stg.bestpa = [-6.73035061178964,-7.04380022646225,0.569005110183267,-6.19877949677366,0.996597348227969,-7.68326809496575];

% Bestpa Experiment E8
% stg.bestpa = [-6.69823392525673,-4.01972901784305,0.807120074538823,-7.95096312807615,-0.134931728159146,-7.98748239135517];


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
stg.sansamples = 36;

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

% % Array with the lower bound of all parameters
% % (Lower bound)
% stg.lb = stg.bestpa-0.1;
% 
% % Array with the upper bound of all parameters
% % (Upper bound)
% stg.ub = stg.bestpa+0.1;

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
stg.popsize = 720;

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

% Options for fmincon
% (fmincon options)
stg.fm_options = optimoptions('fmincon',...
    'UseParallel',stg.optmc,...
    'Algorithm','interior-point',...
    'MaxIterations',2,'OptimalityTolerance',0,...
    'StepTolerance',1e-6,'FiniteDifferenceType','central',...
    'MaxFunctionEvaluations',10000);

% True or false to decide whether to run simulated annealing
% (Simulated annealing)
stg.sa = false;

% Options for simulated annealing
% (Simulated annealing options)
stg.sa_options = optimoptions(@simulannealbnd, ...
    'MaxTime',stg.optt,...
    'InitialTemperature',...
    ones(1,stg.parnum)*2,'ReannealInterval',40);

% True or false to decide whether to run Pattern search
% (Pattern search)
stg.psearch = false;

% Options for Pattern search
% (Pattern search options)
stg.psearch_options = optimoptions(@patternsearch,...
    'MaxTime',stg.optt,'UseParallel',stg.optmc,...
    'UseCompletePoll',true,'UseCompleteSearch',true,...
    'MaxMeshSize',2,'MaxFunctionEvaluations',2000);

% True or false to decide whether to run Genetic algorithm
% (Genetic algorithm)
stg.ga = false;

% Options for Genetic algorithm
% (Genetic algorithm options)
stg.ga_options = optimoptions(@ga,'MaxGenerations',100,...
    'MaxTime',stg.optt,'UseParallel',stg.optmc,...
    'PopulationSize',stg.popsize,...
    'MutationFcn','mutationadaptfeasible','Display','diagnose');

% True or false to decide whether to run Particle swarm
% (Particle swarm)
stg.pswarm = true;

% Options for Particle swarm
% (Particle swarm options)
stg.pswarm_options = optimoptions('particleswarm',...
    'MaxTime',stg.optt,'UseParallel',stg.optmc,...
    'SwarmSize',stg.popsize);

% True or false to decide whether to run Surrogate optimization
% (Surrogate optimization)
stg.sopt = false;

% Options for Surrogate optimization
% (Surrogate optimization options)
stg.sopt_options = optimoptions('surrogateopt',...
    'MaxTime',stg.optt,'UseParallel',stg.optmc,...
    'MaxFunctionEvaluations',5000,...
    'MinSampleDistance',0.2,'MinSurrogatePoints',32*2+1);

end