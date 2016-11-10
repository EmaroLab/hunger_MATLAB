function [gravity, body] = GetComponents(numSamples,x_axis,y_axis,z_axis,debugMode)
% function [gravity, body] = GetComponents(numSamples,x_axis,y_axis,z_axis,debugMode)
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
% GetComponents discriminates between gravity and body acceleration by
% applying an infinite impulse response (IIR) filter to the raw
% acceleration data (one trial) given in input. The parameter [debugMode]
% is a flag to indicate whether the function should plot the results
% (debugMode = 1) or not (debugMode = 0). Default option is 1.
%
% Input:
%   numSamples --> number of sample points measured by the accelerometer in
%                  the considered trial (or window)
%   x_axis --> acceleration values measured along the x axis in the trial
%              at each given time instant
%   y_axis --> acceleration values measured along the y axis in the trial
%              at each given time instant
%   z_axis --> acceleration values measured along the z axis in the trial
%              at each given time instant
%
% Output:
%   gravity --> matrix of the components of the gravity acceleration along
%               the 3 axes
%   body --> matrix of the components of the body motion acceleration along
%            the 3 axes
%
% Example:
%   1) default - plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity_trial_1 body_trial_1] = GetComponents(numSamples,x_set(:,1),y_set(:,1),z_set(:,1));
%
%   2) explicit plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity_trial_1 body_trial_1] = GetComponents(numSamples,x_set(:,1),y_set(:,1),z_set(:,1),1);
%
%   3) no plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity_trial_1 body_trial_1] = GetComponents(numSamples,x_set(:,1),y_set(:,1),z_set(:,1),0);

% DEFINE THE VALUE FOR FLAG debugMode
if nargin < 5 || isempty(debugMode)
    debugMode = 1;
end

% APPLY IIR FILTER TO GET THE GRAVITY COMPONENTS
% IIR filter parameters (all frequencies are in Hz)
Fs = 32;            % sampling frequency
Fpass = 0.25;       % passband frequency
Fstop = 2;          % stopband frequency
Apass = 0.001;      % passband ripple (dB)
Astop = 100;        % stopband attenuation (dB)
match = 'pass';     % band to match exactly
delay = 64;         % delay (# samples) introduced by filtering
% create the IIR filter
h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
Hd = cheby1(h, 'MatchExactly', match);
% apply the filter on the acceleration signals (to isolate gravity)
g(:,1) = filter(Hd,x_axis);
g(:,2) = filter(Hd,y_axis);
g(:,3) = filter(Hd,z_axis);

% COMPUTE THE BODY-ACCELERATION COMPONENTS BY SUBTRACTION
gravity = zeros(numSamples-delay,3);
body = zeros(numSamples-delay,3);
for i=1:1:(numSamples-delay)
    % shift & reshape gravity to reduce the delaying effect of filtering
    gravity(i,1) = g(i+delay,1);
    gravity(i,2) = g(i+delay,2);
    gravity(i,3) = g(i+delay,3);
    
    body(i,1) = x_axis(i) - gravity(i,1);
    body(i,2) = y_axis(i) - gravity(i,2);
    body(i,3) = z_axis(i) - gravity(i,3);
end

% DEBUG: PLOT RAW DATA, GRAVITY AND BODY ACC. COMPONENTS
if (debugMode == 1)
    time = 1:1:(numSamples-delay);
    figure,
        subplot(3,1,1);
        plot(time,x_axis(1:numSamples-delay),'-r');
        hold on;
        plot(time,gravity(1:numSamples-delay,1),'-g');
        hold on;
        plot(time,body(1:numSamples-delay,1),'-b');    
        axis([0 numSamples-delay -14.709 +14.709]);
        legend('raw acceleration','gravity','body acc.');
        title('Raw acceleration, gravity & body acc. components along the x axis');
        subplot(3,1,2);
        plot(time,y_axis(1:numSamples-delay),'-r');
        hold on;
        plot(time,gravity(1:numSamples-delay,2),'-g');
        hold on;
        plot(time,body(1:numSamples-delay,2),'-b');    
        axis([0 numSamples-delay -14.709 +14.709]);
        legend('raw acceleration','gravity','body acc.');
        title('Raw acceleration, gravity & body acc. components along the y axis');
        ylabel('acceleration [m/s^2] ');
        subplot(3,1,3);
        plot(time,z_axis(1:numSamples-delay),'-r');
        hold on;
        plot(time,gravity(1:numSamples-delay,3),'-g');
        hold on;
        plot(time,body(1:numSamples-delay,3),'-b');    
        axis([0 numSamples-delay -14.709 +14.709]);
        legend('raw acceleration','gravity','body acc.');
        title('Raw acceleration, gravity & body acc. components along the z axis');
        xlabel('time [samples]');
end