%% Source and target spatial spread - summary figure layout
% Same general layout as the summary figure.
%
% Color = source area
% Tail width = source ratio
% Head width = target ratio
%
% Wider = broader spatial spread
% Narrower = more spatially specific
%
% Posterior is treated as early visual / EV.

% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 

if ~exist('Responses', 'var')
    error('The table Responses must exist in the workspace.')
end


%%  USER SETTINGS



% Colors


% Make nodes cleaner, like the summary figure
nodeColors.D  = [1 1 1];
nodeColors.L  = [1 1 1];
nodeColors.V  = [1 1 1];
nodeColors.EV = [1 1 1];

% Arrow colors
arrowColors.D  = [89 166 230] / 255;    % #59a6e6
arrowColors.L  = [179 140 199] / 255;   % #b38cc7
arrowColors.V  = [115 191 77] / 255;    % #73bf4d

% Early visual color, made lighter by mixing #eaa28e with white
baseEV = [234 162 142] / 255;            % #eaa28e
evWhitenAmount = 0.6;                   % 0 = original, 1 = white
arrowColors.EV = (1 - evWhitenAmount) * baseEV + evWhitenAmount * [1 1 1];
arrowColors.D = (1 - evWhitenAmount) * arrowColors.D + evWhitenAmount * [1 1 1];
arrowColors.L = (1 - evWhitenAmount) * arrowColors.L + evWhitenAmount * [1 1 1];
arrowColors.V = (1 - evWhitenAmount) * arrowColors.V + evWhitenAmount * [1 1 1];

% Node edge colors
nodeEdgeColors.D  = arrowColors.D;
nodeEdgeColors.L  = arrowColors.L;
nodeEdgeColors.V  = arrowColors.V;
nodeEdgeColors.EV = baseEV;


% Region names in Responses


regionNames.D  = ["Dorsal", "dorsal", "D"];
regionNames.L  = ["Lateral", "lateral", "L"];
regionNames.V  = ["Ventral", "ventral", "V"];

% Posterior = early visual / EV
regionNames.EV = ["Posterior", "posterior", ...
                  "Early Visual", "Early visual", "EarlyVisual", ...
                  "Early_Visual", "early visual", "Early", ...
                  "early", "EV", "early vis", "Early Vis"];


% Arrow width settings

minW = 0.02;
maxW = 0.3;

% Width scaling:
% 1.0 = linear
% 0.7 = makes low ratios more visible
% 1.3 = makes low ratios thinner
widthPower = 1.3;

arrowAlpha = 1;

headLengthStraight = 0.1;
headLengthCurved   = 0.1;

% Draw missing edges as gray placeholders?
plotMissingEdges = false;
missingColor = [0.80 0.80 0.80];
missingRatio = 0.03;

% Optional labels on arrows
showArrowLabels = true;

% Figure title
titleText = 'Source and target spatial spread';

%%  NODE LAYOUT

nodes.EV.type   = 'circle';
nodes.EV.center = [0.75 0.00];
nodes.EV.radius = 0.65;
nodes.EV.label  = 'early visual';

nodes.D.type   = 'rect';
nodes.D.center = [3.15  1.20];
nodes.D.width  = 1.20;
nodes.D.height = 0.62;
nodes.D.label  = 'dorsal';

nodes.L.type   = 'rect';
nodes.L.center = [3.15  0.00];
nodes.L.width  = 1.20;
nodes.L.height = 0.62;
nodes.L.label  = 'lateral';

nodes.V.type   = 'rect';
nodes.V.center = [3.15 -1.20];
nodes.V.width  = 1.20;
nodes.V.height = 0.62;
nodes.V.label  = 'ventral';

%%  GEOMETRY TUNING

geom.gapRect = 0.01;    % gap from rectangles
geom.gapEV   = 0.01;    % gap from EV circle

% Separation of reciprocal straight arrows
geom.straightOffset = 0.10;

% EV-to-stream arrow separations at the rectangle side
geom.sepDV = 0.13;      % dorsal/ventral separation
geom.sepL  = 0.13;      % lateral separation

% Angles on EV circle, in degrees
% Positive = above horizontal axis, negative = below
geom.evAng_D_out = 34;   % EV -> D
geom.evAng_D_in  = 21;   % D  -> EV

