dataPath = '/Users/mattgaidica/Documents/MATLAB/Juxta/Vole 2023 - Mengxiao/Data_Juxta_Trim';

txtFiles = dir2(dataPath,'*.txt');
% remove hidden files
fnames = {};
jj = 0;
for ii = 1:size(txtFiles)
    [~,name,~] = fileparts(txtFiles(ii).name);
    if name(1) ~= '.'
        jj = jj + 1;
        fnames{jj,1} = txtFiles(ii).name(1:end-4); %#ok<SAGROW>, rm .txt
    end
end
%
clc

usedIds = [];
all_my_mac = [];
all_their_mac = [];
all_files = [];
for ii = 1:numel(fnames)
    fileBase = strsplit(fnames{ii},'_');
    fileBase = strjoin(fileBase(1:4),'_');
    ids = find(contains(fnames,fileBase));
    if numel(ids) > 1 && ~any(ismember(ids,usedIds)) && all(fileBase(1:4) == '0505') % has both entries, skip ones that are done
        usedIds = [usedIds;ids]; %#ok<AGROW> 
        if contains(fnames{ii},'_meta')
            meta_id = ii;
            logs_id = ids(ids ~= ii);
        else
            logs_id = ii;
            meta_id = ids(ids ~= ii);
        end
        logsFile = fullfile(dataPath,[fnames{logs_id},'.txt']);
        metaFile = fullfile(dataPath,[fnames{meta_id},'.txt']);
        fprintf("%s\n%s\n",logsFile,metaFile);

        [Logs,Meta] = reviewData(logsFile,metaFile,true);
        all_my_mac = [all_my_mac; Logs.my_mac];
        all_their_mac = [all_their_mac; Logs.their_mac];
        all_files = [all_files; repmat({logsFile}, size(Logs.my_mac))]; % Associate each my_mac with logsFile
    end
end
compiled_data = table(all_my_mac, all_their_mac, all_files, 'VariableNames', {'my_mac', 'their_mac', 'file'});

%% 
logsFile = '0505_0515_C01E8A1_2DB5_trim.txt';
metaFile = '0505_0515_C01E8A1_2DB5_meta_trim.txt';
fragment = '2D:B5';
% fragment = '2D:D4';
% fragment = '2D:F5';

% Get all unique MAC addresses
all_macs = unique([compiled_data.my_mac; compiled_data.their_mac]);

% Create a map to associate each MAC address with a unique index
mac_to_index = containers.Map(all_macs, 1:length(all_macs));

% Initialize the adjacency matrix
adj_matrix = zeros(length(all_macs));

% Populate the adjacency matrix
for i = 1:height(compiled_data)
    row = mac_to_index(compiled_data.my_mac{i});
    col = mac_to_index(compiled_data.their_mac{i});
    adj_matrix(row, col) = adj_matrix(row, col) + 1;  % Increment the count for this relationship
end

% If you want the matrix to be symmetric (for undirected relationships)
adj_matrix = adj_matrix + adj_matrix';

close all
% circularGraph(adj_matrix,'Label',all_macs);
myColorMap = parula(length(all_macs));

% Find all MAC addresses that end with the specified fragment
matching_macs = all_macs(endsWith(all_macs, fragment));
match_index = mac_to_index(matching_macs{1});
LineMask = zeros(1,length(all_macs));
LineMask(match_index) = 1;
circularGraph(adj_matrix,'Colormap',myColorMap,'Label',compose('V%02d',1:length(all_macs)),'LineMask',LineMask);
print(gcf, 'resubmit_adjacencyMatrix.eps', '-depsc', '-painters');


%%

[Logs,Meta] = reviewData(fullfile(dataPath,logsFile),fullfile(dataPath,metaFile),false);
disp(match_index);

t_logs = [];
if ~isempty(Logs)
    [t_logs,ids_logs] = convertJxTime(Logs,"");
    [uniqueTheirMac,~,y] = unique(Logs.their_mac(ids_logs));
    occurrences = histcounts(categorical(Logs.their_mac(ids_logs)),categorical(uniqueTheirMac));
    [~, sortedIdx] = sort(occurrences, 'descend');
    sortedUniqueTheirMac = uniqueTheirMac(sortedIdx);
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
    nMinuteBins = 20;
    xlTimestamps = minTime:minutes(nMinuteBins):maxTime;
    xlCount = zeros(1,length(xlTimestamps)-1);
    for i = 1:numel(xlTimestamps)-1
        xlCount(i) = sum(find(ids_xl) & t_xl >= xlTimestamps(i) & t_xl < xlTimestamps(i+1)) / nMinuteBins;
    end
end

lw = 3;
fs = 12;
close all;
rows = 8;
cols = 1;
ff(450,600);
nSmooth = 1;
capLogsAt = 470;

subplot(rows,cols,1:3);
bar(xlTimestamps(1:end-1),xlCount,'facecolor','k','facealpha',0.75,'EdgeColor','w');
% plot(xlTimestamps(1:end-1),smoothdata(xlCount,'gaussian',nSmooth),'k-','linewidth',lw);
xlim([min(xlTimestamps),max(xlTimestamps)]);
ylabel('XL (norm)');
set(gca,'ycolor','k');
% ylim([-2 2]);
% ylim([0 1]);
set(gca,'fontsize',fs);
% set(gca, 'FontName', 'Monospaced');

yyaxis right;
plot(t_deg_c,smoothdata(Meta.data_value(ids_deg_c),'gaussian',nSmooth),'color','r','linewidth',lw);
xlim([min(t_all),max(t_all)]);
ylabel('Temp (C)');
set(gca,'ycolor','r');
grid on;
hold on;
title(sprintf("XL & Temp for V%02d",match_index));
xlim([t_logs(1),t_logs(capLogsAt)]);
set(gca,'fontsize',fs);
% set(gca, 'FontName', 'Monospaced');

% remake labels
MAC_idx = [];
for ii = 1:length(sortedUniqueTheirMac)
    MAC_idx(ii) = mac_to_index(sortedUniqueTheirMac{ii});
end
y_labels = compose("V%02d",MAC_idx);
[~,k] = sort(MAC_idx,'descend');
unique_colors = myColorMap(MAC_idx(k),:);

% Extract unique y-values and create a mapping to new y-values based on k
[y_unique, ~, idx] = unique(y);
new_y_values = y_unique(k);

% Remap the original y-values to the new y-values
y_remapped = new_y_values(idx);

subplot(rows,cols,5:8);
scatter(t_logs, y_remapped, circle_sizes, unique_colors(y_remapped), 'filled');
set(gca,'YTick',1:numel(uniqueTheirMac),'YTickLabel',y_labels(k));
xlim([t_logs(1),t_logs(capLogsAt)]);
title("Other Vole's RSSI");
grid on;
set(gca,'fontsize',fs);
% set(gca, 'FontName', 'Monospaced');
print(gcf, 'resubmit_XL-MAC.eps', '-depsc', '-painters');

% manual label
% x = datetime(2023,06,09,14,59,26,'timezone','local');
% text(x,1,"-77dB  ",'FontSize',fs,'fontname','monospaced','HorizontalAlignment','right','color',unique_colors(1,:));
% 
% x = datetime(2023,06,10,02,30,12,'timezone','local');
% text(x,2,"-91dB  ",'FontSize',fs,'fontname','monospaced','HorizontalAlignment','right','color',unique_colors(2,:));
% 
% x = datetime(2023,06,10,1,30,02,'timezone','local');
% text(x,3,"-85dB  ",'FontSize',fs,'fontname','monospaced','HorizontalAlignment','right','color',unique_colors(3,:));
