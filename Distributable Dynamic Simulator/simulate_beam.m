% simulate beam - simulation of a cantilever beam
%
% input:
%   Occupancy_Matrix (row x col boolean matrix): 1 for filled voxel, 0 for
%     empty voxel
%   Animate_Simulation (boolean): 1 for true, 0 for false
%
% output:
%   max_displacement (float): the maximum displacement of the proximal end
%     of the beam given a simulation time span. This is not guaranteed to
%     be the maximum displacement given infinite time.
%
% notes:
%   This function sets the simulation time, gravity, the type of solver, 
%   and the applied load. To set k and b values see "Create_Beam.m".
% 
% author:
%   Travis Hainsworth
%   Spring 2018
%   University of Colorado - Boulder

function max_displacement = simulate_beam(Occupancy_Matrix,Animate_Simulation)
%%%% Set up simulation parameters %%%%
[y,x,z] = size(Occupancy_Matrix); 

time_array=single([0,10]);
Grav_const = 0; %change this value to apply a gravitational field %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this is where the gravity vector is defined. Note that the matrix ordering
%is y,x,z, but the gravity vector is ordered [x,y,z]
if z>1 Gravity = Grav_const*[0;-1;0];
else Gravity = Grav_const*[0;-1];
end
Solver = 3;         % Solve symbolic 

%%%% Create the beam %%%%
Voxels = Create_Beam(Occupancy_Matrix);

%%%% Set Constraints %%%%
% FIX BOTTOM PLANE OF MASSES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:x
    Voxels.mesh{i,1}.DL.clamped = 1;
    Voxels.mesh{i,1}.DR.clamped = 1;
end
% Voxels.mesh{1,1}.DL.clamped = 1;

% Apply a force to the top plane of masses
Force = 0; % Newtons
num_end_points = sum(Occupancy_Matrix(1,:)>0)+1; % Number of filled points masses on the end of the beam
d_force = Force/num_end_points; % Force per mass
for i = 1:x
    if Voxels.mesh{i,end}.UR.m ~= 0 % Only apply the static force to the existing voxels
        Voxels.mesh{i,end}.UR.Static_Force(1,1) = d_force; % Apply force in x direction
        Voxels.mesh{i,end}.UL.Static_Force(1,1) = d_force;
    end
end

%%%% Evaluate the simulation %%%%
mass_handle_table = Simulate_Voxel_Mesh(Voxels,time_array,Gravity,Solver);

%%%% Animate the simulation %%%%
if Animate_Simulation == 1
    animate_voxels(Voxels.mesh);
end

%%%% Determine max displacement horizontal displacement of top layer %%%%
displacement = zeros(x+1,1);
displacement(1) = Voxels.mesh{1,end}.UL.X0(1)-max(Voxels.mesh{1,end}.UL.X(:,1));
for i = 1:x
    displacement(i+1) = Voxels.mesh{i,end}.UR.X0(1)-max(Voxels.mesh{i,end}.UR.X(:,1));
end
max_displacement = max(-displacement);
    
end