geom.evAng_L_out = 7;    % EV -> L
geom.evAng_L_in  = -7;   % L  -> EV

% For consistency, EV -> V is above V -> EV
geom.evAng_V_out = -21;  % EV -> V
geom.evAng_V_in  = -34;  % V  -> EV

% Right-side concentric arcs D <-> V
geom.arcXShift = 0.18;   % increase to move both arcs left
geom.rDV = 1.55;         % D -> V radius, outer/right arc
geom.rVD = 1.35;         % V -> D radius, inner/left arc

% Prolong arcs if needed
geom.arcExtraDegDV = 9; % increase to prolong D -> V
geom.arcExtraDegVD = -9;  % increase to prolong V -> D

geom.maxArcAngle = 80;

%%  EDGES TO PLOT

edgeList = [
    "EV" "D";
    "D"  "EV";

    "EV" "L";
    "L"  "EV";

    "EV" "V";
    "V"  "EV";

    "D"  "L";
    "L"  "D";

    "L"  "V";
    "V"  "L";

    "D"  "V";
    "V"  "D";
];

%%   COMPUTE SOURCE AND TARGET RATIOS


edgeStats = computeEdgeStats(Responses, edgeList, regionNames);

disp('Edge statistics:')
disp(edgeStats)

%%   PLOT


figure('Color', 'w');
hold on
axis equal
axis off

% Draw arrows first
for i = 1:height(edgeStats)

    src = edgeStats.Source(i);
    trg = edgeStats.Target(i);

    hasData = ~(isnan(edgeStats.sourceRatio(i)) || isnan(edgeStats.targetRatio(i)));

    if ~hasData && ~plotMissingEdges
        continue
    end

    if hasData
        tailW = ratioToWidth(edgeStats.sourceRatio(i), minW, maxW, widthPower);
        headW = ratioToWidth(edgeStats.targetRatio(i), minW, maxW, widthPower);

        arrowColorNow = getRegionColor(src, arrowColors);
        arrowAlphaNow = arrowAlpha;
    else
        tailW = ratioToWidth(missingRatio, minW, maxW, widthPower);
        headW = ratioToWidth(missingRatio, minW, maxW, widthPower);

        arrowColorNow = missingColor;
        arrowAlphaNow = 0.35;
    end

    [pathXY, isCurved] = makeSummaryPath(src, trg, nodes, geom);

    if isCurved
        headLength = headLengthCurved;
    else
        headLength = headLengthStraight;
    end

    drawTaperedArrow(pathXY, tailW, headW, arrowColorNow, arrowAlphaNow, headLength);

    if showArrowLabels
        midID = round(size(pathXY, 1) / 2);

        if hasData
            txt = sprintf('%.0f%% - %.0f%%', ...
                100 * edgeStats.sourceRatio(i), ...
                100 * edgeStats.targetRatio(i));
        else
            txt = 'no data';
        end

        text(pathXY(midID,1), pathXY(midID,2), txt, ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 8);
    end
end

% Draw nodes on top
drawCircleNode(nodes.EV, nodeColors.EV, nodeEdgeColors.EV);
drawRectNode(nodes.D, nodeColors.D, nodeEdgeColors.D);
drawRectNode(nodes.L, nodeColors.L, nodeEdgeColors.L);
drawRectNode(nodes.V, nodeColors.V, nodeEdgeColors.V);

% Title
text(2.55, 2.55, titleText, ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 16, ...
    'FontWeight', 'bold');

%%   COLOR LEGEND

legendX = -0.55;
legendY = -2.10;
dy = 0.22;
sw = 0.32;

plot([legendX legendX+sw], [legendY legendY], ...
    'Color', arrowColors.D, 'LineWidth', 6, 'Clipping', 'off')
text(legendX+0.42, legendY, 'from dorsal stream (D)', ...
    'FontSize', 10, 'VerticalAlignment', 'middle')

plot([legendX legendX+sw], [legendY-dy legendY-dy], ...
    'Color', arrowColors.L, 'LineWidth', 6, 'Clipping', 'off')
