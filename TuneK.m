function Koptimal = TuneK(set,maxK)
% function Koptimal = TuneK(set,maxK)
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
% TuneK determines the optimal number of clusters to be used to cluster
% the given [set] with K-means algorithm. It cycles from K = 2 to [maxK].
% The optimization criterion adopted is a variant of the elbow method: at
% each iteration TuneK computes the silhouette values of the clusters
% determined by the K-means algorithm and compares them with the values
% obtained at the previous iteration. When the quality of the
% clustering falls below a fixed threshold, TuneK stops.
%
% Input:
%   set --> either the gravity or the body acc. dataset retrived from
%           CreateDatasets
%   maxK --> maximum number of clusters to be used to cluster the given
%            dataset. Default: 1/2 of the number of data-points
%            composing the dataset
%
% Output:
%   Koptimal --> optimal number of clusters to be used to cluster the data
%                of the given dataset
%
% Example:
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);

% DEFINE THE VALUE FOR maxK
if nargin < 2 || isempty(maxK)
    maxK = floor(max(set(1,:))/2);
end

% DETERMINE THE OPTIMAL NUMBER OF CLUSTERS (K) FOR THE GIVEN DATASET
% tuning parameters
threshold = 0.69;   % threshold on the FITNESS of the current clustering
minK = 2;           % initial number of clusters to be used
% first step is outside of the loop to have meaningful initial values
assignments = kmeans(set',minK, 'emptyaction','drop');
s = silhouette(set',assignments,'sqeuclid');
for i=1:1:minK
    s_cluster(i) = sum(s(assignments == i))/length(s(assignments == i));
end
% further steps
for K=(minK+1):1:maxK
    assignments = kmeans(set',K, 'emptyaction','drop');
    s = silhouette(set',assignments,'sqeuclid');
    for i=1:1:K
        s_cluster(i) = sum(s(assignments == i))/length(s(assignments == i));
    end
    current = mean(s_cluster);
    % ending condition
    if (current < threshold)
        break;
    end
end
Koptimal = K;
% warning message in case of bad clustering
if (Koptimal == maxK)
    warning('MATLAB:noConvergence','Failed to converge to the optimal K: increase maxK.');
end

% PLOT THE SILHOUETTE VALUES OF THE OPTIMAL K CLUSTERING
assignments = kmeans(set',Koptimal);
figure,
    silhouette(set',assignments);