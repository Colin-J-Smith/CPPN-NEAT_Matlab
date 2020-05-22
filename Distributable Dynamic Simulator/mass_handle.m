% mass_handle - a data structure to contain relevant information to a point
%   mass in a spring, damping mesh
% On input:
%     RestingLoc (1x3 or 1x2 array): Where the mass resides in the global  
%       system when at rest. Input 1x3 for 3 dimensional systems or 1x2 for
%       2 dimensional systems. Defaults at the origin.
%     m (float): The mass of the point.
%     X0 (1x3 or 1x2 array): The initial displacement of the point mass
%       as defined in the mass's frame. Defaults at [0,0] or [0,0,0].
%     V0 (1x3 or 1x2 array): The initial velocity of the point mass.
%       Defaults at [0,0] or [0,0,0].
%     X (nx3 or nx2 array): The evolution of the position of the mass as
%       time evolves. In standard settings this should be filled in after
%       the ODE solver, and so defaults as [].
%     T (nx1 array): The correspondin time as the position evolves. In 
%       standard settings this should be filled in after the ODE solver, 
%       and so defaults as [].
%     color (1x3 array): RGB color definition of the point. Defaults at
%       random and is intended to be used for plotting purposes.
%     clamped (bool): Boolean to indicate wether the point is free to move
%       or fixed in place, default is free to move. 
% On output:
%     output (handle): The handle pointing to the point mass's
%       information
% Special Notes:
%     
% Author:
%     Travis Hainsworth
%     CUB
%     Fall 2017
%

classdef mass_handle < handle
    properties
        Rest
        X0
        V0
        m
        X
        T
        color
        clamped
        V
        initialized
        Static_Force
        material
    end
    methods
        function output = mass_handle(RestingLoc,m,material,X0,V0,X,T,color,clamped)
            %%%% Define a default point mass centered at the origin with a small
            %%%% initial perturbation
            if nargin < 1,  RestingLoc = [0,0];end
            dim = length(RestingLoc);
            if nargin < 2,  m = 1;             end
            if nargin < 3,  material = 1;      end
            if nargin < 4,  X0 = RestingLoc;   end
            if nargin < 5,  V0 = zeros(1,dim); end
            if nargin < 6,  X = [];            end
            if nargin < 7,  T = [0];           end
            if nargin < 8,  color = rand(1,3); end
            if nargin < 9,  clamped = 0;       end
            
            %%%% Define the structure
            output.Rest = RestingLoc;
            output.X0 = X0;
            output.V0 = V0;
            output.m = m;
            output.X = X;
            output.T = T;
            output.color = color;
            output.clamped = clamped;
            output.V = zeros(1,dim);
            output.Static_Force = zeros(dim,1);
            output.material = material;
            
            % Found out that creating an array of mass handles auto
            % initializes any handles that aren't created yet. (which is no
            % good!) (can't mix floats and handles in an array)
            if dim == 1
                output.initialized = 0;
            else
                output.initialized = 1;
            end
        end
    end
end
