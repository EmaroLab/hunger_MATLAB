function [priors, mu, sigma] = TrainGMM(K,set,priors,mu,sigma,numVar,numData,debugMode)
% function [priors, mu, sigma] = TrainGMM(K,set,priors,mu,sigma,numVar,numData,debugMode)
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
% TrainGMM computes the Gaussian Mixture Model of the given dataset
% starting from the initial values provided by the function InitializeGMM
% and training the modelling parameters with the Expectation-Maximization
% algorithm. The function returns the a-priori probabilities, means and
% covariance matrices of the Gaussians. The parameter [debugMode] is a flag
% to indicate whether the function should plot the results (debugMode = 1)
% or not (debugMode = 0). Default option is 1.
%
% Input:
%   K --> number of Gaussian functions to be used in the GM model
%   set --> dataset of the points to be modelled
%   priors --> a-priori probabilities of all of the clusters
%   mu --> centroids of the clusters = means of the Gaussians
%   sigma --> standard deviation of the points from the clusters' centroids
%             (Euclidean distance) = covariance matrices of the Gaussians
%   numVar --> number of independent variables reported in the dataset
%              (time; acc. along x; acc. along y; acc. along z)
%   numData --> number of points in the dataset
%
% Output:
%   priors --> FINAL a-priori probabilities of all of the Gaussians -->
%              P(data|Gaussian)
%   mu --> FINAL means of the Gaussian functions
%   sigma --> FINAL covariance matrices of the Gaussian functions
%
% Examples:
%   1) default - plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numVar = 4;
%   [priors mu sigma] = InitializeGMM(gravity,K_gravity,numVar,0);
%   numData = size(gravity,2);
%   [priors mu sigma] = TrainGMM(K_gravity,gravity,priors,mu,sigma,numVar,numData);
%
%   2) explicit plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numVar = 4;
%   [priors mu sigma] = InitializeGMM(gravity,K_gravity,numVar,0);
%   numData = size(gravity,2);
%   [priors mu sigma] = TrainGMM(K_gravity,gravity,priors,mu,sigma,numVar,numData,1);
%
%   3) no plot
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numVar = 4;
%   [priors mu sigma] = InitializeGMM(gravity,K_gravity,numVar,0);
%   numData = size(gravity,2);
%   [priors mu sigma] = TrainGMM(K_gravity,gravity,priors,mu,sigma,numVar,numData,0);

% DEFINE THE VALUE FOR FLAG debugMode
if nargin < 8 || isempty(debugMode)
    debugMode = 1;
end

% PARAMETERS OF THE E-M ALGORITHM
log_likelihood_threshold = 1e-10;   % threshold on the log likelihood
log_likelihood_old = -realmax;      % initial log likelihood

