cd /Users/mattgaidica/Documents/MATLAB/misc/Juxta

% dataPath = '/Users/mattgaidica/Dropbox (University of Michigan)/VoleFieldwork2023/Data/Data_Biologger';
dataPath = '/Users/mattgaidica/Dropbox (University of Michigan)/VoleFieldwork2023/Data/Data_BaseStation';

savePath = '/Users/mattgaidica/Dropbox (University of Michigan)/VoleFieldwork2023/Data/Data_Analysis';

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
doSave = 1;
clc
usedIds = [];
for ii = 1:numel(fnames)
    fileBase = strsplit(fnames{ii},'_');
    fileBase = strjoin(fileBase(1:4),'_');
    ids = find(contains(fnames,fileBase));
    if numel(ids) > 1 && ~any(ismember(ids,usedIds)) % has both entries, skip ones that are done
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
        saveFile = fullfile(savePath,[fnames{logs_id},'.png']);
        fprintf("%s\n%s\n",logsFile,metaFile);
        if isfile(saveFile)
            fprintf("--exists, skipping\n\n");
        else
            [Logs,Meta] = reviewData(logsFile,metaFile);
            if doSave && ~isempty(Logs)
                saveas(gcf,saveFile);
                close(gcf);
                fprintf("--saved!\n");
            end
        end
    end
end