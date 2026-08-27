%% Local word selectivity during synthetic task
%
% rr(channel) = mean_BB_words(channel) - mean_BB_nonwords(channel)
%
% Participants:
%   ss = 1 -> sub-01
%   ss = 2 -> sub-11
%   ss = 3 -> sub-17
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 

subjects = {'01','11','17'};

assert(exist('ss','var') == 1, ...
    'Define ss before running vc_words_vs_all_synth.');

assert(ismember(ss,1:numel(subjects)), ...
    'ss must be 1, 2, or 3.');

sub_label = subjects{ss};

fprintf('\nSynthetic local word selectivity: sub-%s\n', sub_label);

% Determine repository root only if it does not already exist.
if ~exist('projectRoot','var') || isempty(projectRoot)

    scriptPath = which('vc_words_vs_all_synth.m');

    assert(~isempty(scriptPath), ...
        'Could not locate vc_words_vs_all_synth.m.');

    projectRoot = fileparts(fileparts(scriptPath));

end

% Analysis window for local broadband response
tt_int = [0.1 0.4];

% Word and nonword stimulus definitions.
word_labels = 65:104;

% Nonwords = gray condition in the timecourse plot:
% noise + gratings + scenes.
nonword_labels = unique([1:12 217:220 105:216 13:24 29:36]);

% Plot scaling.
% maxVal2plot is the value corresponding to the largest pink dot.
maxVal2plot = 0.2;

% Display threshold. Set to 0 to show every positive word > nonword value.
minVal2plot = 0.05;

% Dot size multiplier used by ieeg_elAdd_sizable_pink.
dotScale = 50;

% Whether to show electrode labels on the render.
showLabels = false;

% Whether to save the render.
saveFigure = false;

%% Load broadband data

outdir = fullfile(projectRoot, ...
    'derivatives', 'preproc_synth', ['sub-' sub_label]);

bb_file = fullfile(outdir, ...
    ['sub-' sub_label '_desc-preprocBIPBB_ieeg.mat']);

load(bb_file, 'tt', 'srate', 'Mbb', 'eventsST', 'bip_channels');

fprintf('\nSubject: %s\n', sub_label);
fprintf('Loaded: %s\n', bb_file);

%%  Normalize broadband power per run/tasknumber

% Log-transform broadband power.
Mbb_norm = log10(Mbb);
Mbb_norm(~isfinite(Mbb_norm)) = NaN;

% Baseline interval.
norm_int = tt > -0.2 & tt < 0;

% Normalize within each tasknumber/run.
if ismember('tasknumber', eventsST.Properties.VariableNames)
    run_var = eventsST.tasknumber;
elseif ismember('run', eventsST.Properties.VariableNames)
    run_var = eventsST.run;
else
    run_var = ones(height(eventsST),1);
end

run_levels = unique(run_var);

for rr_run = 1:numel(run_levels)

    this_run = run_var == run_levels(rr_run);

    baseline = mean(Mbb_norm(:,norm_int,this_run), [2 3], 'omitnan');

    Mbb_norm(:,:,this_run) = Mbb_norm(:,:,this_run) - baseline;

end

%%  Extract stimulus labels from events

all_stim_labels = NaN(height(eventsST),1);

for kk = 1:height(eventsST)

    if iscell(eventsST.stim_file)
        stim_file_this = eventsST.stim_file{kk};
    else
        stim_file_this = char(eventsST.stim_file(kk));
    end

    label_temp = extractBetween(stim_file_this, 'nsdsynthetic', '_prepped');

    if ~isempty(label_temp)
        all_stim_labels(kk) = str2double(label_temp{1});
    end

end

word_trials = ismember(all_stim_labels, word_labels);
nonword_trials = ismember(all_stim_labels, nonword_labels);

fprintf('Words trials: %d\n', sum(word_trials));
fprintf('Nonword trials: %d\n', sum(nonword_trials));

%% Compute local words-minus-nonwords broadband response

% Average broadband response in the fixed time window.
time_idx = tt > tt_int(1) & tt < tt_int(2);

bb_words = squeeze(mean(Mbb_norm(:,time_idx,word_trials), 2, 'omitnan'));
bb_nonwords = squeeze(mean(Mbb_norm(:,time_idx,nonword_trials), 2, 'omitnan'));

% Make sure matrices are channels x trials.
if size(bb_words,1) ~= numel(bip_channels.name)
    bb_words = bb_words';
