function [gravity body] = AnalyzeActualWindow(window,window_size)
% function [gravity body] = AnalyzeActualWindow(window,window_size)
%
% -------------------------------------------------------------------------
% Author: Barbara Bruno (dept. DIBRIS, University of Genova, ITALY)
%
% This code is the implementation of the algorithms described in the
% paper "Analysis of human behavior recognition algorithms based on
% acceleration data".
%
% I would be grateful if you refer to the paper in any academic
% publication that uses this code or part of it.
% Here is the BibTeX reference:
% @inproceedings{Bruno13,
% author = "B. Bruno and F. Mastrogiovanni and A. Sgorbissa and T. Vernazza and R. Zaccaria",
% title = "Analysis of human behavior recognition algorithms based on acceleration data",
% booktitle = "Proceedings of the IEEE International Conference on Robotics and Automation (ICRA 2013)",
% address = "Karlsruhe, Germany",
% month = "May",
% year = "2013"
% }
% -------------------------------------------------------------------------
%
% AnalyzeActualWindow separates the gravity and body acceleration features
% contained in the [window] of acceleration data, by first reducing
% the noise on the raw data with a median filter and then discriminating
% between the features with a low-pass IIR filter.
%
% Input:
%   window --> set of acceleration points to be analyzed
%   window_size --> size of the window (equals number of sample points to
%                   be analyzed)
%
% Output:
%   gravity --> matrix of the components of the gravity acceleration along
%               the 3 axes
%   body --> matrix of the components of the body-motion acceleration along
%            the 3 axes
%
% Example:
%   ** this function is part of the code of ValidateWHARF:
%   ** do NOT call it directly!

% REDUCE THE NOISE ON THE SIGNALS BY MEDIAN FILTERING
n = 3;      % order of the median filter
clean_window(:,:) = medfilt1(window(:,:),n);

% SEPARATE THE GRAVITY AND BODY-ACCELERATION COMPONENTS
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
g(:,1) = filter(Hd,clean_window(:,1));
g(:,2) = filter(Hd,clean_window(:,2));
g(:,3) = filter(Hd,clean_window(:,3));
% compute the body-acceleration components by subtraction
g = circshift(g,[-delay 0]);
i = 1:1:(window_size-delay);
gravity(i,:) = g(i,:);
body(i,:) = clean_window(i,:) - gravity(i,:);