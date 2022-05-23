function d = drillingVerticesGenerator(drill_list)

d = zeros(size(drill_list,2), 3);
for i=1:size(drill_list,2)
    d(i, :) = [30 drill_list(i) 200];
end

end