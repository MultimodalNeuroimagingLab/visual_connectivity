function [figH, edgeDisplay] = vc_plot_effective_connectivity_summary(Res, BalanceEV, BalanceD, BalanceL, BalanceV)
% VC_PLOT_EFFECTIVE_CONNECTIVITY_SUMMARY
% Reproduce the effective-connectivity network summary used in Figure 5a.
%
% Edge color   = source pathway
% Edge width   = Res.stroke
% Edge opacity = Res.opacity / 100
% Node number  = output/input balance
%
% Inputs
% ------
% Res       : 12-row pathway-level summary table
% BalanceEV : early visual output/input balance
% BalanceD  : dorsal output/input balance
% BalanceL  : lateral output/input balance
% BalanceV  : ventral output/input balance
%
% Outputs
% -------
% figH        : figure handle
% edgeDisplay : table containing the values used to draw each edge
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 

%% Validate inputs

assert(istable(Res), 'Res must be a MATLAB table.');

requiredVariables = ["from", "to", "stroke", "opacity"];
missingVariables = setdiff(requiredVariables, string(Res.Properties.VariableNames));

assert(isempty(missingVariables), ...
    'Res is missing required variables: %s', ...
    char(strjoin(missingVariables, ', ')));

assert(height(Res) == 12, ...
    'Expected 12 directed pathway relationships; found %d.', height(Res));

%% Convert table columns to plotting values

sourceName = strtrim(string(Res.from));
targetName = strtrim(string(Res.to));

sourceCode = strings(height(Res),1);
targetCode = strings(height(Res),1);

for i = 1:height(Res)
    sourceCode(i) = canonicalRegionCode(sourceName(i));
    targetCode(i) = canonicalRegionCode(targetName(i));
end

lineWidth = numericTableColumn(Res, 'stroke');
opacityPercent = numericTableColumn(Res, 'opacity');
opacityFraction = max(0, min(1, opacityPercent ./ 100));

if ismember('PorcenSignRes', Res.Properties.VariableNames)
    significantResponsePercent = numericTableColumn(Res, 'PorcenSignRes');
else
    significantResponsePercent = nan(height(Res),1);
end

if all(ismember({'numSubj','numSubjAll'}, Res.Properties.VariableNames))
    nParticipants = numericTableColumn(Res, 'numSubj');
    nParticipantsPossible = numericTableColumn(Res, 'numSubjAll');
    participantCoverage = nParticipants ./ nParticipantsPossible;
else
    nParticipants = nan(height(Res),1);
    nParticipantsPossible = nan(height(Res),1);
    participantCoverage = lineWidth ./ 6;
end

edgeDisplay = table( ...
    sourceName, ...
    targetName, ...
    sourceCode, ...
    targetCode, ...
    lineWidth, ...
    opacityPercent, ...
    significantResponsePercent, ...
    nParticipants, ...
    nParticipantsPossible, ...
    participantCoverage, ...
    'VariableNames', { ...
        'Source', ...
        'Target', ...
        'SourceCode', ...
        'TargetCode', ...
        'LineWidth', ...
        'DisplayOpacityPercent', ...
        'SignificantResponsePercent', ...
        'NParticipants', ...
        'NParticipantsPossible', ...
        'ParticipantCoverage'});

fprintf('\nFigure 5a edge display values:\n');
disp(edgeDisplay)

%% Colors

pathwayColors.EV = [234 162 142] / 255;  % #EAA28E
pathwayColors.D  = [ 89 166 230] / 255;  % #59A6E6
pathwayColors.L  = [179 140 199] / 255;  % #B38CC7
pathwayColors.V  = [115 191  77] / 255;  % #73BF4D

%% Node layout

nodes.EV.type   = 'circle';
nodes.EV.center = [0.75 0.00];
nodes.EV.radius = 0.65;
nodes.EV.label  = 'early visual';
nodes.EV.balance = BalanceEV;

nodes.D.type   = 'rect';
nodes.D.center = [3.15  1.20];
nodes.D.width  = 1.20;
nodes.D.height = 0.62;
nodes.D.label  = 'dorsal';
nodes.D.balance = BalanceD;

nodes.L.type   = 'rect';
nodes.L.center = [3.15  0.00];
nodes.L.width  = 1.20;
nodes.L.height = 0.62;
nodes.L.label  = 'lateral';
nodes.L.balance = BalanceL;

nodes.V.type   = 'rect';
nodes.V.center = [3.15 -1.20];
nodes.V.width  = 1.20;
nodes.V.height = 0.62;
nodes.V.label  = 'ventral';
nodes.V.balance = BalanceV;

%% Geometry

