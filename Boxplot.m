

function hFig = Boxplot(RC90_5,RL90_5,RC95_5,RL95_5, ...
    RC90_10,RL90_10,RC95_10,RL95_10, ...
    RC90_15,RL90_15,RC95_15,RL95_15, ...
    RC90_20,RL90_20,RC95_20,RL95_20, Xtick)

% --- positions ---
G=4; BoxesPerGroup=4; startX=1.0; step=0.25; gap=0.25;
positions = make_positions(G, BoxesPerGroup, startX, step, gap);

% --- data (ensure column) ---
X = [RC90_5';RL90_5';RC95_5';RL95_5'; ...
    RC90_10';RL90_10';RC95_10';RL95_10'; ...
    RC90_15';RL90_15';RC95_15';RL95_15'; ...
    RC90_20';RL90_20';RC95_20';RL95_20'];
X = X(:);

% --- groups ---
group10  = [1*ones(1,length(RC90_5)),  2*ones(1,length(RL90_5)), ...
    3*ones(1,length(RC95_5)),  4*ones(1,length(RL95_5))];
group25  = [7*ones(1,length(RC90_10)), 8*ones(1,length(RL90_10)), ...
    9*ones(1,length(RC95_10)),10*ones(1,length(RL95_10))];
group50  = [13*ones(1,length(RC90_15)),14*ones(1,length(RL90_15)), ...
    15*ones(1,length(RC95_15)),16*ones(1,length(RL95_15))];
group100 = [19*ones(1,length(RC90_20)),20*ones(1,length(RL90_20)), ...
    21*ones(1,length(RC95_20)),22*ones(1,length(RL95_20))];
group = [group10 group25 group50 group100];

% --- figure & base boxplot ---
hFig = figure('Color','w','Units','inches','Position',[0.5 0.5 7.2 4]);
set(hFig,'Renderer','painters');

hB = boxplot(X, group, 'positions', positions, 'Colors','k', 'Symbol','');
lw = 1.5;
set(hB,'LineWidth',lw);
set(gca,'FontSize',10,'FontWeight','bold','FontName','Times');
ylim([-2 15]);




set(gcf, 'Renderer', 'opengl');   % optional, helps with layering

h = findobj(gca,'Tag','Box');   % boxes returned in reverse order

% -----------------------------
% Style 1: hatch blue (single)
% -----------------------------
for j = [1,5,9,13]
    hP = patch(get(h(j),'XData'), get(h(j),'YData'), 'b', ...
        'FaceAlpha', 1, 'EdgeColor', 'none');
    hold on
    try
        hh = hatchfill(hP, 'single', 60, 2, 'none', 'w');  % blue hatch lines
        set(hP, 'FaceColor', 'b', 'FaceAlpha', 1);         % restore blue fill
    catch
    end
end

% -----------------------------
% Style 2: blue cross-hatch (was "solid")
% -----------------------------
for j = [2,6,10,14]
    hP = patch(get(h(j),'XData'), get(h(j),'YData'), 'b', ...
        'FaceAlpha', 1, 'EdgeColor', 'none');
    hold on
    try
        hh = hatchfill(hP, 'cross', 135, 2, 'none', 'w');   % cross hatch in blue
        set(hP, 'FaceColor', 'b', 'FaceAlpha', 1);         % restore blue fill
    catch
    end
end

% -----------------------------
% Style 3: hatch red (single)
% -----------------------------
for j = [3,7,11,15]
    hP = patch(get(h(j),'XData'), get(h(j),'YData'), 'r', ...
        'FaceAlpha', 1, 'EdgeColor', 'none');
    hold on
    try
        hh = hatchfill(hP, 'single', 60, 2, 'none', 'w');  % red hatch lines
        set(hP, 'FaceColor', 'r', 'FaceAlpha', 1);         % restore red fill
    catch
    end
end

% -----------------------------
% Style 4: red cross-hatch (was "solid")
% -----------------------------
for j = [4,8,12,16]
    hP = patch(get(h(j),'XData'), get(h(j),'YData'), 'r', ...
        'FaceAlpha', 1, 'EdgeColor', 'none');
    hold on
    try
        hh = hatchfill(hP, 'cross', 135, 2, 'none', 'w');   % cross hatch in red
        set(hP, 'FaceColor', 'r', 'FaceAlpha', 1);         % restore red fill
    catch
    end
end

% Re-draw boxplot outlines on top
h = boxplot(X, group, 'positions', positions, 'Colors', 'k', 'Symbol', '');
set(h, 'LineWidth', lw);


% --- redraw outlines on top (DO NOT overwrite hBoxes variable) ---
% hB2 = boxplot(X, group, 'positions', positions, 'Colors','k', 'Symbol','');
% set(hB2,'LineWidth',lw);

