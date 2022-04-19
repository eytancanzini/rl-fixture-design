function model = loadModel(path)
% Function loads model and creates the structural constraints that are
% needed for constraining the component during simulation. The only
% parameter this takes in is the path to the model, which should follow
% MATLAB syntax.

model = createpde('structural', 'static-solid');
importGeometry(model, path);
rotate(model.Geometry, 90, [0 0 0], [1 0 0]); % Rotate the part

% Set the material parameters and the boundary constraints
E = 69E09;
nu = 0.34;
rho = 2710;

structuralProperties(model, 'YoungsModulus',E, ... 
    'PoissonsRatio',nu, ...
    'MassDensity',rho);
structuralBC(model, "Constraint", "fixed", "Face", [3 14]);

end