end

if size(bb_nonwords,1) ~= numel(bip_channels.name)
    bb_nonwords = bb_nonwords';
end

mean_words = mean(bb_words, 2, 'omitnan');
mean_nonwords = mean(bb_nonwords, 2, 'omitnan');

% Positive values mean local broadband response is stronger for words.
rr_raw = mean_words - mean_nonwords;
rr_raw = real(rr_raw);
rr_raw(~isfinite(rr_raw)) = 0;

% Plot only positive word > nonword values.
rr = rr_raw;
rr(rr < minVal2plot) = 0;
rr(rr > maxVal2plot) = maxVal2plot;

%% Print a quick QC table


qc_table = table;
qc_table.channel = string(bip_channels.name(:));
qc_table.mean_words = mean_words(:);
qc_table.mean_nonwords = mean_nonwords(:);
qc_table.words_minus_nonwords = rr_raw(:);
qc_table.status = bip_channels.status(:);

qc_table = sortrows(qc_table, 'words_minus_nonwords', 'descend');

fprintf('\nTop local word > nonword bipolar channels before GM filtering:\n');
disp(qc_table(1:min(15,height(qc_table)), :));

%% Build bipolar localization table from electrode coordinates


% Load monopolar electrode coordinates.
% Load consolidated monopolar electrode localization.
loc_file = fullfile(projectRoot, ...
    'derivatives', 'loc_info', ['sub-' sub_label], 'loc_info.mat');

tmp = load(loc_file, 'loc_info');
loc_info_all = tmp.loc_info;
clear tmp

% Initialize bipolar localization table from bip_channels.
loc_info = bip_channels;
loc_info.x = NaN(size(bip_channels.status));
loc_info.y = NaN(size(bip_channels.status));
loc_info.z = NaN(size(bip_channels.status));
loc_info.hemisphere = cell(size(bip_channels.status));
loc_info.Destrieux_label = NaN(size(bip_channels.status));
loc_info.gm_wm_el1 = NaN(size(bip_channels.status));
loc_info.gm_wm_el2 = NaN(size(bip_channels.status));
loc_info.is_gm = false(size(bip_channels.status));

for kk = 1:numel(bip_channels.name)

    el1 = extractBefore(bip_channels.name{kk}, '-');
    el2 = extractAfter(bip_channels.name{kk}, '-');

    el1_ind = find(ismember(loc_info_all.name, el1), 1);
    el2_ind = find(ismember(loc_info_all.name, el2), 1);

    if ~isempty(el1_ind) && ~isempty(el2_ind)

        % Bipolar coordinate = midpoint of the two contacts.
        loc_info.x(kk) = mean(loc_info_all.x([el1_ind el2_ind]), 'omitnan');
        loc_info.y(kk) = mean(loc_info_all.y([el1_ind el2_ind]), 'omitnan');
        loc_info.z(kk) = mean(loc_info_all.z([el1_ind el2_ind]), 'omitnan');

        loc_info.hemisphere{kk} = loc_info_all.name{el1_ind}(1);
        loc_info.Destrieux_label(kk) = ...
            loc_info_all.Destrieux_label(el1_ind);

        % GM/WM distance is already contained in loc_info.mat.
        loc_info.gm_wm_el1(kk) = ...
            loc_info_all.gm_wm_relativeDistance(el1_ind);
        
        loc_info.gm_wm_el2(kk) = ...
            loc_info_all.gm_wm_relativeDistance(el2_ind);

        % Bipolar channel is considered GM if at least one
        % monopolar contact satisfies the GM criterion.
        loc_info.is_gm(kk) = ...
            loc_info.gm_wm_el1(kk) >= -1 || ...
            loc_info.gm_wm_el2(kk) >= -1;

    else

        loc_info.hemisphere{kk} = 'NaN';
        loc_info.Destrieux_label(kk) = NaN;
        loc_info.is_gm(kk) = false;

    end
end

loc_info = struct2table(loc_info);


%% Load surfaces and project bipolar electrodes to inflated brain

gL = gifti(fullfile(projectRoot, ...
    'derivatives', 'freesurfer', ['sub-' sub_label], 'white.L.surf.gii'));

gR = gifti(fullfile(projectRoot, ...
    'derivatives', 'freesurfer', ['sub-' sub_label], 'white.R.surf.gii'));

