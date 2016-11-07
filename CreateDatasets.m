function [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,debugMode)
% function [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,debugMode)
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
% CreateDatasets computes the gravity and body acceleration components
% of the trials given in the [*_set]s by calling the function GetComponents
% for each trial and reshapes the results into one set of gravity
% components and one set of body acceleration components according to the
% requirements of Gaussian Mixture Modelling. The parameter [debugMode] is
% a flag to indicate whether the function should plot the results
% (debugMode = 1) or not (debugMode = 0). Default option is 1.
%
% Input:
%   numSamples --> number of sample points measured by the accelerometer in
%                  each file (number of rows in the files, that must be
%                  same for ALL files)
%   x_set --> acceleration values measured along the x axis in each file
%             at each given time instant (each column corresponds to the
%             x axis of a file)
%   y_set --> acceleration values measured along the y axis in each file
%             at each given time instant (each column corresponds to the
%             y axis of a file)
%   z_set --> acceleration values measured along the z axis in each file
%             at each given time instant (each column corresponds to the
%             z axis of a file)
%
% Output:
%   gravity --> dataset of the gravity components along the axes with the
%               time indexes and the acceleration values on 4 rows
%               (row2 -> x_axis, row3 -> y_axis, row4 -> z_axis)
%               and all of the trials concatenated one after the other
%   body --> dataset of the body acc. components along the axes with the
%            time indexes and the acceleration values on 4 rows
%            (row2 -> x_axis, row3 -> y_axis, row4 -> z_axis)
%            and all of the trials concatenated one after the other
%
% Examples:
%   1) default - plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set);
%
%   2) explicit plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,1);
%
%   3) no plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);

% DEFINE THE VALUE FOR FLAG debugMode
if nargin < 5 || isempty(debugMode)
    debugMode = 1;
end

% SEPARATE THE GRAVITY AND BODY-MOTION ACCELERATION COMPONENTS
numFiles = size(x_set,2);
% first trial outside of the loop to have meaningful initial values
[gravity_trial body_trial] = GetComponents(numSamples,x_set(:,1),y_set(:,1),z_set(:,1),0);
shortNumSamples = size(gravity_trial,1);
% initial values of the dataset arrays
time = 1:shortNumSamples;
g_x_s = gravity_trial(1:shortNumSamples,1)';
g_y_s = gravity_trial(1:shortNumSamples,2)';
g_z_s = gravity_trial(1:shortNumSamples,3)';
b_x_s = body_trial(1:shortNumSamples,1)';
b_y_s = body_trial(1:shortNumSamples,2)';
b_z_s = body_trial(1:shortNumSamples,3)';
% further trials
for i=2:1:numFiles
    [gravity_trial body_trial] = GetComponents(numSamples,x_set(:,i),y_set(:,i),z_set(:,i),0);
    % CREATE THE DATASETS FOR THE GMMs
    time = cat(2,time,1:shortNumSamples);
    g_x_s = cat(2,g_x_s,gravity_trial(1:shortNumSamples,1)');
    g_y_s = cat(2,g_y_s,gravity_trial(1:shortNumSamples,2)');
    g_z_s = cat(2,g_z_s,gravity_trial(1:shortNumSamples,3)');
    b_x_s = cat(2,b_x_s,body_trial(1:shortNumSamples,1)');
    b_y_s = cat(2,b_y_s,body_trial(1:shortNumSamples,2)');
    b_z_s = cat(2,b_z_s,body_trial(1:shortNumSamples,3)');
end
gravity = cat(1,time,g_x_s,g_y_s,g_z_s);
body = cat(1,time,b_x_s,b_y_s,b_z_s);

% DEBUG: PLOT GRAVITY AND BODY ACC. COMPONENTS
if (debugMode == 1)
    % display the (3D = 4D - time) gravity and body acceleration datasets
    % gravity dataset
    figure,
        scatter3(gravity(2,:),gravity(3,:),gravity(4,:));
        title('3D gravity set (with NO time information)');
        xlabel('x axis');
        ylabel('y axis');
        zlabel('z axis');
        grid on;
    % body dataset
    figure,
        scatter3(body(2,:),body(3,:),body(4,:));
        title('3D body set (with NO time information)');
        xlabel('x axis');
        ylabel('y axis');
        zlabel('z axis');
        grid on;
    % display the 2D gravity and body acceleration datasets
    % reshape the arrays for plotting (from 3D to 2D)
    for i=1:1:numFiles
        [gravity_trial body_trial] = GetComponents(numSamples,x_set(:,i),y_set(:,i),z_set(:,i),0);
        trial_gx(i,:) = gravity_trial(1:shortNumSamples,1)';
        trial_gy(i,:) = gravity_trial(1:shortNumSamples,2)';
        trial_gz(i,:) = gravity_trial(1:shortNumSamples,3)';
        trial_bx(i,:) = body_trial(1:shortNumSamples,1)';
        trial_by(i,:) = body_trial(1:shortNumSamples,2)';
        trial_bz(i,:) = body_trial(1:shortNumSamples,3)';
    end
    figure,
        subplot(3,2,1);
        plot(1:shortNumSamples,trial_gx(:,:));
        title('Gravity');
        subplot(3,2,3);
        plot(1:shortNumSamples,trial_gy(:,:));
        ylabel('acceleration [m/s^2] ');
        subplot(3,2,5);
        plot(1:shortNumSamples,trial_gz(:,:));
        xlabel('time [samples]');
        subplot(3,2,2);
        plot(1:shortNumSamples,trial_bx(:,:));
        title('Body acceleration');
        subplot(3,2,4);
        plot(1:shortNumSamples,trial_by(:,:));
        subplot(3,2,6);
        plot(1:shortNumSamples,trial_bz(:,:));
        xlabel('time [samples]');
    % display each feature in one figure
    figure,
        subplot(3,1,1);
        plot(1:shortNumSamples,trial_gx(:,:));
        title('Gravity');
        subplot(3,1,2);
        plot(1:shortNumSamples,trial_gy(:,:));
        ylabel('acceleration [m/s^2] ');
        subplot(3,1,3);
        plot(1:shortNumSamples,trial_gz(:,:));
        xlabel('time [samples]');
    figure,
        subplot(3,1,1);
        plot(1:shortNumSamples,trial_bx(:,:));
        title('Body acceleration');
        subplot(3,1,2);
        plot(1:shortNumSamples,trial_by(:,:));
        ylabel('acceleration [m/s^2] ');
        subplot(3,1,3);
        plot(1:shortNumSamples,trial_bz(:,:));
        xlabel('time [samples]');
end