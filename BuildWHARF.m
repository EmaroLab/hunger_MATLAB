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
% This function is associated with the public dataset WHARF Data Set.
% The WHARF Data Set and its rationale are described in the paper "A Public
% Domain Dataset for ADL Recognition Using Wrist-placed Accelerometers".
%
% I would be grateful if you refer to the paper in any academic
% publication that uses the WHARF Data Set.
% Here is the BibTeX reference:
% @inproceedings{Bruno14c,
% author = "B. Bruno and F. Mastrogiovanni and A. Sgorbissa",
% title = "A Public Domain Dataset for {ADL} Recognition Using Wrist-placed Accelerometers",
% booktitle = "Proceedings of the 23rd {IEEE} International Symposium on Robot and Human Interactive Communication ({RO-MAN} 2014)",
% address = "Edinburgh, UK",
% month = "August",
% year = "2014"
% }
% -------------------------------------------------------------------------
%
% BuildWHARF creates the models (with the Gaussian Mixture Modelling
% and Regression procedure) of the gestures of WHARF Data Set, each
% represented by a set of modelling trials stored in a specific folder.
% The module calls the function GenerateModel for each motion passing it the
% appropriate modelling folder. In addition, the function computes the
% model-specific threshold to be later used by the Classifier to
% discriminate between known and unknown motions.

% CREATE THE MODELS AND ASSOCIATED THRESHOLDS
scale = 1.5;  % experimentally set scaling factor for the threshold computation

% climb_stairs
disp('Building CLIMB_STAIRS model...');
folder = 'WHARF_DataSet\MODELS\Climb_stairs_MODEL\';
[CLIMB_STAIRSgP, CLIMB_STAIRSgS, CLIMB_STAIRSbP, CLIMB_STAIRSbS] = GenerateModel(folder);
CLIMB_STAIRS_threshold = ComputeThreshold(CLIMB_STAIRSgP,CLIMB_STAIRSgS,CLIMB_STAIRSbP,CLIMB_STAIRSbS,scale);
models(1) = struct('name',{'Climb_stairs'},'gP',CLIMB_STAIRSgP,'gS',CLIMB_STAIRSgS,'bP',CLIMB_STAIRSbP,'bS',CLIMB_STAIRSbS,'threshold',CLIMB_STAIRS_threshold);
clear CLIMB_STAIRSgP CLIMB_STAIRSgS CLIMB_STAIRSbP CLIMB_STAIRSbS CLIMB_STAIRS_threshold

% drink_glass
disp('Building DRINK_GLASS model...');
folder = 'WHARF_DataSet\MODELS\Drink_glass_MODEL\';
[DRINK_GLASSgP, DRINK_GLASSgS, DRINK_GLASSbP, DRINK_GLASSbS] = GenerateModel(folder);
DRINK_GLASS_threshold = ComputeThreshold(DRINK_GLASSgP,DRINK_GLASSgS,DRINK_GLASSbP,DRINK_GLASSbS,scale);
models(2) = struct('name',{'Drink_glass'},'gP',DRINK_GLASSgP,'gS',DRINK_GLASSgS,'bP',DRINK_GLASSbP,'bS',DRINK_GLASSbS,'threshold',DRINK_GLASS_threshold);
clear DRINK_GLASSgP DRINK_GLASSgS DRINK_GLASSbP DRINK_GLASSbS DRINK_GLASS_threshold

% getup_bed
disp('Building GETUP_BED model...');
folder = 'WHARF_DataSet\MODELS\Getup_bed_MODEL\';
[GETUP_BEDgP, GETUP_BEDgS, GETUP_BEDbP, GETUP_BEDbS] = GenerateModel(folder);
GETUP_BED_threshold = ComputeThreshold(GETUP_BEDgP,GETUP_BEDgS,GETUP_BEDbP,GETUP_BEDbS,scale);
models(3) = struct('name',{'Getup_bed'},'gP',GETUP_BEDgP,'gS',GETUP_BEDgS,'bP',GETUP_BEDbP,'bS',GETUP_BEDbS,'threshold',GETUP_BED_threshold);
clear GETUP_BEDgP GETUP_BEDgS GETUP_BEDbP GETUP_BEDbS GETUP_BED_threshold

