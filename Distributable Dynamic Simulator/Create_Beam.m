% Create_Beam

function Voxel_Mesh = Create_Beam(Beam_Fill_Matrix)
%%%% Define void material %%%%
kv = 0;
bv = 0;
mv = 0;
fv = 'w'; % face white
ev = 'w'; % edge white
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Define filled material %%
kf = 1;
bf = 1;
mf = 1;
ff = [.5 .5 .5]; % gray
ef = 'k'; % edge black
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Define "air" material %%
ka = 1;
ba = 1;
ma = 1;
fa = [.25 .25 .25]; % light gray
ea = 'g'; % edge black
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Determine beam size %%%%
[row,col,dep] = size(Beam_Fill_Matrix);

%%%% Determine 2D or 3D %%%%
if dep == 1
      d3 = 0;
else, d3 = 1;
end

%%%% Create origin voxel %%%%
voxel_dimension = 1; % size of voxels sides
if Beam_Fill_Matrix(row,1,dep) == 0 % determine void or filled
    mass = mv; k = kv; b = bv; face = fv; edge = ev; material = 0;
elseif Beam_Fill_Matrix(row,1,dep) == 2
    mass = ma; k = ka; b = ba; face = fa; edge = ea; material = 2;
else
    mass = mf; k = kf; b = bf; face = ff; edge = ef; material = 1;
end

%%%% Define the first voxel %%%%
location = zeros(1,2+d3);
mass_array(1) = mass_handle(location,mass,material);
location(1) = location(1)+voxel_dimension;
mass_array(2) = mass_handle(location,mass,material);
location(2) = location(2)+voxel_dimension;
mass_array(4) = mass_handle(location,mass,material);
location(1) = location(1)-voxel_dimension;
mass_array(3) = mass_handle(location,mass,material);
if d3 == 1
    location(2) = location(2)-voxel_dimension;
    location(3) = location(3)+voxel_dimension;
    mass_array(5) = mass_handle(location,mass,material);
    location(1) = location(1)+voxel_dimension;
    mass_array(6) = mass_handle(location,mass,material);
    location(2) = location(2)+voxel_dimension;
    mass_array(8) = mass_handle(location,mass,material);
    location(1) = location(1)-voxel_dimension;
    mass_array(7) = mass_handle(location,mass,material);
end

V1 = voxel(mass_array,k,b,face,edge, material);
VM = voxel_mesh(V1);

%%%% Fill in the rest %%%% 
% (note that voxels want to be added in xyz format not row,col,depth
for K = dep:-1:1
for J = row:-1:1
for I = 1:col
    if I~= 1 || J~=row || K~= dep % skip the first voxel because its already made
        % Set material properties
        if Beam_Fill_Matrix(J,I,K) == 0
            mass = mv; k = kv; b = bv; face = fv; edge = ev; material = 0;
        elseif Beam_Fill_Matrix(J,I,K) == 2
            mass = ma; k = ka; b = ba; face = fa; edge = ea; material = 2;
        else
            mass = mf; k = kf; b = bf; face = ff; edge = ef; material = 1;
        end
        % add the voxel
        x = I; y = row+1-J; z = dep+1-K;
        VM.add_voxel([x,y,z],k,b,mass,face,edge, material);
    end
end
end
end

Voxel_Mesh = VM;
end