clear;

dataDir = './data';
resultsDir = 'ResultsSIGGRAPH2012';

mkdir(resultsDir);

setPath;
make;

%% baby2
inFile = fullfile(dataDir,'baby2.mp4');
fprintf('Processing %s\n', inFile);
amplify_spatial_Gdown_temporal_ideal(inFile,resultsDir,150,6, 140/60,160/60,30, 1);

%% face
inFile = fullfile(dataDir,'face.mp4');
fprintf('Processing %s\n', inFile);
amplify_spatial_Gdown_temporal_ideal(inFile,resultsDir,50,4, ...
                     50/60,60/60,30, 1);
%% face2
inFile = fullfile(dataDir,'face2.mp4');
fprintf('Processing %s\n', inFile);

% Color
tic
%amplify_spatial_Gdown_temporal_ideal(inFile,resultsDir,50,6, ...
%                                     50/60,60/60,30, 1);
amplify_spatial_Gdown_temporal_ideal(inFile,resultsDir,75,6, ...
                                    50/60,60/60,30, 1);
toc

%% peter
inFile = fullfile(dataDir,'peter.mp4');
fprintf('Processing %s\n', inFile);
tic
amplify_spatial_Gdown_temporal_ideal(inFile,resultsDir,50,4, ...
                     50/60,60/60,30, 1);
toc

%% mathias_130
%Good
inFile = fullfile(dataDir,'mathias_130.mp4');
fprintf('Processing %s\n', inFile);
tic
amplify_spatial_Gdown_temporal_ideal(inFile,resultsDir,50,4, ...
                     120/60,130/60,30, 1);
toc
%% mathias_57
%Good
inFile = fullfile(dataDir,'mathias_57.mp4');
fprintf('Processing %s\n', inFile);
tic
amplify_spatial_Gdown_temporal_ideal(inFile,resultsDir,50,4, ...
                     50/60,65/60,30, 1);
toc
%% mathias_61bpm
%Mask takes up background
inFile = fullfile(dataDir,'mathias_61bpm.mp4');
fprintf('Processing %s\n', inFile);
tic
amplify_spatial_Gdown_temporal_ideal(inFile,resultsDir,50,4, ...
                     55/60,67/60,30, 1);
toc
%% mathias_60_ish
%Ok
inFile = fullfile(dataDir,'mathias_60_ish.mp4');
fprintf('Processing %s\n', inFile);
tic
amplify_spatial_Gdown_temporal_ideal(inFile,resultsDir,50,4, ...
                     55/60,65/60,30, 1);
toc