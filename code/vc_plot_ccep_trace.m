function vc_plot_ccep_trace(response, varargin)
% Plot individual ccpe traces with the mean 
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 

p = inputParser;

addParameter(p, 'TrialDisplay', 'ci');   % 'ci' or 'trials'
addParameter(p, 'ShowTR', true);

parse(p, varargin{:});

trialDisplay = lower(string(p.Results.TrialDisplay));
showTR = logical(p.Results.ShowTR);


%% Data

tt = response.prep.tt * 1000;
%data = response.prep.data;
% Remove the mean of base line
baseRange = [-100, -10];

baseIdx = ...
    tt >= baseRange(1) & ...
    tt <= baseRange(2);

baseline = mean( ...
    response.prep.data(baseIdx,:), ...
    1, ...
    'omitnan');

data = response.prep.data - baseline;

hold on

%% Show trials

switch trialDisplay

    case "ci"

        ieeg_plotCurvConf( ...
            tt, ...
            data', ...
            [.7 .7 .8], ...
            0.5);

    case "trials"

        plot( ...
            tt, ...
            data, ...
            'Color', [.75 .75 .75], ...
            'LineWidth', 0.5);

    otherwise

        error( ...
            'TrialDisplay must be ''ci'' or ''trials''.');

end


%% Mean trace

meanTrace = mean(data,2);

plot( ...
    tt, ...
    meanTrace, ...
    'k', ...
    'LineWidth', 2);


%% Significant CRP interval

if showTR

    ttTR = response.crp_parms.parms_times * 1000;

    meanTR = mean( ...
        response.crp_parms.avg_trace_tR, ...
        2);

    % Black outline
    plot( ...
        ttTR, ...
        meanTR, ...
        'k', ...
        'LineWidth', 4);

    % Yellow center
    plot( ...
        ttTR, ...
        meanTR, ...
        'Color', '#fcd400', ...
        'LineWidth', 3);

end


%% Formatting

ylabel('amplitude (\muV)')
xlabel('time (ms)')

xlim([-100 1000])
ylim([-200 250])

xticks(0:200:800)
yticks(-100:100:200)

box off
hold off

end