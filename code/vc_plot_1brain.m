function b = vc_plot_1brain(crp, all_subjects, localDataPath, pathwayT, whoplot, S, plotOnePair, stimPair2plot, mni, inflatedBrain, yesLabels, AreaInStream, Hem2plot, views2plot)
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
%   Hem2plot         : 1 left, 2 rigth
%   views2plot       : 'lateral', 'medial', 'ventral', '[60,-30]'
%
% Output:
%   b                : subplot handles
%
% Example:
%   b = plot_roi_outputs(crp, all_subjects, localDataPath, ...
%       'Ventral', 0, all_subjects(1), 0, 'LG6-LG7', 1, 1, 0, []);
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 
    

    
    %% Fixed canvas for individual brain plots
    subjLabel =[ 'sub_' char(S)];
    brainCanvasPx = 296;
    
    figH = gcf;
    
    set(figH, ...
        'Units', 'pixels', ...
        'Position', [100 100 brainCanvasPx brainCanvasPx], ...
        'Color', 'w');
    
    ax = gca;
    
    set(ax, ...
        'Units', 'pixels', ...
        'Position', [0 0 brainCanvasPx brainCanvasPx]);
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
    subjFolder =[ 'sub-' char(S)];
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
    axis off

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
            'derivatives','loc_info',subjFolder,'loc_info.mat'));
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
    for hh = Hem2plot
        if hh == 1
            hemi = 'l';
            g = gL_infl;
            g1 = gL;
            if strcmp(views2plot,'lateral')
                views_plot = {[270,0]};
            elseif strcmp(views2plot,'medial')
                views_plot = {[90,0]};
            elseif strcmp(views2plot,'ventral')
                views_plot = {[-90,-90]};
            else
                views_plot = views2plot;
            end
        else
            hemi = 'r';
            g = gR_infl;
            g1 = gR;
            if strcmp(views2plot,'lateral')
                views_plot = {[90,0]};% 70,-20
            elseif strcmp(views2plot,'medial')
                views_plot = {[270,0]};
            elseif strcmp(views2plot,'ventral')
                views_plot = {[90,-90]};
            else
                views_plot = views2plot;
            end
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
        end
    end

end