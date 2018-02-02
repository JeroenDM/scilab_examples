
function [position, speed, acceleration] = simulateRobot(timeVector)
    // Simulate robot driving at constant speed
    // With normal distributed noise on the acceleration
    speedIdeal = 5; // constant driving speed [m/s]
    sigmaA = 0.1; // acceleration noise standard deviation
    N = length(timeVector);
    
    acceleration = [0 rand(1, N - 1, 'normal')] * sigmaA;
    speed = cumsum(dt * acceleration) + ones(1, N) * speedIdeal;
    position = cumsum(dt * speed);
endfunction