text(legendX+0.42, legendY-dy, 'from lateral stream (L)', ...
    'FontSize', 10, 'VerticalAlignment', 'middle')

plot([legendX legendX+sw], [legendY-2*dy legendY-2*dy], ...
    'Color', arrowColors.V, 'LineWidth', 6, 'Clipping', 'off')
text(legendX+0.42, legendY-2*dy, 'from ventral stream (V)', ...
    'FontSize', 10, 'VerticalAlignment', 'middle')

plot([legendX legendX+sw], [legendY-3*dy legendY-3*dy], ...
    'Color', arrowColors.EV, 'LineWidth', 6, 'Clipping', 'off')
text(legendX+0.42, legendY-3*dy, 'from early visual areas (EV)', ...
    'FontSize', 10, 'VerticalAlignment', 'middle')

%%  WIDTH / PERCENT SCALE LEGEND


% Combine every source and target ratio represented by arrow width.
ratioValues = [ ...
    edgeStats.sourceRatio; ...
    edgeStats.targetRatio];

% Remove missing values.
ratioValues = ratioValues(isfinite(ratioValues));

assert(~isempty(ratioValues), ...
    'No valid source or target ratios were found.');

% Observed range across all arrow tails and heads.
scaleTopRatio = max(ratioValues);
positiveRatios = ratioValues(ratioValues > 0);

if isempty(positiveRatios)
    scaleBottomRatio = 0;
else
    scaleBottomRatio = min(positiveRatios);
end;

% Percent values displayed in the legend.
scaleTopPct = 100 * scaleTopRatio;
scaleBottomPct = 100 * scaleBottomRatio;

fprintf( ...
    'Arrow-width legend range: %.1f%% to %.1f%%\n', ...
    scaleBottomPct, ...
    scaleTopPct);

scaleX = 5.35;
scaleYTop = 2.05;
scaleYBottom = 1.10;

drawSpreadScaleLegendExact( ...
    scaleX, ...
    scaleYTop, ...
    scaleYBottom, ...
    scaleTopRatio, ...
    scaleBottomRatio, ...
    minW, ...
    maxW, ...
    widthPower, ...
    [0.60 0.60 0.60], ...
    round(scaleTopPct), ...
    round(scaleBottomPct), ...
    'Significant');

%%   AXIS LIMITS


xlim([-1.05 6.20])
ylim([-3.05 2.75])

%% Optional export
% exportgraphics(gcf, 'source_target_spatial_spread_summary_layout.png', 'Resolution', 300);

%%   LOCAL FUNCTIONS

function edgeStats = computeEdgeStats(Responses, edgeList, regionNames)

    pathway    = string(Responses.pathway);
    recPathway = string(Responses.recPathway);
    subj       = string(Responses.Subj);
    stimPair   = string(Responses.stimPair);
    recordCh   = string(Responses.recordCh);
    % Current dataset uses:
    %   'sig'   = significant
    %   'NOsig' = non-significant
    
    sigLabel = lower(strtrim(string(Responses.Sig)));
    
    unexpectedLabels = setdiff( ...
        unique(sigLabel), ...
        ["sig", "nosig"]);
    
    assert(isempty(unexpectedLabels), ...
        'Unexpected labels found in Responses.Sig: %s', ...
        char(strjoin(unexpectedLabels, ', ')));
    
    sig = sigLabel == "sig";

    nEdges = size(edgeList, 1);

    Source = edgeList(:,1);
    Target = edgeList(:,2);

    sourceRatio = nan(nEdges,1);
    targetRatio = nan(nEdges,1);

    nSourceSig = nan(nEdges,1);
    nSourceTotal = nan(nEdges,1);

    nTargetSig = nan(nEdges,1);
    nTargetTotal = nan(nEdges,1);

    nRows = nan(nEdges,1);

    for i = 1:nEdges

        src = Source(i);
        trg = Target(i);

        idxSource = matchRegion(pathway, src, regionNames);
        idxTarget = matchRegion(recPathway, trg, regionNames);

        idx = idxSource & idxTarget;

        nRows(i) = sum(idx);

        if ~any(idx)
            continue
        end

        sigNow = sig(idx);

        % Source ratio:
        % fraction of source stimulation pairs with at least 1 significant response
        stimID = subj(idx) + "_" + stimPair(idx);

        [Gstim, stimNames] = findgroups(stimID);
        stimHadSig = splitapply(@(x) any(x), sigNow, Gstim);

        nSourceTotal(i) = numel(stimNames);
        nSourceSig(i) = sum(stimHadSig);
        sourceRatio(i) = nSourceSig(i) / nSourceTotal(i);

        % Target ratio:
        % fraction of target recording electrodes with at least 1 significant response
        recID = subj(idx) + "_" + recordCh(idx);

        [Grec, recNames] = findgroups(recID);
        recHadSig = splitapply(@(x) any(x), sigNow, Grec);

        nTargetTotal(i) = numel(recNames);
        nTargetSig(i) = sum(recHadSig);
        targetRatio(i) = nTargetSig(i) / nTargetTotal(i);
    end

    edgeStats = table(Source, Target, nRows, ...
        sourceRatio, targetRatio, ...
        nSourceSig, nSourceTotal, ...
        nTargetSig, nTargetTotal);