geom.gapRect = 0.03;
geom.gapEV = 0.03;
geom.straightOffset = 0.10;
geom.sepDV = 0.13;
geom.sepL = 0.13;

geom.evAng_D_out = 34;
geom.evAng_D_in  = 21;
geom.evAng_L_out = 7;
geom.evAng_L_in  = -7;
geom.evAng_V_out = -21;
geom.evAng_V_in  = -34;

geom.arcXShift = 0.18;
geom.rDV = 1.55;
geom.rVD = 1.35;
geom.arcExtraDegDV = 9;
geom.arcExtraDegVD = -9;
geom.maxArcAngle = 80;

%% Create figure

figH = figure( ...
    'Color', 'w', ...
    'Position', [100 100 600 670], ...
    'Name', 'Figure 5a - Effective connectivity', ...
    'NumberTitle', 'off');

ax = axes('Parent', figH);
hold(ax, 'on')
axis(ax, 'equal')
axis(ax, 'off')
set(ax, 'Clipping', 'off', 'SortMethod', 'childorder');


%% Draw edges first

% Draw faint edges first and stronger edges last.
[~, drawOrder] = sort(opacityFraction, 'ascend');

for orderIndex = 1:numel(drawOrder)

    rowIndex = drawOrder(orderIndex);
    src = sourceCode(rowIndex);
    trg = targetCode(rowIndex);

    [pathXY, isCurved] = makeSummaryPath(src, trg, nodes, geom);

    if isCurved
        headLength = 0.1;
    else
        headLength = 0.1;
    end

    % All arrows use black as the base color.
    % Res.opacity controls the apparent transparency on a white background.
    baseColor = [0 0 0];
    
    alphaNow = opacityFraction(rowIndex);
    
    displayColor = ...
        alphaNow .* baseColor + ...
        (1 - alphaNow) .* [1 1 1];

    drawConstantWidthArrow( ...
        ax, ...
        pathXY, ...
        4*lineWidth(rowIndex), ...
        displayColor, ...
        headLength);
end

%% Draw nodes on top

drawCircleNode(ax, nodes.EV, [1 1 1], pathwayColors.EV);
drawRectNode(ax, nodes.D, [1 1 1], pathwayColors.D);
drawRectNode(ax, nodes.L, [1 1 1], pathwayColors.L);
drawRectNode(ax, nodes.V, [1 1 1], pathwayColors.V);
 


%% 
%  Inset: percentage of significant responses by direction
%  Figure 5a, lower-right corner


% Feedforward: Posterior -> Dorsal/Lateral/Ventral
ff = 100 * ...
    sum(cell2mat(Res.SignRes(10:12))) / ...
    sum(cell2mat(Res.AllRes(10:12)));

% Feedback: Dorsal/Lateral/Ventral -> Posterior
fb = 100 * ...
    sum(cell2mat(Res.SignRes([3 6 9]))) / ...
    sum(cell2mat(Res.AllRes([3 6 9])));

% Upward:
% Ventral -> Lateral
% Lateral -> Dorsal
% Ventral -> Dorsal
uw = 100 * ...
    sum(cell2mat(Res.SignRes([8 4 7]))) / ...
    sum(cell2mat(Res.AllRes([8 4 7])));

% Downward:
% Lateral -> Ventral
% Dorsal -> Lateral
% Dorsal -> Ventral
dw = 100 * ...
    sum(cell2mat(Res.SignRes([5 1 2]))) / ...
    sum(cell2mat(Res.AllRes([5 1 2])));

directionPercent = [ff fb uw dw];

% Small axes inside the same figure
axInset = axes( ...
    'Parent', figH, ...
    'Position', [0.8 0.08 0.20 0.20]);

bar(axInset, directionPercent, ...
    'FaceColor', [0.75 0.75 0.75], ...
    'EdgeColor', 'none');

ylim(axInset, [0 50])

ylabel(axInset, '% significant responses')

xticks(axInset, 1:4)
xticklabels(axInset, {'ff','fb','uw','dw'})

box(axInset, 'off')
set(axInset, ...
    'TickDir', 'out', ...
    'FontSize', 9)

