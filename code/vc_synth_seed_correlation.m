%% Seed-to-all broadband correlation during synthetic word trials
%
% Participants:
%   ss = 1 -> sub-01
%   ss = 2 -> sub-11
%   ss = 3 -> sub-17
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 

subjects = {'01','11','17'};

sub_label = subjects{ss};

fprintf('\nSynthetic correlation map: sub-%s\n', sub_label);
% Repository root: parent directory of /code

scriptPath = which('vc_synth_seed_correlation.m');

projectRoot = fileparts(fileparts(scriptPath));

addpath(genpath(fullfile(projectRoot,'code','external')));

outdir = fullfile(projectRoot, ...
    'derivatives', 'preproc_synth', ['sub-' sub_label]);

load(fullfile(outdir, ['sub-' sub_label '_desc-preprocBIPBB_ieeg.mat']), 'tt', 'Mbb', 'eventsST', 'bip_channels');

%% Normalize bb power per run

% Initialize normalized log power of BB
Mbb_norm = log10(Mbb); 

% Indicate the interval for baseline, used in normalization
norm_int = find(tt>-.2 & tt<0);

% Normalize per run
for run_idx = 1:max(eventsST.tasknumber)
    this_run = find(eventsST.tasknumber==run_idx); % out of 1500
    Mbb_norm(:,:,this_run) = minus(Mbb_norm(:,:,this_run),mean(Mbb_norm(:,norm_int,this_run),[2 3],'omitnan'));
end

%% get stim labels

all_stim_labels = NaN(height(eventsST.stim_file),1);

for kk = 1:height(eventsST.stim_file)
    label_temp = extractBetween(eventsST.stim_file{kk},'nsdsynthetic','_prepped');
    if ~isempty(label_temp)
        all_stim_labels(kk) = str2double(label_temp{1});
    end
end
clear label_temp


%% correlate one channel with all other channels

% sub-01
if ss == 1 % sub-1
    chan_nr1 = find(ismember(bip_channels.name,'LG6-LG7'));
elseif ss == 2 % sub-11
    chan_nr1 = find(ismember(bip_channels.name,'LQ8-LQ9'));
elseif ss == 3 % sub-17
    chan_nr1 = find(ismember(bip_channels.name, 'RSP8-RSP9'));
end


%%  Seed-to-all correlation during WORD trials

tt_int = [0.01 0.8];
time_idx = tt > tt_int(1) & tt < tt_int(2);

word_labels = 65:104;
word_trials = ismember(all_stim_labels, word_labels);

fprintf('Word trials used for correlation map: %d\n', sum(word_trials));

av_bb = squeeze(mean(Mbb_norm(:,time_idx,word_trials),2,'omitnan'));

% Make sure av_bb is channels x trials
if size(av_bb,1) ~= numel(bip_channels.name)
    av_bb = av_bb';
end

rr_raw = corr(av_bb(chan_nr1,:)', av_bb', 'rows', 'pairwise')';
rr_raw = real(rr_raw);
rr_raw(~isfinite(rr_raw)) = 0;

% Threshold only for display
display_Threshold = 0.25;
maxCorrelationDisplay = 0.55;
dotScale = 50;

rr = rr_raw;
rr(rr < display_Threshold) = 0;

% loc_info subject folders use BIDS-style sub-XX naming.
loc_file = fullfile(projectRoot, ...
    'derivatives', 'loc_info', ['sub-' sub_label], 'loc_info.mat');

tmp = load(loc_file, 'loc_info');
loc_info_all = tmp.loc_info;
clear tmp

% Initialize bipolar localization information.
loc_info = bip_channels;
loc_info.x = NaN(size(bip_channels.status));
loc_info.y = NaN(size(bip_channels.status));
loc_info.z = NaN(size(bip_channels.status));
loc_info.hemisphere = cell(size(bip_channels.status));
loc_info.Destrieux_label = NaN(size(bip_channels.status));

% Compute bipolar positions from the two monopolar contacts.
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
    else
        loc_info.hemisphere{kk} = 'NaN';
        loc_info.Destrieux_label(kk) = NaN;
    end
end

loc_info = struct2table(loc_info);


