function threshold = ComputeThreshold(MODELgP,MODELgS,MODELbP,MODELbS,factor)
% function threshold = ComputeThreshold(MODELgP,MODELgS,MODELbP,MODELbS,factor)
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
% ComputeThreshold computes the static threshold associated to the given
% model as the Mahalanobis distance between the expected curve defined in
% the model and the "farthest" admissible trial, defined as the expected
% curve plus the standard deviation. The distance is then scaled by
% [factor].
%
% Input:
%   MODELgP --> expected curve of the gravity feature
%   MODELgS --> associated covariance matrices
%   MODELbP --> expected curve of the body acc. feature
%   MODELbS --> associated covariance matrices
%   factor --> scaling factor for the threshold computation
%
% Output:
%   threshold --> static threshold associated to the given model
%
% Example:
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [CLIMB_gP CLIMB_gS CLIMB_bP CLIMB_bS] = GenerateModel(folder);
%   scale = 1.5;
%   CLIMB_threshold = ComputeThreshold(CLIMB_gP,CLIMB_gS,CLIMB_bP,CLIMB_bS,scale);

% COMPUTE THE FARTHEST ADMISSIBLE TRIAL
% initialize the farthest trial as the generalized curve
% time is removed --> 3D data
for i=2:1:4
    reference_G(i-1,:) = MODELgP(i,:);
    reference_B(i-1,:) = MODELbP(i,:);
    far_G(i-1,:) = MODELgP(i,:);
    far_B(i-1,:) = MODELbP(i,:);
end
% add the standard deviation
len = length(far_G);
for i=1:1:len
    for j=1:1:3
        if (far_G(j,i) > 0)
            far_G(j,i) = far_G(j,i) + factor.*MODELgS(j,j,i);
        else
            far_G(j,i) = far_G(j,i) - factor.*MODELgS(j,j,i);
        end
        if (far_B(j,i) > 0)
            far_B(j,i) = far_B(j,i) + factor.*MODELbS(j,j,i);
        else
            far_B(j,i) = far_B(j,i) - factor.*MODELbS(j,j,i);
        end
    end
end

% COMPUTE MAHALANOBIS DISTANCE BETWEEN THE FARTHEST TRIAL AND THE MODEL
for i=1:1:len
    distance(i,1) = (transpose(far_G(:,i)-reference_G(:,i)))*inv(MODELgS(:,:,i))*(far_G(:,i)-reference_G(:,i));
    distance(i,2) = (transpose(far_B(:,i)-reference_B(:,i)))*inv(MODELbS(:,:,i))*(far_B(:,i)-reference_B(:,i));
end
% compute the likelihood of the model as the mean value of the distances
threshold = mean(mean(distance));