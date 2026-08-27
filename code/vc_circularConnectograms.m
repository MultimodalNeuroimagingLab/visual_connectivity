%% Creating connectograms between visual areas
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 
%%
% Only one Area for rec
for i=1:size(sigResponses,1)
    if strcmp(sigResponses.recPathway(i),'Posterior')
        sigResponses.recArea(i) = sigResponses.recCh_areaBenson(i);
    elseif strcmp(sigResponses.recPathway(i),'Dorsal')
        sigResponses.recArea(i) = sigResponses.recCh_areaWang(i);
    elseif strcmp(sigResponses.recPathway(i),'Lateral')
        sigResponses.recArea(i) = sigResponses.recCh_areaWang(i);
    elseif strcmp(sigResponses.recPathway(i),'Ventral')
        if strcmp(char(sigResponses.recCh_areaBN(i)),"A37elv_L") || strcmp(char(sigResponses.recCh_areaBN(i)),"A37elv_R")
            sigResponses.recArea(i) = 'A37elv';
        else
            sigResponses.recArea(i) = sigResponses.recCh_areaRosenke(i);
        end
    end
end

for i=1:size(noSigResponses,1)
    if strcmp(noSigResponses.recPathway(i),'Posterior')
        noSigResponses.recArea(i) = noSigResponses.recCh_areaBenson(i);
    elseif strcmp(noSigResponses.recPathway(i),'Dorsal')
        noSigResponses.recArea(i) = noSigResponses.recCh_areaWang(i);
    elseif strcmp(noSigResponses.recPathway(i),'Lateral')
        noSigResponses.recArea(i) = noSigResponses.recCh_areaWang(i);
    elseif strcmp(noSigResponses.recPathway(i),'Ventral')
        if strcmp(char(noSigResponses.recCh_areaBN(i)),"A37elv_L") || strcmp(char(noSigResponses.recCh_areaBN(i)),"A37elv_R")
            noSigResponses.recArea(i) = 'A37elv';
        else
            noSigResponses.recArea(i) = noSigResponses.recCh_areaRosenke(i);
        end
    end
end

%% Stim areas

for i=1:size(sigResponses,1)
    if strcmp(sigResponses.pathway(i),'Posterior')
        thisPairStim = split(sigResponses.stimPair_areaBenson(i),'-');
    elseif strcmp(sigResponses.pathway(i),'Dorsal')
        thisPairStim = split(sigResponses.stimPair_areaWang(i),'-');
    elseif strcmp(sigResponses.pathway(i),'Lateral')
        thisPairStim = split(sigResponses.stimPair_areaWang(i),'-');
    elseif strcmp(sigResponses.pathway(i),'Ventral')
        isBN = split(sigResponses.stimPair_areaBN(i),'-');
        if ismember("A37elv_L",isBN) || ismember("A37elv_R",isBN)
            thisPairStim = split(sigResponses.stimPair_areaBN(i),'-');
        else
            thisPairStim = split(sigResponses.stimPair_areaRosenke(i),'-');
            
        end
    end
    if strcmp(char(thisPairStim(1)),"A37elv_L") || strcmp(char(thisPairStim(1)),"A37elv_R")
        sigResponses.stimPair_areaEl1(i) = 'A37elv';
    else
        sigResponses.stimPair_areaEl1(i) = thisPairStim(1);
    end
    if strcmp(char(thisPairStim(2)),"A37elv_L") || strcmp(char(thisPairStim(2)),"A37elv_R")
        sigResponses.stimPair_areaEl2(i) = 'A37elv';
    else
        sigResponses.stimPair_areaEl2(i) = thisPairStim(2);
    end
end

