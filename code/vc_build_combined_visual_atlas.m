function [vert_label,cmap,ROI_Names,sulcal_labels] = vc_build_combined_visual_atlas(projectRoot,sub_label,hemi,mni)
    % Build combined visual atlas
    %
    % This creates:
    %   vert_label    = combined atlas labels on the surface
    %   cmap          = combined atlas colormap
    %   ROI_Names     = combined atlas names
    %   sulcal_labels = sulcal map
    %
    % Combined atlas labels:
    %   1  V1
    %   2  V2
    %   3  V3
    %   4  hOc4v
    %   5  FG1
    %   6  FG2
    %   7  FG3
    %   8  FG4
    %   9  TO2
    %   10 TO1
    %   11 LO2
    %   12 LO1
    %   13 V3B
    %   14 V3A
    %   15 IPS0
    %   16 IPS1
    %   17 IPS2
    %   18 IPS3
    %   19 IPS4
    %   20 IPS5
    %   21 SPL1
    %   22 FEF
    %   23 A37a
    %   projectRoot = localDataPath, depending on your folder structure
    %   sub_label = '22';
    %   hemi = 'l';  % 'l' or 'r'
    %   mni = 0;     % 0 = subject native, 1 = fsaverage
    %   [vert_label,cmap,ROI_Names,sulcal_labels] = build_combined_visual_atlas(projectRoot, sub_label, hemi, mni);
    %   Aug 2026
    %   Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 

    hemi = lower(hemi);

    if strcmpi(hemi,'l')
        hemiNum = 1;
    elseif strcmpi(hemi,'r')
        hemiNum = 2;
    else
        error('hemi must be ''l'' or ''r''.');
    end

    if mni == 1
        fsSubject = 'fsaverage';
    else
        fsSubject = ['sub-' sub_label];
    end

    fsDir = fullfile(projectRoot,'derivatives','freesurfer',fsSubject);

    % 1. Wang atlas
    % ------------------------------------------------------------

    surface_labels_W = MRIread(fullfile(fsDir,'surf', ...
        [hemi 'h.wang15_mplbl.mgz']));

    vert_label_W = surface_labels_W.vol(:);

    WchgIdx = vert_label_W - 3;

    noInterest = WchgIdx < 9;
    WchgIdx(noInterest) = 0;


    % 2. Rosenke ventral category atlas
    % ------------------------------------------------------------

    surface_labels_R = MRIread(fullfile(fsDir,'surf', ...
        [hemi 'h.rosenke18_vcatlas.mgz']));

    vert_label_R = surface_labels_R.vol(:);

    noInterest1 = vert_label_R < 4;
    vert_label_R(noInterest1) = 0;

    % 3. Benson V1-V3
    % ------------------------------------------------------------

    surface_labels_B = MRIread(fullfile(fsDir,'surf', ...
        [hemi 'h.benson14_varea.mgz']));

    vert_label_B = surface_labels_B.vol(:);

    noInterest2 = vert_label_B > 3;
    vert_label_B(noInterest2) = 0;


    % 4. Brainnetome A37a
    % ------------------------------------------------------------

    verlab_A37a = zeros(size(vert_label_B));

    annotFile = fullfile(fsDir,'label',[hemi 'h.BN_Atlas.annot']);

    if exist(annotFile,'file')

        [~,verlab,temp] = read_annotation(annotFile);

        nRows = size(temp.table,1);

        % Create numeric label IDs in column 6.
        temp.table(:,6) = (0:(nRows-1))';

        for ver = 2:nRows
            idxCh = ismember(verlab,temp.table(ver,5));
            verlab(idxCh) = temp.table(ver,6)/100;
        end

        verlab = int16(verlab*100);

        isRosenke = find(~ismember(vert_label_R,0));

        if hemiNum == 1
            targetBN = 91;  % left A37a
        else
            targetBN = 92;  % right A37a
        end

        verlab(verlab ~= targetBN) = 0;
        verlab(isRosenke) = 0;
        verlab(verlab == targetBN) = 23;

        verlab_A37a = verlab;

    else
        warning('Brainnetome annotation file not found: %s', annotFile);
    end


    % 5. Combine labels
    % ------------------------------------------------------------

    vert_label = zeros(size(vert_label_B));

    for ii = 1:length(vert_label_B)

        if verlab_A37a(ii) == 23

            % Highest priority: Brainnetome A37a
            vert_label(ii,1) = 23;

        elseif vert_label_B(ii) ~= 0

            % Benson V1-V3
            vert_label(ii,1) = vert_label_B(ii);

        else

            % Wang/Rosenke
            vert_label(ii,1) = WchgIdx(ii) + vert_label_R(ii);

        end
    end


    % 6. Colormap and ROI names
    % ------------------------------------------------------------

    cmap = [0.9882    0.5647    0.5647;  % V1 Benson 1
            0.9882    0.7098    0.5255;  % V2 Benson 2
            1         1         0.6000;  % V3 Benson 3
            0.0784    0.9490    0.9176;  % hOc4v Rosenke 4
            0.1137    0.9647    0.0549;  % FG1 Rosenke 5
            0.9333    0.0549    0.9647;  % FG2 Rosenke 6
            0.0863    0.1059    0.6824;  % FG3 Rosenke 7
            0.4784    0.0471    0.0471;  % FG4 Rosenke 8
            0.9000    0.6000    1.0000;  % TO2 Wang 9
            0.3438    0.3910    0.3668;  % TO1 Wang 10
            0.6974    0.5129    0.8403;  % LO2 Wang 11
            0.1978    0.8408    0.7445;  % LO1 Wang 12
            0.3955    0.8227    0.5828;  % V3B Wang 13
            0.9686    0.3098    0.7353;  % V3A Wang 14
            0.2417    0.9409    0.7096;  % IPS0 Wang 15
            0.2196    0.0039    0.7588;  % IPS1 Wang 16
            0.2000    0.8000    0.5000;  % IPS2 Wang 17
            0.9539    0.7295    0.7562;  % IPS3 Wang 18
            0.2877    0.6154    0.4391;  % IPS4 Wang 19
            0.2206    0.2239    0.4094;  % IPS5 Wang 20
            0.9000    1.0000    0.7000;  % SPL1 Wang 21
            0.2000    0.5000    0.2000;  % FEF Wang 22
            0.6000    0.8227    0.5828]; % A37a Brainnetome 23

    % Pastel adjustment
    cmap(1:3,:)  = (cmap(1:3,:)).^0.8;
    cmap(4:8,:)  = (cmap(4:8,:)).^0.15;
    cmap(9:22,:) = (cmap(9:22,:)).^0.5;

    ROI_Names = {'V1' 'V2' 'V3' ...
        'hOc4v' 'FG1' 'FG2' 'FG3' 'FG4' ...
        'TO2' 'TO1' 'LO2' 'LO1' ...
        'V3B' 'V3A' ...
        'IPS0' 'IPS1' 'IPS2' 'IPS3' 'IPS4' 'IPS5' ...
        'SPL1' 'FEF' ...
        'A37a'};

    % 7. Sulcal labels
    % ------------------------------------------------------------

    sulcal_labels = read_curv(fullfile(fsDir,'surf',[hemi 'h.sulc']));

end