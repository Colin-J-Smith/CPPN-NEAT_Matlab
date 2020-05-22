% voxel_mesh - a handle to a cell array of voxels
%
% On initialization:
%   Initial_Voxel (voxel class): The first voxel that all other voxels will
%     be built around.
% On Methods:
%  add_voxel:
%    Location (1x3 array): The location of new voxel in the format x, y, z;
%      note, however, that these must be positive integers.
%    k (spring array): The spring array for creation of the new voxel.
%    b (damping array): The damping array for creation of the new voxel.
%      For more information on k and b see the voxel class.
%
% Special Notes:
%   Assumes square/cubic voxels
%   Assumes voxels are all the same size
%   Is structured in x, y, z format but must be placed and accessed as
%     positive integers and the size of this grid is that of voxel size Iso
%     essentially this is column, row, depth layout)
%   Voxels HAVE to be added in connection to another voxel (no free
%     floating voxels here)
%
% Author
%   Travis Hainsworth
%   University of Colorado - Boulder
%   Spring 2018
%
% TODO: Need to get rid of the try statements! I don't know a good way to
%   check if a cell exists, however; I keep getting errors because I'm
%   checking out of the cell's size


classdef voxel_mesh < handle
    
    properties
        mesh
        voxel_3d
        
    end
    
    methods
        
        function obj = voxel_mesh(initial_voxel)
            obj.mesh{1,1,1} = initial_voxel;
            obj.voxel_3d = initial_voxel.d3;
        end
        
        function add_voxel(obj,Location,k,b,mass,face_color,edge_color, material)
            if nargin < 5, mass = obj.mesh{1,1,1}.DL.m; end
            if nargin < 6, face_color = 'r'; end
            if nargin < 7; edge_color = 'k'; end
            if nargin < 8; material = 1; end
            
            %%%% Determine wether we have a 2d or 3d system %%%%
            d3 = obj.voxel_3d;
            
            %%%% Preintialize the matrix handles %%%%
            DL = 0;
            DR = 0;
            UL = 0;
            UR = 0;
            if d3 == 1
                BDL = 0;
                BDR = 0;
                BUL = 0;
                BUR = 0;
            end
            
            %%%% Check if left, down, back voxels exist %%%%\
            % Check left
            Check = Location; Check(1) = Check(1)-1;
            try
                if Check(1) > 0 && isempty(obj.mesh{Check(1),Check(2),Check(3)}) == 0
                    Old_Voxel = obj.mesh{Check(1),Check(2),Check(3)};
                    UL = Old_Voxel.UR;
                    DL = Old_Voxel.DR;
                    if d3 == 1
                        BUL = Old_Voxel.BUR;
                        BDL = Old_Voxel.BDR;
                    end
                    % add the desired voxel's dimension and location
                    dimension = UL.Rest(2)-DL.Rest(2);
                    center = DL.Rest+ones(1,2+d3)*dimension/2;
                end
            end
            % Check right
            Check = Location; Check(1) = Check(1)+1;
            try
                if Check(1) < mesh_size(1) && isempty(obj.mesh{Check(1),Check(2),Check(3)}) == 0
                    Old_Voxel = obj.mesh{Check(1),Check(2),Check(3)};
                    UR = Old_Voxel.UL;
                    DR = Old_Voxel.DL;
                    if d3 == 1
                        BUR = Old_Voxel.BUL;
                        BDR = Old_Voxel.BDL;
                    end
                    % add the desired voxel's dimension and location
                    dimension = UR.Rest(2)-DR.Rest(2);
                    center = DR.Rest+ones(1,2+d3)*dimension/2; center(1) = center(1)-dimension;
                end
            end
            % Check up
            Check = Location; Check(2) = Check(2)+1;
            try
                if Check(2) < mesh_size(2) && isempty(obj.mesh{Check(1),Check(2),Check(3)}) == 0
                    Old_Voxel = obj.mesh{Check(1),Check(2),Check(3)};
                    UL = Old_Voxel.DL;
                    UR = Old_Voxel.DR;
                    if d3 == 1
                        BUL = Old_Voxel.BDL;
                        BUR = Old_Voxel.BDR;
                    end
                    % add the desired voxel's dimension and location
                    dimension = UR.Rest(1)-UL.Rest(1);
                    center = UL.Rest+ones(1,2+d3)*dimension/2; center(2) = center(2)-dimension;
                end
            end
            % Check Down
            Check = Location; Check(2) = Check(2)-1;
            try
                if Check(2) > 0 && isempty(obj.mesh{Check(1),Check(2),Check(3)}) == 0
                    Old_Voxel = obj.mesh{Check(1),Check(2),Check(3)};
                    DL = Old_Voxel.UL;
                    DR = Old_Voxel.UR;
                    if d3 == 1
                        BDL = Old_Voxel.BUL;
                        BDR = Old_Voxel.BUR;
                    end
                    % add the desired voxel's dimension and location
                    dimension = DR.Rest(1)-DL.Rest(1);
                    center = DL.Rest+ones(1,2+d3)*dimension/2;
                end
            end
            % Check Back and Forward
            if d3 == 1
                % back (towards viewer)
                Check = Location; Check(3) = Check(3)+1;
                try
                    if Check(3) > 0 && isempty(obj.mesh{Check(1),Check(2),Check(3)}) == 0
                        Old_Voxel = obj.mesh{Check(1),Check(2),Check(3)};
                        BDL = Old_Voxel.DL;
                        BDR = Old_Voxel.DR;
                        BUL = Old_Voxel.UL;
                        BUR = Old_Voxel.UR;
                        % add the desired voxel's dimension and location
                        dimension = BUL.Rest(2)-BDL.Rest(2);
                        center = DL.Rest+ones(1,2+d3)*dimension/2; center(3) = center(3) - dimension;
                    end
                end
                % forward (away from viewer)
                Check = Location; Check(3) = Check(3)-1;
                try
                    if Check(3) > 0 && isempty(obj.mesh{Check(1),Check(2),Check(3)}) == 0
                        Old_Voxel = obj.mesh{Check(1),Check(2),Check(3)};
                        DL = Old_Voxel.BDL;
                        DR = Old_Voxel.BDR;
                        UL = Old_Voxel.BUL;
                        UR = Old_Voxel.BUR;
                        % add the desired voxel's dimension and location
                        dimension = UL.Rest(2)-DL.Rest(2);
                        center = DL.Rest+ones(1,2+d3)*dimension/2;
                    end
                end
            end
            
            if d3 == 1, handle_array = [DL DR UL UR BDL BDR BUL BUR];
            else,       handle_array = [DL DR UL UR]; end
            
            % Turns out trying to add a mix of handles and 0 will cut out some
            % zeros: test = [0 0 0 0], test = [test DL 0] creates a 1x3 handle
            % array
            %%%% Fill in any empty masses %%%%
            %%%% Also update old voxel masses to the heavier mass %%%%
            for i = 1:length(handle_array)
                if handle_array(i).initialized == 0
                    location = center-dimension/2; % Default of DL point
                    
                    switch i
                        case 2 % DR point
                            location(1) = location(1)+dimension;
                        case 3 % UL point
                            location(2) = location(2)+dimension;
                        case 4 % UR point
                            location(1) = location(1)+dimension;
                            location(2) = location(2)+dimension;
                        case 5 % BDL point
                            location(3) = location(3)+dimension;
                        case 6 % BDR point
                            location(3) = location(3)+dimension;
                            location(1) = location(1)+dimension;
                        case 7 % BUL point
                            location(3) = location(3)+dimension;
                            location(2) = location(2)+dimension;
                        case 8 % BUR point
                            location(3) = location(3)+dimension;
                            location(1) = location(1)+dimension;
                            location(2) = location(2)+dimension;
                    end
                    handle_array(i) = mass_handle(location,mass,material);
                elseif handle_array(i).m < mass
                    handle_array(i).m = mass;
                end
                
                % Make sure that any voxels labled "air" pass material=2 to it's masses
                if material == 2, handle_array(i).material = material;end
                
            end
            
            %%%% Create the voxel %%%%
            obj.mesh{Location(1),Location(2),Location(3)} = voxel(handle_array,k,b,face_color,edge_color, material);
        end
        
    end
end
