This file set includes all of the necessary components for simulating a beam of voxels. 
Test it with demo.m and the simulation ends when a maximum deflection has appeared to be reached.

Note that contact mechanics have not been implemented -> voxels can collapse and move through each.
NOTE that gravity on line 27 of simulate_beam.m must be 2D or 3D to match the beam you created.

Parameters to change and where to change them:

demo.m : Design the beam in "demo.m" out of two materials

simulate_beam: line 26 -> specify the time of the simulation
               line 27 -> set the gravity vector
               line 28 -> set the solving type, choose from either 1, 2, or 3 (speed usually goes 3, 2, 1 but occasionally 2 is faster than 3)
                               1 uses a standard solver as described in the ODE23 description
                               2 uses a symbolic solver
                               3 automatically generates a single written equation of motion that has no loops
               line 33-45 -> sets the constraints and forces on the voxels

create_beam: line 5-17 -> define the two material's properties as well as the animation color of each voxel type.
                               


