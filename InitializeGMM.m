function [priors mu sigma] = InitializeGMM(set,K,numVar,debugMode)
% function [priors mu sigma] = InitializeGMM(set,K,numVar,debugMode)
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
% -------------------------------------------------------------------------
% This function was developed starting from the source code of:
%   Sylvain Calinon
%	http://programming-by-demonstration.org
%
% BibTex references of the corresponding books and articles are:
% @book{Calinon09book,
%   author="S. Calinon",
%   title="Robot Programming by Demonstration: A Probabilistic Approach",
%   publisher="EPFL/CRC Press",
%   year="2009",
%   note="EPFL Press ISBN 978-2-940222-31-5, CRC Press ISBN 978-1-4398-0867-2"
% }
%
% @article{Calinon07,
%   title="On Learning, Representing and Generalizing a Task in a Humanoid Robot",
%   author="S. Calinon and F. Guenter and A. Billard",
%   journal="IEEE Transactions on Systems, Man and Cybernetics, Part B",
%   year="2007",
%   volume="37",
%   number="2",
%   pages="286--298",
% }
% -------------------------------------------------------------------------
%
% InitializeGMM initializes the parameters to be used in the Gaussian
% Mixture Model (a-priori probabilities, mean and standard deviation for
% each Gaussian) by using the K-means clustering algorithm on the given
% dataset. The parameter [debugMode] is a flag to indicate whether the
% function should plot the results (debugMode = 1) or not (debugMode = 0).
% Default option is 1.
%
% Input:
%   set --> dataset of the points to be modelled (clustered with K-means)
%   K --> number of Gaussian functions to be used in the GM model =
%         number of clusters to be used in the K-means clustering
%   numVar --> number of independent variables reported in the dataset
%              (time; acc. along x; acc. along y; acc. along z)
%
% Output:
%   priors --> a-priori probabilities of all of the clusters
%   mu --> centroids of the clusters = means of the Gaussians
%   sigma --> standard deviation of the points from the clusters' centroids
%             (Euclidean distance) = covariance matrices of the Gaussians
%
% Examples:
%   1) default - plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numVar = 4;
%   [priors mu sigma] = InitializeGMM(gravity,K_gravity,numVar);
%
%   2) explicit plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numVar = 4;
%   [priors mu sigma] = InitializeGMM(gravity,K_gravity,numVar,1);
%
%   3) no plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numVar = 4;
%   [priors mu sigma] = InitializeGMM(gravity,K_gravity,numVar,0);

% DEFINE THE VALUE FOR FLAG debugMode
if nargin < 4 || isempty(debugMode)
    debugMode = 1;
end

% USE K-MEANS CLUSTERING ALGORITHM TO INITIALIZE THE GAUSSIANS
% apply K-means algorithm
[assignments, centroids] = kmeans(set',K,'emptyaction','drop');
% initialize the gaussians parameters
mu = centroids';
priors = zeros(1,K);
sigma = zeros(numVar,numVar,K);
for i=1:1:K
    temp_id = find(assignments==i);
    priors(i) = length(temp_id);
    sigma(:,:,i) = cov([set(:,temp_id) set(:,temp_id)]');
    % add a tiny variance to avoid numerical instability
    sigma(:,:,i) = sigma(:,:,i) + 1E-5.*diag(ones(numVar,1));
end
priors = priors ./ sum(priors);

% DEBUG: PLOT THE OUTPUT OF K-MEANS CLUSTERING
if (debugMode == 1)
    % display the output of K-means clustering (3D)
    result = cat(1,set,assignments');
    figure,
        % display all of the points
        % (to verify that they're all clustered)
        scatter3(set(2,:),set(3,:),set(4,:),'k');
        hold on;
        % display the clusters of points
        for i=1:1:K
            gruppo = result(:,find(result(5,:)==i));
            scatter3(gruppo(2,:),gruppo(3,:),gruppo(4,:),'*');
            hold on;
        end
        % display the clusters' centroids
        scatter3(centroids(:,2),centroids(:,3),centroids(:,4),'MarkerEdgeColor','k','MarkerFaceColor','g');
        title('Output of K-means clustering (3D)');
        xlabel('x axis');
        ylabel('y axis');
        zlabel('z axis');
    % display the output of K-means clustering (2D)
    result = cat(1,set,assignments');
    figure,
        % display the x-axis projection
        subplot(3,1,1);
        scatter(set(1,:),set(2,:),'k');
        hold on;
        for i=1:1:K
            gruppo = result(:,find(result(5,:)==i));
            scatter(gruppo(1,:),gruppo(2,:),'*');
            hold on;
        end
        scatter(centroids(:,1),centroids(:,2),'MarkerEdgeColor','k','MarkerFaceColor','g');
        title('Output of K-means clustering (2D)');
        % display the y-axis projection
        subplot(3,1,2);
        scatter(set(1,:),set(3,:),'k');
        hold on;
        for i=1:1:K
            gruppo = result(:,find(result(5,:)==i));
            scatter(gruppo(1,:),gruppo(3,:),'*');
            hold on;
        end
        scatter(centroids(:,1),centroids(:,3),'MarkerEdgeColor','k','MarkerFaceColor','g');
        ylabel('acceleration [m/s^2]');
        % display the z-axis projection
        subplot(3,1,3);
        scatter(set(1,:),set(4,:),'k');
        hold on;
        for i=1:1:K
            gruppo = result(:,find(result(5,:)==i));
            scatter(gruppo(1,:),gruppo(4,:),'*');
            hold on;
        end
        scatter(centroids(:,1),centroids(:,4),'MarkerEdgeColor','k','MarkerFaceColor','g');
        xlabel('time [samples]');
end