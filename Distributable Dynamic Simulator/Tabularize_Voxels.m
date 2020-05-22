% Tabularize_Voxels - Convert a mesh of voxels to a table of point mass
%   handles with the spring and damping constants 
%
% On input:
%   Voxel_Mesh (class handle): populated voxel mesh from the class
%     voxel_mesh.m
%
% On output:
%   table (n x 14 x 4 array): Each row contains a mass handle, then every 
%     mass handle it could connect with. Behind each connecting mass handle
%     is the spring constant and behind that is the damping constant and 
%     behind that is the total times that connection has been made.
%
% Special Notes:
%   Currently only uniform k and b values within a voxel are supported.
%
% Author:
%   Travis Hainsworth
%   University of Colorado - Boulder
%   Spring 2018

function table = Tabularize_Voxels(Voxel_Mesh)
[m,n,o] = size(Voxel_Mesh.mesh);

% 3D?
d3 = Voxel_Mesh.mesh{1,1,1}.d3;

% Preallocation
NumPoints = 0;
table{1,1,1} = [];

% Parsing
for k = 1:o
for j = 1:n
for i = 1:m
    % get current voxel's information
    spring_k = Voxel_Mesh.mesh{i,j,k}.k(1); 
    damp_b = Voxel_Mesh.mesh{i,j,k}.b(1);
    material = Voxel_Mesh.mesh{i,j,k}.material(1);
    
    % Analyze each point in the voxel
    for p = 1:4+4*d3
        point = Voxel_Mesh.mesh{i,j,k}.mass_handle_array(p);
        
       % If it isn't in the table then add it to the table 
       if cell_ismember(point,table{:,1,1}) == 0
           NumPoints = NumPoints+1;
           table{NumPoints,1,1} = point;
       end
       
       % Get it's index in the table
       ind = cell_find(point,table{:,1,1});
       
       % Update the table with all of the connections using the helper
       % function
       ignore = 9-p; % index of the opposing voxel (which isn't connected)
       for neighbor = 1:4+4*d3
           if neighbor ~= p && neighbor ~= ignore
               if spring_k ~= 0 || damp_b ~= 0
               update_with_neighbor(Voxel_Mesh.mesh{i,j,k}.mass_handle_array(neighbor),ind,spring_k,damp_b,material);
               end
           end
       end
    end
end
end
end

%%%% Go through and average all of the constants %%%%
for row = 1:NumPoints
    for col = 2:cell_length(table{row,:,1})
        table{row,col,2} = table{row,col,2}/table{row,col,4};
        table{row,col,3} = table{row,col,3}/table{row,col,4};
    end
end

%%%% Helper Functions %%%%
% Helper function to see if a neighbor exists, if it does then average the
% data, if it doesn't then add an entry
    function update_with_neighbor(Neighbor_Handle,current_row,current_k,current_b,current_mat)
       % See if it's neighbor is in this row
       if cell_ismember(Neighbor_Handle,table{current_row,:,1}) == 0
           % If it isn't add the neighbor and this voxel's data to the table
           num_entries = cell_length(table{current_row,:,1});
           table{current_row,num_entries+1,1} = Neighbor_Handle;
           table{current_row,num_entries+1,2} = current_k;
           table{current_row,num_entries+1,3} = current_b;
           table{current_row,num_entries+1,4} = 1;
           table{current_row,num_entries+1,5} = current_mat^2;
       else
           % otherwise average the data with this voxel's data
           current_col = cell_find(Neighbor_Handle,table{current_row,:,1});
           table{current_row,current_col,2} = table{current_row,current_col,2}+current_k; % need to average not just add (this is done later)
           table{current_row,current_col,3} = table{current_row,current_col,3}+current_b;
           table{current_row,current_col,4} = table{current_row,current_col,4}+1;
           table{current_row,current_col,5} = table{current_row,current_col,5}+current_mat^2;
       end
    end

% ismember doesn't work on a row of a cell array :(
    function here = cell_ismember(Neighbor_Handle,varargin)
        here = 0;
        for num_inputs = 1:length(varargin)
            if Neighbor_Handle == varargin{num_inputs}
                here = 1;
            end
        end
    end

% length doesn't work on a row of a cell array :(
    function num_entries = cell_length(varargin)
        num_entries = 0;
        for index = 1:length(varargin)
            if isempty(varargin{index}) == 0
                num_entries = num_entries+1;
            end
        end
    end

% find doesn't work on a row/col of a cell array :(
    function index = cell_find(point,varargin)
        for index = 1:length(varargin)
            if point == varargin{index}
                break
            end
        end
    end

end