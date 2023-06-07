clc

fileID = fopen('/Users/mattgaidica/Downloads/TIdata.dat', 'r');
data = textscan(fileID, '%s');
fclose(fileID);

data = data{1};  % Extract the data from the cell array

numLines = numel(data);
numCols = 13;
numRows = ceil(numLines / numCols);

% Pad the data with empty strings if necessary
numExtraRows = numRows * numCols - numLines;
data = [data; repmat({''}, numExtraRows, 1)];

% Reshape the data matrix
dataMatrix = reshape(data, numCols, numRows).';
dataMatrix = string(dataMatrix);  % Convert to string format

disp(dataMatrix);

writematrix(dataMatrix,'dataMatrix.csv');
