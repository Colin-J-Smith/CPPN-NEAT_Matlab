%%%%%%%%%%%%%%%% XOR experiment file  (contains experiment, receives genom, decodes it, evaluates it and returns raw fitnesses) (function)

%% Neuro_Evolution_of_Augmenting_Topologies - NEAT
%% developed by Kenneth Stanley (kstanley@cs.utexas.edu) & Risto Miikkulainen (risto@cs.utexas.edu)
%% Coding by Christian Mayr (matlab_neat@web.de)
%% Modifications for CPPN by Colin Smith
% May 1, 2020

function population_plus_fitnesses=cppn_objective_func(population)
population_plus_fitnesses=population;
no_change_threshold=1e-3; %threshold to judge if state of a node has changed significantly since last iteration
number_individuals=size(population,2);

nx = 10;
ny = 25;


% these are the x and y coordinates of the node mesh
% size(population,1) x 2
[X,Y] = meshgrid(1:nx,1:ny);
input_pattern = zeros(nx*ny,2);
for i = 1:nx*ny
    input_pattern(i,:) = [X(i), Y(i)];
end

% these are the material values present at x,y node coordinates
% size(population,1) x 1
% output_pattern=zeros(size(input_pattern,1),1);

% material specification
% materials = [0;  % static
%              1]; % actuated

% Activation functions
% activation_func = [1; %sigmoid
%                    2; %gaussian
%                    3; %sine
%                    4;]; %linear

for index_individual=1:number_individuals
    number_nodes=size(population(index_individual).nodegenes,2);
    number_connections=size(population(index_individual).connectiongenes,2);
    %individual_fitness=0;
    output1=[];
    output2=[];
    for index_pattern=1:size(input_pattern,1) %4; %%%MAYBE UNECCESSARY%%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % the following code assumes node 1 and 2 inputs, node 3 bias, node 4 output, rest arbitrary (if existent, will be hidden nodes)
        % set node input steps for first timestep
        population(index_individual).nodegenes(3,4:number_nodes)=0; %set all node input states to zero
        population(index_individual).nodegenes(3,3)=1; %bias node input state set to 1
        population(index_individual).nodegenes(3,1:2)=input_pattern(index_pattern,:); %node input states of the two input nodes are consecutively set to the input pattern
        
        %set node output states for first timestep (depending on input states)
        population(index_individual).nodegenes(4,1:3)=population(index_individual).nodegenes(3,1:3); % INHERIT THE INPUT STATES ON THESE NODES
        population(index_individual)= activation(population(index_individual), number_nodes); %CALCULATE THE OUTPUT STATE FOR HIDDEN AND OUTPUT NODES
        
        no_change_count=0;
        index_loop=0;
        while (no_change_count<number_nodes) & index_loop<3*number_connections
            index_loop=index_loop+1;
            vector_node_state=population(index_individual).nodegenes(4,:);
            for index_connections=1:number_connections
                %read relevant contents of connection gene (ID of Node where connection starts, ID of Node where it ends, and connection weight)
                ID_connection_from_node=population(index_individual).connectiongenes(2,index_connections);
                ID_connection_to_node=population(index_individual).connectiongenes(3,index_connections);
                connection_weight=population(index_individual).connectiongenes(4,index_connections);
                %map node ID's (as extracted from single connection genes above) to index of corresponding node in node genes matrix
                index_connection_from_node=find((population(index_individual).nodegenes(1,:)==ID_connection_from_node));
                index_connection_to_node=find((population(index_individual).nodegenes(1,:)==ID_connection_to_node));
                
                if population(index_individual).connectiongenes(5,index_connections)==1 %Check if Connection is enabled
                    population(index_individual).nodegenes(3,index_connection_to_node)=population(index_individual).nodegenes(3,index_connection_to_node)+population(index_individual).nodegenes(4,index_connection_from_node)*connection_weight; %take output state of connection_from node, multiply with weight, add to input state of connection_to node
                end
            end
            %pass on node input states to outputs for next timestep
            population(index_individual).nodegenes(4,4:number_nodes)=1./(1+exp(-4.9*population(index_individual).nodegenes(3,4:number_nodes)));
            %Re-initialize node input states for next timestep
            population(index_individual).nodegenes(3,4:number_nodes)=0; %set all output and hidden node input states to zero
            no_change_count=sum(abs(population(index_individual).nodegenes(4,:)-vector_node_state)<no_change_threshold); %check for alle nodes where the node output state has changed by less than no_change_threshold since last iteration through all the connection genes
        end
        if index_loop>=2.7*number_connections
            index_individual;
            population(index_individual).connectiongenes;
        end
        output1=[output1;population(index_individual).nodegenes(4,4)];
        output2=[output2;population(index_individual).nodegenes(4,5)];
    end
    %%%%%% EVALUATE THE FITNESS FUNCTION FOR A CHROMOSOME HERE%%%%%%%%%%%
    OccVector = (round(output1)+round(output2)).*round(output1); % output1 is filled/not, output2 is mat1/mat2
    OccMatrix = reshape(OccVector,nx,ny)';
    OccMatrix(end,1) = 1; %Place a static node bottom left
    OccMatrix(end-1,1) = 2; %Place an actuated node above it (guarantees actuation)
    OccMatrix(1,end) = 1; %Place a static node upper right
    
    population_plus_fitnesses(index_individual).design = OccMatrix;
  
        
%     for p = 1:number_individuals
%         if isempty(population_plus_fitnesses(p).design),continue
%         elseif population_plus_fitnesses(index_individual).design == population_plus_fitnesses(p).design
%             population_plus_fitnesses(index_individual).fitness = population_plus_fitnesses(p).fitness;
%         else % only simulate if the expressed design isn't already in the population to save time
%             population_plus_fitnesses(index_individual).fitness = cppn_simulate(OccMatrix,0); %Fitness function as defined by Colin Smith
%         end
%     end
    population_plus_fitnesses(index_individual).fitness = cppn_simulate(OccMatrix,0);
    
end

% ACTIVATION HELPER FUNCTION
    function population_out = activation(population_in, number_nodes)
        population_out = population_in;
        
        for j = 4:number_nodes
            func = population_out.nodegenes(5,j); % activation function for node j
            if func == 1 %sigmoid
                population_out.nodegenes(4,j) = 1./(1+exp(-4.9*population_in.nodegenes(3,j))); % y = sig(x)
            elseif func == 2 % gaussian
                population_out.nodegenes(4,j) = 1./(sqrt(2*pi)*exp(-0.5*population_in.nodegenes(3,j).^2)); % y = gauss(x)
            elseif func == 3 % sine
                population_out.nodegenes(4,j) = sin(population_in.nodegenes(3,j)); % y = sin(x)
            elseif func == 4 % linear
                population_out.nodegenes(4,j) = population_in.nodegenes(3,j); % y = x
            else % error
            end
        end
    end

    function fitness = cppn_simulate(OccMatrix,animate)
        % check to ensure there is a voxel in every row. If not, this is
        % invalid. This should save some CPU time.
        if nnz(~sum(OccMatrix,2)) % if there are empty columns
            fitness = 0;
            return
        end
        fitness = simulate_beam(OccMatrix, animate); % use horiz displacment
        %disp =  = simulate_beam(OccMatrix, animate); % use horiz displacment
        %n_static = sum(OccMatrix~=2,'all');
        %n_voxel = numel(OccMatrix);
        %fitness = disp + n_static/n_voxel; % penalize actuator voxels
        %fitness = disp/(sum(OccMatrix==2,'all'));
    end

end
