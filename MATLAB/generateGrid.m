function arr = generateGrid(y_lower_lim, y_upper_lim, z_lower_lim, z_upper_lim, delta_y, delta_z)
% Generate a grid of points that serve as the Markov Decision space for the
% RL algorithm. Inputs consist of four values (upper and lower bounds in
% two directions) and two delta values for the number of points in each
% direction.
%
% Inputs:
%       y_lims - Upper and lower limits for the Y direction
%       z_lims - Upper and lower limits for the Z direction
%       delta - Number of points required in each direction
%
% arr - full factorial sampling plan of points on face
%

if delta_y <= 0 || delta_z <= 0

    error("Error. \nDelta between points must be positive and greater than 0") 
else

    vals = fullfactorial([10 10], 2);
    Y = rescale(vals(:,1), y_lower_lim, y_upper_lim);
    Z = rescale(vals(:,2), z_lower_lim, z_upper_lim);
    
    X = zeros(size(Z)); % All points are on the face
    
    arr = [X(:), Y(:), Z(:)];
end

end