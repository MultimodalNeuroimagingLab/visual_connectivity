function b = vc_plot_roi_outputs(crp, all_subjects, localDataPath, pathwayT, whoplot, S, plotOnePair, stimPair2plot, mni, inflatedBrain, yesLabels, AreaInStream)
% plot_roi_outputs
%
% Plot CoD and gray matter contacts from one region of interest.
%
% Inputs:
%   crp              : struct with results
%   all_subjects     : subject list
%   localDataPath    : base local path
%   pathwayT         : 'Dorsal' | 'Lateral' | 'Ventral' | 'Posterior'
%   whoplot          : 0 all subjects | 1 one specific subject
%   S                : subject ID, e.g. '01'
%   plotOnePair      : 0 all pairs | 1 one pair
%   stimPair2plot    : e.g. 'LG6-LG7'
%   mni              : 1 MNI | 0 individual
%   inflatedBrain    : 1 inflated | 0 non-inflated
%   yesLabels        : 1 yes | 0 no
%   AreaInStream     : [] or e.g. 'A37elv'
%
% Output:
%   b                : subplot handles
%
% Example:
%   b = plot_roi_outputs(crp, all_subjects, localDataPath, ...
%       'Ventral', 0, all_subjects(1), 0, 'LG6-LG7', 1, 1, 0, []);
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 

    %% Defaults
    if nargin < 12 || isempty(AreaInStream), AreaInStream = []; end
    if nargin < 11 || isempty(yesLabels), yesLabels = 0; end
    if nargin < 10 || isempty(inflatedBrain), inflatedBrain = 1; end
    if nargin < 9 || isempty(mni), mni = 1; end
    if nargin < 8 || isempty(stimPair2plot), stimPair2plot = 'LG6-LG7'; end
    if nargin < 7 || isempty(plotOnePair), plotOnePair = 0; end
    if nargin < 6 || isempty(S), S = all_subjects(1); end
    if nargin < 5 || isempty(whoplot), whoplot = 0; end
    if nargin < 4 || isempty(pathwayT), pathwayT = 'Ventral'; end

    %% Subject strings
    subjFolder = ['sub-' char(S)];       % FreeSurfer folder
    subjLabel  = ['sub_' char(S)];       % subject label stored in crp
    locInfoFolder = ['sub-' char(S)];    % loc_info folder

    %% Plot one subject?
    warning('off')
    gmThr = -1; % threshold for gray matter

    if whoplot == 1 && plotOnePair == 0
        aDi = find(ismember({crp.(pathwayT).DivergentP.Subj}, subjLabel));
        aDiN = find(ismember({crp.(pathwayT).DivergentP_NoSig.Subj}, subjLabel));

        DivergentP = crp.(pathwayT).DivergentP(aDi);
        DivergentP_NoSig = crp.(pathwayT).DivergentP_NoSig(aDiN);

    elseif whoplot == 1 && plotOnePair == 1
        aDi = find(ismember({crp.(pathwayT).DivergentP.Subj}, subjLabel) & ...
                   ismember([crp.(pathwayT).DivergentP.stimPair], stimPair2plot));

        aDiN = find(ismember({crp.(pathwayT).DivergentP_NoSig.Subj}, subjLabel) & ...
                    ismember([crp.(pathwayT).DivergentP_NoSig.stimPair], stimPair2plot));

        DivergentP = crp.(pathwayT).DivergentP(aDi);
        DivergentP_NoSig = crp.(pathwayT).DivergentP_NoSig(aDiN);

    elseif whoplot == 0
        DivergentP = crp.(pathwayT).DivergentP;
        DivergentP_NoSig = crp.(pathwayT).DivergentP_NoSig;
        mni = 1;
    end

    %% One specific area
    if ~isempty(AreaInStream)
        stimPair4area = squeeze(split([DivergentP.stimPair_areaBN],'-'));
        AreaIdx = find(startsWith(stimPair4area(:,1),AreaInStream) | startsWith(stimPair4area(:,2),AreaInStream));
        DivergentP = DivergentP(AreaIdx);

        stimPair4area = squeeze(split([DivergentP_NoSig.stimPair_areaBN],'-'));
        AreaIdx = find(startsWith(stimPair4area(:,1),AreaInStream) | startsWith(stimPair4area(:,2),AreaInStream));
        DivergentP_NoSig = DivergentP_NoSig(AreaIdx);
    end

    %% Plot gray matter
    gmIdx = find([DivergentP.stim_gm_wmDist_el1] >= gmThr & ...
                 [DivergentP.stim_gm_wmDist_el2] >= gmThr & ...
                 [DivergentP.record_gm_wmDist] >= gmThr);

    gmIdxNs = find([DivergentP_NoSig.stim_gm_wmDist_el1] >= gmThr & ...
                   [DivergentP_NoSig.stim_gm_wmDist_el2] >= gmThr & ...
                   [DivergentP_NoSig.record_gm_wmDist] >= gmThr);

    DivergentP = DivergentP(1,gmIdx);
    DivergentP_NoSig = DivergentP_NoSig(1,gmIdxNs);

    %% Load pial and inflated giftis
    if mni == 0 && whoplot == 1
        gL = gifti(fullfile(localDataPath,'derivatives','freesurfer',subjFolder,'pial.L.surf.gii'));
        gR = gifti(fullfile(localDataPath,'derivatives','freesurfer',subjFolder,'pial.R.surf.gii'));
        gL_infl = gifti(fullfile(localDataPath,'derivatives','freesurfer',subjFolder,'inflated.L.surf.gii'));
        gR_infl = gifti(fullfile(localDataPath,'derivatives','freesurfer',subjFolder,'inflated.R.surf.gii'));
    elseif mni == 0 && whoplot == 0
        fprintf('Individual space is not possible for all subjects together\n');
        return
    else
        gL = gifti(fullfile(localDataPath,'derivatives','freesurfer','fsaverage','pial.L.surf.gii'));
        gR = gifti(fullfile(localDataPath,'derivatives','freesurfer','fsaverage','pial.R.surf.gii'));
        gL_infl = gifti(fullfile(localDataPath,'derivatives','freesurfer','fsaverage','inflated.L.surf.gii'));
        gR_infl = gifti(fullfile(localDataPath,'derivatives','freesurfer','fsaverage','inflated.R.surf.gii'));
    end

    whereplot = [4 7 10 8 5 11];
    wherePlotIdx = 1;

 
    set(gcf,'position',[0 0 800 800]);

    %% Colorbars
    cmap = [0.9882    0.5647    0.5647;
            0.9882    0.7098    0.5255;
            1.0000    1.0000    0.6000;
            0.0784    0.9490    0.9176;
            0.1137    0.9647    0.0549;
            0.9333    0.0549    0.9647;
            0.0863    0.1059    0.6824;
            0.4784    0.0471    0.0471;
            0.9000    0.6000    1.0000;
            0.3438    0.3910    0.3668;
            0.6974    0.5129    0.8403;
            0.1978    0.8408    0.7445;
            0.3955    0.8227    0.5828;
            0.9686    0.3098    0.7353;
            0.2417    0.9409    0.7096;
            0.2196    0.0039    0.7588;
            0.2000    0.8000    0.5000;
            0.9539    0.7295    0.7562;
            0.2877    0.6154    0.4391;
            0.2206    0.2239    0.4094;
            0.9000    1.0000    0.7000;
            0.6000    0.8227    0.5828];

    cmap(1:3,:) = (cmap(1:3,:)).^0.8;
    cmap(4:8,:) = (cmap(4:8,:)).^0.15;
    cmap(9:21,:) = (cmap(9:21,:)).^.5;

    ROI_Names = {'V1' 'V2' 'V3' ...
        'hOc4v' 'FG1' 'FG2' 'FG3' 'FG4' ...
        'TO2' 'TO1' 'LO2' 'LO1' 'V3B' 'V3A' 'IPS0' 'IPS1' 'IPS2' 'IPS3' 'IPS4' 'IPS5' 'SPL1' ...
        'A37a'};

    b(7) = subplot(4,3,3);
    axis off
    els = [.01 .01 0; .01 .02 0; .01 .03 0; .01 .04 0; .01 .05 0];
    r2 = [0.1 0.2 0.3 0.4 0.5];
    ieeg_elAdd_sizable(els,r2,0.5,40)
    text(els(:,1)+.3,els(:,2),['0.1'; '0.2'; '0.3'; '0.4'; '0.5'], ...
        'Color','black','VerticalAlignment','middle','FontSize',12);
    b(7).InnerPosition = [0.895 0.85 .08 .07];

    b(8) = subplot(4,3,6);
    axis off
    cmapP = cmap(9:21,:);
    ROI_NamesP = ROI_Names(9:21);
    hold on
    for k = 1:length(ROI_NamesP)
        plot(1,k,'.','Color','black','MarkerSize',18,'Marker','square','MarkerFaceColor','black')
        plot(1,k,'.','Color',cmapP(k,:),'MarkerSize',17,'Marker','square','MarkerFaceColor',cmapP(k,:))
        text(1.05,k,ROI_NamesP{k},'Color','black','VerticalAlignment','middle')
    end
    xlim([0.8 1.2]), ylim([0 length(ROI_NamesP)+1])
    b(8).InnerPosition = [0.895 0.52 .1 .3];

    b(9) = subplot(4,3,9);
    axis off
    cmapP = cmap(1:3,:);
    ROI_NamesP = ROI_Names(1:3);
    hold on
    for k = 1:length(ROI_NamesP)
        plot(1,k,'.','Color','black','MarkerSize',18,'Marker','square','MarkerFaceColor','black')
        plot(1,k,'.','Color',cmapP(k,:),'MarkerSize',17,'Marker','square','MarkerFaceColor',cmapP(k,:))
        text(1.05,k,ROI_NamesP{k},'Color','black','VerticalAlignment','middle')
    end
    xlim([0.8 1.2]), ylim([0 length(ROI_NamesP)+1]);
    b(9).InnerPosition = [0.895 0.4 .1 .09];

    b(10) = subplot(4,3,12);
    axis off
    cmapP = cmap([4:8,22],:);
    ROI_NamesP = ROI_Names([4:8,22]);
    hold on
    for k = 1:length(ROI_NamesP)
        plot(1,k,'.','Color','black','MarkerSize',18,'Marker','square','MarkerFaceColor','black')
        plot(1,k,'.','Color',cmapP(k,:),'MarkerSize',17,'Marker','square','MarkerFaceColor',cmapP(k,:))
        text(1.05,k,ROI_NamesP{k},'Color','black','VerticalAlignment','middle');
    end
    xlim([0.8 1.2]), ylim([0 length(ROI_NamesP)+1]);
    b(10).InnerPosition = [0.895 0.17 .1 .15];

    %% Create loc_info tables
    loc_info = table;
    loc_info.name = [{DivergentP.recordCh}]';
    loc_info.x = [DivergentP.x_recordCh]';
    loc_info.y = [DivergentP.y_recordCh]';
    loc_info.z = [DivergentP.z_recordCh]';
    loc_info.hemisphere = [{DivergentP.hemisphere}]';
    loc_info.Destrieux_label = [{DivergentP.Destrieux_label_recordCh}]';

    if mni == 0
        loc_info_raw = open(fullfile(localDataPath, ...
            'derivatives','loc_info',locInfoFolder,'loc_info.mat'));
        for zzz = 1:size(loc_info,1)
            thisidx = find(ismember(loc_info_raw.loc_info.name,loc_info.name(zzz)));
            loc_info.x(zzz) = loc_info_raw.loc_info.x(thisidx);
            loc_info.y(zzz) = loc_info_raw.loc_info.y(thisidx);
            loc_info.z(zzz) = loc_info_raw.loc_info.z(thisidx);
        end
    end

    xyz_inflated1 = ieeg_snap2inflated(loc_info,gR,gL,gR_infl,gL_infl);

    loc_info_noSig = table;
    loc_info_noSig.name = [{DivergentP_NoSig.recordCh}]';
    loc_info_noSig.x = [DivergentP_NoSig.x_recordCh]';
    loc_info_noSig.y = [DivergentP_NoSig.y_recordCh]';
    loc_info_noSig.z = [DivergentP_NoSig.z_recordCh]';
    loc_info_noSig.hemisphere = [{DivergentP_NoSig.hemisphere}]';
    loc_info_noSig.Destrieux_label = [{DivergentP_NoSig.Destrieux_label_recordCh}]';

    if mni == 0
        for zzz = 1:size(loc_info_noSig,1)
            thisidx = find(ismember(loc_info_raw.loc_info.name,loc_info_noSig.name(zzz)));
            loc_info_noSig.x(zzz) = loc_info_raw.loc_info.x(thisidx);
            loc_info_noSig.y(zzz) = loc_info_raw.loc_info.y(thisidx);
            loc_info_noSig.z(zzz) = loc_info_raw.loc_info.z(thisidx);
        end
    end

    xyz_inflated_noSig1 = ieeg_snap2inflated(loc_info_noSig,gR,gL,gR_infl,gL_infl);

    loc_info_stimTarget = table;
    stimPairs = [DivergentP.stimPair];
    elAll = squeeze(split(stimPairs,'-'));

    try
        el1All = elAll(:,1);
        el2All = elAll(:,2);
    catch
        el1All = elAll(1);
        el2All = elAll(2);
    end

    loc_info_stimTarget.name = [el1All; el2All];
    loc_info_stimTarget.x = [[DivergentP.x_stim_el1]'; [DivergentP.x_stim_el2]'];
    loc_info_stimTarget.y = [[DivergentP.y_stim_el1]'; [DivergentP.y_stim_el2]'];
    loc_info_stimTarget.z = [[DivergentP.z_stim_el1]'; [DivergentP.z_stim_el2]'];
    loc_info_stimTarget.hemisphere = [[DivergentP.hemisphere]'; [DivergentP.hemisphere]'];
    loc_info_stimTarget.Destrieux_label = [[DivergentP.Destrieux_label_stim]'; [DivergentP.Destrieux_label_stim]'];

    if mni == 0
        for zzz = 1:size(loc_info_stimTarget,1)
            thisidx = find(ismember(loc_info_raw.loc_info.name,loc_info_stimTarget.name(zzz)));
            loc_info_stimTarget.x(zzz) = loc_info_raw.loc_info.x(thisidx);
            loc_info_stimTarget.y(zzz) = loc_info_raw.loc_info.y(thisidx);
            loc_info_stimTarget.z(zzz) = loc_info_raw.loc_info.z(thisidx);
        end
    end

    xyz_inflated_all_stimTarget = ieeg_snap2inflated(loc_info_stimTarget,gR,gL,gR_infl,gL_infl);

    %% Hemispheres
    for hh = 1:2
        if hh == 1
            hemi = 'l';
            g = gL_infl;
            g1 = gL;
            views_plot = {[270,0],[90,0],[-90,-90]};
        else
            hemi = 'r';
            g = gR_infl;
            g1 = gR;
            views_plot = {[270,0],[90,0],[90,-90]};
        end

        % Wang
        if mni == 1
            surface_labels_W = MRIread(fullfile(localDataPath,'derivatives','freesurfer','fsaverage','surf',[hemi 'h.wang15_mplbl.mgz']));
        else
            surface_labels_W = MRIread(fullfile(localDataPath,'derivatives','freesurfer',subjFolder,'surf',[hemi 'h.wang15_mplbl.mgz']));
        end
        vert_label_W = surface_labels_W.vol(:);
        WchgIdx = vert_label_W - 3;
        noInterest = find(WchgIdx < 9 | WchgIdx == 22);
        WchgIdx(noInterest) = 0;

        % Rosenke
        if mni == 1
            surface_labels_R = MRIread(fullfile(localDataPath,'derivatives','freesurfer','fsaverage','surf',[hemi 'h.rosenke18_vcatlas.mgz']));
        else
            surface_labels_R = MRIread(fullfile(localDataPath,'derivatives','freesurfer',subjFolder,'surf',[hemi 'h.rosenke18_vcatlas.mgz']));
        end
        vert_label_R = surface_labels_R.vol(:);
        noInterest1 = find(vert_label_R < 4);
        vert_label_R(noInterest1) = 0;

        % Benson
        if mni == 1
            surface_labels_B = MRIread(fullfile(localDataPath,'derivatives','freesurfer','fsaverage','surf',[hemi 'h.benson14_varea.mgz']));
        else
            surface_labels_B = MRIread(fullfile(localDataPath,'derivatives','freesurfer',subjFolder,'surf',[hemi 'h.benson14_varea.mgz']));
        end
        vert_label_B = surface_labels_B.vol(:);
        noInterest2 = find(vert_label_B > 3);
        vert_label_B(noInterest2) = 0;

        % BN
        if mni == 1
            [~, verlab, temp] = read_annotation(fullfile(localDataPath,'derivatives','freesurfer','fsaverage','label',[hemi 'h.BN_Atlas.annot']));
        else
            [~, verlab, temp] = read_annotation(fullfile(localDataPath,'derivatives','freesurfer',subjFolder,'label',[hemi 'h.BN_Atlas.annot']));
        end

        temp.table(1:211,6) = 0:210;
        for ver = 2:length(temp.table)
            idxCh = find(ismember(verlab,temp.table(ver,5)));
            verlab(idxCh) = temp.table(ver,6)/100;
        end
        verlab = int16(verlab*100);

        isRosenke = find(~ismember(vert_label_R,0));
        if hh == 1
            verlab1 = find(verlab ~= 91);
            verlab(verlab1) = 0;
            verlab(isRosenke) = 0;
            verlab2 = find(verlab == 91);
            verlab(verlab2) = 22;
        else
            verlab1 = find(verlab ~= 92);
            verlab(verlab1) = 0;
            verlab(isRosenke) = 0;
            verlab2 = find(verlab == 92);
            verlab(verlab2) = 22;
        end

        clear vert_label
        for i = 1:length(vert_label_B)
            if verlab(i) == 22
                vert_label(i,1) = verlab(i);
            elseif vert_label_B(i) == 0
                vert_label(i,1) = WchgIdx(i) + vert_label_R(i);
            else
                vert_label(i,1) = vert_label_B(i);
            end
        end

        % Sulcal labels
        if mni == 1
            sulcal_labels = read_curv(fullfile(localDataPath,'derivatives','freesurfer','fsaverage','surf',[hemi 'h.sulc']));
        else
            sulcal_labels = read_curv(fullfile(localDataPath,'derivatives','freesurfer',subjFolder,'surf',[hemi 'h.sulc']));
        end

        electrodes_thisHemi = find(startsWith({DivergentP.recordCh},upper(hemi)) & strcmpi([DivergentP.hemisphere],hemi));
        electrodes_thisHemi_noSig = find(startsWith({DivergentP_NoSig.recordCh},upper(hemi)) & strcmpi([DivergentP_NoSig.hemisphere],hemi));
        electrodes_thisHemi_all_stimTarget = find(ismember(loc_info_stimTarget.hemisphere,upper(hemi)));

        for vv = 1:length(views_plot)
            v_d = [views_plot{vv}(1), views_plot{vv}(2)];

            if inflatedBrain == 1
                els = xyz_inflated1;
                els_noSig = xyz_inflated_noSig1;
                els_all_stimTarget = xyz_inflated_all_stimTarget;
            else
                els = [loc_info.x loc_info.y loc_info.z];
                els_noSig = [loc_info_noSig.x loc_info_noSig.y loc_info_noSig.z];
                els_all_stimTarget = [loc_info_stimTarget.x loc_info_stimTarget.y loc_info_stimTarget.z];
            end

            b(wherePlotIdx) = subplot(4,3,whereplot(wherePlotIdx));
            hold on;

            a_offset = .1 * max(abs(els(:,1))) * ...
                [cosd(v_d(1)-90)*cosd(v_d(2)) sind(v_d(1)-90)*cosd(v_d(2)) sind(v_d(2))];

            els_pop = els + repmat(a_offset,size(els,1),1);

            try
                els_pop_noSig = els_noSig + repmat(a_offset*.5,size(els_noSig,1),1);
            catch
                els_pop_noSig = [0 0 0];
            end

            els_pop_all_stimTarget = els_all_stimTarget + repmat(a_offset,size(els_all_stimTarget,1),1);

            if inflatedBrain == 1
                tH = vc_render_gifti_labels(g,vert_label,cmap,sulcal_labels);
            else
                tH = vc_render_gifti_labels(g1,vert_label,cmap,sulcal_labels);
                tH.FaceAlpha = .3;
            end
            
            ieeg_elAdd(els_pop_noSig(electrodes_thisHemi_noSig,:),'black',12);
            ieeg_elAdd(els_pop_all_stimTarget(electrodes_thisHemi_all_stimTarget,:),[0, 0, 0],26);
            ieeg_elAdd(els_pop_all_stimTarget(electrodes_thisHemi_all_stimTarget,:),[0.99999,0.99999,0.99999],18);

            mea2plot = [DivergentP.cod];
            ieeg_elAdd_sizable(els_pop(electrodes_thisHemi,:),mea2plot(electrodes_thisHemi),0.5,40);

            if yesLabels == 1
                ieeg_label(els_pop(electrodes_thisHemi,:),15,10,loc_info.name(electrodes_thisHemi));
            end

            ieeg_viewLight(v_d(1),v_d(2))
            wherePlotIdx = wherePlotIdx + 1;
        end
    end

    %% Final layout
 

    boxSiz = 0.37;
    yy = 0.600;
    b(1).InnerPosition = [0.1 yy boxSiz boxSiz];
    b(5).InnerPosition = [0.5 yy boxSiz boxSiz];

    yy = 0.2950;
    b(2).InnerPosition = [0.1 yy boxSiz boxSiz];
    b(4).InnerPosition = [0.5 yy boxSiz boxSiz];

    yy = 0.050;
    b(3).InnerPosition = [0.1 yy boxSiz boxSiz];
    b(6).InnerPosition = [0.5 yy boxSiz boxSiz];
end