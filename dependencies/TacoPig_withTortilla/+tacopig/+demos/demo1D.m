%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Gaussian Process Demo Script
%  Demonstrates GP regression using the taco-pig toolbox on 1-D Data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Add optimization folder
if ~exist('minfunc')
    fprintf('It looks like you need to add minfunc to your default path...\n');
    fprintf('(Add tacopig/optimization/minfunc{/mex} to pathdef.m for permanent access)\n');
    fprintf('Press any key to attempt to continue...\n');
    pause();
end
p = pwd(); slash = p(1);
addpath(genpath(['..',slash,'optimization']))


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1-D Example%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
close all; clear all; clear functions; clc;
% import tacopig.*;

%% Set up 1-D Data
% Training Data
% Rasmussen & Williams "Gaussian Processes for Machine Learning", Fig. 2.5
% X = [-2.1775,-0.9235,0.7502,-5.8868,-2.7995,4.2504,2.4582,6.1426,...
%     -4.0911,-6.3481,1.0004,-4.7591,0.4715,4.8933,4.3248,-3.7461,...
%     -7.3005,5.8177,2.3851,-6.3772];
% y = [1.4121,1.6936,-0.7444,0.2493,0.3978,-1.2755,-2.221,-0.8452,...
%     -1.2232,0.0105,-1.0258,-0.8207,-0.1462,-1.5637,-1.098,-1.1721,...
%     -1.7554,-1.0712,-2.6937,-0.0329];

X = [-7.3005, -6.3772, -6.3481, -5.8868, -4.7591, -4.0911, -3.7461,...
    -2.7995, -2.1775, -0.9235, 0.7502, 1.0004, 2.3851, 2.4582,...
    4.2504, 4.3248, 4.8933, 5.8177, 6.1426];

y = [ -3.1593, -2.6634, -2.6364, -2.5123, -2.0282, -2.2231, -2.4161,...
    -2.1390, -1.5605, -1.4464, -0.4838, -0.2821, -1.4956,...
    -1.6061, -2.8353, -2.7971, -2.5217, -2.2265, -2.1399];


xstar = linspace(-8, 8, 201); 

% Order data points for visualisation
[X id] = sort(X);
y = y(id)+0.1*randn(size(y));

%% Set up Gaussian process

% Use a standard GP regression model:
GP = tacopig.gp.Regressor;

% Plug in the data
GP.X = X;
GP.y = y;

% Plug in the components
GP.MeanFn  = tacopig.meanfn.FixedMean(mean(y));
% GP.CovFn   = tacopig.covfn.Sum(tacopig.covfn.Mat3(),tacopig.covfn.SqExp());%SqExp();
GP.CovFn   = tacopig.covfn.SqExp();
GP.NoiseFn = tacopig.noisefn.Stationary();
% GP.objective_function = @tacopig.objectivefn.CrossVal;
GP.objective_function = @tacopig.objectivefn.NLML;

% GP.solver_function = @anneal;

% Initialise the hyperparameters
GP.covpar   = 0.5*ones(1,GP.CovFn.npar(size(X,1)));
GP.meanpar  = zeros(1,GP.MeanFn.npar(size(X,1)));
GP.noisepar = 1e-1*ones(1,GP.NoiseFn.npar);


%% Before Learning: Query
GP.solve(); 
[mf, vf] = GP.query(xstar);
sf  = sqrt(vf);

% Display predicitve mean and variance
figure
plot(X, y, 'k+', 'MarkerSize', 17)
f  = [mf+2*sf,flipdim(mf-2*sf,2)]';
h(1) = fill([xstar, flipdim(xstar,2)], f, [6 6 6]/8, 'EdgeColor', [6 6 6]/8);
hold on
h(2) = plot(xstar,mf,'k-','LineWidth',2);
h(3) = plot(X, y, 'k+', 'MarkerSize', 17);
title('Before Hyperparameter Training');
legend(h,'Predictive Standard Deviation','Predictive Mean', 'Training Points','Location','SouthWest')

%% Learn & Query
disp('Press any key to begin learning.')
pause
GP.learn();
GP.solve();
[mf, vf] = GP.query(xstar);
sf  = sqrt(vf);

% Display learnt model
figure
plot(X, y, 'k+', 'MarkerSize', 17)
f  = [mf+2*(sf),flipdim(mf-2*(sf),2)]';
h(1) = fill([xstar, flipdim(xstar,2)], f, [6 6 6]/8, 'EdgeColor', [6 6 6]/8);
hold on
h(2) = plot(xstar,mf,'k-','LineWidth',2);
h(3) = plot(X, y, 'k+', 'MarkerSize', 17);
title('After Hyperparameter Training');
legend(h,'Predictive Standard Deviation','Predictive Mean', 'Training Points','Location','SouthWest')

fprintf('Press any key to draw samples from these distributions...\n');
pause

%% Generate samples from prior and posterior
figure; subplot(1,2,1)
xstar = linspace(-8,8,100);
hold on;
for i = 1:5
    fstar = GP.sampleprior(xstar);
    plot(xstar,fstar, 'color', rand(1,3));
end
title('Samples from Prior')

subplot(1,2,2)
plot(X, y, 'k+', 'MarkerSize', 17)
xstar = linspace(-8,8,100);
hold on;
for i = 1:5
    fstar = GP.sampleposterior(xstar, 50+i);
    plot(xstar,fstar, 'color', rand(1,3));
end
title('Samples from Posterior')

