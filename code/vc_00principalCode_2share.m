% Purpose
% -------
% Reproduce the visual cortical connectivity analyses and figures.
%
% Expected local project structure
% --------------------------------
% projectRoot/
% ├── code/
% │   ├── config/
% │   │   └── stimPairs.mat
% │   └── external/
% ├── derivatives/
% │   ├── ccep_connectivity/
% │   │   └── sub-XX/
% │   ├── freesurfer/
% │   │   └── sub-XX/
% │   ├── loc_info/
% │   │   └── sub-XX/
% │   └── preproc_synth/
% │       └── sub-XX/
% └── participants.tsv
%
% CCEP analyses
% 1.  Load subject-level CCEP connectivity data.
% 2.  Organize significant and non-significant responses by stream.
% 3.  Add stimulation-pair configuration.
% 4a. Render example CCEP responses on individual cortical surfaces
%     for Figure 1.
% 4b. Render example CCEP responses and traces for Figure 2.
% 5.  Compute stream-level connectivity and CoD measures used in
%     Figures 3 and 4.
% 6.  Prepare response tables for downstream analyses.
% 7.  Generate violin plots and fit linear mixed-effects models for
%     Figures 3 and 4 and supplementary statistics.
% 8.  Compute relative output/input balances for Figure 5a.
% 9a. Generate the effective-connectivity summary for Figure 5a.
% 9b. Generate source-target spatial specificity for Figure 5b and
%     calculate the percentage of significant responses.
% 10. Generate circular connectograms for Figure 6.
% 11. Generate the connectivity matrix for Figure 7.
% 12. Render dorsal-stream outputs and example CCEP traces for
%     Figure 8a.
% 13. Render A37elv outputs and example CCEP traces for Figure 8b.
%
% Synthetic-task analyses
%   data are available for: sub-01, sub-11, and sub-17
% 14. Generate seed-to-all broadband correlation maps during word
%     trials.
% 15. Generate local word-selectivity maps using the broadband
%     words-minus-nonwords response.
% 16. Generate regional broadband time courses with mean traces and
%     95% confidence intervals.
%
% Synthetic-task scripts
% ----------------------
%   vc_synth_seed_correlation.m
%   vc_synth_local_word_selectivity.m
%   vc_synth_regional_bb_timecourses.m
%
% Authors
% -------
% Lupita Yanez-Ramos (MGYR) and Dora Hermes (DH)
%
% Last validated
% --------------
% August 2026: complete CCEP workflow and all three synthetic analyses
% validated.


clc
clear
close all

% Determine the repository root from this script's location:
% projectRoot/code/vc_principalCode_2share.m
scriptFile = which('vc_principalCode_2share.m');

projectRoot = fileparts(fileparts(scriptFile));

disp(scriptFile)
disp(projectRoot)

localDataPath = projectRoot;

codeDir = fullfile(projectRoot, 'code');

if ~isfolder(codeDir)
    error('Code directory not found: %s', codeDir);
end

addpath(genpath(codeDir));

fprintf('\nVisual Connectivity reproduction workflow\n');
fprintf('Project root: %s\n\n', projectRoot);
%% New participant
% projectRoot = '/Users/yanez-ramos.mariaguadalupe/Documents/visual_connectivity';
% 
% PREvc_finalize_new_ccep_subject(projectRoot,24);


%% Participants included in the CCEP analysis

all_subjects = { ...
    '01', '02', '03', '04', '05', ...
    '06', '07', '08', '09', '10', ...
    '11', '12', '13', '14', '15', ...
    '16', '17', '18', '19', '20',...
    '21', '22', '23'};


%% Step 1. Load subject-level CCEP connectivity data
% ~ 3 minutes
tic
fprintf('\n[Step 1/16] Load subject-level CCEP connectivity data.\n');

all = [];

for i = 1:numel(all_subjects)

    sub_label = all_subjects{i};

    subject_file = fullfile(localDataPath, ...
        'derivatives', ...
        'ccep_connectivity', ...
        ['sub-' sub_label], ...
        ['sub-' sub_label '_desc-ccepconnectivity.mat']);

    s = load(subject_file);

    fn = fieldnames(s);
    all = [all, s.(fn{1})];
    disp(['please wait...', ' loading sub' sub_label])