% --- ticks & labels ---
set(gca,'XTick',[1.375, 2.625, 3.875, 5.125], 'XTickLabel',Xtick);
ylabel('\bf{PAR}','FontSize',10,'FontWeight','bold','FontName','Times');
xlabel('Sample Size','FontSize',10,'FontWeight','bold','FontName','Times');

% --- white medians & reference lines ---
set(findobj(gcf,'Type','line','Tag','Median'),'Color','w');
line([2, 2], ylim, 'Color','k','LineWidth',0.5,'LineStyle','--');
line([3.25,3.25], ylim, 'Color','k','LineWidth',0.5,'LineStyle','--');
line([4.5, 4.5], ylim, 'Color','k','LineWidth',0.5,'LineStyle','--');
line(xlim, [1,1], 'Color','k','LineWidth',lw,'LineStyle','-.')

%ylim([-0.75,7.35]);    % final y-limit
ylim([-0.5,3.5]); 

% --- Legend (fixed, color-only) ---
% legendLabels = { ...
%     'C-moment - ', ...
%     'Blue — cross hatch', ...
%     'Red  — single hatch', ...
%     'Red  — cross hatch' };


legendLabels = { ...
    'C-moment (P_S(0.90))', ...
    'L-moment (P_S(0.90))', ...
    'C-moment (P_S(0.95))', ...
    'L-moment (P_S(0.95))' };


legendColors = { 'b', 'b', 'r', 'r' };

% Get or create the Ideal line handle (you already draw it above)
% If you want it included, capture the handle at draw-time:
% hIdeal = line(xlim, [1,1], 'Color','k','LineWidth',lw,'LineStyle','-.');

% Re-find the ideal line handle if needed:
hIdeal = findobj(gca, 'Type','line', 'LineStyle','-.', 'Color','k', '-and', 'LineWidth', lw);
if isempty(hIdeal)
    % Fallback if not found (optional)
    hIdeal = line(xlim, [1,1], 'Color','k','LineWidth',lw,'LineStyle','-.');
end

make_fixed_legend(gca, legendLabels, legendColors, hIdeal, 'northeast');


hold off;

end



function hLeg = make_fixed_legend(ax, legendLabels, colors, hIdeal, location)
%MAKE_FIXED_LEGEND Build a compact, fixed, color-only legend with uniform text color.
%
% hLeg = make_fixed_legend(ax, legendLabels, colors, hIdeal, location)
%
% Inputs:
%   ax           : target axes
%   legendLabels : cellstr for legend entries (N items)
%   colors       : cell array of N color specs ('b','r',[r g b], etc.)
%   hIdeal       : handle to "Ideal" line (optional, [] to omit)
%   location     : legend location (default 'northeast')
%
% Output:
%   hLeg         : legend handle

    if nargin < 5 || isempty(location), location = 'northeast'; end
    N = numel(legendLabels);
    hProxy = gobjects(N,1);

    % Tiny, off-plot patches so the tokens show color but don't clutter axes
    xsq = [-1 -1 -0.5 -0.5];
    ysq = [-1 -0.5 -0.5 -1];

    for k = 1:N
        hProxy(k) = patch('XData', xsq, 'YData', ysq, ...
                          'FaceColor', colors{k}, ...
                          'EdgeColor', 'k', ...
                          'Parent', ax, ...
                          'Visible', 'off', ...
                          'HandleVisibility', 'on');
        a = get(hProxy(k), 'Annotation');
        if isfield(a, 'LegendInformation')
            a.LegendInformation.IconDisplayStyle = 'on';
        end
    end

    items  = hProxy;
    labels = legendLabels(:);

    % Append Ideal if provided
    if ~isempty(hIdeal) && isgraphics(hIdeal)
        items  = [items; hIdeal];
        labels = [labels; {'Ideal'}];
    end

    % Build legend
    hLeg = legend(ax, items, labels, ...
        'Location', location, ...
        'Box', 'on');
    hLeg.TextColor = 'k'; %[0 0 0]; 
    % --- Compact, small-box styling ---
    set(hLeg, 'AutoUpdate', 'off');        % prevent changes on future plots
    set(hLeg, 'FontSize', 12);              % smaller text
    set(hLeg, 'ItemTokenSize', [8, 8]);    % smaller color boxes
    set(hLeg, 'Orientation', 'vertical');  % keep compact vertically
    
    % % Uniform text color (all entries same color)
    % if isprop(hLeg, 'TextColor')
    %     hLeg.TextColor = [0 0 0];          % black text for all legend strings
    % end

    % Optional: tidy box appearance (consistent small box)
    if isprop(hLeg, 'Color')
        hLeg.Color = [1 1 1];              % white background
    end
    if isprop(hLeg, 'EdgeColor')
        hLeg.EdgeColor = [0 0 0];          % black border
    end
