function [expData expSigma] = GetExpected(set,K,numGMRPoints,debugMode)
% function [expData expSigma] = GetExpected(set,K,numGMRPoints,debugMode)
%
% -------------------------------------------------------------------------
% Author: Barbara Bruno (dept. DIBRIS, University of Genova, ITALY)
%
% This code is the implementation of the algorithms described in the
% paper "Human motion modeling and recognition: a computational approach".
%
% I would be grateful if you refer to the paper in any academic
% publication that uses this code or part of it.
% Here is the BibTeX reference:
% @inproceedings{Bruno12,
% author = "B. Bruno and F. Mastrogiovanni and A. Sgorbissa and T. Vernazza and R. Zaccaria",
% title = "Human motion modeling and recognition: a computational approach",
% booktitle = "Proceedings of the 8th {IEEE} International Conference on Automation Science and Engineering ({CASE} 2012)",
% address = "Seoul, Korea",
% year = "2012",
% month = "August"
% }
% -------------------------------------------------------------------------
%
% GetExpected performs Gaussian Mixture Modeling (GMM) and Gaussian Mixture
% Regression (GMR) over the given dataset. It returns the expected curve
% (expected mean for each point, computed over the values given in the
% [set]) and associated set of covariance matrices defining the "model"
% of the given dataset. The parameter [debugMode] is a flag to indicate
% whether the function should plot the results (debugMode = 1) or not
% (debugMode = 0). Default option is 1.
%
% Input:
%   set --> either the gravity or the body acc. dataset retrived from
%           CreateDatasets
%   K --> optimal number of clusters to be used to cluster the data
%         of the given dataset retrieved from TuneK
%   numGMRPoints --> number of data points composing the expected curves to
%                    be computed by GMR
%
% Output:
%   expData --> expected curve obtained by modelling the given dataset with
%               the GMM+GMR procedure
%   expSigma --> associated covariance matrices obtained by modelling the
%                given dataset with the GMM+GMR procedure
%
% Examples:
%   1) default - plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numPoints = max(gravity(1,:));
%   scaling_factor = 10/10;
%   numGMRPoints = ceil(numPoints*scaling_factor);
%   [gravity_points gravity_sigma] = GetExpected(gravity,K_gravity,numGMRPoints);
%
%   2) explicit plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numPoints = max(gravity(1,:));
%   scaling_factor = 10/10;
%   numGMRPoints = ceil(numPoints*scaling_factor);
%   [gravity_points gravity_sigma] = GetExpected(gravity,K_gravity,numGMRPoints,1);
%
%   3) no plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numPoints = max(gravity(1,:));
%   scaling_factor = 10/10;
%   numGMRPoints = ceil(numPoints*scaling_factor);
%   [gravity_points gravity_sigma] = GetExpected(gravity,K_gravity,numGMRPoints,0);

% DEFINE THE VALUE FOR FLAG debugMode
if nargin < 4 || isempty(debugMode)
    debugMode = 1;
end

% PARAMETERS OF THE GMM+GMR PROCEDURE
numVar = 4;             % number of variables in the system (time & 3 accelerations)
numData = size(set,2);  % number of points in the dataset

% INITIALIZE THE GAUSSIAN MIXTURE MODEL WITH K-MEANS CLUSTERING
[priors mu sigma] = InitializeGMM(set,K,numVar,0);

% TRAIN THE GAUSSIAN MIXTURE MODEL WITH E-M ALGORITHM
[priors mu sigma] = TrainGMM(K,set,priors,mu,sigma,numVar,numData,0);

% APPLY GAUSSIAN MIXTURE REGRESSION TO FIND THE EXPECTED CURVE
% define the points to be used for the regression
% (assumption: CONSTANT SPACING)
 expData(1,:) = ceil(linspace(min(set(1,:)),max(set(1,:)),numGMRPoints));
% apply GMR to get the expected curve (computed in the given points)
[expData(2:numVar,:), expSigma] = RetrieveModel(K,priors,mu,sigma,expData(1,:),1,2:numVar);

% DEBUG: PLOT THE EXPECTED CURVE AND ASSOCIATED COVARIANCE (2D)
if (debugMode == 1)
    % plot the expected curve and associated covariance projected over 3 2D
    % domains (time + mono-axial acceleration)
    darkcolor = [0.8 0 0];
    lightcolor = [1 0.7 0.7];
    figure,
        % time and acceleration along x
        subplot(3,1,1);
        for i=1:1:numGMRPoints
            sigma = sqrtm(3.*expSigma(:,:,i));
            maximum(i) = expData(2,i) + sigma(1,1);
            minimum(i) = expData(2,i) - sigma(1,1);
        end
        patch([expData(1,1:end) expData(1,end:-1:1)], [maximum(1:end) minimum(end:-1:1)], lightcolor);
        hold on;
        plot(expData(1,:),expData(2,:),'-','linewidth',3,'color',darkcolor);
        axis([min(set(1,:)) max(set(1,:)) min(set(2,:)) max(set(2,:))]);
        title('GMR - expected curve and covariance - x axis');
        % time and acceleration along y
        subplot(3,1,2);
        for i=1:1:numGMRPoints
            sigma = sqrtm(3.*expSigma(:,:,i));
            maximum(i) = expData(3,i) + sigma(2,2);
            minimum(i) = expData(3,i) - sigma(2,2);
        end
        patch([expData(1,1:end) expData(1,end:-1:1)], [maximum(1:end) minimum(end:-1:1)], lightcolor);
        hold on;
        plot(expData(1,:),expData(3,:),'-','linewidth',3,'color',darkcolor);
        axis([min(set(1,:)) max(set(1,:)) min(set(3,:)) max(set(3,:))]);
        title('GMR - expected curve and covariance - y axis');
        ylabel('acceleration [m/s^2]');
        % time and acceleration along z
        subplot(3,1,3);
        for i=1:1:numGMRPoints
            sigma = sqrtm(3.*expSigma(:,:,i));
            maximum(i) = expData(4,i) + sigma(3,3);
            minimum(i) = expData(4,i) - sigma(3,3);
        end
        patch([expData(1,1:end) expData(1,end:-1:1)], [maximum(1:end) minimum(end:-1:1)], lightcolor);
        hold on;
        plot(expData(1,:),expData(4,:),'-','linewidth',3,'color',darkcolor);
        axis([min(set(1,:)) max(set(1,:)) min(set(4,:)) max(set(4,:))]);
        title('GMR - expected curve and covariance - z axis');
        xlabel('time [samples]');
end