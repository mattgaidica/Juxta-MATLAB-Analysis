function [Logs,Meta] = reviewData(logsFile,metaFile,~)

Logs = [];
if ~isempty(logsFile)
    Logs = readtable(logsFile,'Delimiter',',');
end
Meta = [];
if ~isempty(metaFile)
    Meta = readtable(metaFile);
end

if nargin == 3
    return;
end

t_logs = [];
if ~isempty(Logs)
    [t_logs,ids_logs] = convertJxTime(Logs,"");
    [uniqueTheirMac,~,y] = unique(Logs.their_mac(ids_logs));
    occurrences = histcounts(categorical(Logs.their_mac(ids_logs)),categorical(uniqueTheirMac));
    [~, sortedIdx] = sort(occurrences, 'descend');
    sortedUniqueTheirMac = uniqueTheirMac(sortedIdx);
    unique_colors = parula(numel(uniqueTheirMac));
    y_labels = cellstr(sortedUniqueTheirMac);
    circle_sizes = rescale(-Logs.rssi(ids_logs).^2,20,100);

    % Group the table rows by their_mac and assign a color to each group
    color_map = lines(numel(uniqueTheirMac));
    colors = color_map(y,:);
end

t_all = [];
if ~isempty(Meta)
    [t_vbatt,ids_vbatt] = convertJxTime(Meta,"vbatt");
    [t_deg_c,ids_deg_c] = convertJxTime(Meta,"deg_c");
    [t_sync,ids_sync] = convertJxTime(Meta,"tsync");
    
    [t_xl,ids_xl] = convertJxTime(Meta,"xl");
    
    t_all = convertJxTime(Meta,"");
    if ~isempty(t_logs)
        t_all = unique(sort([t_all;t_logs])); % debug this case
    end
    minTime = min(t_all);
    maxTime = max(t_all);
    if maxTime - minTime > hours(1)
        xlTimestamps = minTime:hours(1):maxTime;
    else
        xlTimestamps = minTime:minutes(1):maxTime;
    end
    xlCount = zeros(size(xlTimestamps));
    for i = 1:numel(xlTimestamps)-1
        xlCount(i) = 100 * sum(find(ids_xl) & t_xl >= xlTimestamps(i) & t_xl < xlTimestamps(i+1)) / 60;
    end
end

lw = 1;
fs = 14;
% close all;
rows = 2;
cols = 2;
figure('position',[0,0,1400,600]);

if ~isempty(t_all)
    if ~isempty(logsFile)
        [~,logsName] = fileparts(logsFile);
    else
        logsName = '';
    end
    subplot(rows,cols,1);
    plot(t_vbatt,Meta.data_value(ids_vbatt),'color','w','linewidth',lw);
    title(sprintf("%s\n%1.1f hours (%1.2f days) runtime",...
        logsName,hours(max(t_vbatt) - min(t_vbatt)),days(max(t_vbatt) - min(t_vbatt))),...
        'interpreter','none');
    ylabel('Vbatt (V)');
    set(gca,'ycolor','w');
    hold on;
    lineColors = lines(5);
    for i = 1:numel(t_sync)
        xline(t_sync(i),'color',lineColors(5,:),'LineWidth',5);
        if i == 1
            text(t_sync(i),mean(ylim)," \leftarrow Time Synced",'fontsize',fs,'color',lineColors(5,:));
        end
    end
    xlim([min(t_all),max(t_all)]);
    ylim([2.8 4.1]);
    grid on;

    subplot(rows,cols,3);
    bar(xlTimestamps,xlCount,'facecolor','w','facealpha',0.5);
    xlim([min(xlTimestamps),max(xlTimestamps)]);
    ylabel('XL (%)');
    set(gca,'ycolor','w');
    
    yyaxis right;
    plot(t_deg_c,Meta.data_value(ids_deg_c),'color','r','linewidth',lw);
    xlim([min(t_all),max(t_all)]);
    ylabel('Temp (C)');
    set(gca,'ycolor','r');
    grid on;
    hold on;
    title("XL & Temp")
end

if ~isempty(t_logs)
    subplot(rows,cols,[2,4]);
    scatter(t_logs,y,circle_sizes,unique_colors(y,:),'filled');
    set(gca,'YTick',1:numel(uniqueTheirMac),'YTickLabel',y_labels);
    if isempty(t_all)
        xlim([t_logs(1),t_logs(end)]);
    else
        xlim([min(t_all),max(t_all)]);
    end
    title("Their MAC");
    grid on;
end