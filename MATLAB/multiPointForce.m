function F = multiPointForce(location, state)

    m = 7588;
    mu = 1.05;
    g = 9.81;
    a = 0;
    S = 2;
    
    % Return the minimum force exerted by the vacuum gripper on the surface of the 
    F = (m/mu)*(g+a)*S;
    
    
    end