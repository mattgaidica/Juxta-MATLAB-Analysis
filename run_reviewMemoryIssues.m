dataPath = '/Users/mattgaidica/Downloads/3105_data.txt';
Data = readtable(dataPath,'Delimiter',',');
%%
integers = Data.local_time(1261:end);
integers = Data.local_time;

% Determine the number of integers
numIntegers = size(integers, 1);

% Initialize the binary array
binaryArray = false(numIntegers, 32);

% Convert each integer to its binary representation
for i = 1:numIntegers
    binaryString = dec2bin(integers(i), 32);
    binaryArray(i, :) = binaryString == '1';
end


% close all;
ff(600,500);
imagesc(binaryArray);
% set(gca,'YDir','normal');
colormap(gray)