end
toc
%% Step 2. Organize responses by stream and significance

fprintf('\n[Step 2/16] Organize significant and non-significant responses by stream.\n');

% Dorsal significant
crp.Dorsal.DivergentP = all(1, find(ismember([all.pathway],{'Dorsal'}) & ismember([all.Sig],{'sig'})));
% Dorsal non significant
crp.Dorsal.DivergentP_NoSig = all(1, find(ismember([all.pathway],{'Dorsal'}) & ismember([all.Sig],{'NOsig'})));

% Lateral significant
crp.Lateral.DivergentP = all(1, find(ismember([all.pathway],{'Lateral'}) & ismember([all.Sig],{'sig'})));
% Lateral non significant
crp.Lateral.DivergentP_NoSig = all(1, find(ismember([all.pathway],{'Lateral'}) & ismember([all.Sig],{'NOsig'})));

% Ventral significant
crp.Ventral.DivergentP = all(1, find(ismember([all.pathway],{'Ventral'}) & ismember([all.Sig],{'sig'})));
% Ventral non significant
crp.Ventral.DivergentP_NoSig = all(1, find(ismember([all.pathway],{'Ventral'}) & ismember([all.Sig],{'NOsig'})));

% Early visual significant
crp.Posterior.DivergentP = all(1, find(ismember([all.pathway],{'Posterior'}) & ismember([all.Sig],{'sig'})));
% Early visual non significant
crp.Posterior.DivergentP_NoSig = all(1, find(ismember([all.pathway],{'Posterior'}) & ismember([all.Sig],{'NOsig'})));

%% Step 3. Add stimulation-pair configuration
fprintf('\n[Step 3/16] Add stimulation-pair configuration.\n');

load(fullfile(localDataPath, 'code', 'config', 'stimPairs.mat'))

crp.Dorsal.stimPairAll = stimPairs.Dorsal.stimPairAll;
crp.Dorsal.aroundStim_gm = stimPairs.Dorsal.aroundStim_gm;

crp.Lateral.stimPairAll = stimPairs.Lateral.stimPairAll;
crp.Lateral.aroundStim_gm = stimPairs.Lateral.aroundStim_gm;

crp.Ventral.stimPairAll = stimPairs.Ventral.stimPairAll;
crp.Ventral.aroundStim_gm = stimPairs.Ventral.aroundStim_gm;

crp.Posterior.stimPairAll = stimPairs.Posterior.stimPairAll;
crp.Posterior.aroundStim_gm = stimPairs.Posterior.aroundStim_gm;

clear stimPairs

%% Step 4a. Render CCEP responses on cortical surface - Figure 1
fprintf('\n[Step 4a/16] Render CCEP responses on cortical surfaces.\n');

subject_fig1 = {'01', '11', '13', '17'};
stimPair2plot_fig1 = { ...
    'LOC1-LOC2', ...
    'LSL1-LSL2', ...
    'ROI2-ROI3', ...
    'ROC3-ROC4'};
numViews = 2;
view4plot = {[60,-30],[-60,30], [60,-30],[-60,30], [60,30],[-60,-30], [60,30],[-60,-30]};

hem4plot = {1, 1, 2, 2};

% Make sure each subject has one corresponding stimulation pair
assert(numel(subject_fig1) == numel(stimPair2plot_fig1), ...
    'subject_fig1 and stimPair2plot_fig1 must have the same length.');

% Figure 1 settings
pathwayT = 'Posterior';
whoplot = true;          % true = one subject
plotOnePair = true;      % true = one stimulation pair
mni = false;             % false = native subject surface
inflatedBrain = true;    % true = inflated surface
yesLabels = false;       % false = no electrode labels
AreaInStream = [];

idxView = 1;
for thisSub = 1:numel(subject_fig1)
    S = subject_fig1(thisSub);
    stimPair2plot = stimPair2plot_fig1(thisSub);
    hem2plot = hem4plot{thisSub};
    for j = 1:numViews
        disp(['please wait... ploting sub' char(S) '   view ' num2str(j)])
        figure
        views2plot = view4plot(idxView);
        vc_plot_1brain( ...
            crp, ...
            all_subjects, ...
            projectRoot, ...
            pathwayT, ...
            whoplot, ...
            S, ...
            plotOnePair, ...
            stimPair2plot, ...
            mni, ...
            inflatedBrain, ...
            yesLabels, ...
            AreaInStream,...
            hem2plot,...
            views2plot);
    idxView = idxView + 1;
    end
