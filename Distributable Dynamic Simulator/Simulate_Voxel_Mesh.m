% Simulate_Voxel_Mesh - ODE solver for the evolution of a voxel mesh
%
% On input:
%   Voxel_Mesh_Handle - Handle pointing to a voxel mesh from voxel_mesh.m
%
%   time_array [t0 tf] - optional input for the time array of ODE23.
%     Defaults are [0 10] seconds.
%
%   Gravity [column vector] - Vector describing gravity
%
%   Solver [1, 2, or 3] - Set as 1 for standard solving, set as 2 for 
%     symbolic solving, set as 3 for fprintf solving. In most cases 3 is
%     fastest.
%
% On output:
%   NA - the masses within voxels within the voxel mesh will have their X
%     and t array filled
%
%   table - also outputs the tabularized mass handle system for plotting
%     convenience
%
% Note:
%   
% Author:
%   Travis Hainsworth
%   University of Colorado - Boulder
%   Spring 2018

function table = Simulate_Voxel_Mesh(Voxel_Mesh_Handle,time_array,Gravity,Solver)
    
    %%%% Determine 2D or 3D %%%%
    d3 = Voxel_Mesh_Handle.mesh{1,1}.d3;
    
    %%%% Set Defaults %%%%
    if nargin < 2, time_array = [0 10];    end 
    if nargin < 3, Gravity = zeros(2+d3,1); end
    if nargin < 4, Solver = 1;             end
    
    %%%% Tabularize the mass_handles %%%%
    table = Tabularize_Voxels(Voxel_Mesh_Handle); 
    
    %%%% Obtain IC %%%%
    Num_Points = length(table); % Only interested in the first output (num rows)
    IC = [];
    for i = 1:Num_Points
        IC = [IC; table{i,1,1}.X0'; table{i,1,1}.V0'];
    end   
    
    
    %%%% Standard Solver %%%%
    if Solver == 1
        %%%% Run ODE23 %%%%
        [t,x] = ode23(@(t,s) EOM(t,s,table,Gravity,Solver), time_array, IC); % Have to set outputs to not plot. Which is dumb.
        %%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%% Symbolic Solver %%%%
    elseif Solver == 2
        %%%% Make Symbolic EOM %%%%
        s_sim = [evalin(symengine,sprintf('a%d(t)',1))];
        for i = 2:length(IC)       
            s_sim = [s_sim; evalin(symengine,sprintf('a%d(t)',i))]; % Only way I know how to make an array of variable dependent on t (univariate function call)
        end

        s_dot_sim = EOM(0,s_sim,table,Gravity,Solver);
        sim_EOM = odeFunction(s_dot_sim,s_sim);    

        %%%% Run ODE23 %%%%
        [t,x] = ode23(sim_EOM, time_array, IC); % Have to set outputs to not plot. Which is dumb.
        %%%%%%%%%%%%%%%%%%%%%%%%%
        
    else
        filler = EOM(0,IC,table,Gravity,3);
        rehash % Update the matlab directory to have EOM_written update
        IC = single(IC);
        odet = tic;
        [t,x] = ode23(@EOM_written,time_array,IC);
        t_ode = toc(odet);
    end
    
    %%%% Unpack x into table %%%%
    count = 1;
    for i = 1:Num_Points
        table{i,1,1}.X = x(:,count:count+1+d3);
        table{i,1,1}.V = x(:,count+2+d3:count+3+2*d3);
        table{i,1,1}.T = t;
        
       count = count + 4 + 2*d3;
    end
    
end