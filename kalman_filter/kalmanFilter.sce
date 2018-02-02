clc;
chdir('C:\Users\jeroen.demaeyer\Documents\python\kalmanFilter');
exec('fun.sce');

// Simulation setup
//-----------------------------------------------------------------------------
dt = 0.1; // simulation time step [s]
t = 0:dt:20; // simulation time vector [s]
N = length(t); // Number of simulation steps [-]

// Simulate a robot driving at constant speed with acceleration noise
[xSim, vSim, aSim] = simulateRobot(t);

// Add noise to simulated position
sigmaY = 1; // Positin noise standard deviation [m]
y = xSim  + rand(1,N,'normal') * sigmaY;

// System matrices
F=[1 dt ; 0 1];
B=[0; 0];
H = [1,0];

// Process and measurement covariance matrices
Q= [dt^4/4 dt^3/2 ; dt^3/2 dt^2];
R=[sigmaY^2]

// state vector and covariance matrix
x = zeros(2, length(t));
P = zeros(2,2,length(t));

// Discrete Kalman filter iterations
//-----------------------------------------------------------------------------
// Initial state and covariance matrix
x(:,1) = [0; 5];
P(:,:,1)=[2 0 ; 0 2];

for(i = 2:length(t))
    // Prediction step
    xkp= F*x(:,i-1);
    Pkp = F*P(:,:,i-1)*F' + Q;

    // Calculate Kalman gain
    K = Pkp*H' / (H*Pkp*H' + R);
    
    // Update step
    x(:,i) = xkp + K*(y(i) - H*xkp);
    P(:,:,i) = Pkp - K*H*Pkp;
end

// Plot results
//-----------------------------------------------------------------------------
figure(1, 'background', 8)
title('$\text{State Vector}$', 'font_size', 4);
subplot(2,1,1);
plot(t, x(1,:), t, y);
xlabel('$\text{Time\, [s]}$', 'font_size', 4);
ylabel('$\text{Position\, [m]}$', 'font_size', 4);
legend('Estimated position', 'Measured position');

subplot(2,1,2);
plot(t, x(2,:), t, vSim)
xlabel('$\text{Time\, [s]}$', 'font_size', 4);
ylabel('$\text{Speed\, [m/s]}$', 'font_size', 4);
legend('Estimated speed', 'Simulated speed (True speed)');

figure(2, 'background', 8)
pxx = matrix(P(1,1,:), 1, length(t));
pxy = matrix(P(1,2,:), 1, length(t));
pyy = matrix(P(2,2,:), 1, length(t));
plot(t, sqrt(pxx), t, sqrt(pyy))
title('$\text{State Covariance}$', 'font_size', 4);
xlabel('$\text{Time\, [s]}$', 'font_size', 4);
ylabel('$\text{Standard deviation}$', 'font_size', 4)
legend('Position [m]', 'speed [m/s]')

xs2png(1, 'stateVector.png');
xs2png(2, 'stateCov.png');