end

%% Step 4b. Render CCEP responses on the cortical surface Figure 2
fprintf('\n[Step 4b/16] Render CCEP responses on cortical surfaces.\n');

subject_fig2 = {'13', '13', '17', '17'};
stimPair2plot_fig2 = {'ROI3-ROI4', 'RLI4-RLI5', 'LOC1-LOC2', 'LOC11-LOC12'};
recChannels = {'RLI4', 'RLI5', 'ROI3', 'ROI4', 'LOC11', 'LOC12', 'LOC1', 'LOC2'};
pathwayT_fig2 = {'Posterior','Lateral', 'Posterior','Lateral'};
numViews = 2;
view4plot = {'lateral','medial', 'lateral','medial', 'lateral','medial', 'lateral','medial'};
hem4plot = [2, 2, 1, 1];
recChNum = 1;
idxView = 1;
mni = false; % true is mni
inflatedBrain = true; %true is inflated
yesLabels = false; %true is labels
AreaInStream = []; % an specific area
plotOnePair = true; % just one pair
whoplot = true; %true one subject

for thisSub = 1:4
    % Cortical-render settings
    pathwayT = pathwayT_fig2{thisSub};
    hem2plot = hem4plot(thisSub);
    S = subject_fig2(thisSub);
    stimPair2plot = stimPair2plot_fig2(thisSub);
    for j = 1:numViews
        views2plot = view4plot(idxView);
        figure
        vc_plot_1brain( ...
            crp, ...
            all_subjects, ...
            projectRoot, ...
            pathwayT, ...
            whoplot, ...
            S, ...
            plotOnePair, ...
            stimPair2plot, ...
            mni, ...
            inflatedBrain, ...
            yesLabels, ...
            AreaInStream,...
            hem2plot,...
            views2plot);
        
    idxView = idxView + 1;
    end

    % plot example traces
    figure
    sub2plot = ['sub_' char(S)]; 
    for k = 1:2
        subplot(2,1,k)
        disp(['Please wait...', char(num2str(100*(recChNum/9))), ' %'])
        recCh = recChannels(recChNum);
        idx = find(ismember([all.stimPair], stimPair2plot) & ismember({all.recordCh}, recCh) & ismember({all.Subj}, {sub2plot}));
        % Individual trials + mean, without tR
        vc_plot_ccep_trace(all(idx), ...
            'TrialDisplay','ci', ...
            'ShowTR',false);
        title(['sub' char(S), '    CoD = ',...
        num2str(median(all(idx).codAll))],'FontSize', 10);
        
        recChNum = recChNum + 1;
    end
    pause(2)
end
disp(['Please wait...', char(num2str(100*(recChNum/9))), ' %'])

%% Step 5. Generate effective-connectivity/CoD summary Figures 3 and 4
% This step creates:
% - Res: table with stream-level results
% - tableRes: structure with individual stream measures
fprintf('\n[Step 5/16] Compute stream-level output measures and relative balances.\n');

[Res, tableRes] = vc_measure_streams(crp, localDataPath);

% Compute graphical edge width and opacity for Figure 5a
maxOpacity = max(cell2mat(Res.PorcenSignRes));
for i = 1:12
    Res.stroke(i) = 3*cell2mat(Res.numSubj(i))/cell2mat(Res.numSubjAll(i));
    
    Res.opacity(i) = 100*cell2mat(Res.PorcenSignRes(i))/maxOpacity;
end

fprintf('\nPlots for figures 3 and 4 \n');
run(fullfile(codeDir, 'vc_ploting_Cod.m'));

%% Step 6. Prepare response tables
fprintf('\n[Step 6/16] Prepare response tables.\n');

run(fullfile(codeDir, 'vc_data2connectograms.m'));

%% Step 7. Generate violin plots and fit mixed-effects models Figures 3 and 4
fprintf('\nPlots for figures 3 and 4 and tables for supplemental material S1-2\n');

fprintf('\n[Step 7/16] Generating violin plots and statistical models.\n');

run(fullfile(codeDir, 'vc_violinPlots_stats.m'));

%% Step 8. Compute relative-balance  Summary figure 5