end

function tf = matchRegion(x, regionCode, regionNames)

    xClean = lower(strtrim(string(x)));
    names = lower(strtrim(string(regionNames.(char(regionCode)))));

    tf = ismember(xClean, names);

    % Extra flexible matching for EV / Posterior
    if regionCode == "EV"
        tf = tf | contains(xClean, "posterior") | ...
                  contains(xClean, "early") | ...
                  xClean == "ev";
    end
end

function w = ratioToWidth(r, minW, maxW, widthPower)

    r = max(0, min(1, r));
    r = r ^ widthPower;

    w = minW + r * (maxW - minW);
end

function c = getRegionColor(regionCode, colors)

    switch char(regionCode)
        case 'D'
            c = colors.D;
        case 'L'
            c = colors.L;
        case 'V'
            c = colors.V;
        case 'EV'
            c = colors.EV;
        otherwise
            c = [0.4 0.4 0.4];
    end
end

function [pathXY, isCurved] = makeSummaryPath(src, trg, nodes, geom)

    key = char(src + "_" + trg);

    switch key


        % EV <-> streams


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
            % EV -> V is above V -> EV for visual consistency
            p0 = circleAnchorFixed(nodes.EV, geom.evAng_V_out, geom.gapEV);
            p1 = rectAnchor(nodes.V, 'left', geom.sepDV, geom.gapRect);

            pathXY = straightPointPath(p0, p1, 120);
            isCurved = false;

        case 'V_EV'
            p0 = rectAnchor(nodes.V, 'left', -geom.sepDV, geom.gapRect);
            p1 = circleAnchorFixed(nodes.EV, geom.evAng_V_in, geom.gapEV);

            pathXY = straightPointPath(p0, p1, 120);
            isCurved = false;


        % Adjacent stream connections


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


        % D <-> V concentric arcs


        case 'D_V'
            % D -> V is the outer/right concentric arc
            arcCenter = [nodes.D.center(1) - geom.arcXShift, 0];
            yLevel = abs(nodes.D.center(2));

            angleDV = asind(yLevel / geom.rDV) + geom.arcExtraDegDV;
            angleDV = min(angleDV, geom.maxArcAngle);

            pathXY = circularArcPath(arcCenter, geom.rDV, ...
                angleDV, -angleDV, 240);

            isCurved = true;

        case 'V_D'
            % V -> D is the inner/left concentric arc
            arcCenter = [nodes.D.center(1) - geom.arcXShift, 0];
            yLevel = abs(nodes.D.center(2));

            angleVD = asind(yLevel / geom.rVD) + geom.arcExtraDegVD;
            angleVD = min(angleVD, geom.maxArcAngle);

            pathXY = circularArcPath(arcCenter, geom.rVD, ...
                -angleVD, angleVD, 220);

            isCurved = true;

        otherwise
            error('No path defined for edge %s', key)
    end
end

