function ovDistance = CompareWithModels(gravity,body,MODELgP,MODELgS,MODELbP,MODELbS)
% function ovDistance = CompareWithModels(gravity,body,MODELgP,MODELgS,MODELbP,MODELbS)
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
% CompareWithModels computes Mahalanobis distance between the features
% [gravity] and [body] of the actual window and one model of HMP, defined
% by expected curve [MODEL*P] and associated set of covariance matrices
% [MODEL*S]. The overall distance is the mean of the two feature distances.
%
% Input:
%   gravity --> matrix of the components of the gravity acceleration along
%               the 3 axes
%   body --> matrix of the components of the body-motion acceleration along
%            the 3 axes
%   MODELgP --> expected curve of the gravity feature of the given model
%   MODELgS --> associated covariance matrices
%   MODELbP --> expected curve of the body acc. feature  of the given model
%   MODELbS --> associated covariance matrices
%
% Output:
%   ovDistance --> distance between the features of the actual window and
%                  the features of the models
%
% Example:
%   ** this function is part of the code of ValidateWHARF:
%   ** do NOT call it directly!

% COMPUTE MAHALANOBIS DISTANCE BETWEEN MODEL FEATURES AND WINDOW FEATURES
numPoints = size(MODELgS,3);
gravity = gravity';
body = body';
time = MODELgP(1,:);
distance = zeros(numPoints,2);
for i=1:1:numPoints
    x = time(i);
    distance(i,1) = (transpose(gravity(:,x)-MODELgP(2:4,time==x)))*inv(MODELgS(:,:,time==x))*(gravity(:,i)-MODELgP(2:4,time==x));
    distance(i,2) = (transpose(body(:,x)-MODELbP(2:4,time==x)))*inv(MODELbS(:,:,time==x))*(body(:,i)-MODELbP(2:4,time==x));
end
% compute the overall distance as the mean of the features distances
ovDistance = mean(mean(distance));