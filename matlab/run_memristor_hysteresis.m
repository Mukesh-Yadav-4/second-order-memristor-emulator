%% Second-Order Memristor (SOM) - Hysteresis & Dynamics Simulation
% Reproduction of Fig. 2 & Fig. 4 from Lin et al. (IEEE TCAS-I)
% Style: LTspice-like black canvas with white axes and thin traces

clear; clc; close all;

%% System parameters (Section II-B)
p.alpha = 1;
p.beta  = 1;
p.gamma = 0.01;
p.a     = 1;
p.b     = 1;
p.c     = 0.1;
p.p     = 2.2;
p.q     = 5;
p.M     = 3;

phi0 = [0; 0];
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', 0.05);

%% Setup main window with tabs
fig = figure('Name', 'Second-Order Memristor Simulation', 'Color', 'k', ...
             'NumberTitle', 'off', 'Position', [100, 60, 1100, 700]);
tabs = uitabgroup(fig);

%% 1. Fig. 2(a) - Time Series (A = 2, F = 0.05)
A = 2; F = 0.05;
tspan = [0, 500];

[t, phi] = ode23(@(t, y) som_ode(t, y, p, A, F), tspan, phi0, opts);
phi1 = phi(:, 1);
phi2 = phi(:, 2);
v = A * sin(F * t);
W = p.alpha - p.beta * phi1 - p.gamma * phi2;

tab1 = uitab(tabs, 'Title', 'Fig 2(a) - Time Series', 'BackgroundColor', 'k');
ax1 = axes('Parent', tab1);
plot(ax1, t, v, 'w-', 'LineWidth', 1.0, 'DisplayName', 'v'); hold(ax1, 'on');
plot(ax1, t, phi1, 'r-', 'LineWidth', 1.0, 'DisplayName', '\phi_1');
plot(ax1, t, phi2, 'c-', 'LineWidth', 1.0, 'DisplayName', '\phi_2');
plot(ax1, t, W, 'g-', 'LineWidth', 1.0, 'DisplayName', 'W');
xlim(ax1, [0, 500]);
xlabel(ax1, 't', 'FontSize', 12);
ylabel(ax1, 'v / \phi_1 / \phi_2 / W', 'FontSize', 12);
title(ax1, 'Fig. 2(a): Time Series', 'Color', [0 1 0], 'FontSize', 13, 'FontWeight', 'bold');
legend(ax1, 'Location', 'northwest', 'TextColor', 'w', 'Color', 'k', 'EdgeColor', [0.4 0.4 0.4]);

%% 2. Fig. 2(b) - State Variables vs v (Steady State: t >= 300)
idx_ss = (t >= 300);

tab2 = uitab(tabs, 'Title', 'Fig 2(b) - State vs v', 'BackgroundColor', 'k');
ax2 = axes('Parent', tab2);
plot(ax2, v(idx_ss), phi1(idx_ss), 'r-', 'LineWidth', 1.1, 'DisplayName', '\phi_1'); hold(ax2, 'on');
plot(ax2, v(idx_ss), phi2(idx_ss), 'c-', 'LineWidth', 1.1, 'DisplayName', '\phi_2');
plot(ax2, v(idx_ss), W(idx_ss), 'g-', 'LineWidth', 1.1, 'DisplayName', 'W');
xlabel(ax2, 'v', 'FontSize', 12);
ylabel(ax2, '\phi_1 / \phi_2 / W', 'FontSize', 12);
title(ax2, 'Fig. 2(b): \phi_1, \phi_2, W vs v', 'Color', [0 1 0], 'FontSize', 13, 'FontWeight', 'bold');
legend(ax2, 'Location', 'northwest', 'TextColor', 'w', 'Color', 'k', 'EdgeColor', [0.4 0.4 0.4]);

%% 3. Fig. 2(c) / Fig. 4(a) - Amplitude Sweep (F = 0.05, A = 2, 3, 4)
A_list = [2, 3, 4];
colors_A = {[0 1 0], [0 0.45 1], [1 0 0]}; % Green, Blue, Red

tab3 = uitab(tabs, 'Title', 'Fig 4(a) - Amplitude', 'BackgroundColor', 'k');
ax3 = axes('Parent', tab3);
hold(ax3, 'on');

