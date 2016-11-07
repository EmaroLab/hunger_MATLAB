function [expMeans expSigma] = RetrieveModel(K,priors,mu,sigma,points,in,out)
% function [expMeans expSigma] = RetrieveModel(K,priors,mu,sigma,points,in,out)
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
% RetrieveModel performs Gaussian Mixture Regression (GMR) over the GM
% model defined by its parameters. By providing temporal values as inputs,
% it returns a smooth generalized version of the data encoded in the GMM
% and the associated constraints expressed by the covariance matrices.
%
% Input:
%   K --> number of Gaussian functions used in the GM model
%   priors --> (GMM param) a-priori probabilities of all of the Gaussians
%   mu --> (GMM param) means of the Gaussian functions
%   sigma --> (GMM param) covariance matrices of the Gaussian functions
%   points --> input data (starting points to be used for GMR)
%   in --> input dimension (here: time --> 1)
%   out --> output dimension (here: accelerations --> 2,3,4)
%
% Output:
%   expMeans --> set of expected means for the given GM model
%   expSigma --> covariance matrices of the expected points in expMeans
%
% Example:
%   folder = 'Data\MODELS\Climb_stairs_MODEL\';
%   [x_set y_set z_set numSamples] = ReadFiles(folder,0);
%   [gravity body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);
%   K_gravity = TuneK(gravity);
%   numVar = 4;
%   [priors mu sigma] = InitializeGMM(gravity,K_gravity,numVar,0);
%   numData = size(gravity,2);
%   [priors mu sigma] = TrainGMM(K_gravity,gravity,priors,mu,sigma,numVar,numData,0);
%   numPoints = max(gravity(1,:));
%   expData(1,:) = linspace(min(gravity(1,:)),max(gravity(1,:)),numPoints);
%   [expData(2:numVar,:), expSigma] = RetrieveModel(K_gravity,priors,mu,sigma,expData(1,:),1,2:numVar);

% COMPUTE THE PARAMETERS' VALUES
% compute the influence of each GMM component on the data points
% --> P(points|Gaussians)
numData = length(points);
for i=1:1:K
    % compute the probability of each point to belong to the actual GM
    % model (probability density function of the point) --> p(point)
    mu2 = repmat(mu(in,i)',numData,1);
    pdf_point(:,i) = mvnpdf(points',mu2,sigma(in,in,i));
    % compute p(Gaussians) * p(point|Gaussians)
    pdf_point(:,i) = priors(i).*pdf_point(:,i);
end
% estimate the parameters beta
beta = pdf_point./repmat(sum(pdf_point,2)+realmin,1,K);

% RETRIEVE THE EXPECTED CURVE (SET OF EXPECTED MEANS)
% compute the expected point xi^a_k --> exp_point_k
for j=1:K
  exp_point_k(:,:,j) = repmat(mu(out,j),1,numData) + sigma(out,in,j)*inv(sigma(in,in,j)) * (points-repmat(mu(in,j),1,numData));
end
% compute beta_k * exp_point_k
beta_tmp = reshape(beta,[1 size(beta)]);
exp_point_k2 = repmat(beta_tmp,[length(out) 1 1]) .* exp_point_k;
% compute the set of expected means
expMeans = sum(exp_point_k2,3);

% RETRIEVE THE ASSOCIATED COVARIANCE MATRICES
% compute the expected set of covariance matrices sigma^aa_k --> exp_sigma_k
for j=1:K
  exp_sigma_k(:,:,1,j) = sigma(out,out,j) - (sigma(out,in,j)*inv(sigma(in,in,j))*sigma(in,out,j));
end
% compute beta^2 * exp_sigma_k
beta_tmp = reshape(beta,[1 1 size(beta)]);
exp_sigma_k2 = repmat(beta_tmp.*beta_tmp, [length(out) length(out) 1 1]) .* repmat(exp_sigma_k,[1 1 numData 1]);
% compute the set of associated covariance matrices
expSigma = sum(exp_sigma_k2,4);