% Load pial and inflated surfaces
gL = gifti(fullfile(projectRoot, ...
    'derivatives', 'freesurfer', ['sub-' sub_label], 'white.L.surf.gii'));

gR = gifti(fullfile(projectRoot, ...
    'derivatives', 'freesurfer', ['sub-' sub_label], 'white.R.surf.gii'));

gL_infl = gifti(fullfile(projectRoot, ...
    'derivatives', 'freesurfer', ['sub-' sub_label], 'inflated.L.surf.gii'));

gR_infl = gifti(fullfile(projectRoot, ...
    'derivatives', 'freesurfer', ['sub-' sub_label], 'inflated.R.surf.gii'));

% snap electrodes to surface and then move to inflated
xyz_inflated = ieeg_snap2inflated(loc_info,gR,gL,gR_infl,gL_infl,4);

mni = 0; % 0 = subject native surface, 1 = fsaverage

if ss == 1 || ss == 2
    hemi = 'l';
    g = gL_infl;
    v_d = [-30 0];
else
    hemi = 'r';
    g = gR_infl;
    v_d = [35 0];
end

% Load combined visual atlas 
[vert_label,cmap,~, sulcal_labels] = vc_build_combined_visual_atlas( ...
    projectRoot, sub_label, hemi, mni);

% Select electrodes in this hemisphere
electrodes_thisHemi = find(ismember(loc_info.hemisphere,upper(hemi)) );

% Get inflated electrode coordinates
els = xyz_inflated;

% Electrode popout.
finiteMask = builtin('all', isfinite(els), 2);
finiteEls = els(finiteMask,:);

if isempty(finiteEls)
    scaleForPopout = 1;
else
    scaleForPopout = max(abs(finiteEls(:,1)));
end

a_offset = .1 * scaleForPopout * ...
    [cosd(v_d(1)-90)*cosd(v_d(2)), ...
     sind(v_d(1)-90)*cosd(v_d(2)), ...
     sind(v_d(2))];

els_pop = els + repmat(a_offset,size(els,1),1);

figure
vc_render_gifti_labels(g, vert_label, cmap, sulcal_labels);
xyz = els_pop(electrodes_thisHemi,:);
rr_plot = rr(electrodes_thisHemi);

% Dot size reflects rr_plot.
vc_ieeg_elAdd_sizable_colors(xyz, rr_plot, 'pink', maxCorrelationDisplay, dotScale)

%ieeg_label(els_pop(electrodes_thisHemi,:),20,12,loc_info.name(electrodes_thisHemi))
ieeg_viewLight(v_d(1),v_d(2))
title(['S' sub_label ' corr with ' bip_channels.name{chan_nr1}])
set(gcf,'PaperPositionMode','auto')


%%  Standalone dot-size legend for seed-to-all correlation map

legend_vals = (display_Threshold:0.1:maxCorrelationDisplay)';

if abs(legend_vals(end) - maxCorrelationDisplay) > 1e-6
    legend_vals = [legend_vals; maxCorrelationDisplay];
end

legend_vals = unique(round(legend_vals,3), 'stable');

figure('Position', [300 300 160 160])
hold on

% Coordinates for legend dots.
legend_xyz = [
    zeros(numel(legend_vals),1), ...
    (1:numel(legend_vals))', ...
    zeros(numel(legend_vals),1)
];

% Black dot: below display threshold
scatter3(0, 0, 0, 45, [0 0 0], 'filled')

text(0.35, 0, 0, ...
    sprintf('r < %.2f', display_Threshold), ...
    'FontSize', 11, ...
    'VerticalAlignment', 'middle');

% Colored dots using the same function as the brain plot.
vc_ieeg_elAdd_sizable_colors(legend_xyz, legend_vals, 'pink', maxCorrelationDisplay, dotScale)

% Text labels for each dot
for ii = 1:numel(legend_vals)

    text(0.35, ii, 0, ...
        sprintf('r = %.2f', legend_vals(ii)), ...
        'FontSize', 11, ...
        'VerticalAlignment', 'middle');

end

axis equal
axis off
view(2)
title('Seed-to-all word coupling')