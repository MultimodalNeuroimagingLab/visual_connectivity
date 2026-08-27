%% COD VIOLIN PLOTS and stats
% Feedforward vs Feedback
% Upward vs Downward
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 


%% Feedforward and Feedback
fromPathway = {'Posterior'};
toPathway = {'Dorsal', 'Lateral', 'Ventral'};
whoPath = {[1:3],1,2,3};
colorpath=[...
    [0.7 0.7 0.7]           % gray
    [0.380, 0.584, 0.808]   % #6195ce
    [0.690, 0.549, 0.749]   % #B08CBF
    [0.459, 0.776, 0.627]   % #75C6A0
    ];
namePath = {'all', 'dorsal', 'lateral', 'ventral'};
h=figure('Position',[0 0 650 1000]);

modelsForwardBack = cell(1,4);
for k=1:4
    toPathwat = toPathway(cell2mat(whoPath(k)));
    CoD1stDirection = [];
    Subj1stDirection = [];
    for i=1:size(Responses,1)
        if ismember(Responses.pathway(i),fromPathway) && ismember(Responses.recPathway(i),toPathwat)
            CoD1stDirection = [CoD1stDirection median(Responses.codAll{i,:})];
            Subj1stDirection = [Subj1stDirection Responses.Subj(i)];
        end
    end
    subplot(4,2,2*k-1);distributionPlot(CoD1stDirection','histOpt',1.1,'addBoxes',0,'showMM',1,'Color',colorpath(k,:))
    hold on
    plot([0,2],[0,0], 'k--')
    hold off
    ylim([-0.6 1])
    title(['Feedforward ' char(string(namePath(k))) ' ' char(string(size(CoD1stDirection,2))) ' possible connections'])
    ylabel('CoD');
    CoD2ndDirection = [];
    Subj2ndDirection = [];
    for i=1:size(Responses,1)
        if ismember(Responses.pathway(i),toPathwat) && ismember(Responses.recPathway(i),fromPathway)
            CoD2ndDirection = [CoD2ndDirection median((Responses.codAll{i,:}))];
            Subj2ndDirection = [Subj2ndDirection Responses.Subj(i)];
        end
    end
    subplot(4,2,2*k);distributionPlot(CoD2ndDirection','histOpt',1.1,'addBoxes',0,'showMM',1,'Color',colorpath(k,:))
    hold on
    plot([0,2],[0,0], 'k--')
    hold off
    ylim([-0.6 1])
    title(['Feedback ' char(string(namePath(k))) ' ' char(string(size(CoD2ndDirection,2))) ' possible connections'])
    ylabel('CoD');

    clearvars thisCategory Feed
    % stats
    Feed.cod = [CoD1stDirection'; CoD2ndDirection'];
    thisCategory(1,1:length(CoD1stDirection)) = {'Feedforward'};
    thisCategory(1,(length(CoD1stDirection)+1:size(Feed.cod,1))) = {'Feedback'};
    Feed.groupAll = thisCategory';
    Feed.subject = [Subj1stDirection'; Subj2ndDirection'];
    Feed = struct2table(Feed);
    Feed.groupAll = categorical(Feed.groupAll);
    Feed.subject = categorical(Feed.subject);
    % linear mixed effects model 
    modelsForwardBack{k} = fitlme(Feed,'cod ~groupAll + (1|subject)');
    
end


% modelsForwardBack{1} -> Posterior ↔ Dorsal/Lateral/Ventral, all combined
% modelsForwardBack{2} -> Posterior ↔ Dorsal
% modelsForwardBack{3} -> Posterior ↔ Lateral
% modelsForwardBack{4} -> Posterior ↔ Ventral

%BHFDR
pForwardBack = [ ...
    modelsForwardBack{2}.Coefficients.pValue(2) ...
    modelsForwardBack{3}.Coefficients.pValue(2) ...
    modelsForwardBack{4}.Coefficients.pValue(2)];

qForwardBack = vc_bh_fdr(pForwardBack);
for i = 1:numel(qForwardBack)

    if qForwardBack(i) < 0.0001
        stars{i} = '***';

    elseif qForwardBack(i) < 0.001
        stars{i} = '**';

    elseif qForwardBack(i) < 0.05
        stars{i} = '*';

    else
        stars{i} = 'ns';
    end

end

fprintf('* q < 0.05,  ** q < 0.001,  *** q < 0.0001');

table(pForwardBack(:), qForwardBack(:), stars(:), ...
    'VariableNames', {'p_raw','q_FDR','significance'})

% Suplementary table for paper: Feedforward vs Feedback

comparisonNames = { ...
    'Feedforward vs Feedback'
    'EV -> Do vs Do -> EV'
    'EV -> La vs La -> EV'
    'EV -> Ve vs Ve -> EV'};

nModels = numel(modelsForwardBack);

Comparison = strings(nModels*2,1);
Effect     = strings(nModels*2,1);

Estimate = nan(nModels*2,1);
SE       = nan(nModels*2,1);
tStat    = nan(nModels*2,1);
DF       = nan(nModels*2,1);
pValue   = nan(nModels*2,1);
CI_Lower = nan(nModels*2,1);
CI_Upper = nan(nModels*2,1);

row = 0;

for k = 1:nModels

    C = modelsForwardBack{k}.Coefficients;


    % Intercept

    row = row + 1;

    Comparison(row) = comparisonNames{k};
    Effect(row)     = "Intercept";

    Estimate(row) = C.Estimate(1);
    SE(row)       = C.SE(1);
    tStat(row)    = C.tStat(1);
    DF(row)       = C.DF(1);
    pValue(row)   = C.pValue(1);
    CI_Lower(row) = C.Lower(1);
    CI_Upper(row) = C.Upper(1);

    % Feedforward vs Feedback

    row = row + 1;

    Comparison(row) = "";
    Effect(row)     = "group";

    Estimate(row) = C.Estimate(2);
    SE(row)       = C.SE(2);
    tStat(row)    = C.tStat(2);
    DF(row)       = C.DF(2);
    pValue(row)   = C.pValue(2);
    CI_Lower(row) = C.Lower(2);
    CI_Upper(row) = C.Upper(2);

end

PaperTable_ForwardBack = table( ...
    Comparison, ...
    Effect, ...
    Estimate, ...
    SE, ...
    tStat, ...
    DF, ...
    pValue, ...
    CI_Lower, ...
    CI_Upper);

disp(PaperTable_ForwardBack)


%% Upward and Downward
fromPathway = {'Ventral', 'Lateral', 'Ventral'};
toPathway = {'Lateral', 'Dorsal', 'Dorsal'};
whoPath = {[1:3],1,2,3};

colorpath=[...
    [0.7 0.7 0.7]           % gray
    [0.851, 0.325, 0.098]   % #D95319
    [0.635, 0.078, 0.184]   % #A2142F
    [0.929, 0.694, 0.125]   % #EDB120
    ];

namePath = {'all', 'ventrolateral', 'laterodorsal', 'ventrodorsal'};

h1 = figure('Position',[0 0 650 1000]);

modelsUpDown = cell(1,4);

for k = 1:4

    % Upward
    CoD1stDirection = [];
    Subj1stDirection = [];

    for j = cell2mat(whoPath(k))

        for i = 1:size(Responses,1)

            if ismember(Responses.pathway(i),fromPathway(j)) && ...
                    ismember(Responses.recPathway(i),toPathway(j))

                CoD1stDirection = [CoD1stDirection ...
                    median(Responses.codAll{i,:})];

                Subj1stDirection = [Subj1stDirection ...
                    Responses.Subj(i)];
            end

        end
    end

    subplot(4,2,2*k-1)

    distributionPlot(CoD1stDirection', ...
        'histOpt',1.1, ...
        'addBoxes',0, ...
        'showMM',1, ...
        'Color',colorpath(k,:))

    hold on
    plot([0,2],[0,0],'k--')
    hold off

    ylim([-0.6 1])

    title(['Upward ' char(string(namePath(k))) ' ' ...
        char(string(size(CoD1stDirection,2))) ...
        ' possible connections'])

    ylabel('CoD')


    % Downward
    CoD2ndDirection = [];
    Subj2ndDirection = [];

    for j = cell2mat(whoPath(k))

        for i = 1:size(Responses,1)

            if ismember(Responses.pathway(i),toPathway(j)) && ...
                    ismember(Responses.recPathway(i),fromPathway(j))

                CoD2ndDirection = [CoD2ndDirection ...
                    median(Responses.codAll{i,:})];

                Subj2ndDirection = [Subj2ndDirection ...
                    Responses.Subj(i)];
            end

        end
    end

    subplot(4,2,2*k)

    distributionPlot(CoD2ndDirection', ...
        'histOpt',1.1, ...
        'addBoxes',0, ...
        'showMM',1, ...
        'Color',colorpath(k,:))

    hold on
    plot([0,2],[0,0],'k--')
    hold off

    ylim([-0.6 1])

    title(['Downward ' char(string(namePath(k))) ' ' ...
        char(string(size(CoD2ndDirection,2))) ...
        ' possible connections'])

    ylabel('CoD')


    % Linear mixed-effects model
    clearvars thisCategory Feed

    Feed.cod = [CoD1stDirection'; CoD2ndDirection'];

    thisCategory(1,1:length(CoD1stDirection)) = {'Upward'};

    thisCategory(1, ...
        length(CoD1stDirection)+1:size(Feed.cod,1)) = {'Downward'};

    Feed.groupAll = thisCategory';

    Feed.subject = ...
        [Subj1stDirection'; Subj2ndDirection'];

    Feed = struct2table(Feed);

    Feed.groupAll = categorical(Feed.groupAll);
    Feed.subject = categorical(Feed.subject);

    modelsUpDown{k} = ...
        fitlme(Feed,'cod ~ groupAll + (1|subject)');

end


% modelsUpDown{1} -> all upward/downward connections combined
% modelsUpDown{2} -> Ventral -> Lateral vs Lateral -> Ventral
% modelsUpDown{3} -> Lateral -> Dorsal vs Dorsal -> Lateral
% modelsUpDown{4} -> Ventral -> Dorsal vs Dorsal -> Ventral


% BH-FDR

pUpDown = [ ...
    modelsUpDown{2}.Coefficients.pValue(2) ...
    modelsUpDown{3}.Coefficients.pValue(2) ...
    modelsUpDown{4}.Coefficients.pValue(2)];

qUpDown = vc_bh_fdr(pUpDown);

starsUpDown = cell(1,numel(qUpDown));

for i = 1:numel(qUpDown)

    if qUpDown(i) < 0.0001
        starsUpDown{i} = '***';

    elseif qUpDown(i) < 0.001
        starsUpDown{i} = '**';

    elseif qUpDown(i) < 0.05
        starsUpDown{i} = '*';

    else
        starsUpDown{i} = 'ns';
    end

end

fprintf('* q < 0.05,  ** q < 0.001,  *** q < 0.0001\n');

table( ...
    pUpDown(:), ...
    qUpDown(:), ...
    starsUpDown(:), ...
    'VariableNames', ...
    {'p_raw','q_FDR','significance'})


% Supplementary table for paper: Upward vs Downward

comparisonNames = { ...
    'Upward vs Downward'
    'Ve -> La vs La -> Ve'
    'La -> Do vs Do -> La'
    'Ve -> Do vs Do -> Ve'};

nModels = numel(modelsUpDown);

Comparison = strings(nModels*2,1);
Effect     = strings(nModels*2,1);

Estimate = nan(nModels*2,1);
SE       = nan(nModels*2,1);
tStat    = nan(nModels*2,1);
DF       = nan(nModels*2,1);
pValue   = nan(nModels*2,1);
CI_Lower = nan(nModels*2,1);
CI_Upper = nan(nModels*2,1);

row = 0;

for k = 1:nModels

    C = modelsUpDown{k}.Coefficients;


    % Intercept
 
    row = row + 1;

    Comparison(row) = comparisonNames{k};
    Effect(row)     = "Intercept";

    Estimate(row) = C.Estimate(1);
    SE(row)       = C.SE(1);
    tStat(row)    = C.tStat(1);
    DF(row)       = C.DF(1);
    pValue(row)   = C.pValue(1);
    CI_Lower(row) = C.Lower(1);
    CI_Upper(row) = C.Upper(1);


    % Upward vs Downward
 
    row = row + 1;

    Comparison(row) = "";
    Effect(row)     = "group";

    Estimate(row) = C.Estimate(2);
    SE(row)       = C.SE(2);
    tStat(row)    = C.tStat(2);
    DF(row)       = C.DF(2);
    pValue(row)   = C.pValue(2);
    CI_Lower(row) = C.Lower(2);
    CI_Upper(row) = C.Upper(2);

end

PaperTable_UpDown = table( ...
    Comparison, ...
    Effect, ...
    Estimate, ...
    SE, ...
    tStat, ...
    DF, ...
    pValue, ...
    CI_Lower, ...
    CI_Upper);

disp(PaperTable_UpDown)