% pour_water
disp('Building POUR_WATER model...');
folder = 'WHARF_DataSet\MODELS\Pour_water_MODEL\';
[POUR_WATERgP, POUR_WATERgS, POUR_WATERbP, POUR_WATERbS] = GenerateModel(folder);
POUR_WATER_threshold = ComputeThreshold(POUR_WATERgP,POUR_WATERgS,POUR_WATERbP,POUR_WATERbS,scale);
models(4) = struct('name',{'Pour_water'},'gP',POUR_WATERgP,'gS',POUR_WATERgS,'bP',POUR_WATERbP,'bS',POUR_WATERbS,'threshold',POUR_WATER_threshold);
clear POUR_WATERgP POUR_WATERgS POUR_WATERbP POUR_WATERbS POUR_WATER_threshold

% sitdown_chair
disp('Building SITDOWN_CHAIR model...');
folder = 'WHARF_DataSet\MODELS\Sitdown_chair_MODEL\';
[SITDOWN_CHAIRgP, SITDOWN_CHAIRgS, SITDOWN_CHAIRbP, SITDOWN_CHAIRbS] = GenerateModel(folder);
SITDOWN_CHAIR_threshold = ComputeThreshold(SITDOWN_CHAIRgP,SITDOWN_CHAIRgS,SITDOWN_CHAIRbP,SITDOWN_CHAIRbS,scale);
models(5) = struct('name',{'Sitdown_chair'},'gP',SITDOWN_CHAIRgP,'gS',SITDOWN_CHAIRgS,'bP',SITDOWN_CHAIRbP,'bS',SITDOWN_CHAIRbS,'threshold',SITDOWN_CHAIR_threshold);
clear SITDOWN_CHAIRgP SITDOWN_CHAIRgS SITDOWN_CHAIRbP SITDOWN_CHAIRbS SITDOWN_CHAIR_threshold

% standup_chair
disp('Building STANDUP_CHAIR model...');
folder = 'WHARF_DataSet\MODELS\Standup_chair_MODEL\';
[STANDUP_CHAIRgP, STANDUP_CHAIRgS, STANDUP_CHAIRbP, STANDUP_CHAIRbS] = GenerateModel(folder);
STANDUP_CHAIR_threshold = ComputeThreshold(STANDUP_CHAIRgP,STANDUP_CHAIRgS,STANDUP_CHAIRbP,STANDUP_CHAIRbS,scale);
models(6) = struct('name',{'Standup_chair'},'gP',STANDUP_CHAIRgP,'gS',STANDUP_CHAIRgS,'bP',STANDUP_CHAIRbP,'bS',STANDUP_CHAIRbS,'threshold',STANDUP_CHAIR_threshold);
clear STANDUP_CHAIRgP STANDUP_CHAIRgS STANDUP_CHAIRbP STANDUP_CHAIRbS STANDUP_CHAIR_threshold

% walk
disp('Building WALK model...');
folder = 'WHARF_DataSet\MODELS\Walk_MODEL\';
[WALKgP, WALKgS, WALKbP, WALKbS] = GenerateModel(folder);
WALK_threshold = ComputeThreshold(WALKgP,WALKgS,WALKbP,WALKbS,scale);
models(7) = struct('name',{'Walk'},'gP',WALKgP,'gS',WALKgS,'bP',WALKbP,'bS',WALKbS,'threshold',WALK_threshold);
clear WALKgP WALKgS WALKbP WALKbS WALK_threshold

% SAVE THE MODELS IN THE CURRENT DIRECTORY
save models_and_thresholds.mat