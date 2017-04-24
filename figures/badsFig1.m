% Make Figure 1 for BADS whitepaper

figure(1); clf;
currentDir = pwd();

% Folder that contains benchmark data
datafolder = 'C:\Users\Luigi\Dropbox\Postdoc\BenchMark\data';

grid = [1 1 1 3 2 2 2];
% grid = [1 1 1 2 2 2 3 3 3 4];
hg = plotify(grid,'Margins',[0.05 0.05 0.15 0.1],'Gutter',0.075,'FontSize',18);

cd([datafolder filesep 'bbob09']);
% load('benchdata_1.mat');

axes(hg(1));
benchmark_summaryplot(benchdata1);
title('BBOB09 noiseless');

%axes(hg(2));
%benchdata2.options.Method = 'FST';
%benchmark_summaryplot(benchdata2);

axes(hg(2));
title('BBOB09 with heteroskedastic noise');
benchdata3.options.Method = 'FST';
benchdata3.options.FunEvalsPerD = [];
benchmark_summaryplot(benchdata3);

axes(hg(3));
axis off;

set(gcf,'Position',[1 241 1920 720]);


cd(currentDir);