for k = 1:length(A_list)
    Ak = A_list(k);
    t_end = max(500, 10 * (2*pi/F));
    [tk, phik] = ode23(@(t, y) som_ode(t, y, p, Ak, F), [0, t_end], phi0, opts);
    
    vk = Ak * sin(F * tk);
    Wk = p.alpha - p.beta * phik(:, 1) - p.gamma * phik(:, 2);
    ik = Wk .* vk;
    
    % Last 2 cycles for steady-state loop
    T = 2 * pi / F;
    idx = tk >= (t_end - 2*T);
    plot(ax3, vk(idx), ik(idx), '-', 'Color', colors_A{k}, 'LineWidth', 1.1, ...
         'DisplayName', sprintf('A = %d V', Ak));
end

xlabel(ax3, 'V(v)', 'FontSize', 12);
ylabel(ax3, 'I(Vsen)', 'FontSize', 12);
title(ax3, 'I(Vsen)', 'Color', [0 1 0], 'FontSize', 13, 'FontWeight', 'bold');
legend(ax3, 'Location', 'northwest', 'TextColor', 'w', 'Color', 'k', 'EdgeColor', [0.4 0.4 0.4]);

%% 4. Fig. 2(d) / Fig. 4(b) - Frequency Sweep (A = 2, F = 0.05, 0.2, 0.8)
A = 2;
F_list = [0.05, 0.2, 0.8];
colors_F = {[1 0 0], [0 0.45 1], [0 1 0]}; % Red, Blue, Green

tab4 = uitab(tabs, 'Title', 'Fig 4(b) - Frequency', 'BackgroundColor', 'k');
ax4 = axes('Parent', tab4);
hold(ax4, 'on');

for k = 1:length(F_list)
    Fk = F_list(k);
    T = 2 * pi / Fk;
    t_end = max(200, 20 * T);
    [tk, phik] = ode23(@(t, y) som_ode(t, y, p, A, Fk), [0, t_end], phi0, opts);
    
    vk = A * sin(Fk * tk);
    Wk = p.alpha - p.beta * phik(:, 1) - p.gamma * phik(:, 2);
    ik = Wk .* vk;
    
    idx = tk >= (t_end - 2*T);
    plot(ax4, vk(idx), ik(idx), '-', 'Color', colors_F{k}, 'LineWidth', 1.1, ...
         'DisplayName', sprintf('F = %.2f', Fk));
end

xlabel(ax4, 'V(v)', 'FontSize', 12);
ylabel(ax4, 'I(Vsen)', 'FontSize', 12);
title(ax4, 'I(Vsen)', 'Color', [0 1 0], 'FontSize', 13, 'FontWeight', 'bold');
legend(ax4, 'Location', 'northwest', 'TextColor', 'w', 'Color', 'k', 'EdgeColor', [0.4 0.4 0.4]);

%% Apply consistent dark scope styling across all axes
all_axes = [ax1, ax2, ax3, ax4];
for ax = all_axes
    ax.Color = 'k';
    ax.XColor = 'w';
    ax.YColor = 'w';
    ax.LineWidth = 0.8;
    ax.Box = 'on';
    ax.XGrid = 'off';
    ax.YGrid = 'off';
    ax.FontName = 'Arial';
    ax.FontSize = 11;
end

%% Export figures
fig_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end

exportgraphics(ax1, fullfile(fig_dir, 'Fig2a_Time_Series.png'), 'Resolution', 300);
exportgraphics(ax2, fullfile(fig_dir, 'Fig2b_State_vs_v.png'), 'Resolution', 300);
exportgraphics(ax3, fullfile(fig_dir, 'Fig2c_Pinched_Hysteresis_Amplitude.png'), 'Resolution', 300);
exportgraphics(ax4, fullfile(fig_dir, 'Fig2d_Pinched_Hysteresis_Frequency.png'), 'Resolution', 300);

fprintf('Done. Figures saved to %s\n', fig_dir);

%% Second-Order Memristor ODE (Eq. 3 & Eq. 4)
function dphi = som_ode(t, phi, p, A, F)
    phi1 = phi(1);
    phi2 = phi(2);
    v = A * sin(F * t);

    if p.M < 0
        h = phi2;
    else
        h = phi2 + p.M - sum(sign(phi2 + 2 * (0:p.M)));
    end

    dphi = zeros(2, 1);
    dphi(1) = p.a - p.b * (v^2) - p.c * phi1;
    dphi(2) = p.p * v - p.q * h;
end