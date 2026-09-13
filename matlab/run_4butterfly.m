%% 4-Butterfly Attractor in Second-Order Memristor HNN (Fig. 9c)
% Paper: Lin et al., "A Second-Order Memristor Method to Construct Memristive 
% Neural Networks With Multi-Butterfly and Multi-Scroll Dynamics" (IEEE TCAS-I)
% Displays all plots in one clean, high-contrast tabbed window.

clear; clc; close all;

plot_color = [0.85 0.20 0.05]; % Red-orange trace

%% Model parameters
p.alpha = 1;
p.beta  = 1;
p.gamma = 0.01;
p.a     = 1;
p.b     = 1;
p.c     = 0.1;
p.p     = 2.2;
p.q     = 5;

% SOM-HNN control parameters (k = 0.4, M = 2 gives 4-butterfly)
p.k = 0.4;
p.M = 2;

%% Initial conditions & simulation settings
x0 = 0.1 * ones(5, 1);
t0 = 500;
tf = 3000;

opts = odeset('RelTol', 1e-7, 'AbsTol', 1e-9, 'MaxStep', 0.01);

fprintf('Simulating SOM-HNN (k = %.2f, M = %d, t = %.0f to %.0f)...\n', p.k, p.M, t0, tf);
tic;
[t, x] = ode23(@(t, x) som_hnn_eq(t, x, p), [t0, tf], x0, opts);
fprintf('Completed in %.2f s (%d points).\n', toc, length(t));

x1   = x(:, 1);
x2   = x(:, 2);
x3   = x(:, 3);
phi1 = x(:, 4);
phi2 = x(:, 5);

% Steady state: t >= 2000
idx_ss  = (t >= 2000);
t_ss    = t(idx_ss);
x1_ss   = x1(idx_ss);
x2_ss   = x2(idx_ss);
x3_ss   = x3(idx_ss);
phi1_ss = phi1(idx_ss);
phi2_ss = phi2(idx_ss);

%% Setup main window (forced white background for high contrast)
fig = figure('Name', 'SOM-HNN 4-Butterfly Dynamics', 'Color', 'w', ...
             'NumberTitle', 'off', 'Position', [80, 50, 1100, 720]);
tabs = uitabgroup(fig);

%% Tab 1: State Variables vs Time
tab1 = uitab(tabs, 'Title', 'State Variables', 'BackgroundColor', 'w');
states = {x1, x2, x3, phi1, phi2};
labels = {'x_1', 'x_2', 'x_3', '\phi_1', '\phi_2'};

for i = 1:5
    ax = subplot(5, 1, i, 'Parent', tab1);
    plot(ax, t, states{i}, 'Color', plot_color, 'LineWidth', 0.6);
    grid(ax, 'on'); 
    set(ax, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10);
    ylabel(ax, labels{i}, 'Color', 'k', 'FontSize', 11, 'FontWeight', 'bold');
    if i == 1
        title(ax, 'SOM-HNN State Variables vs Time', 'Color', 'k', 'FontSize', 12);
    elseif i == 5
        xlabel(ax, 'Time (t)', 'Color', 'k', 'FontSize', 11);
    end
end

%% Tab 2: 3D State-Space Trajectory (x1 - x2 - x3)
tab2 = uitab(tabs, 'Title', '3D State Space', 'BackgroundColor', 'w');
ax2 = axes('Parent', tab2);
plot3(ax2, x1_ss, x2_ss, x3_ss, 'Color', plot_color, 'LineWidth', 0.5);
grid(ax2, 'on'); view(ax2, 45, 30);
set(ax2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k', 'FontSize', 11);
xlabel(ax2, 'x_1', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
ylabel(ax2, 'x_2', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
zlabel(ax2, 'x_3', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');
title(ax2, 'SOM-HNN 3D State-Space Trajectory', 'Color', 'k', 'FontSize', 13);

%% Tab 3: 4-Butterfly Phase Portrait (Main Fig. 9c)
tab3 = uitab(tabs, 'Title', '4-Butterfly Attractor (Fig 9c)', 'BackgroundColor', 'w');
ax3 = axes('Parent', tab3);
plot(ax3, phi2_ss, phi1_ss, 'Color', plot_color, 'LineWidth', 0.8);
grid(ax3, 'on'); axis(ax3, 'tight');
set(ax3, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 11);
xlabel(ax3, '\phi_2', 'Color', 'k', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(ax3, '\phi_1', 'Color', 'k', 'FontSize', 13, 'FontWeight', 'bold');
title(ax3, 'Fig. 9(c): SOM-HNN 4-Butterfly Attractor (k = 0.4, M = 2)', 'Color', 'k', 'FontSize', 13);

%% Tab 4: Transient vs Steady State (Stacked vertically so it is NOT squeezed)
tab4 = uitab(tabs, 'Title', 'Transient vs Steady State', 'BackgroundColor', 'w');

% Top: Full Trajectory (Wide, unsqueezed)
ax4a = subplot(2, 1, 1, 'Parent', tab4);
plot(ax4a, phi2, phi1, 'Color', plot_color, 'LineWidth', 0.4);
grid(ax4a, 'on'); axis(ax4a, 'tight');
set(ax4a, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10);
xlabel(ax4a, '\phi_2', 'Color', 'k', 'FontSize', 11);
ylabel(ax4a, '\phi_1', 'Color', 'k', 'FontSize', 11);
title(ax4a, 'Full Trajectory (with initial transient)', 'Color', 'k', 'FontSize', 11);

% Bottom: Steady State (Wide, unsqueezed)
ax4b = subplot(2, 1, 2, 'Parent', tab4);
plot(ax4b, phi2_ss, phi1_ss, 'Color', plot_color, 'LineWidth', 0.6);
grid(ax4b, 'on'); axis(ax4b, 'tight');
set(ax4b, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10);
xlabel(ax4b, '\phi_2', 'Color', 'k', 'FontSize', 11);
ylabel(ax4b, '\phi_1', 'Color', 'k', 'FontSize', 11);
title(ax4b, 'Steady State (t \geq 2000)', 'Color', 'k', 'FontSize', 11);

%% Save numerical results
results = struct('t', t, 'x', x, 't_ss', t_ss, 'phi1_ss', phi1_ss, ...
                 'phi2_ss', phi2_ss, 'p', p, 'x0', x0);
save('results_4butterfly.mat', 'results');
fprintf('Results saved to results_4butterfly.mat\n');

%% SOM-HNN 5D System Equations (Eq. 19 in paper)
function dx = som_hnn_eq(~, x, p)
    x1   = x(1);
    x2   = x(2);
    x3   = x(3);
    phi1 = x(4);
    phi2 = x(5);

    v = x2 - x3;
    W = p.alpha - p.beta * phi1 - p.gamma * phi2;

    % Multi-piecewise function h(phi2) for M=2 (Eq. 4)
    if p.M < 0
        h = phi2;
    else
        h = phi2 + p.M - sum(sign(phi2 + 2 * (0:p.M)));
    end

    dx = zeros(5, 1);
    dx(1) = -x1 + 0.4 * tanh(x2) - 4.0 * tanh(x3);
    dx(2) = -x2 - 0.23 * tanh(x1) - 0.3 * tanh(x2) - p.k * W * v;
    dx(3) = -x3 - 4.5 * tanh(x2) + p.k * W * v;
    dx(4) = p.a - p.b * (v^2) - p.c * phi1;
    dx(5) = p.p * v - p.q * h;
end