for i=1:size(noSigResponses,1)
    if strcmp(noSigResponses.pathway(i),'Posterior')
        thisPairStim = split(noSigResponses.stimPair_areaBenson(i),'-');
    elseif strcmp(noSigResponses.pathway(i),'Dorsal')
        thisPairStim = split(noSigResponses.stimPair_areaWang(i),'-');
    elseif strcmp(noSigResponses.pathway(i),'Lateral')
        thisPairStim = split(noSigResponses.stimPair_areaWang(i),'-');
    elseif strcmp(noSigResponses.pathway(i),'Ventral')
        isBN = split(noSigResponses.stimPair_areaBN(i),'-');
        if ismember("A37elv_L",isBN) || ismember("A37elv_R",isBN)
            thisPairStim = split(noSigResponses.stimPair_areaBN(i),'-');
        else
            thisPairStim = split(noSigResponses.stimPair_areaRosenke(i),'-');
        end
    end
    if strcmp(char(thisPairStim(1)),"A37elv_L") || strcmp(char(thisPairStim(1)),"A37elv_R")
        noSigResponses.stimPair_areaEl1(i) = 'A37elv';
    else
        noSigResponses.stimPair_areaEl1(i) = thisPairStim(1);
    end
    if strcmp(char(thisPairStim(2)),"A37elv_L") || strcmp(char(thisPairStim(2)),"A37elv_R")
        noSigResponses.stimPair_areaEl2(i) = 'A37elv';
    else
        noSigResponses.stimPair_areaEl2(i) = thisPairStim(2);
    end
end


%%
% Colormap
cmap = [0.9882    0.5647    0.5647;% V1 Benson 1
        0.9882    0.7098    0.5255;% V2 Benson 2
        1         1         0.6000;% V3 Benson  3
        0.0784    0.9490    0.9176;% hOc4v Rosenke 4
        0.1137    0.9647    0.0549;% FG1 Rosenke 5
        0.9333    0.0549    0.9647;% FG2 Rosenke 6
        0.0863    0.1059    0.6824;% FG3 Rosenke 7
        0.4784    0.0471    0.0471;% FG4 Rosenke 8
        0.6000    0.8235    0.5843;% IPS1 Brainnetome A37elv 9 
        0.9000    0.6000    1.0000;% TO2 Wang 10
        0.3500    0.3500    0.3500;% TO1 Wang 11
        0.6974    0.5129    0.8403;% LO2 Wang 12 
        0.1978    0.8408    0.7445;% LO1 Wang 13
        0.9686    0.3098    0.7353;% V3A Wang 14 
        0.3955    0.8227    0.5828;% V3B Wang 15 
        0.2417    0.9409    0.7096;% IPS0 Wang 16
        0.2196    0.0039    0.7588;% IPS1 Wang 18 
        0.2000    0.8000    0.5000;% IPS2 Wang 19
        0.9539    0.7295    0.7562;% IPS3 Wang 20 
        0.2877    0.6154    0.4391;% IPS4 Wang 21
        0.2206    0.2239    0.4094;% IPS5 Wang 22 
        0.9000    1.0000    0.7000];% SPL1 Wang 23
         
%pastel amp
        cmap(1:3,:) = (cmap(1:3,:)).^0.8;
        cmap(4:8,:) = (cmap(4:8,:)).^0.15;
        cmap(10:end,:) = (cmap(10:end,:)).^.6;

areaNames = [{'V1'} {'V2'} {'V3'}... %(1:3) 
    {'hOc4v'} {'FG1'} {'FG2'} {'FG3'} {'FG4'} {'A37elv'}... %(4:9)
    {'TO2'} {'TO1'} {'LO2'} {'LO1'}... %(10:13)
    {'V3A'} {'V3B'} {'IPS0'} {'IPS1'} {'IPS2'} {'IPS3'} {'IPS4'} {'IPS5'} {'SPL1'} ]; %(14:22)



%%
%% Build significant-response connectograms and node annotations

% All areas, early visual, ventral, lateral, dorsal
toplotHere = { ...
    1:22, ...
    1:3, ...
    4:9, ...
    10:13, ...
    14:22};

panelNames = { ...
    'all', ...
    'early_visual', ...
    'ventral', ...
    'lateral', ...
    'dorsal'};

N = numel(areaNames);

% Determine which areas have at least one recording represented
% anywhere in the response tables.
allRecordedAreas = [ ...
    string(sigResponses.recArea(:)); ...
    string(noSigResponses.recArea(:))];

recordedMask = ismember( ...
    string(areaNames), ...
    unique(allRecordedAreas));

nodeSummaries = cell(1, numel(toplotHere));