function pathXY = straightNodePath(nodeA, nodeB, offsetAmount, nPoints)

    gap = 0.08;

    p0 = nodeBoundaryPoint(nodeA, nodeB.center, gap);
    p1 = nodeBoundaryPoint(nodeB, nodeA.center, gap);

    v = p1 - p0;
    L = norm(v);

    if L == 0
        pathXY = [p0; p1];
        return
    end

    u = v / L;
    normal = [-u(2), u(1)];

    % Same offset sign keeps reciprocal arrows on opposite sides
    p0 = p0 + offsetAmount * normal;
    p1 = p1 + offsetAmount * normal;

    t = linspace(0, 1, nPoints)';

    pathXY = (1 - t) .* p0 + t .* p1;
end

function p = nodeBoundaryPoint(node, towardPoint, gap)

    c = node.center;
    v = towardPoint - c;

    if norm(v) == 0
        p = c;
        return
    end

    u = v / norm(v);

    if strcmp(node.type, 'circle')

        p = c + u * (node.radius + gap);

    else

        halfW = node.width / 2 + gap;
        halfH = node.height / 2 + gap;

        tx = inf;
        ty = inf;

        if abs(u(1)) > eps
            tx = halfW / abs(u(1));
        end

        if abs(u(2)) > eps
            ty = halfH / abs(u(2));
        end

        t = min(tx, ty);

        p = c + u * t;
    end
end

function p = rectAnchor(node, side, offset, gap)

    cx = node.center(1);
    cy = node.center(2);

    w = node.width;
    h = node.height;

    switch side
        case 'left'
            p = [cx - w/2 - gap, cy + offset];

        case 'right'
            p = [cx + w/2 + gap, cy + offset];

        case 'top'
            p = [cx + offset, cy + h/2 + gap];

        case 'bottom'
            p = [cx + offset, cy - h/2 - gap];

        otherwise
            error('Unknown rectangle side: %s', side)
    end
end

function p = circleAnchorFixed(node, angleDeg, gap)

    r = node.radius + gap;

    p = node.center + r * [cosd(angleDeg), sind(angleDeg)];
end

function pathXY = straightPointPath(p0, p1, nPoints)

    t = linspace(0, 1, nPoints)';

    pathXY = (1 - t) .* p0 + t .* p1;
end

function pathXY = circularArcPath(center, radius, startAngle, endAngle, n)

    th = linspace(startAngle, endAngle, n)';

    x = center(1) + radius * cosd(th);
    y = center(2) + radius * sind(th);

    pathXY = [x y];
end

function drawTaperedArrow(pathXY, tailW, headW, colorVal, alphaVal, headLength)

    % Remove repeated points
    d0 = sqrt(sum(diff(pathXY).^2, 2));
    keep = [true; d0 > 1e-9];
    pathXY = pathXY(keep,:);

    % Arc length
    d = sqrt(sum(diff(pathXY).^2, 2));
    s = [0; cumsum(d)];
    totalLength = s(end);

    if totalLength <= headLength * 1.5
        return
    end

    % Body ends before arrowhead
    bodyEnd = totalLength - headLength;

    nBody = 180;
    sBody = linspace(0, bodyEnd, nBody)';

    bodyX = interp1(s, pathXY(:,1), sBody);
    bodyY = interp1(s, pathXY(:,2), sBody);

    bodyXY = [bodyX bodyY];

    % Width changes continuously from source/tail to target/head
    widthBody = tailW + (headW - tailW) * (sBody / bodyEnd);

    % Local tangent
    dx = gradient(bodyXY(:,1));
    dy = gradient(bodyXY(:,2));

    tangentLength = sqrt(dx.^2 + dy.^2);
    tangentLength(tangentLength == 0) = eps;

    dx = dx ./ tangentLength;
    dy = dy ./ tangentLength;

    % Local normal
    nx = -dy;
    ny = dx;

    % Boundaries of variable-width body
    leftX  = bodyXY(:,1) + nx .* widthBody / 2;
    leftY  = bodyXY(:,2) + ny .* widthBody / 2;

    rightX = bodyXY(:,1) - nx .* widthBody / 2;
    rightY = bodyXY(:,2) - ny .* widthBody / 2;

    % Draw body
    patch([leftX; flipud(rightX)], ...
          [leftY; flipud(rightY)], ...
          colorVal, ...
          'EdgeColor', 'none', ...
          'FaceAlpha', alphaVal);

    % Arrowhead
    tip = pathXY(end,:);
    base = bodyXY(end,:);

    direction = tip - base;
    direction = direction / norm(direction);

    normal = [-direction(2), direction(1)];

    headBaseWidth = max(headW * 1.25, 0.07);

    pTip   = tip;
    pLeft  = base + normal * headBaseWidth / 2;
    pRight = base - normal * headBaseWidth / 2;

    patch([pTip(1) pLeft(1) pRight(1)], ...
          [pTip(2) pLeft(2) pRight(2)], ...
          colorVal, ...
          'EdgeColor', 'none', ...
          'FaceAlpha', alphaVal);
