%% Porcentage of significant responses
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 
% 
sigAll = 100*size(sigResponses)/size(Responses);
disp([char(string(sigAll)), '% of significant responses between all visual areas']);

for i = 1:size(sigResponses,1)
    if strcmp(sigResponses.pathway(i),"Posterior")
        sigResponses.direction(i) = "Feedforward";
    elseif strcmp(sigResponses.recPathway(i),"Posterior")
        sigResponses.direction(i) = "Feedback";
    elseif (strcmp(sigResponses.pathway(i),"Ventral") && strcmp(sigResponses.recPathway(i),"Lateral")) ||...
            (strcmp(sigResponses.pathway(i),"Lateral") && strcmp(sigResponses.recPathway(i),"Dorsal")) ||...
            (strcmp(sigResponses.pathway(i),"Ventral") && strcmp(sigResponses.recPathway(i),"Dorsal"))
        sigResponses.direction(i) = "Upward";
    elseif (strcmp(sigResponses.pathway(i),"Lateral") && strcmp(sigResponses.recPathway(i),"Ventral")) ||...
            (strcmp(sigResponses.pathway(i),"Dorsal") && strcmp(sigResponses.recPathway(i),"Lateral")) ||...
            (strcmp(sigResponses.pathway(i),"Dorsal") && strcmp(sigResponses.recPathway(i),"Ventral"))
        sigResponses.direction(i) = "Downward";
    end
end


for i = 1:size(noSigResponses,1)
    if strcmp(noSigResponses.pathway(i),"Posterior")
        noSigResponses.direction(i) = "Feedforward";
    elseif strcmp(noSigResponses.recPathway(i),"Posterior")
        noSigResponses.direction(i) = "Feedback";
    elseif (strcmp(noSigResponses.pathway(i),"Ventral") && strcmp(noSigResponses.recPathway(i),"Lateral")) ||...
            (strcmp(noSigResponses.pathway(i),"Lateral") && strcmp(noSigResponses.recPathway(i),"Dorsal")) ||...
            (strcmp(noSigResponses.pathway(i),"Ventral") && strcmp(noSigResponses.recPathway(i),"Dorsal"))
        noSigResponses.direction(i) = "Upward";
    elseif (strcmp(noSigResponses.pathway(i),"Lateral") && strcmp(noSigResponses.recPathway(i),"Ventral")) ||...
            (strcmp(noSigResponses.pathway(i),"Dorsal") && strcmp(noSigResponses.recPathway(i),"Lateral")) ||...
            (strcmp(noSigResponses.pathway(i),"Dorsal") && strcmp(noSigResponses.recPathway(i),"Ventral"))
        noSigResponses.direction(i) = "Downward";
    end
end

%% Porcentage of significant responses and balance

% feedforward 
pcFf = (100*sum(ismember(sigResponses.direction,"Feedforward")))/...
    (sum(ismember(sigResponses.direction,"Feedforward"))+sum(ismember(noSigResponses.direction,"Feedforward")));
% feedback 
pcFb = (100*sum(ismember(sigResponses.direction,"Feedback")))/...
    (sum(ismember(sigResponses.direction,"Feedback"))+sum(ismember(noSigResponses.direction,"Feedback")));
% upward
pcuw = (100*sum(ismember(sigResponses.direction,"Upward")))/...
    (sum(ismember(sigResponses.direction,"Upward"))+sum(ismember(noSigResponses.direction,"Upward")));
% downward
pcdw = (100*sum(ismember(sigResponses.direction,"Downward")))/...
    (sum(ismember(sigResponses.direction,"Downward"))+sum(ismember(noSigResponses.direction,"Downward")));
% lateral inputs 
latIn = (100*sum(ismember(sigResponses.recPathway,"Lateral")))/...
    (sum(ismember(sigResponses.recPathway,"Lateral"))+sum(ismember(noSigResponses.recPathway,"Lateral")));
% lateral outputs
latOut = (100*sum(ismember(sigResponses.pathway,"Lateral")))/...
    (sum(ismember(sigResponses.pathway,"Lateral"))+sum(ismember(noSigResponses.pathway,"Lateral")));
% early visual inputs 
evIn = (100*sum(ismember(sigResponses.recPathway,"Posterior")))/...
    (sum(ismember(sigResponses.recPathway,"Posterior"))+sum(ismember(noSigResponses.recPathway,"Posterior")));
% early visual  outputs
evOut = (100*sum(ismember(sigResponses.pathway,"Posterior")))/...
    (sum(ismember(sigResponses.pathway,"Posterior"))+sum(ismember(noSigResponses.pathway,"Posterior")));
% Ventral inputs 
venIn = (100*sum(ismember(sigResponses.recPathway,"Ventral")))/...
    (sum(ismember(sigResponses.recPathway,"Ventral"))+sum(ismember(noSigResponses.recPathway,"Ventral")));
% Ventral  outputs
venOut = (100*sum(ismember(sigResponses.pathway,"Ventral")))/...
    (sum(ismember(sigResponses.pathway,"Ventral"))+sum(ismember(noSigResponses.pathway,"Ventral")));
% Dorsal inputs 
dorIn = (100*sum(ismember(sigResponses.recPathway,"Dorsal")))/...
    (sum(ismember(sigResponses.recPathway,"Dorsal"))+sum(ismember(noSigResponses.recPathway,"Dorsal")));
% Dorsal  outputs
dorOut = (100*sum(ismember(sigResponses.pathway,"Dorsal")))/...
    (sum(ismember(sigResponses.pathway,"Dorsal"))+sum(ismember(noSigResponses.pathway,"Dorsal")));
