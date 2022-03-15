function P = movingPulseFcn(region, state)

    x = region.x+5;
    dx = 0.4;
    
    A = 0.8*4;
    P = zeros(1, numel(x));
    
    loadVelocity = 1.5;
    if isnan(state.time)
        P = nan(1, numel(x));
    end
    
    if state.time < 7
        
        loadLocation = loadVelocity*state.time;
        x1 = loadLocation-dx;
        x2 = loadLocation+dx;
    
        idx = x>x1 & x<x2;
        F = 2000;
    
        P(idx) = F/A;
    end
    
    end