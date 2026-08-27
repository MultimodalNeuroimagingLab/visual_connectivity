%%  Regional broadband timecourses with 95% confidence intervals
%
% Participants:
%   ss = 1 -> sub-01
%   ss = 2 -> sub-11
%   ss = 3 -> sub-17
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 

subjects = {'01','11','17'};
sub_label = subjects{ss};

scriptPath = which('vc_synth_regional_bb_timecourses.m');
projectRoot = fileparts(fileparts(scriptPath));

% Main comparison for the traces.
% Options:
%   'words_scenes'
%   'words_nonwords'
%   'words_scenes_grating'
comparison_mode = 'words_nonwords';

% Analysis window shown with dotted vertical lines.
tt_int = [0.10 0.40];

% Show the channel names used in each regional group in the panel title.
show_channel_names_in_title = true;

%% Load broadband data


outdir = fullfile(projectRoot, ...
    'derivatives', 'preproc_synth', ['sub-' sub_label]);

bb_file = fullfile(outdir, ...
    ['sub-' sub_label '_desc-preprocBIPBB_ieeg.mat']);

load(bb_file, 'tt', 'srate', 'Mbb', 'eventsST', 'bip_channels');

fprintf('\nLoaded subject: %s\n', sub_label);
fprintf('Loaded file: %s\n', bb_file);

%%  Normalize broadband power per tasknumber/run


Mbb_norm = log10(Mbb);
Mbb_norm(~isfinite(Mbb_norm)) = NaN;

baseline_idx = tt > -0.2 & tt < 0;

if ismember('tasknumber', eventsST.Properties.VariableNames)
    run_var = eventsST.tasknumber;
    run_name = 'tasknumber';
elseif ismember('run', eventsST.Properties.VariableNames)
    run_var = eventsST.run;
    run_name = 'run';
else
    run_var = ones(height(eventsST),1);
    run_name = 'constant';
end

fprintf('Using %s for run-wise baseline normalization.\n', run_name);

run_levels = unique(run_var);

for rr = 1:numel(run_levels)

    trials_this_run = run_var == run_levels(rr);

    baseline = mean(Mbb_norm(:,baseline_idx,trials_this_run), [2 3], 'omitnan');

    Mbb_norm(:,:,trials_this_run) = Mbb_norm(:,:,trials_this_run) - baseline;

end

%% Extract stimulus labels


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

%% Define stimulus groups


noise_labels   = unique([1:12 217:220]);
grating_labels = unique(105:216);
word_labels    = unique(65:104);

% Current scene definition.
scene_labels   = unique([13:24 29:36]);

% Non-words = noise + gratings + scenes.
nonword_labels = unique([grating_labels noise_labels scene_labels]);

switch comparison_mode

    case 'words_scenes'

        cond_names = {'words','scenes'};

        cond_labels = {
            word_labels, ...
            scene_labels
        };

        cond_colors = {
            [1 0 0], ...          % words = red
            [0.5 0 0.5]           % scenes = purple
        };

    case 'words_nonwords'

        cond_names = {'words','non-words'};

        cond_labels = {
            word_labels, ...
            nonword_labels
        };

        cond_colors = {
            [1 0 0], ...          % words = red
            [0.25 0.25 0.25]      % non-words = dark gray
        };

    case 'words_scenes_grating'

        cond_names = {'words','scenes','gratings'};

        cond_labels = {
            word_labels, ...
            scene_labels, ...
            grating_labels
        };

        cond_colors = {
            [1 0 0], ...          % words = red
            [0.5 0 0.5], ...      % scenes = purple
            [0.5 0.5 0.5]         % gratings = gray
        };

    otherwise

        error('Unknown comparison_mode: %s', comparison_mode);

end

fprintf('Trial counts for plotted conditions:\n');
for cc = 1:numel(cond_names)
    fprintf('  %s: %d trials\n', cond_names{cc}, sum(ismember(all_stim_labels, cond_labels{cc})));
end

%% Define regional bipolar channel groups
%
%  Plot order:
%      1. Ventral: A37elv
%      2. Dorsal
%      3. Lateral


if ss == 1

    region_names = {'Ventral: A37elv','Dorsal IPS1','Lateral'};

    region_chans = {...
        {'LT8-LT9'},....       % Ventral: A37elv
        {'LG6-LG7'}, ...       % Dorsal / IPS1
        {'LOC8-LOC9'}, ...     % Lateral
    };

