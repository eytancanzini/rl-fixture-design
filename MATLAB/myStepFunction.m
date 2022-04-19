function [Observation, Reward, IsDone, LoggedSignals] = myStepFunction(action, LoggedSignals)

model = loadModel('../models/front_wing_spar.stl');
drill_list = -950:50:-50;
drillingVertices = drillingVerticesGenerator(drill_list);

drilling_results_z = {};
drilling_results_x = {};
drilling_meshes = {};



end