gL_infl = gifti(fullfile(projectRoot, ...
    'derivatives', 'freesurfer', ['sub-' sub_label], 'inflated.L.surf.gii'));

gR_infl = gifti(fullfile(projectRoot, ...
    'derivatives', 'freesurfer', ['sub-' sub_label], 'inflated.R.surf.gii'));

% Snap electrodes to white surface, then move them to inflated surface.
xyz_inflated = ieeg_snap2inflated(loc_info, gR, gL, gR_infl, gL_infl, 4);

%% Render local word selectivity on inflated brain
mni = 0;  % native subject surface

if ss == 1 || ss == 2
    hemi = 'l';
    g = gL_infl;
    v_d = [320 -10];
else
    hemi = 'r';
    g = gR_infl;
    v_d = [40 -10];
end

% Load combined visual atlas.
[vert_label, cmap, ~, sulcal_labels] = vc_build_combined_visual_atlas( ...
    projectRoot, sub_label, hemi, mni);

% Select only gray-matter bipolar electrodes in the plotted hemisphere.
electrodes_thisHemi = find( ...
    ismember(loc_info.hemisphere, upper(hemi)) & loc_info.is_gm);

% Print top GM electrodes for this hemisphere.
hemi_table = qc_table(ismember(qc_table.channel, string(loc_info.name(electrodes_thisHemi))), :);
hemi_table = sortrows(hemi_table, 'words_minus_nonwords', 'descend');

fprintf('\nTop GM bipolar electrodes in plotted hemisphere:\n');
disp(hemi_table(1:min(15,height(hemi_table)), :));

% Get inflated coordinates.
els = xyz_inflated;

% Electrode popout for visibility.
finiteMask = builtin('all', isfinite(els), 2);
finiteEls = els(finiteMask,:);

if isempty(finiteEls)
    scaleForPopout = 1;
else
    scaleForPopout = max(abs(finiteEls(:,1)));
end

a_offset = 0.1 * scaleForPopout * ...
    [cosd(v_d(1)-90)*cosd(v_d(2)), ...
     sind(v_d(1)-90)*cosd(v_d(2)), ...
     sind(v_d(2))];

els_pop = els + repmat(a_offset, size(els,1), 1);

% Render surface and atlas.
figure

tH = vc_render_gifti_labels(g, vert_label, cmap, sulcal_labels);

xyz = els_pop(electrodes_thisHemi,:);
rr_plot = rr(electrodes_thisHemi);

% Dot size reflects local words-minus-nonwords broadband response.
vc_ieeg_elAdd_sizable_colors(xyz, rr_plot, 'green', maxVal2plot, dotScale)

if showLabels
    ieeg_label(els_pop(electrodes_thisHemi,:), 20, 12, loc_info.name(electrodes_thisHemi));
end

ieeg_viewLight(v_d(1), v_d(2))

title(['S' sub_label ' local BB: words - nonwords, 0.1-0.4 s'])

set(gcf, 'PaperPositionMode', 'auto')

if saveFigure
    fig_dir = fullfile(projectRoot, ...
        'derivatives', 'figures', 'synthetic', 'render', ['sub-' sub_label]);

    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir);
    end

    print('-dpng', '-r300', fullfile(fig_dir, ...
        [hemi '_infl_words_minus_nonwords_sub-' sub_label ...
        '_v' int2str(v_d(1)) '_' int2str(v_d(2))]));
end


%% Optional standalone size legend


legend_vals = (0.05:0.05:maxVal2plot)';
legend_vals = unique(round(legend_vals,3), 'stable');

figure('Position', [300 300 160 120])
hold on

legend_xyz = [zeros(numel(legend_vals),1), (1:numel(legend_vals))', zeros(numel(legend_vals),1)];

scatter3(0, 0, 0, 45, [0 0 0], 'filled')
text(0.35, 0, 0, '< 0.05', ...
    'FontSize', 12, 'VerticalAlignment', 'middle')

vc_ieeg_elAdd_sizable_colors(legend_xyz, legend_vals, 'green', maxVal2plot, dotScale)

for ii = 1:numel(legend_vals)
    text(0.35, ii, 0, sprintf('%.2f', legend_vals(ii)), ...
        'FontSize', 12, 'VerticalAlignment', 'middle')
end

axis equal
axis off
view(2)
title('Legend: local word selectivity')