for k = 1:numel(toplotHere)

    stimIdx = toplotHere{k};

    % x = significant responses
    % y = non-significant responses
    % z = all tested responses
    x = zeros(N,N);
    y = zeros(N,N);

    %% Significant responses

    for i = stimIdx

        for j = 1:N

            valx = find( ...
                (ismember(sigResponses.stimPair_areaEl1, areaNames(i)) | ...
                 ismember(sigResponses.stimPair_areaEl2, areaNames(i))) & ...
                 ismember(sigResponses.recArea, areaNames(j)));

            x(i,j) = numel(valx);

        end
    end

    %% Non-significant responses

    for i = stimIdx

        for j = 1:N

            valy = find( ...
                (ismember(noSigResponses.stimPair_areaEl1, areaNames(i)) | ...
                 ismember(noSigResponses.stimPair_areaEl2, areaNames(i))) & ...
                 ismember(noSigResponses.recArea, areaNames(j)));

            y(i,j) = numel(valy);

        end
    end

    %% All tested responses

    z = x + y;

    %% Establish one common line-width scale using all significant data

    if k == 1

        positiveSignificantCounts = x(x > 0);

        assert(~isempty(positiveSignificantCounts), ...
            'No significant CCEP responses were found.');

        wminSignificant = min(positiveSignificantCounts);
        wmaxSignificant = max(positiveSignificantCounts);

        fprintf( ...
            'Significant CCEP response range: %g to %g\n', ...
            wminSignificant, ...
            wmaxSignificant);

        % Keep these matrices in the workspace for QC.
        sigResMatrix = x;
        TestedMatrix = z;

        % Do not plot the all-area source panel.
        continue

    end

    %% Node-level incoming response counts

    % Sum incoming responses over every stimulated area belonging
    % to the stream represented in the current panel.
    sigIncoming = sum(x(stimIdx,:), 1);
    testedIncoming = sum(z(stimIdx,:), 1);

    %% Determine which source areas were actually stimulated
    %
    % Stimulation status must not depend on whether the stimulation
    % produced a significant response or whether its recording targets
    % could be assigned to one of the plotted visual areas.
    
    stimulatedAreas = [ ...
        string(sigResponses.stimPair_areaEl1(:)); ...
        string(sigResponses.stimPair_areaEl2(:)); ...
        string(noSigResponses.stimPair_areaEl1(:)); ...
        string(noSigResponses.stimPair_areaEl2(:))];
    
    % Remove empty or missing labels.
    stimulatedAreas = stimulatedAreas( ...
        ~ismissing(stimulatedAreas) & stimulatedAreas ~= "");
    
    stimulatedAreas = unique(stimulatedAreas);
    
    % Mark only source areas belonging to the stream in the current panel.
    stimulatedMask = false(1,N);
    
    stimulatedMask(stimIdx) = ismember( ...
        string(areaNames(stimIdx)), ...
        stimulatedAreas);
    
    % NS means Not Stimulated.
    sourceNotStimulatedMask = false(1,N);
    sourceNotStimulatedMask(stimIdx) = ...
        ~stimulatedMask(stimIdx);

    %% Create text displayed inside every node

    nodeText = strings(1,N);

    for j = 1:N

        if stimulatedMask(j)

            % The visual function will draw an inward arrow.
            nodeText(j) = "";

        elseif sourceNotStimulatedMask(j)

            % Area belongs to the selected stream but had no
            % eligible stimulation pair.
            nodeText(j) = "NS";

        elseif ~recordedMask(j)

            % No recording represented for this area.
            nodeText(j) = "NR";

        elseif testedIncoming(j) > 0

            nodeText(j) = sprintf( ...
                '%d/%d', ...
                sigIncoming(j), ...
                testedIncoming(j));

        else

            % This branch should be inspected if it appears.
            % It means that the area was recorded somewhere in the
            % dataset but had no tested connection from this stream.
            nodeText(j) = "NR";

        end
    end

    %% Print the values used in the figure

    nodeSummary = table( ...
        string(areaNames(:)), ...
        sigIncoming(:), ...
        testedIncoming(:), ...
        nodeText(:), ...
        stimulatedMask(:), ...
        'VariableNames', { ...
            'area', ...
            'n_significant', ...
            'n_tested', ...
            'node_label', ...
            'stimulated_source'});

    nodeSummaries{k} = nodeSummary;

    fprintf('\nNode values for %s panel:\n', panelNames{k});
    disp(nodeSummary)

    %% Plot the significant-response connectogram

    vc_visualConnectograms( ...
        x, ...
        cmap, ...
        areaNames, ...
        wmaxSignificant, ...
        nodeText, ...
        stimulatedMask);

    set(gcf, ...
        'Name', panelNames{k}, ...
        'NumberTitle', 'off');

    drawnow

end