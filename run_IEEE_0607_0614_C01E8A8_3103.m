dataPath = '/Users/mattgaidica/Documents/MATLAB/Juxta/Vole 2023 - Mengxiao/Data_Juxta_Trim';
logsFile = fullfile(dataPath,'0505_0514_88BD95B_2DA8_trim_TrappedDead.txt');
metaFile = fullfile(dataPath,'0505_0514_88BD95B_2DA8_meta_trim_TrappedDead.txt');

% logsFile = fullfile(dataPath,'0505_0514_C01E8C8_2DD4_trim_TrappedDead.txt');
% metaFile = fullfile(dataPath,'0505_0514_C01E8C8_2DD4_meta_trim_TrappedDead.txt');

% logsFile = '/Users/mattgaidica/Dropbox (University of Michigan)/VoleFieldwork2023/Data/Data_Biologger/0607_0614_C01E8A8_3103.txt';
% metaFile = '/Users/mattgaidica/Dropbox (University of Michigan)/VoleFieldwork2023/Data/Data_Biologger/0607_0614_C01E8A8_3103_meta.txt';

Meta = readtable(metaFile);
Logs = readtable(logsFile,'Delimiter',',');

t_logs = [];
if ~isempty(Logs)
    [t_logs,ids_logs] = convertJxTime(Logs,"");
    [uniqueTheirMac,~,y] = unique(Logs.their_mac(ids_logs));
    occurrences = histcounts(categorical(Logs.their_mac(ids_logs)),categorical(uniqueTheirMac));
    [~, sortedIdx] = sort(occurrences, 'descend');
    sortedUniqueTheirMac = uniqueTheirMac(sortedIdx);
    unique_colors = parula(numel(uniqueTheirMac)+3);
    y_labels = cellstr(sortedUniqueTheirMac);
    circle_sizes = rescale(-Logs.rssi(ids_logs).^4,10,300);

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
fs = 12;
close all;
rows = 2;
cols = 1;
ff(600,450);

subplot(rows,cols,1);
% bar(xlTimestamps,xlCount,'facecolor','k','facealpha',0.5);
plot(xlTimestamps,smoothdata(normalize(xlCount),'gaussian',3),'k-','linewidth',3);
xlim([min(xlTimestamps),max(xlTimestamps)]);
ylabel('XL (norm)');
set(gca,'ycolor','k');
ylim([-2 2]);
set(gca,'fontsize',fs);
set(gca, 'FontName', 'Monospaced');

yyaxis right;
plot(t_deg_c,smoothdata(Meta.data_value(ids_deg_c),'gaussian',10),'color','r','linewidth',lw);
xlim([min(t_all),max(t_all)]);
ylabel('Temp (C)');
set(gca,'ycolor','r');
grid on;
hold on;
title("XL & Temp")
xlim([t_logs(1),t_logs(end)]);
set(gca,'fontsize',fs);
set(gca, 'FontName', 'Monospaced');

subplot(rows,cols,2);
scatter(t_logs,y,circle_sizes,unique_colors(y,:),'filled');
set(gca,'YTick',1:numel(uniqueTheirMac),'YTickLabel',y_labels);
xlim([t_logs(1),t_logs(end)]);
title("Their MAC RSSI");
grid on;
set(gca,'fontsize',fs);
set(gca, 'FontName', 'Monospaced');

% manual label
x = datetime(2023,06,09,14,59,26,'timezone','local');
text(x,1,"-77dB  ",'FontSize',fs,'fontname','monospaced','HorizontalAlignment','right','color',unique_colors(1,:));

x = datetime(2023,06,10,02,30,12,'timezone','local');
text(x,2,"-91dB  ",'FontSize',fs,'fontname','monospaced','HorizontalAlignment','right','color',unique_colors(2,:));

x = datetime(2023,06,10,1,30,02,'timezone','local');
text(x,3,"-85dB  ",'FontSize',fs,'fontname','monospaced','HorizontalAlignment','right','color',unique_colors(3,:));
% saveas(gcf,'JuxtaIEEE_DataFigure.png');