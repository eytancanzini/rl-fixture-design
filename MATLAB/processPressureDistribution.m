function P = processPressureDistribution(region, state)

x = region.y; % Make the left end x = 0
dx = 2;
%Distribute the load over an area:
A = dx*0.5;
P = zeros(1,numel(x));
loadVelocity = 0.2; %m/sec
if isnan(state.time)
    P = nan(1,numel(x));
end
if state.time < 11 % Load would cross the bridge in about 7 sec
    loadLocation = loadVelocity*state.time;
    disp(loadLocation)
    x1 = loadLocation-dx;
    x2 = loadLocation+dx;
      idx = x>x1 & x<x2;
      % Weight of four people
      F = 2000;
      P(idx) = F/A;
disp("-----------")
end