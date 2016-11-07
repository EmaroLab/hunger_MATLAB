function possibilities = Classify(ovDistances,thresholds)
% function possibilities = Classify(ovDistances,thresholds)
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
% Classify analyzes the overall distances between the actual window and all
% of the models to determine the possibility of each model to represent the
% actual acceleration data.
%
% Input:
%   ovDistances --> distances between the actual window and all of the
%                   known models
%   thresholds --> static thresholds associated to the given models (define
%                  the maximum distance between the model and acceleration
%                  data that could be an instance of that model)
%
% Output:
%   possibilities --> possibilities of all the models to represent the
%                     actual window
%
% Example:
%   ** this function is part of the code of ValidateWHARF:
%   ** do NOT call it directly!

% COMPUTE THE POSSIBILITY OF EACH MODEL
% (mapping of the likelihoods from [0..threshold(i)] to [1..0]
numModels = length(thresholds);
for i=1:1:numModels
    possibilities(i) = 1 - ovDistances(i)/thresholds(i);
    if (possibilities(i) < 0)
        possibilities(i) = 0;
    end
end