fprintf('\n[Step 8/16] Calculating balance for Figure 5a.\n');

% Balance early visual
BalanceEV = (sum([cell2mat(Res.SignRes(10:12))])/sum([cell2mat(Res.AllRes(10:12))]))/... % relative outputs/
    (sum([cell2mat(Res.SignRes([3 6 9]))])/sum([cell2mat(Res.AllRes([3 6 9]))])); % realative inputs 

% Balance dorsal
BalanceD = (sum([cell2mat(Res.SignRes(1:3))])/sum([cell2mat(Res.AllRes(1:3))]))/... % relative outputs/
    (sum([cell2mat(Res.SignRes([4 7 10]))])/sum([cell2mat(Res.AllRes([4 7 10]))])); % realative inputs 

% Balance lateral
BalanceL = (sum([cell2mat(Res.SignRes(4:6))])/sum([cell2mat(Res.AllRes(4:6))]))/... % relative outputs/
    (sum([cell2mat(Res.SignRes([1 8 11]))])/sum([cell2mat(Res.AllRes([1 8 11]))])); % realative inputs 

% Balance ventral
BalanceV = (sum([cell2mat(Res.SignRes(7:9))])/sum([cell2mat(Res.AllRes(7:9))]))/... % relative outputs/
    (sum([cell2mat(Res.SignRes([2 5 12]))])/sum([cell2mat(Res.AllRes([2 5 12]))])); % realative inputs 

% For figure 5a
fprintf(['\n BALANCE for figure 5a: \n Early visual areas:' char(string(BalanceEV))...
    ', \n Dorsal stream:' char(string(BalanceD)) ', \n Lateral stream:' char(string(BalanceL))...
    ', \n Ventral stream:' char(string(BalanceV)) '\n']);

%% Step 9a. Generate source-target spatial specificity summary - Figure 5a 
fprintf('\n[Step 9a/16] Generating effective-connectivity summary for Figure 5a.\n');

[fig5a, edgeDisplayFig5a] = ...
    vc_plot_effective_connectivity_summary( ...
        Res, ...
        BalanceEV, ...
        BalanceD, ...
        BalanceL, ...
        BalanceV);
drawnow

%% Step 9b. Generate source-target spatial specificity summary - Figure 5b
fprintf('\n[Step 9b/16] Generating source-target spatial specificity summary.\n');

run('vp_Specificity_Source_Target.m');

%Calculate percentage of significant responses
run(fullfile(codeDir, 'vc_porcentageSigRes.m'));

%% Step 10. Generate circular connectograms Figure 6
fprintf('\n[Step 10/16] Generating circular connectograms.\n');

run(fullfile(codeDir, 'vc_circularConnectograms.m'));

%% Step 11. Generate connectivity matrix. Figure 7

fprintf('\n[Step 11/16] Generating connectivity matrix.\n');

run(fullfile(codeDir, 'vc_connectivityMatrix.m'));

%% Step 12. Dorsal outputs and traces. Figure 8a

fprintf('\n[Step 12/16] Dorsal outputs all subjects.\n');

pathwayT = 'Dorsal';    % 'Dorsal' | 'Lateral' | 'Ventral' | 'Posterior'
whoplot = 0;            % 0 all subjects | 1 one specific subject
plotOnePair = 0;        % 0 all pairs | 1 one pair
mni = 1;                % 1 MNI | 0 individual
inflatedBrain = 1;      % 1 inflated | 0 non-inflated
yesLabels = 0;          % 1 yes | 0 no
AreaInStream = [];      % [] or e.g. 'A37elv'
vc_plot_roi_outputs(crp, all_subjects, localDataPath, pathwayT, whoplot, '', plotOnePair, '', mni, inflatedBrain, yesLabels, AreaInStream)

% plot example traces 
subjects_fig8a = {'01', '11', '14', '17'};
recChannels_fig8a = {'LT8','LT8','LPT6','RTO10'};
stimPairs_fig8a = { ...
    'LG6-LG7', ...
    'LQ7-LQ8', ...
    'LPO8-LPO9', ...
    'RPP12-RPP13'};

