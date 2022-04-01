function arr = generateGrid(y_lower_lim, y_upper_lim, z_lower_lim, z_upper_lim, delta)
% Generate a grid of points that serve as the Markov Decision space for the
% RL algorithm
if delta <= 0

    error("Error. \nDelta between points must be positive and greater than 0. The current value of delta %d", delta) 
else

    y = linspace(y_lower_lim, y_upper_lim, abs((y_lower_lim-y_upper_lim)/delta));
    z = linspace(z_lower_lim, z_upper_lim, abs((z_lower_lim-z_upper_lim)/(delta/2)));
    x = 0; % All points are on the face
    
    [X, Y, Z] = meshgrid(x, y, z);
    
    arr = [X(:), Y(:), Z(:)];
end

end