% Quantifying streams for gray matter 
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 
fontsize2print = 12;
idsp = 1;
figure ('Position',[0 0 580 940])
whereplot = [1 2 3 7 8 9 13 14 15 19 20 21];
for pathwaytarget = 1:4 % All
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
    DivergentP = crp.(Pathtarget).DivergentP;
    for i = 1:3
        switch i
        case 1
            thisPath = Path1;
        case 2
            thisPath = Path2;
        case 3
            thisPath = Path3;
        end
        
        DivergentP = crp.(Pathtarget).DivergentP;
        %figure ('Position',[0 0 360 200])
        
        p = subplot(8,3,whereplot(idsp));
        p.Position(4) = .1;
        DivergentP = crp.(Pathtarget).DivergentP;
        T = tableRes.(Pathtarget).(thisPath);
        
        keyD = string({DivergentP.Subj})' + "|" + ...
               string({DivergentP.stimPair})' + "|" + ...
               string({DivergentP.recordCh})';
        
        keyT = string(T.SubjDi) + "|" + ...
               string(T.stimPairDi) + "|" + ...
               string(T.recordDi);
        
        Di = find(ismember(keyD,keyT));
        Di = flip(Di);

        for j = 1:length(Di)
            tt = DivergentP(Di(j)).crp_parms.parms_times;
            color2sub = "#0072BD";
            plot(tt*1000,DivergentP(Di(j)).crp_parms.avg_trace_tR,'LineWidth',0.5,'Color', color2sub)
            hold on
            xlim([0 1000]);
            xticks(0:00:1000);
            xticklabels([]);
            ylim([-400 450]);
            yticks(-400:200:400);
        end
        if strcmp(Pathtarget,'Posterior')
            Pathtarget1 = 'Early visual';
        else
            Pathtarget1 = Pathtarget;
        end
        if strcmp(thisPath,'Posterior')
            thisPath1 = 'Early visual';
        else
            thisPath1 = thisPath;
        end
        title([Pathtarget1, ' --> ', thisPath1],'FontSize',fontsize2print,'HorizontalAlignment','center');
        set(gca,'fontsize',fontsize2print,'LineWidth',1);
        %xlabel('time (ms)','FontSize',12);
        box off;
        LineWidth = 1;
        
        % PIE PLOTS
        aPie = cell2mat(Res.PorcenSignRes(find(ismember([Res.from],Pathtarget) & ismember([Res.to],thisPath))));
        txt2 = (string(Res.numSubj(find(ismember([Res.from],Pathtarget) & ismember([Res.to],thisPath)))) + '/' + string(Res.numSubjAll(find(ismember([Res.from],Pathtarget) & ismember([Res.to],thisPath)))));
        bPie = cell2mat(Res.numSubj(find(ismember([Res.from],Pathtarget) & ismember([Res.to],thisPath))));
        cPie = cell2mat(Res.numSubjAll(find(ismember([Res.from],Pathtarget) & ismember([Res.to],thisPath))));
        dPie = 100*bPie/cPie;
        ylabel('amplitude (uV)','FontSize',fontsize2print);
        box off
        idsp = idsp + 1;
        
        % pie plot for porcentage of sig responses
        X = [aPie 100-aPie];
        %h = pie(X);
        %explode = [1 0];
        h = pie(X);
        xpos = 900;
        ypos = 320;
        scale = 70;
        for k = 1:length(h) % Walk the vector of text and patch handles
              if strcmp(get(h(k),'Type'),'patch') % Patch graphics
                  XData = get(h(k),'XData');  % Extract current data
                  YData = get(h(k),'YData');
                  set(h(k),'XData',XData*scale + xpos); % Insert modified data
                  set(h(k),'YData',YData*scale + ypos);
                  
              else % Text labels
                  set(h(k),'FontSize',90);
              end
        end
        h(1).FaceColor = [0 0.4470 0.7410];
        h(3).FaceColor = [0.9999 0.9999 0.9999];
        h(4).String = '';
        h(1).LineWidth = 1;
        h(3).LineWidth = 1;
       
        % Adjust text label alignment
        tobj = findobj(h,'type','text'); 
        set(tobj, 'VerticalAlignment', 'Bottom', 'HorizontalAlignment', 'Center');
        set(h(2),'Position',[730 270 0],'FontSize',fontsize2print);
        % pie plot for porcentage of subjects
        X1 = [dPie 100-dPie];
        %h = pie(X);
        %explode = [1 0];
        h1 = pie(X1);
        %Move to xpos,ypos and rescale by scale
        xpos = 900;
        ypos = 150;
        scale = 70;
        for k = 1:length(h1) % Walk the vector of text and patch handles
              if strcmp(get(h1(k),'Type'),'patch') % Patch graphics
                  XData = get(h1(k),'XData');  % Extract current data
                  YData = get(h1(k),'YData');
                  set(h1(k),'XData',XData*scale + xpos); % Insert modified data
                  set(h1(k),'YData',YData*scale + ypos);
              else % Text labels
                  set(h1(k),'FontSize',fontsize2print);
                  
              end
        end
        h1(1).FaceColor = [0.7 0.7 0.7];
        h1(3).FaceColor = [0.9999 0.9999 0.9999];
        h1(4).String = '';
        % Adjust text label alignment
        tobj = findobj(h1,'type','text'); 
        set(tobj, 'VerticalAlignment', 'Bottom', 'HorizontalAlignment', 'Center');
        set(h1(2),'Position',[730 105 0]);
        h1(2).String = txt2;
        h1(1).LineWidth = 1;
        h1(3).LineWidth = 1;
        % Data for violinplots
        stream2stream(idsp-1) = {tableRes.(Pathtarget).(thisPath).tRDi*1000};
    end
end

%% Violin plot
toPlot = [4; 5; 6; 10; 11; 12; 16; 17; 18; 22; 23; 24];

color2violin = [[0.6350 0.0780 0.1840];...
    [0.8500 0.3250 0.0980];...
    [0.3010 0.7450 0.9330];...
    [0.6350 0.0780 0.1840];...
    [0.9290 0.6940 0.1250];...
    [0.4940 0.1840 0.5560];...
    [0.8500 0.3250 0.0980];...
    [0.9290 0.6940 0.1250];...
    [0.4660 0.6740 0.1880];...
    [0.3010 0.7450 0.9330];...
    [0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880]];

for i = 1:length(toPlot)
    p = subplot(8,3,toPlot(i));
    violinplot(stream2stream(i),1,'ViolinColor',color2violin(i,:), 'ShowMean', true, 'ShowMedian', false, 'ShowBox', false, 'ShowWhiskers', false,'MarkerSize',15);
    ylim([0, 1000]);
    yticks(0:400:1000)
    xticklabels([])
    view([90 90]);
    p.Position(4) = .03;
    p.LineWidth = 1;
    ylabel('time (ms)','FontSize',fontsize2print);
    xlabel('tR','FontSize',fontsize2print,'HorizontalAlignment','right');
    set(get(gca,'xlabel'),'rotation',0,'VerticalAlignment','middle')
    set(gca,'fontsize',fontsize2print)
    box off
    if ismember(i,[1:3])
        p.Position(2) = .817; 
    elseif ismember(i,[4:6])
        p.Position(2) = .605;
    elseif ismember(i,[7:9])
        p.Position(2) = .395;
    elseif ismember(i,[10:12])
        p.Position(2) = .183;
    end
end

