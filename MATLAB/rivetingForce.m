function F = rivetingForce(diameter, thickness, shearStress)
% Function calculate the riveting force based on the rivet type being
% used. Inputs are the outer diameter of the rivet, the thickness of the
% rivet if it is hollow and the shear stress value of the material

if thickness == 0
    A = pi*(diameter/2)^2;
    F = A*shearStress;
else
    A = pi*((diameter/2)^2-((diameter-thickness)/2)^2);
    F = A*shearStress;
end

end