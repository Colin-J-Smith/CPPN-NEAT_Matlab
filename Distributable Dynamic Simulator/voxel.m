% voxel - A class to contain the information of a voxel comprised of point
%         masses
%
% On input:
%   mass_handle_array (mass handles [DL DR UL UR] or [DL DR UL UR BDL BDR 
%     BUL BUR]): Array of mass handles.
%
%   spring_constants (array of size 1 OR 6 OR 24): If of size 1
%     all springs will have the same value. If of size 6, dimensionality of 
%     voxel will be 2 and order of constants will be [L R U D UL-DR UR-DL].
%     Order specification of size 24 has not yet been decided.
%
%   damping_constants (float array): Same structure as the spring constants
%     but for damping.
%
% On output:
%   Voxel (class): A class containing point mass structures and other 
%     relevant voxel information. (see code)
%
% Special notes: 
%    
% Author:
%     Travis Hainsworth
%     CUB
%     Spring 2018
%

classdef voxel
    properties
        k
        b
        mass_handle_array
        
        DL
        DR
        UL
        UR
        BDL 
        BDR
        BUL 
        BUR 
        
        material %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        mass_of_each_point
        center
        dimension
        d3
        
        face_color
        edge_color
    end
    methods
        % ADD ACCESS TO A TIME DEPENDENT STATIC LINK LENGTH.
        function obj = voxel(mass_handle_array, k, b,face_color,edge_color, material)
            if nargin < 2, k = 1; end
            if nargin < 3, b = 1; end
            if nargin < 4, face_color = 'r'; end
            if nargin < 5, edge_color = 'k'; end
            if nargin < 6, material = 1; end
            
            % Set 3d boolean
            d3 = 1;
            if length(mass_handle_array) == 4, d3 = 0; end             
            obj.d3 = d3;
            
            % populate k
            if size(k) == 1, obj.k = k*ones(1,6+d3*18); 
            else obj.k = k; end
            
            % populate b
            if size(b) == 1, obj.b = b*ones(1,6+d3*18);
            else obj.b = b; end
            
            % populate material
            if size(material) == 1, obj.material = material*ones(1,6+d3*18);
            else obj.material = material; end
            
            obj.mass_handle_array = mass_handle_array;
            
            obj.DL = obj.mass_handle_array(1);
            obj.DR = obj.mass_handle_array(2);
            obj.UL = obj.mass_handle_array(3);
            obj.UR = obj.mass_handle_array(4);
            if d3 == 1
                obj.BDL  = obj.mass_handle_array(5);
                obj.BDR = obj.mass_handle_array(6);
                obj.BUL = obj.mass_handle_array(7);
                obj.BUR = obj.mass_handle_array(8);
            end
            
            obj.mass_of_each_point = obj.DL.m;
            obj.dimension = obj.UR.Rest(1)-obj.UL.Rest(1);
            
            obj.face_color = face_color;
            obj.edge_color = edge_color;
        end
    end
end
    