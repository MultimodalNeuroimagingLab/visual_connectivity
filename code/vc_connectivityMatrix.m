%% Connectivity matrix
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 
% Minimum number of tested connections considered sufficiently sampled
minConnectionsForStable = 4;

%% NaN for intrastream in EV
for i = 1:3
    for j = 1:3
        sigResMatrix(i,j) = NaN;
        TestedMatrix(i,j) = NaN;
    end
end

%% NaN for intrastream in Ventral
for i = 4:9
    for j = 4:9
        sigResMatrix(i,j) = NaN;
        TestedMatrix(i,j) = NaN;
    end
end

%% NaN for intrastream in Lateral
for i = 10:13
    for j = 10:13
        sigResMatrix(i,j) = NaN;
        TestedMatrix(i,j) = NaN;
    end
end

%% NaN for intrastream in Dorsal
for i = 14:22
    for j = 14:22
        sigResMatrix(i,j) = NaN;
        TestedMatrix(i,j) = NaN;
    end
end

%% Identify sparsely sampled connections
% Tested but fewer than the requested minimum.
lowSamplingMask = ...
    TestedMatrix > 0 & ...
    TestedMatrix < minConnectionsForStable;

%% Percentage significant
rel_prop = 100 * sigResMatrix ./ TestedMatrix;

% NaN = intrastream / not applicable
rel_prop(isnan(rel_prop)) = -1;

% Zero tested = unmeasured
rel_prop(TestedMatrix == 0) = -2;

%% Colormap
cm = hot(150);
cm = cm(1:100,:);

% -1 = intrastream
cm = [1 1 1; cm];

% -2 = unmeasured
cm = [.5 .5 .5; cm];

area_labels = { ...
    'V1','V2','V3', ...
    'hOc4v','FG1','FG2','FG3','FG4','A37', ...
    'TO2','TO1','LO2','LO1', ...
    'V3A','V3B','IPS0','IPS1','IPS2','IPS3','IPS4','IPS5','SPL1'};

%% Plot
figure

imagesc(rel_prop,[-2 100])

colormap(cm)
colorbar

h = set(gca, ...
    'XTick',1:length(area_labels), ...
    'XTickLabel',area_labels, ...
    'YTick',1:length(area_labels), ...
    'YTickLabel',area_labels);

hold on

%% Gray diagonal hatching for sparsely sampled cells
hatchColor = [0.45 0.45 0.45];
hatchLineWidth = 1.2;

for kk = 1:22
    for ii = 1:22

        if lowSamplingMask(kk,ii)

            % Three parallel diagonal lines inside the cell
            line([ii-0.5 ii], ...
                 [kk kk-0.5], ...
                 'Color',hatchColor, ...
                 'LineWidth',hatchLineWidth);

            line([ii-0.5 ii+0.5], ...
                 [kk+0.5 kk-0.5], ...
                 'Color',hatchColor, ...
                 'LineWidth',hatchLineWidth);

            line([ii ii+0.5], ...
                 [kk+0.5 kk], ...
                 'Color',hatchColor, ...
                 'LineWidth',hatchLineWidth);

        end
    end
end

%% Number of tested connections
for kk = 1:22
    for ii = 1:22

        if ~isnan(TestedMatrix(kk,ii))

            text(ii,kk, ...
                int2str(TestedMatrix(kk,ii)), ...
                'Color',[1 1 1], ...
                'HorizontalAlignment','Center');

        end
    end
end

hold off

h.Position = [0 0 560 491];

%% Report sparsely sampled cells
fprintf('\nConnectivity-matrix sampling threshold: < %d connections\n', ...
    minConnectionsForStable);

fprintf('Hatched cells: %d\n',sum(lowSamplingMask(:)));