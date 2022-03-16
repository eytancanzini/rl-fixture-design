function P = processPressureDistribution(region, state)

x = region.y+5; % Make the left end x = 0
dx = 2;
%Distribute the load over an area:
A = dx*0.1;
P = zeros(1,numel(x));
loadVelocity = 1.5; %m/sec
if isnan(state.time)
    P = nan(1,numel(x));
end
if state.time < 7 % Load would cross the bridge in about 7 sec
    loadLocation = loadVelocity*state.time;
    x1 = loadLocation-dx;
    x2 = loadLocation+dx;
      idx = x>x1 & x<x2;
      % Weight of four people
      F = 2000;
      P(idx) = F/A;

end