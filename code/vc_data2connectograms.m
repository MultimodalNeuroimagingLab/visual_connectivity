%% Connectivity maps: violin plots and connectograms ~ 5 min
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 
tic
% responses in gm and recording in a pathway
dorsalSig = crp.Dorsal.DivergentP;
for i = size(crp.Dorsal.DivergentP,2):-1:1
    if ~(dorsalSig(i).stim_gm_wmDist_el1 >= -1 &&...
            dorsalSig(i).stim_gm_wmDist_el2 >= -1 &&...
            dorsalSig(i).record_gm_wmDist >= -1) ||...
            strcmp(string(dorsalSig(i).recPathway),"")
            dorsalSig(i) = [];
    end
end

dorsalNoSig = crp.Dorsal.DivergentP_NoSig;
for i = size(crp.Dorsal.DivergentP_NoSig,2):-1:1
    if ~(dorsalNoSig(i).stim_gm_wmDist_el1 >= -1 &&...
            dorsalNoSig(i).stim_gm_wmDist_el2 >= -1 &&...
            dorsalNoSig(i).record_gm_wmDist >= -1) ||...
            strcmp(string(dorsalNoSig(i).recPathway),"")
            dorsalNoSig(i) = [];
    end
end

ventralSig = crp.Ventral.DivergentP;
for i = size(crp.Ventral.DivergentP,2):-1:1
    if ~(ventralSig(i).stim_gm_wmDist_el1 >= -1 &&...
            ventralSig(i).stim_gm_wmDist_el2 >= -1 &&...
            ventralSig(i).record_gm_wmDist >= -1) ||...
            strcmp(string(ventralSig(i).recPathway),"")
            ventralSig(i) = [];
    end
end

ventralNoSig = crp.Ventral.DivergentP_NoSig;
for i = size(crp.Ventral.DivergentP_NoSig,2):-1:1
    if ~(ventralNoSig(i).stim_gm_wmDist_el1 >= -1 &&...
            ventralNoSig(i).stim_gm_wmDist_el2 >= -1 &&...
            ventralNoSig(i).record_gm_wmDist >= -1) ||...
            strcmp(string(ventralNoSig(i).recPathway),"")
            ventralNoSig(i) = [];
    end
end

lateralSig = crp.Lateral.DivergentP;
for i = size(crp.Lateral.DivergentP,2):-1:1
    if ~(lateralSig(i).stim_gm_wmDist_el1 >= -1 &&...
            lateralSig(i).stim_gm_wmDist_el2 >= -1 &&...
            lateralSig(i).record_gm_wmDist >= -1) ||...
            strcmp(string(lateralSig(i).recPathway),"")
            lateralSig(i) = [];
    end
end

lateralNoSig = crp.Lateral.DivergentP_NoSig;
for i = size(crp.Lateral.DivergentP_NoSig,2):-1:1
    if ~(lateralNoSig(i).stim_gm_wmDist_el1 >= -1 &&...
            lateralNoSig(i).stim_gm_wmDist_el2 >= -1 &&...
            lateralNoSig(i).record_gm_wmDist >= -1) ||...
            strcmp(string(lateralNoSig(i).recPathway),"")
            lateralNoSig(i) = [];
    end
end

earlyViSig = crp.Posterior.DivergentP;
for i = size(crp.Posterior.DivergentP,2):-1:1
    if ~(earlyViSig(i).stim_gm_wmDist_el1 >= -1 &&...
            earlyViSig(i).stim_gm_wmDist_el2 >= -1 &&...
            earlyViSig(i).record_gm_wmDist >= -1) ||...
            strcmp(string(earlyViSig(i).recPathway),"")
            earlyViSig(i) = [];
    end
end

earlyViNoSig = crp.Posterior.DivergentP_NoSig;
for i = size(crp.Posterior.DivergentP_NoSig,2):-1:1
    if ~(earlyViNoSig(i).stim_gm_wmDist_el1 >= -1 &&...
            earlyViNoSig(i).stim_gm_wmDist_el2 >= -1 &&...
            earlyViNoSig(i).record_gm_wmDist >= -1) ||...
            strcmp(string(earlyViNoSig(i).recPathway),"")
            earlyViNoSig(i) = [];
    end
end
sigResponses = [struct2table(dorsalSig);struct2table(lateralSig);struct2table(ventralSig);struct2table(earlyViSig)];
noSigResponses = [struct2table(dorsalNoSig);struct2table(lateralNoSig);struct2table(ventralNoSig);struct2table(earlyViNoSig)];

clear Responses
Responses = [sigResponses; noSigResponses];
toc