% Values above bars
for k = 1:4
    text(axInset, ...
        k, ...
        directionPercent(k) + 1, ...
        sprintf('%.1f', directionPercent(k)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 8);
end

end



%% Local functions


function x = numericTableColumn(T, variableName)

    x = T.(variableName);

    if iscell(x)
        x = cellfun(@double, x);
    else
        x = double(x);
    end

    x = x(:);
end

function code = canonicalRegionCode(regionName)

    value = lower(strtrim(string(regionName)));

    if value == "posterior" || value == "early visual" || ...
            value == "earlyvisual" || value == "ev"
        code = "EV";
    elseif value == "dorsal" || value == "d"
        code = "D";
    elseif value == "lateral" || value == "l"
        code = "L";
    elseif value == "ventral" || value == "v"
        code = "V";
    else
        error('Unknown pathway label: %s', char(regionName));
    end
end

function c = getRegionColor(regionCode, colors)

    switch char(regionCode)
        case 'EV'
            c = colors.EV;
        case 'D'
            c = colors.D;
        case 'L'
            c = colors.L;
        case 'V'
            c = colors.V;
        otherwise
            error('Unknown region code: %s', char(regionCode));
    end
end

function [pathXY, isCurved] = makeSummaryPath(src, trg, nodes, geom)

    key = char(src + "_" + trg);

    switch key
        case 'EV_D'
            p0 = circleAnchorFixed(nodes.EV, geom.evAng_D_out, geom.gapEV);
            p1 = rectAnchor(nodes.D, 'left', geom.sepDV, geom.gapRect);
            pathXY = straightPointPath(p0, p1, 120);
            isCurved = false;

        case 'D_EV'
            p0 = rectAnchor(nodes.D, 'left', -geom.sepDV, geom.gapRect);
            p1 = circleAnchorFixed(nodes.EV, geom.evAng_D_in, geom.gapEV);
            pathXY = straightPointPath(p0, p1, 120);
            isCurved = false;

        case 'EV_L'
            p0 = circleAnchorFixed(nodes.EV, geom.evAng_L_out, geom.gapEV);
            p1 = rectAnchor(nodes.L, 'left', geom.sepL, geom.gapRect);
            pathXY = straightPointPath(p0, p1, 120);
            isCurved = false;

        case 'L_EV'
            p0 = rectAnchor(nodes.L, 'left', -geom.sepL, geom.gapRect);
            p1 = circleAnchorFixed(nodes.EV, geom.evAng_L_in, geom.gapEV);
            pathXY = straightPointPath(p0, p1, 120);
            isCurved = false;

        case 'EV_V'
            p0 = circleAnchorFixed(nodes.EV, geom.evAng_V_out, geom.gapEV);
            p1 = rectAnchor(nodes.V, 'left', geom.sepDV, geom.gapRect);
            pathXY = straightPointPath(p0, p1, 120);
            isCurved = false;

        case 'V_EV'
            p0 = rectAnchor(nodes.V, 'left', -geom.sepDV, geom.gapRect);
            p1 = circleAnchorFixed(nodes.EV, geom.evAng_V_in, geom.gapEV);
            pathXY = straightPointPath(p0, p1, 120);
            isCurved = false;

        case 'D_L'
            pathXY = straightNodePath(nodes.D, nodes.L, geom.straightOffset, 90);
            isCurved = false;

        case 'L_D'
            pathXY = straightNodePath(nodes.L, nodes.D, geom.straightOffset, 90);
            isCurved = false;

        case 'L_V'
            pathXY = straightNodePath(nodes.L, nodes.V, geom.straightOffset, 90);
            isCurved = false;

        case 'V_L'
            pathXY = straightNodePath(nodes.V, nodes.L, geom.straightOffset, 90);
            isCurved = false;

        case 'D_V'
            arcCenter = [nodes.D.center(1) - geom.arcXShift, 0];
            yLevel = abs(nodes.D.center(2));
            angleDV = asind(yLevel / geom.rDV) + geom.arcExtraDegDV;
            angleDV = min(angleDV, geom.maxArcAngle);
            pathXY = circularArcPath(arcCenter, geom.rDV, angleDV, -angleDV, 240);
            isCurved = true;

        case 'V_D'
            arcCenter = [nodes.D.center(1) - geom.arcXShift, 0];
            yLevel = abs(nodes.D.center(2));
            angleVD = asind(yLevel / geom.rVD) + geom.arcExtraDegVD;
            angleVD = min(angleVD, geom.maxArcAngle);
            pathXY = circularArcPath(arcCenter, geom.rVD, -angleVD, angleVD, 220);
            isCurved = true;

        otherwise
            error('No path defined for edge %s.', key);
    end
end

function pathXY = straightNodePath(nodeA, nodeB, offsetAmount, nPoints)

    gap = 0.08;
    p0 = nodeBoundaryPoint(nodeA, nodeB.center, gap);
    p1 = nodeBoundaryPoint(nodeB, nodeA.center, gap);

    v = p1 - p0;
    pathLength = norm(v);

    if pathLength == 0
        pathXY = [p0; p1];
        return
    end

    unitVector = v / pathLength;
    normal = [-unitVector(2), unitVector(1)];

    p0 = p0 + offsetAmount .* normal;
    p1 = p1 + offsetAmount .* normal;

    pathXY = straightPointPath(p0, p1, nPoints);
end

function p = nodeBoundaryPoint(node, towardPoint, gap)

    center = node.center;
    direction = towardPoint - center;

    if norm(direction) == 0
        p = center;
        return
    end

    unitVector = direction ./ norm(direction);

    if strcmp(node.type, 'circle')
        p = center + unitVector .* (node.radius + gap);
    else
        halfWidth = node.width / 2 + gap;
        halfHeight = node.height / 2 + gap;

        tx = inf;
        ty = inf;

        if abs(unitVector(1)) > eps
            tx = halfWidth / abs(unitVector(1));
        end

        if abs(unitVector(2)) > eps
            ty = halfHeight / abs(unitVector(2));
        end

        scale = min(tx, ty);
        p = center + unitVector .* scale;
    end
end

function p = rectAnchor(node, side, offset, gap)

    cx = node.center(1);
    cy = node.center(2);

    switch side
        case 'left'
            p = [cx - node.width/2 - gap, cy + offset];
        case 'right'
            p = [cx + node.width/2 + gap, cy + offset];
        case 'top'
            p = [cx + offset, cy + node.height/2 + gap];
        case 'bottom'
            p = [cx + offset, cy - node.height/2 - gap];
        otherwise
            error('Unknown rectangle side: %s', side);
    end
end

function p = circleAnchorFixed(node, angleDegrees, gap)

    radius = node.radius + gap;
    p = node.center + radius .* [cosd(angleDegrees), sind(angleDegrees)];
end

function pathXY = straightPointPath(p0, p1, nPoints)

    t = linspace(0,1,nPoints)';
    pathXY = (1-t).*p0 + t.*p1;
end

function pathXY = circularArcPath(center, radius, startAngle, endAngle, nPoints)

    theta = linspace(startAngle, endAngle, nPoints)';
    x = center(1) + radius .* cosd(theta);
    y = center(2) + radius .* sind(theta);
    pathXY = [x y];
end

function drawConstantWidthArrow(ax, pathXY, lineWidth, colorValue, headLength)

    plot(ax, pathXY(:,1), pathXY(:,2), ...
        'Color', colorValue, ...
        'LineWidth', lineWidth, ...
        'Clipping', 'off');

    tip = pathXY(end,:);

    % Use a point sufficiently far from the tip to obtain a stable tangent.
    backIndex = max(1, size(pathXY,1)-5);
    previousPoint = pathXY(backIndex,:);

    direction = tip - previousPoint;

    if norm(direction) == 0
        return
    end

    direction = direction ./ norm(direction);
    normal = [-direction(2), direction(1)];

    base = tip - headLength .* direction;
    halfHeadWidth = 0.030 + 0.006 .* lineWidth;

    leftPoint = base + halfHeadWidth .* normal;
    rightPoint = base - halfHeadWidth .* normal;

    patch(ax, ...
        [tip(1), leftPoint(1), rightPoint(1)], ...
        [tip(2), leftPoint(2), rightPoint(2)], ...
        colorValue, ...
        'EdgeColor', 'none', ...
        'Clipping', 'off');
end

function drawCircleNode(ax, node, faceColor, edgeColor)

    theta = linspace(0,2*pi,200);
    x = node.center(1) + node.radius .* cos(theta);
    y = node.center(2) + node.radius .* sin(theta);

    patch(ax, x, y, faceColor, ...
        'EdgeColor', edgeColor, ...
        'LineWidth', 3, ...
        'FaceAlpha', 1);

    text(ax, node.center(1), node.center(2)+0.10, ...
        node.label, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 13, ...
        'FontWeight', 'bold');

    text(ax, node.center(1), node.center(2)-0.15, ...
        sprintf('%.2f', node.balance), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 13, ...
        'FontWeight', 'bold', ...
        'Color', [0.90 0.12 0.12]);
end

function drawRectNode(ax, node, faceColor, edgeColor)

    x0 = node.center(1) - node.width/2;
    y0 = node.center(2) - node.height/2;

    rectangle(ax, ...
        'Position', [x0 y0 node.width node.height], ...
        'Curvature', 0.04, ...
        'FaceColor', faceColor, ...
        'EdgeColor', edgeColor, ...
        'LineWidth', 3);

    text(ax, node.center(1), node.center(2)+0.08, ...
        node.label, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 13, ...
        'FontWeight', 'bold');

    text(ax, node.center(1), node.center(2)-0.14, ...
        sprintf('%.2f', node.balance), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 13, ...
        'FontWeight', 'bold', ...
        'Color', [0.90 0.12 0.12]);
end