% APPLY THE E-M ALGORITHM TO TUNE THE GAUSSIANS' PARAMETERS
while true
    % EXPECTATION step
    for i=1:1:K
        % compute the probability of each point to belong to the actual GM
        % model (probability density function of the point) --> p(point)
        mu2 = repmat(mu(:,i)',numData,1);
        pdf_point(:,i) = mvnpdf(set',mu2,sigma(:,:,i));
    end
    % compute the a-posteriori probabilities --> p(Gaussian|point)
    posteriors_temp = repmat(priors,[numData 1]).*pdf_point;
    posteriors = posteriors_temp ./ repmat(sum(posteriors_temp,2),[1 K]);
    % compute the cumulated a-posteriori probability --> E_k
    E = sum(posteriors);
    % MAXIMIZATION step
    for i=1:1:K
        % update the a-priori probabilities
        priors(i) = E(i)/numData;
        % update the means
        mu(:,i) = set*posteriors(:,i)/E(i);
        % update the covariance matrices
        set_temp = set - repmat(mu(:,i),1,numData);
        sigma(:,:,i) = (repmat(posteriors(:,i)',numVar,1).*set_temp*set_temp')/E(i);
        % add a tiny variance to avoid numerical instability
        sigma(:,:,i) = sigma(:,:,i) + 1E-5.*diag(ones(numVar,1));
    end
    % update the probability of each point to belong to the actual GM model
    for i=1:1:K
        mu2 = repmat(mu(:,i)',numData,1);
        pdf_point(:,i) = mvnpdf(set',mu2,sigma(:,:,i));
    end
    % compute the current average log-likelihood
    F = pdf_point*priors';
    F(F<realmin) = realmin;
    log_likelihood = mean(log(F));
    % ENDING condition (check convergence on the likelihood)
    if abs((log_likelihood/log_likelihood_old)-1) < log_likelihood_threshold
        break;
    end
    log_likelihood_old = log_likelihood;
end

% DEBUG: PLOT THE OUTPUT OF K-MEANS CLUSTERING
if (debugMode == 1)
    % project the computed 4D GM model over 3 2D domains
    % (time + mono-axial acceleration)
    % 1) time and acceleration along x
    x = 1:4:(max(set(1,:)));
    y = (min(set(2,:))):0.3:(max(set(2,:)));
    [X, Y] = meshgrid(x,y);
    Z = zeros(size(y,2),size(x,2));
    % compute each gaussian distribution
    for i=1:1:K
        mu_x = mu(1,i);
        mu_y = mu(2,i);
        std_dev = sqrtm(3.0.*sigma(:,:,i));
        sigma_x = std_dev(1,1);
        sigma_y = std_dev(2,2);
        rho = std_dev(1,2)/(sigma_x*sigma_y);
        den = 2*pi*sigma_x*sigma_y*sqrt(1-rho^2);
        mult = -1/(2*(1-rho^2));
        first = realmin+((X-mu_x).^2)/sigma_x^2;
        second = realmin+((Y-mu_y).^2)/sigma_y^2;
        third = realmin-(2*rho*(X-mu_x).*(Y-mu_y))/sigma_x*sigma_y;
        gauss_dist = (1/den)*exp(mult*(first+second+third));
        gauss_dist = mat2gray(gauss_dist);
        % sum up all the gaussian distributions to have the general model
        Z = Z + gauss_dist;
    end
    % display the GMM result (2D)
    figure,
        % draw the GMM
        contour(X,Y,Z,'Fill','on');
        hold on;
        % draw the dataset
        plot(set(1,:),set(2,:),'*','MarkerSize',2,'Color','k');
        title('2D display of the Gaussian Mixture Model - x axis');
        xlabel('time [samples]');
        ylabel('acceleration [m/s^2]');
    % 2) time and acceleration along y
    x = 1:4:(max(set(1,:)));
    y = (min(set(3,:))):0.3:(max(set(3,:)));
    [X, Y] = meshgrid(x,y);
    Z = zeros(size(y,2),size(x,2));
    % compute each gaussian distribution
    for i=1:1:K
        mu_x = mu(1,i);
        mu_y = mu(3,i);
        std_dev = sqrtm(3.0.*sigma(:,:,i));
        sigma_x = std_dev(1,1);
        sigma_y = std_dev(2,2);
        rho = std_dev(1,2)/(sigma_x*sigma_y);
        den = 2*pi*sigma_x*sigma_y*sqrt(1-rho^2);
        mult = -1/(2*(1-rho^2));
        first = realmin+((X-mu_x).^2)/sigma_x^2;
        second = realmin+((Y-mu_y).^2)/sigma_y^2;
        third = realmin-(2*rho*(X-mu_x).*(Y-mu_y))/sigma_x*sigma_y;
        gauss_dist = (1/den)*exp(mult*(first+second+third));
        gauss_dist = mat2gray(gauss_dist);
        % sum up all the gaussian distributions to have the general model
        Z = Z + gauss_dist;
    end
    % display the GMM result (2D)
    figure,
        % draw the GMM
        contour(X,Y,Z,'Fill','on');
        hold on;
        % draw the dataset
        plot(set(1,:),set(3,:),'*','MarkerSize',2,'Color','k');
        title('2D display of the Gaussian Mixture Model - y axis');
        xlabel('time [samples]');
        ylabel('acceleration [m/s^2]');
    % 3) time and acceleration along z
    x = 1:4:(max(set(1,:)));
    y = (min(set(4,:))):0.3:(max(set(4,:)));
    [X, Y] = meshgrid(x,y);
    Z = zeros(size(y,2),size(x,2));
    % compute each gaussian distribution
    for i=1:1:K
        mu_x = mu(1,i);
        mu_y = mu(4,i);
        std_dev = sqrtm(3.0.*sigma(:,:,i));
        sigma_x = std_dev(1,1);
        sigma_y = std_dev(2,2);
        rho = std_dev(1,2)/(sigma_x*sigma_y);
        den = 2*pi*sigma_x*sigma_y*sqrt(1-rho^2);
        mult = -1/(2*(1-rho^2));
        first = realmin+((X-mu_x).^2)/sigma_x^2;
        second = realmin+((Y-mu_y).^2)/sigma_y^2;
        third = realmin-(2*rho*(X-mu_x).*(Y-mu_y))/sigma_x*sigma_y;
        gauss_dist = (1/den)*exp(mult*(first+second+third));
        gauss_dist = mat2gray(gauss_dist);
        % sum up all the gaussian distributions to have the general model
        Z = Z + gauss_dist;
    end
    % display the GMM result (2D)
    figure,
        % draw the GMM
        contour(X,Y,Z,'Fill','on');
        hold on;
        % draw the dataset
        plot(set(1,:),set(4,:),'*','MarkerSize',2,'Color','k');
        title('2D display of the Gaussian Mixture Model - z axis');
        xlabel('time [samples]');
        ylabel('acceleration [m/s^2]');
    % summarize the results in a single figure
    figure,
        % time and acceleration along x
        subplot(3,1,1);
        x = 1:4:(max(set(1,:)));
        y = (min(set(2,:))):0.3:(max(set(2,:)));
        [X, Y] = meshgrid(x,y);
        Z = zeros(size(y,2),size(x,2));
        % compute each gaussian distribution
        for i=1:1:K
            mu_x = mu(1,i);
            mu_y = mu(2,i);
            std_dev = sqrtm(3.0.*sigma(:,:,i));
            sigma_x = std_dev(1,1);
            sigma_y = std_dev(2,2);
            rho = std_dev(1,2)/(sigma_x*sigma_y);
            den = 2*pi*sigma_x*sigma_y*sqrt(1-rho^2);
            mult = -1/(2*(1-rho^2));
            first = realmin+((X-mu_x).^2)/sigma_x^2;
            second = realmin+((Y-mu_y).^2)/sigma_y^2;
            third = realmin-(2*rho*(X-mu_x).*(Y-mu_y))/sigma_x*sigma_y;
            gauss_dist = (1/den)*exp(mult*(first+second+third));
            gauss_dist = mat2gray(gauss_dist);
            % sum up all the gaussian distributions to have the general model
            Z = Z + gauss_dist;
        end
        % draw the GMM
        contour(X,Y,Z,'Fill','on');
        hold on;
        % draw the dataset
        plot(set(1,:),set(2,:),'*','MarkerSize',2,'Color','k');
        title('2D display of the Gaussian Mixture Model - x axis');
        % time and acceleration along y
        subplot(3,1,2);
        x = 1:4:(max(set(1,:)));
        y = (min(set(3,:))):0.3:(max(set(3,:)));
        [X, Y] = meshgrid(x,y);
        Z = zeros(size(y,2),size(x,2));
        % compute each gaussian distribution
        for i=1:1:K
            mu_x = mu(1,i);
            mu_y = mu(3,i);
            std_dev = sqrtm(3.0.*sigma(:,:,i));
            sigma_x = std_dev(1,1);
            sigma_y = std_dev(2,2);
            rho = std_dev(1,2)/(sigma_x*sigma_y);
            den = 2*pi*sigma_x*sigma_y*sqrt(1-rho^2);
            mult = -1/(2*(1-rho^2));
            first = realmin+((X-mu_x).^2)/sigma_x^2;
            second = realmin+((Y-mu_y).^2)/sigma_y^2;
            third = realmin-(2*rho*(X-mu_x).*(Y-mu_y))/sigma_x*sigma_y;
            gauss_dist = (1/den)*exp(mult*(first+second+third));
            gauss_dist = mat2gray(gauss_dist);
            % sum up all the gaussian distributions to have the general model
            Z = Z + gauss_dist;
        end
        % draw the GMM
        contour(X,Y,Z,'Fill','on');
        hold on;
        % draw the dataset
        plot(set(1,:),set(3,:),'*','MarkerSize',2,'Color','k');
        title('2D display of the Gaussian Mixture Model - y axis');
        ylabel('acceleration [m/s^2]');
        % time and acceleration along z
        subplot(3,1,3);
        x = 1:4:(max(set(1,:)));
        y = (min(set(4,:))):0.3:(max(set(4,:)));
        [X, Y] = meshgrid(x,y);
        Z = zeros(size(y,2),size(x,2));
        % compute each gaussian distribution
        for i=1:1:K
            mu_x = mu(1,i);
            mu_y = mu(4,i);
            std_dev = sqrtm(3.0.*sigma(:,:,i));
            sigma_x = std_dev(1,1);
            sigma_y = std_dev(2,2);
            rho = std_dev(1,2)/(sigma_x*sigma_y);
            den = 2*pi*sigma_x*sigma_y*sqrt(1-rho^2);
            mult = -1/(2*(1-rho^2));
            first = realmin+((X-mu_x).^2)/sigma_x^2;
            second = realmin+((Y-mu_y).^2)/sigma_y^2;
            third = realmin-(2*rho*(X-mu_x).*(Y-mu_y))/sigma_x*sigma_y;
            gauss_dist = (1/den)*exp(mult*(first+second+third));
            gauss_dist = mat2gray(gauss_dist);
            % sum up all the gaussian distributions to have the general model
            Z = Z + gauss_dist;
        end
        % draw the GMM
        contour(X,Y,Z,'Fill','on');
        hold on;
        % draw the dataset
        plot(set(1,:),set(4,:),'*','MarkerSize',2,'Color','k');
        title('2D display of the Gaussian Mixture Model - z axis');
        xlabel('time [samples]');
end