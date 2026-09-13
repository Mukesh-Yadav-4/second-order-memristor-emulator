function dx = som_hnn(~, x, p)
% SOM_HNN - Second-Order Memristor Hopfield Neural Network (Eq. 19)
% State: x = [x1; x2; x3; phi1; phi2]

x1   = x(1);
x2   = x(2);
x3   = x(3);
phi1 = x(4);
phi2 = x(5);

% Membrane potential difference across neuron 2 and 3
v = x2 - x3;

% Memductance W(phi1, phi2)
W = p.alpha - p.beta * phi1 - p.gamma * phi2;

% Multi-piecewise nonlinear function h(phi2) (Eq. 4)
if p.M < 0
    h = phi2;
else
    h = phi2 + p.M - sum(sign(phi2 + 2 * (0:p.M)));
end

% 5D ODE System
dx = zeros(5, 1);
dx(1) = -x1 + 0.4 * tanh(x2) - 4 * tanh(x3);
dx(2) = -x2 - 0.23 * tanh(x1) - 0.3 * tanh(x2) - p.k * W * v;
dx(3) = -x3 - 4.5 * tanh(x2) + p.k * W * v;
dx(4) = p.a - p.b * (v^2) - p.c * phi1;
dx(5) = p.p * v - p.q * h;

end