function [fixtureVertices, drillingVertices] = generateVertex(precision)

% Creating the vertices that are used for the fixturing force
fixtureVertices = generateGrid(-990, -10, 20, 180, precision);

drill_list = -950:50:-50;
drillingVertices = zeros(size(drill_list,2), 3);
for i=1:size(drill_list,2)
    drillingVertices(i, :) = [20 drill_list(i) 200];
end

end