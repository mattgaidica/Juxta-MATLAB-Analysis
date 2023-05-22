dataPath = '/Users/mattgaidica/Dropbox (University of Michigan)/VoleFieldwork2023/Data/Data_Biologger copy';

txtFiles = dir2(dataPath,'*.txt');
fnames = {};
jj = 0;
for ii = 1:size(txtFiles)
    [~,name,~] = fileparts(txtFiles(ii).name);
    if name(1) ~= '.' && ~contains(name,'meta') && ~contains(name,'debug')
        jj = jj + 1;
        fnames{jj,1} = txtFiles(ii).name; %#ok<SAGROW>, rm .txt
    end
end

for ii = 1:numel(fnames)
    fprintf("%i/%i\n",ii,numel(fnames));
    Logs = readtable(fullfile(dataPath,fnames{ii}),'Delimiter',',','TreatAsEmpty','');
    Logs.subject = string(Logs.subject);
    for iRow = 1:height(Logs)
        % Split the MAC address into individual hex values
        hexValues = split(Logs.my_mac{iRow}, ':');
        % Loop through each hex value and pad with a leading zero if necessary
        for i = 1:numel(hexValues)
            if numel(hexValues{i}) < 2
                hexValues{i} = ['0' hexValues{i}];
            end
        end
        % Join the hex values back together with colons
        Logs.my_mac{iRow} = strjoin(hexValues, ':');

        hexValues = split(Logs.their_mac{iRow}, ':');
        % Loop through each hex value and pad with a leading zero if necessary
        for i = 1:numel(hexValues)
            if numel(hexValues{i}) < 2
                hexValues{i} = ['0' hexValues{i}];
            end
        end
        % Join the hex values back together with colons
        Logs.their_mac{iRow} = strjoin(hexValues, ':');

        if ismissing(Logs.subject(iRow))
            Logs.subject(iRow) = '';
        end
    end
    writetable(Logs,fullfile(dataPath,fnames{ii}),'Delimiter',',');
end