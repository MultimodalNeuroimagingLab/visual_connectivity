function [Res, tableRes] = vc_measure_streams(crp, localDataPath)
% Input crp Summary results and localpath
% Outpt:
% - Res that include the measures 
% - tableRes to plot
% For grey matter
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 
    gmb = -1; % max gray matter distance 
    Res = table;
    indxRes = 1;
    warning off

    for pathwaytarget = 1:4
    % 1. Dorsal | 2. Lateral | 3. Ventral | 4. Posterior
        switch pathwaytarget
            case 1
                disp('Dorsal')
                Pathtarget = 'Dorsal';
                Path1 = 'Lateral';
                Path2 = 'Ventral';
                Path3 = 'Posterior';
            case 2
                disp('Lateral')
                Pathtarget = 'Lateral';
                Path1 = 'Dorsal';
                Path2 = 'Ventral';
                Path3 = 'Posterior';
            case 3
                disp('Ventral')
                Pathtarget = 'Ventral';
                Path1 = 'Dorsal';
                Path2 = 'Lateral';
                Path3 = 'Posterior';
            case 4
                disp('Posterior')
                Pathtarget = 'Posterior';
                Path1 = 'Dorsal';
                Path2 = 'Lateral';
                Path3 = 'Ventral';
        end

        %% Path1-3
        for j = 1:3
            switch j
            case 1
                thisPath = Path1;
            case 2
                thisPath = Path2;
            case 3
                thisPath = Path3;
            end

            % Significant responses 
            Path = [];
            subjInPath = [];
            subjInPathNoSig = [];
            for i = 1:length(crp.(Pathtarget).DivergentP)
               
                Subject = crp.(Pathtarget).DivergentP(i).Subj;
                try
                    aroundEl = crp.(Pathtarget).aroundStim_gm.(Subject); 
                catch
                    aroundEl = [];
                end
                stimPair= crp.(Pathtarget).DivergentP(i).stimPair;
                el1 = extractBefore(stimPair,'-');
                el2 = extractAfter(stimPair,'-');
                if strcmp(crp.(Pathtarget).DivergentP(i).recPathway,thisPath) &&...
                        startsWith(crp.(Pathtarget).DivergentP(i).stimPair, ...
                        crp.(Pathtarget).DivergentP(i).hemisphere) && ...%
                        crp.(Pathtarget).DivergentP(i).stim_gm_wmDist_el1 >= gmb &&...
                        crp.(Pathtarget).DivergentP(i).stim_gm_wmDist_el2 >= gmb &&...
                        crp.(Pathtarget).DivergentP(i).record_gm_wmDist >= gmb  
                    Path = [Path i];
                    subjInPath = [subjInPath {crp.(Pathtarget).DivergentP(i).Subj}];
                end 
            end
            subjInPath = unique(subjInPath);
            
            
            % No significant responses 
            PathNoSig = [];
            for k = 1:length(crp.(Pathtarget).DivergentP_NoSig)
                if strcmp(crp.(Pathtarget).DivergentP_NoSig(k).recPathway,thisPath) &&...
                        startsWith(crp.(Pathtarget).DivergentP_NoSig(k).stimPair, ...
                        crp.(Pathtarget).DivergentP_NoSig(k).hemisphere) && ...%
                        crp.(Pathtarget).DivergentP_NoSig(k).stim_gm_wmDist_el1 >= gmb &&...
                        crp.(Pathtarget).DivergentP_NoSig(k).stim_gm_wmDist_el2 >= gmb &&...
                        crp.(Pathtarget).DivergentP_NoSig(k).record_gm_wmDist >= gmb
                    PathNoSig = [PathNoSig k];
                    subjInPathNoSig = [subjInPathNoSig {crp.(Pathtarget).DivergentP_NoSig(k).Subj}];
                end 
            end
            subjInPathAll = unique([subjInPathNoSig subjInPath]);

            tRDi = [];
            VsrnDi = [];
            SubjDi = [];
            stimPairDi = {};
            recordDi = {};
            codDi = [];
            stimArea = {};
            recArea = {};
            x_recCh = [];
            y_recCh = [];
            z_recCh = [];
            Destrieux_label_recordCh = {};
            hemisphere = {};
            for i = Path
                tRDi = [tRDi; crp.(Pathtarget).DivergentP(i).crp_parms.tR];
                VsrnDi = [VsrnDi; mean(crp.(Pathtarget).DivergentP(i).crp_parms.Vsnr)];
                SubjDi = [SubjDi; crp.(Pathtarget).DivergentP(i).Subj];
                stimPairDi = [stimPairDi; crp.(Pathtarget).DivergentP(i).stimPair];
                recordDi = [recordDi; crp.(Pathtarget).DivergentP(i).recordCh];
                codDi = [codDi; crp.(Pathtarget).DivergentP(i).cod];
                x_recCh = [x_recCh; crp.(Pathtarget).DivergentP(i).x_recordCh];
                y_recCh = [y_recCh; crp.(Pathtarget).DivergentP(i).y_recordCh];
                z_recCh = [z_recCh; crp.(Pathtarget).DivergentP(i).z_recordCh];
                Destrieux_label_recordCh = [Destrieux_label_recordCh; crp.(Pathtarget).DivergentP(i).Destrieux_label_recordCh];
                hemisphere = [hemisphere; crp.(Pathtarget).DivergentP(i).hemisphere];
                
                subjID = char(crp.(Pathtarget).DivergentP(i).Subj);
                locInfoFolder = strrep(subjID, 'sub_', 'sub-');
                
                load(fullfile(localDataPath, ...
                    'derivatives', 'loc_info', locInfoFolder, 'loc_info.mat'));
                el1 = extractBefore(crp.(Pathtarget).DivergentP(i).stimPair,'-');
                el1Num = find(ismember(loc_info.name, el1));
                el2 = extractAfter(crp.(Pathtarget).DivergentP(i).stimPair,'-');
                el2Num = find(ismember(loc_info.name, el2));

                % Stim Area
                if strcmp(Pathtarget, 'Dorsal')
                    if loc_info.WaVert(el1Num) >= loc_info.WaVert(el2Num)
                        stimArea = [stimArea loc_info.WaArea(el1Num)];
                    else
                        stimArea = [stimArea loc_info.WaArea(el2Num)];
                    end
                elseif strcmp(Pathtarget, 'Lateral')
                    if loc_info.WaVert(el1Num) >= loc_info.WaVert(el2Num)
                        stimArea = [stimArea loc_info.WaArea(el1Num)];
                    else
                        stimArea = [stimArea loc_info.WaArea(el2Num)];
                    end
                elseif strcmp(Pathtarget, 'Ventral')
                    if startsWith(loc_info.BnArea(el1Num),'A37elv') || startsWith(loc_info.BnArea(el2Num),'A37elv')
                        stimArea = [stimArea loc_info.BnArea(el1Num)];
                    elseif loc_info.RoVert(el1Num) >= loc_info.RoVert(el2Num)
                        stimArea = [stimArea loc_info.RoArea(el1Num)];
                    elseif loc_info.RoVert(el1Num) < loc_info.RoVert(el2Num)
                        stimArea = [stimArea loc_info.RoArea(el2Num)];
                    elseif startsWith(loc_info.BnArea(el1Num),'A37lv') || startsWith(loc_info.BnArea(el2Num),'A37lv') 
                        stimArea = [stimArea loc_info.BnArea(el1Num)];
                    end
                elseif strcmp(Pathtarget, 'Posterior')
                    if loc_info.BeVert(el1Num) >= loc_info.BeVert(el2Num)
                        stimArea = [stimArea loc_info.BeArea(el1Num)];
                    else
                        stimArea = [stimArea loc_info.BeArea(el2Num)];
                    end
                end
                
                % recording area
                recNum = find(ismember(loc_info.name, crp.(Pathtarget).DivergentP(i).recordCh));
                if strcmp(thisPath, 'Dorsal')
                    recArea = [recArea {crp.(Pathtarget).DivergentP(i).recCh_areaWang}];
                elseif strcmp(thisPath, 'Lateral')
                    recArea = [recArea {crp.(Pathtarget).DivergentP(i).recCh_areaWang}];
                elseif strcmp(thisPath, 'Ventral')
                    if startsWith(string(crp.(Pathtarget).DivergentP(i).recCh_areaBN),'A37elv')
                        recArea = [recArea {"A37elv"}];
                    elseif ~strcmp(string(crp.(Pathtarget).DivergentP(i).recCh_areaRosenke),"")
                        recArea = [recArea {crp.(Pathtarget).DivergentP(i).recCh_areaRosenke}];
                    elseif startsWith(string(crp.(Pathtarget).DivergentP(i).recCh_areaBN),'A37lv')
                        recArea = [recArea {"A37lv"}];
                    end
                elseif strcmp(thisPath, 'Posterior')
                    recArea = [recArea {crp.(Pathtarget).DivergentP(i).recCh_areaBenson}];
                end

            end
            clear loc_info
            meantRDi = mean(tRDi);
            meanVsnrDi = mean(VsrnDi);
            stimArea = stimArea';
            recArea = recArea';

            tableRes.(Pathtarget).(thisPath) = table(SubjDi, stimPairDi,...
                recordDi, x_recCh, y_recCh, z_recCh, Destrieux_label_recordCh,...
                hemisphere, stimArea, recArea, tRDi, VsrnDi, codDi);
            Res.from{indxRes} = Pathtarget;
            Res.to{indxRes} = thisPath;
            
            Res.median_tR{indxRes} = median(tableRes.(Pathtarget).(thisPath).tRDi);
            Res.mean_tR{indxRes} = mean(tableRes.(Pathtarget).(thisPath).tRDi);
            Res.SE_tR{indxRes} = std(tableRes.(Pathtarget).(thisPath).tRDi)/sqrt(height(tableRes.(Pathtarget).(thisPath)));
            
            Res.mean_Vsrn{indxRes} = mean(tableRes.(Pathtarget).(thisPath).VsrnDi);
            Res.SE_Vsrn{indxRes} = std(tableRes.(Pathtarget).(thisPath).VsrnDi)/sqrt(height(tableRes.(Pathtarget).(thisPath)));
            
            Res.mean_cod{indxRes} = mean(tableRes.(Pathtarget).(thisPath).codDi);
            Res.SE_cod{indxRes} = std(tableRes.(Pathtarget).(thisPath).codDi)/sqrt(height(tableRes.(Pathtarget).(thisPath)));
            
            Res.numSubj{indxRes} = length(subjInPath); % Subjects with sig resp
            Res.Subjs{indxRes} = subjInPath;
            Res.numSubjAll{indxRes} = length(subjInPathAll);
            Res.SubjsAll{indxRes} = subjInPathAll;
            % Porcentage of significant responses
            Res.PorcenSignRes{indxRes} = 100*length(Path)/(length(PathNoSig)+length(Path));
            Res.SignRes{indxRes} = length(Path);
            Res.AllRes{indxRes} = length(PathNoSig)+length(Path);

            indxRes = indxRes + 1;
        end
        %clear aroundEl codDi el1 el2 i j k meantRDi meanVsnrDi Path Path1 Path2 Path3 PathAll Pathtarget pathwaytarget recordDi stimPair stimPairDi SubjDi Subject thisPath tRDi VsrnDi
    end
    fprintf('end'); 
end