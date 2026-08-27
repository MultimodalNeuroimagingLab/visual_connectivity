function tH = vc_render_gifti_labels(g, vert_label, cmapInput, varargin)
% vc_render_gifti_labels
%
% Modified from ieeg_RenderGiftiLabels.
% Render a GIFTI cortical surface using vertex labels and a colormap.
%
% Inputs
% ------
% g           : GIFTI surface containing faces and vertices
% vert_label  : label assigned to each surface vertex
% cmapInput   : numeric colormap or MATLAB colormap name
% varargin{1} : optional sulcal map, e.g. read_curv('lh.sulc')
%
% Output
% ------
% tH          : trimesh handle
%
% Notes
% -----
% - Surface proportions are preserved with axis equal.
% - The initial lateral view is used to establish the brain scale.
% - axis vis3d preserves that scale when the brain is subsequently rotated.
%
% MGYR & DH 2026. Modified from DH 2017 code.


%% Prepare vertex labels


vert_label = vert_label(:);


%%  Prepare colormap

if ischar(cmapInput)

    eval(['cmap = ' cmapInput '(max(vert_label));']);

elseif isnumeric(cmapInput)

    cmap = cmapInput;

end


%%  Create base vertex colors

if isempty(varargin)

    % Uniform gray background
    c = 0.7 + zeros(size(vert_label,1), 3);

else

    % Use sulcal map to create light/dark gray folding pattern
    sulcal_labels = varargin{1};

    c = 0.5 + zeros(size(vert_label,1), 3);
    c(sulcal_labels < 0, :) = 0.7;

end


%%  Apply ROI colors

for k = 1:max(vert_label)

    idx = ceil(vert_label) == k;

    c(idx,:) = repmat( ...
        cmap(k,:), ...
        sum(idx), ...
        1);

end


%%  Render cortical surface

tH = trimesh( ...
    g.faces, ...
    g.vertices(:,1), ...
    g.vertices(:,2), ...
    g.vertices(:,3), ...
    c);

set(tH, ...
    'LineStyle', 'none', ...
    'FaceColor', 'interp', ...
    'FaceVertexCData', c);

hold on


%% Lighting and material

l1 = light;

lighting gouraud
material([.3 .9 .2 50 1]);


%%  plotArea and brain scale
ax = gca;

% Preserve anatomical proportions
axis(ax, 'equal');

% Avoid perspective-related changes in apparent brain size
camproj(ax, 'orthographic');

% Reference lateral view used to establish the initial scale
view(ax, 270, 0);

% Fit the brain once
axis(ax, 'tight');

% Freeze aspect/camera properties so the brain keeps its scale when rotated
axis(ax, 'vis3d');

axis(ax, 'off');

drawnow


%%  Light position

set(l1, 'Position', [-1 0 1]);

end