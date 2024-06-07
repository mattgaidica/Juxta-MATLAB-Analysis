logsDataFolder = '/Users/gaidica/Library/CloudStorage/Box-Box/Neurotech Hub/Projects/Gaidica Lab/Juxta/Mengxiao Data/Data_Juxta_meta';
metaDataFolder = '/Users/gaidica/Library/CloudStorage/Box-Box/Neurotech Hub/Projects/Gaidica Lab/Juxta/Mengxiao Data/Data_Juxta_Trim_meta';
tagDataFile = '/Users/gaidica/Library/CloudStorage/Box-Box/Neurotech Hub/Projects/Gaidica Lab/Juxta/Mengxiao Data/Vole_Data_from_Toledo.xlsx';

T = readtable(tagDataFile);
%%
% Convert 'Sex' to numeric values
% Add jitter to the Sex_numeric values
jitter_amount = 0.1; % Adjust this value as needed
Sex_jittered = Sex_numeric + (rand(size(Sex_numeric)) - 0.5) * jitter_amount;

% Plotting with jitter
figure;
scatter(T.DOB, Sex_jittered, 20, 'filled'); % 'o' for dot markers
xlabel('Date of Birth');
ylabel('Sex');
yticks([1 2]);
yticklabels({'Male', 'Female'});
ylim([0.5 2.5]); % Adjusted ylim to accommodate jitter


%%
% Bin edges in 7-day increments
bin_edges = min(T.DOB):days(7):max(T.DOB);

% Histogram counts for males
male_counts = histcounts(T.DOB(strcmp(T.Sex, 'M')==0), bin_edges);

% Histogram counts for females
female_counts = histcounts(T.DOB(strcmp(T.Sex, 'F')==0), bin_edges);

% Plotting
figure;
bar(bin_edges(1:end-1), [male_counts; female_counts]');
xlabel('Date of Birth');
ylabel('Count');
legend({'Male', 'Female'});