for recChNum = 1:4
    figure
    sub2plot = ['sub_' subjects_fig8a{recChNum}];
    recCh = recChannels_fig8a(recChNum);
    stimPair2plot = stimPairs_fig8a(recChNum);
    idx = find(ismember([all.stimPair], stimPair2plot) & ismember({all.recordCh}, recCh) & ismember({all.Subj}, {sub2plot}));
    % Individual trials + mean, without tR
    vc_plot_ccep_trace(all(idx), ...
        'TrialDisplay','ci', ...
        'ShowTR',true);
    title(['sub' subjects_fig8a{recChNum}, '    CoD = ',...
    num2str(all(idx).cod)],'FontSize', 10);
    pause(1)
end

%% Step 13. A37elv outputs and traces - Figure 8b

fprintf('\n[Step 13/16] A37elv outputs all subjects.\n');

pathwayT = 'Ventral';
AreaInStream = 'A37elv';
whoplot = 0;
plotOnePair = 0;
mni = 1;
inflatedBrain = 1;
yesLabels = 0;
hem_fig8b = [1 2];
view_fig8b = { ...
    [-60,-30], ...
    [60,-30]};

for i = 1:size(view_fig8b,2)
    hem2plot = hem_fig8b(i);
    views2plot = view_fig8b(i);
    figure;
    vc_plot_1brain( ...
        crp, ...
        all_subjects, ...
        localDataPath, ...
        pathwayT, ...
        whoplot, ...
        '', ...
        plotOnePair, ...
        '', ...
        mni, ...
        inflatedBrain, ...
        yesLabels, ...
        AreaInStream,...
        hem2plot,...
        views2plot);
end
pause(1)

% plot example traces
subjects_fig8b = {'01','05','17'};
recChannels_fig8b = {'LOC8','ROC12','ROC14'};
stimPairs_fig8b = { ...
    'LT8-LT9', ...
    'RC7-RC8', ...
    'RTO10-RTO11'};

for recChNum = 1:3
    figure
    sub2plot = ['sub_' subjects_fig8b{recChNum}];
    recCh = recChannels_fig8b(recChNum);
    stimPair2plot = stimPairs_fig8b(recChNum);
    idx = find(ismember([all.stimPair], stimPair2plot) & ismember({all.recordCh}, recCh) & ismember({all.Subj}, {sub2plot}));
    % Individual trials + mean, without tR
    vc_plot_ccep_trace(all(idx), ...
        'TrialDisplay','ci', ...
        'ShowTR',true);
    title(['sub' subjects_fig8b{recChNum}, '    CoD = ',...
    num2str(all(idx).cod)],'FontSize', 10);
    pause(1)
end

%% Synthetic-task analyses
%
% Participants:
%   ss = 1 -> sub-01
%   ss = 2 -> sub-11
%   ss = 3 -> sub-17
syntheticSubjects = {'01', '11', '17'};

%% Step 14. Synthetic-task seed-to-all correlation maps

fprintf('\n[Step 14/16] Synthetic-task seed-to-all correlation maps.\n');

for ss = 1:numel(syntheticSubjects)

    fprintf('\nProcessing sub-%s (%d/%d)\n', ...
        syntheticSubjects{ss}, ...
        ss, ...
        numel(syntheticSubjects));

    run(fullfile( ...
        codeDir, ...
        'vc_synth_seed_correlation.m'));
    drawnow
end
clear ss

%% Step 15. Synthetic-task local word selectivity

fprintf('\n[Step 15/16] Generate synthetic-task local word selectivity.\n');

for ss = 1:numel(syntheticSubjects)
    fprintf('\nProcessing sub-%s (%d/%d)\n', ...
        syntheticSubjects{ss}, ...
        ss, ...
        numel(syntheticSubjects));
    run(fullfile( ...
        codeDir, ...
        'vc_synth_local_word_selectivity.m'));
    drawnow
end
clear ss

%% Step 16. Regional broadband time courses

fprintf('\n[Step 16/16] Generate regional broadband time courses with 95%% CI.\n');

for ss = 1:numel(syntheticSubjects)
    fprintf('\nProcessing sub-%s (%d/%d)\n', ...
        syntheticSubjects{ss}, ...
        ss, ...
        numel(syntheticSubjects));
    run(fullfile( ...
        codeDir, ...
        'vc_synth_regional_bb_timecourses.m'));
    drawnow
end

%% Complete
fprintf('\nVisual Connectivity workflow completed.\n');
