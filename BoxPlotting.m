
clear;
close all;

CaseNs = [ Add the case Names in string ];

FolderN = Folder Name; 
Xtick =  {'5+2 Extremes','7+2 Extremes','9+2 Extremes','11+2 Extremes'}; 
% Xtick =  {'5+1 Extreme','7+1 Extreme','9+1 Extreme','11+1 Extreme'}; 
for i  = 4
    caseName = CaseNs(i);
    matFile  = fullfile(FolderN, caseName + ".mat");
    load(matFile);   % loads RC90_5, RL90_5, ...

    % Plot and get figure handle

hFig = Boxplot( RC90_5, RL90_5, RC95_5, RL95_5, ...   % 15
    RC90_7, RL90_7, RC95_7, RL95_7, ...   % 20
    RC90_9, RL90_9, RC95_9, RL95_9, ...   % 25
    RC90_11, RL90_11, RC95_11, RL95_11,Xtick );      % 30


    % Build base save path (no extension)
    base = fullfile(FolderN, caseName);

    % % Save editable .fig
    % savefig(hFig, base + ".fig");
    % 
    % % Save high-res PNG (600 DPI)
    % exportgraphics(hFig, base + ".png", 'Resolution', 600, 'BackgroundColor', 'white');

    % close(hFig);   % close only the figure you created
end