elseif ss == 2

    region_names = {'Dorsal IPS0','Lateral','Ventral: A37elv'};

    region_chans = {...
        {'LT6-LT7'},...         % Ventral: A37elv
        {'LQ8-LQ9'}, ...        % Dorsal / IPS0
        {'LSL7-LSL8'}, ...      % Lateral
    };

elseif ss == 3

    region_names = {'Dorsal IPS0/IPS1','Lateral','Ventral: A37elv'};

    region_chans = {...
        {'RTO8-RTO9'},...       % Ventral: A37elv
        {'RSP8-RSP9'}, ...      % Dorsal
        {'ROC10-ROC11'}, ...    % Lateral 
    };

end

%%  Set smoothing window


if exist('srate','var') && ~isempty(srate)
    smooth_win = max(1, round(srate/20));
else
    smooth_win = max(1, round(1 / median(diff(tt)) / 20));
end

%% Plot regional timecourses


figure('Position',[0 0 240 650])

n_regions = numel(region_names);
h_legend = gobjects(numel(cond_names),1);
chan_names = string(bip_channels.name(:));

for gg = 1:n_regions

    subplot(n_regions,1,gg)
    hold on

    this_region = region_names{gg};
    this_chans = string(region_chans{gg});

    % Use only channels that exist and are marked good.
    chan_idx = find(ismember(chan_names, this_chans) & bip_channels.status(:) == 1);

    if isempty(chan_idx)

        title([this_region ' | no valid channels found'], ...
            'Interpreter','none', 'FontWeight','bold')
        axis off
        continue

    end

    % Print selected channels for QC.
    fprintf('\n%s channels used:\n', this_region);
    disp(chan_names(chan_idx)')

    for cc = 1:numel(cond_names)

        these_trials = ismember(all_stim_labels, cond_labels{cc});
        trial_idx = find(these_trials);
        n_trials_this = numel(trial_idx);

        if n_trials_this == 0
            warning('No trials found for condition %s.', cond_names{cc});
            continue
        end


        X = NaN(numel(tt), n_trials_this);

        for tr = 1:n_trials_this

            this_trial = trial_idx(tr);

            % tmp is channels x time. Do not use squeeze here.
            tmp = double(Mbb_norm(chan_idx,:,this_trial));

            % If MATLAB keeps a singleton third dimension, remove it safely.
            if ndims(tmp) == 3
                tmp = tmp(:,:,1);
            end

            % Force tmp to be channels x time.
            if size(tmp,2) ~= numel(tt) && size(tmp,1) == numel(tt)
                tmp = tmp';
            end

            if size(tmp,2) ~= numel(tt)
                error('tmp has wrong size. size(tmp) = [%d %d], length(tt) = %d', ...
                    size(tmp,1), size(tmp,2), numel(tt));
            end

            % Average across regional channels.
            X(:,tr) = mean(tmp, 1, 'omitnan')';

        end

        Y = X';   % trials x time
        
        % Optional safety check: remove fully invalid trials
        good_trials = any(isfinite(Y), 2);
        Y = Y(good_trials, :);
        
        c = cond_colors{cc};
        
        % Shaded 95% confidence interval around the mean
        h_ci = ieeg_plotCurvConf(tt, Y, c, 0.18);
        
        % Keep confidence patch out of legend
        set(h_ci, 'HandleVisibility', 'off');
        
        % Mean trace
        mu = mean(Y, 1, 'omitnan');
        
        h_legend(cc) = plot(tt, mu, ...
            'Color', c, ...
            'LineWidth', 2);

    end

    % Reference lines.
    xline(0, 'k--', 'LineWidth', 1);
    xline(tt_int(1), 'k:', 'LineWidth', 1);
    xline(tt_int(2), 'k:', 'LineWidth', 1);
    yline(0, 'k-', 'LineWidth', 0.5);

    xlim([-0.2 0.8])
    ylim([-0.2 0.38])

    ylabel('Norm. log BB power')

    if show_channel_names_in_title
        title(sprintf('%s | %s', this_region, strjoin(cellstr(chan_names(chan_idx)'), ', ')), ...
            'Interpreter','none', 'FontWeight','bold')
    else
        title(this_region, 'Interpreter','none', 'FontWeight','bold')
    end

    grid off
    box off

    if gg == 1
        legend(h_legend, cond_names, ...
            'Location','best', ...
            'Box','off')
    end

end

xlabel('Time from stimulus onset (s)')

sgtitle({ ...
    ['sub-' sub_label ' | Regional broadband response'], ...
    [comparison_mode ' | line = mean, shading = 95% CI | window = 0.10-0.40 s']}, ...
    'Interpreter','none', ...
    'FontWeight','bold')


