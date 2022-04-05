function magForce = calculateMagneticForce(I, position)
% Calculates the force exerted by the electromagnetic gripper on the surface of the component 

mu_0 = pi*4E-7;
g = 0.01;
N = 2000;
r = 0.04;
A = pi*r^2;
F = ((N*I)^2*mu_0*A)/(2*g^2);

switch position
    case 'x'
        magForce = [F 0 0];
    case 'y'
        magForce = [0 F 0];
    case 'z'
        magForce = [0 0 F];
    otherwise
        error("Error. \nMagnetic force must be present in the XYZ Cartesian system")
end