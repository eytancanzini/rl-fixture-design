model = createpde('structural','transient-solid');
gm=multicuboid(10,4,0.3);
model.Geometry = gm;

E = 210E9; nu = 0.3; rho = 8000; 
structuralProperties(model,'YoungsModulus',E, ... 
    'PoissonsRatio',nu, ... 
    'MassDensity',rho);

structuralBC(model,'Face',[5 3],'XDisplacement',0,'YDisplacement',0,'ZDisplacement',0);
generateMesh(model);
structuralBoundaryLoad(model,'Face',2,'Pressure',@movingPulseFcn);
d0=[0,0,0];
v0=[0,0,0];
structuralIC(model,'Displacement',d0,'Velocity',v0);
t_max = 20;
tlist=0:0.1:t_max; 
structuralResults=solve(model,tlist);

for i = 1:numel(structuralResults.SolutionTimes)
    pdeplot3D(model,'ColorMapData',structuralResults.Displacement.uz(:,i))
    title(['Deflection of bridge at Time = ' num2str(structuralResults.SolutionTimes(i))]);
    pause
end
