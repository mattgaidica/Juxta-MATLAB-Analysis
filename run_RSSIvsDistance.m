j1path = '/Users/mattgaidica/Dropbox (University of Michigan)/VoleFieldwork2023/Data/Tests_RSSI_Dist/Animal_Animal/2DF3.csv';
j2path = '/Users/mattgaidica/Dropbox (University of Michigan)/VoleFieldwork2023/Data/Tests_RSSI_Dist/Animal_Animal/2DDE.csv';

j1data = readtable(j1path,'Delimiter',',');
j2ids = find(strcmp(j1data.their_mac,'6C:B2:FD:CE:2D:DE'));
j2RSSI = j1data.rssi(j2ids);

j2data = readtable(j2path,'Delimiter',',');
j1ids = find(strcmp(j2data.their_mac,'6C:B2:FD:CE:2D:F3'));
j1RSSI = j2data.rssi(j1ids);

close all
ff(400,300);
plot(j2RSSI,'LineWidth',2);
hold on;
plot(j1RSSI,'LineWidth',2);
grid on;
legend({'2DDE RSSI','2DF3 RSSI'})
xlabel('sample');
ylabel('RSSI');
set(gca,'FontSize',14);
title('RSSI vs. Sample (2DF3-2DDE)');
saveas(gcf,'RSSIvsSample_2DF3-2DDE.jpg');

%%
figure;
% Reference power or signal intensity
P = 1.0;

% Distance range
distance = linspace(1, 10, 100);

% Calculate signal intensity using inverse-square law
signal_intensity = P ./ (4 * pi * distance.^2);

% Plotting
plot(distance, signal_intensity);
xlabel('Distance');
ylabel('Signal Intensity');
title('Signal Intensity vs Distance');
grid on;
