model = createpde('structural', 'static-solid');
importGeometry(model, '../models/front_wing_spar.stl');
rotate(model.Geometry, 90, [0 0 0],[1 0 0]); % Rotate to correct orientation

figure
pdegplot(model, 'FaceLabels','on')
view(90,45)
title('Front Spar')