end







function hPanelAx = draw_hatch_legend_panel(parentAx, legendLabels, colors, hatches, posPixels, varargin)
%DRAW_HATCH_LEGEND_PANEL Create a custom legend panel that shows hatched boxes.
%
% hPanelAx = draw_hatch_legend_panel(parentAx, legendLabels, colors, hatches, posPixels, ...)
%
% Inputs:
%   parentAx     : handle to the main plot axes (for figure parent)
%   legendLabels : cellstr, N items
%   colors       : cellstr or Nx3, colors for each item (e.g., {'b','b','r','r'})
%   hatches      : cellstr, hatch token for each item (e.g., {'/','x','/','x'} or {'////','xxxx',...})
%   posPixels    : [x y w h] in figure pixel units where the panel should be drawn
%
% Name-Value:
%   'LineColor'    : hatch line color (default 'w')
%   'HatchAngle'   : angle for '/' (default 60)
%   'HatchDensity' : lines per axis unit (default 40)
%   'LineWidth'    : hatch line width (default 1.0)
%   'FontName'     : legend font (default 'Times')
%   'FontSize'     : legend font size (default 12)
%   'IdealLabel'   : char label to add at bottom (e.g., 'Ideal') or '' to skip (default '')
%
% Output:
%   hPanelAx : handle to the inset legend axes
%
% Notes:
% - Uses a separate axes so the hatch lines are drawn and visible exactly as in the main plot.
% - It’s not a built-in legend; it’s a visual panel that functions like a legend.
%

    p = inputParser;
    addParameter(p,'LineColor','w');
    addParameter(p,'HatchAngle',60);
    addParameter(p,'HatchDensity',40);
    addParameter(p,'LineWidth',1.0);
    addParameter(p,'FontName','Times');
    addParameter(p,'FontSize',12);
    addParameter(p,'IdealLabel','');
    parse(p,varargin{:});

    fig = ancestor(parentAx,'figure');
    % Create an inset axes in pixel units
    hPanelAx = axes('Parent', fig, 'Units','pixels', 'Position', posPixels, ...
                    'Color','none', 'XColor','none', 'YColor','none', 'Box','off');
    hold(hPanelAx,'on');

    N = numel(legendLabels);
    x0 = 10;  y0 = posPixels(4) - 20;   % starting from top-left inside panel
    dx = 100; dy = 22;                  % row spacing
    sw = 24;  sh = 14;                  % swatch size

    for i = 1:N
        % Swatch rectangle at (x0, y0 - (i-1)*dy)
        xi = x0;
        yi = y0 - (i-1)*dy;
        px = [xi, xi+sw, xi+sw, xi];
        py = [yi, yi, yi-sh, yi-sh];

        % Draw colored patch
        col = colors{i};
        hPatch = patch('XData', px, 'YData', py, 'FaceColor', col, ...
                       'EdgeColor', 'k', 'Parent', hPanelAx);

        % Add hatch (using your integrated hatchfill2)
        ht = hatches{i};
        if ~isempty(ht)
            try
                hatchfill2(hPatch, ht, ...
                           'LineColor', p.Results.LineColor, ...
                           'HatchAngle', p.Results.HatchAngle, ...
                           'HatchDensity', p.Results.HatchDensity, ...
                           'LineWidth', p.Results.LineWidth);
            catch ME
                warning('Legend hatch failed (%s). Showing solid swatch.', ME.message);
            end
        end

        % Label text to the right of swatch
        text(xi + sw + 8, yi - sh/2, legendLabels{i}, ...
             'Parent', hPanelAx, 'VerticalAlignment','middle', ...
             'FontName', p.Results.FontName, 'FontSize', p.Results.FontSize, 'Color','k');
    end

    % Optional "Ideal" label
    if ~isempty(p.Results.IdealLabel)
        xi = x0; yi = y0 - N*dy - 4;
        % Draw a small sample line style for Ideal (dash-dot)
        line([xi xi+sw], [yi yi], 'Parent', hPanelAx, 'Color','k', 'LineWidth', 1.5, 'LineStyle','-.');
        text(xi + sw + 8, yi, p.Results.IdealLabel, ...
             'Parent', hPanelAx, 'VerticalAlignment','middle', ...
             'FontName', p.Results.FontName, 'FontSize', p.Results.FontSize, 'Color','k');
    end

    % Set fixed axis limits to panel bounds for easier placement
    xlim(hPanelAx,[0 posPixels(3)]);
    ylim(hPanelAx,[0 posPixels(4)]);

    % Keep panel on top
    uistack(hPanelAx,'top');
end