end

function drawCircleNode(node, faceColor, edgeColor)

    th = linspace(0, 2*pi, 200);

    x = node.center(1) + node.radius * cos(th);
    y = node.center(2) + node.radius * sin(th);

    patch(x, y, faceColor, ...
        'EdgeColor', edgeColor, ...
        'LineWidth', 2.5, ...
        'FaceAlpha', 1);

    text(node.center(1), node.center(2), node.label, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 13, ...
        'FontWeight', 'bold');
end

function drawRectNode(node, faceColor, edgeColor)

    x0 = node.center(1) - node.width / 2;
    y0 = node.center(2) - node.height / 2;

    rectangle('Position', [x0 y0 node.width node.height], ...
        'Curvature', 0.04, ...
        'FaceColor', faceColor, ...
        'EdgeColor', edgeColor, ...
        'LineWidth', 2.5);

    text(node.center(1), node.center(2), node.label, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 14, ...
        'FontWeight', 'bold');
end

function drawSpreadScaleLegend(xCenter, yTop, yBottom, ...
    topRatio, bottomRatio, minW, maxW, widthPower, scaleFactor, ...
    colorVal, topPct, bottomPct, sideLabel)

    topWidth = scaleFactor * ratioToWidth(topRatio, minW, maxW, widthPower);
    bottomWidth = scaleFactor * ratioToWidth(bottomRatio, minW, maxW, widthPower);

    xPatch = [ ...
        xCenter - topWidth/2, ...
        xCenter + topWidth/2, ...
        xCenter + bottomWidth/2, ...
        xCenter - bottomWidth/2];

    yPatch = [ ...
        yTop, ...
        yTop, ...
        yBottom, ...
        yBottom];

    patch(xPatch, yPatch, colorVal, ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.75, ...
        'Clipping', 'off');

    text(xCenter, yTop + 0.16, sprintf('%d%%', topPct), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 13, ...
        'Clipping', 'off');

    text(xCenter, yBottom - 0.12, sprintf('%d%%', bottomPct), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 13, ...
        'Clipping', 'off');

    text(xCenter + topWidth/2 + 0.25, mean([yTop yBottom]), sideLabel, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Rotation', -90, ...
        'FontSize', 12, ...
        'Clipping', 'off');
end


function drawSpreadScaleLegendExact(xCenter, yTop, yBottom, ...
    topRatio, bottomRatio, minW, maxW, widthPower, ...
    colorVal, topPct, bottomPct, sideLabel)

    % Use the exact same mapping as the arrows
    topWidth = ratioToWidth(topRatio, minW, maxW, widthPower);
    bottomWidth = ratioToWidth(bottomRatio, minW, maxW, widthPower);

    xPatch = [ ...
        xCenter - topWidth/2, ...
        xCenter + topWidth/2, ...
        xCenter + bottomWidth/2, ...
        xCenter - bottomWidth/2];

    yPatch = [ ...
        yTop, ...
        yTop, ...
        yBottom, ...
        yBottom];

    patch(xPatch, yPatch, colorVal, ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.75, ...
        'Clipping', 'off');

    text(xCenter, yTop + 0.16, sprintf('%d%%', topPct), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 13, ...
        'Clipping', 'off');

    text(xCenter, yBottom - 0.12, sprintf('%d%%', bottomPct), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 13, ...
        'Clipping', 'off');

    text(xCenter + topWidth/2 + 0.25, mean([yTop yBottom]), sideLabel, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Rotation', -90, ...
        'FontSize', 12, ...
        'Clipping', 'off');
end