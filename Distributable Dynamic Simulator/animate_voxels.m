% animate_voxels
% On input:
%     
%
% On output:
%
% Author:
%     Travis Hainsworth
%     CUB
%     Spring 2018
%

function animate_voxels(Voxel_Mesh, FigureHandle, Save_Video_Boolean)
    if nargin < 2, FigureHandle = figure(); end % open the next possible figure
    if nargin < 3, Save_Video_Boolean = 0; end  % don't save the video
    
    if Save_Video_Boolean == 1 % Create the avi file
        video = VideoWriter('mesh_animation.avi');
        open(video);
    end
    
    % if there isn't any depth in z direction make the problem 2d
    if length(Voxel_Mesh{1,1,1}.DL.Rest) == 2, d3 = 0;
    else       d3 = 1; end
    
    % Determine number of voxels
    [row,col,dep] = size(Voxel_Mesh);
    
    % set the current figure handle    
    set(0,'CurrentFigure',FigureHandle);
    
    % Determine how many time steps there are    
    NumSteps = length(Voxel_Mesh{1,1,1}.DL.T);    
    counter  = 0;
    plotter = 1;
    for h = 2:NumSteps-1 %start at 2 for pausing time definition and end at minus 1 to avoid the blank finish
        % Shenanigans
        if plotter == 1
            counter = counter + 0.1;
        end
        current_time = Voxel_Mesh{1,1,1}.DL.T(h);
        if current_time > counter
            plotter = 1;
            
            % End of Shenanigans
            tic
            clf(FigureHandle);   
            hold on

            % plot all of the surface voxels
            for i = 1:row
                for j = 1:col
                    % Don't plot if the voxel is a void (represented by
                    % white face and white edges
                    if all(Voxel_Mesh{i,j}.face_color ~= 'w') || all(Voxel_Mesh{i,j}.edge_color ~= 'w')
                        v = zeros(4+4*d3,2+d3);
                        for mass = 1:4+4*d3
                            v(mass,:) = Voxel_Mesh{i,j}.mass_handle_array(mass).X(h,:);
                        end
                        f = [2 1 3 4];
                        patch('Faces', f, 'Vertices', v, 'FaceColor', Voxel_Mesh{i,j}.face_color, 'EdgeColor', Voxel_Mesh{i,j}.edge_color);
                    end
                end
            end

            %%%% Tidy up the plot %%%%
            title_string = sprintf('Time = %d',current_time);
            title(title_string);
            axis('equal')
            drawnow

            % get animation info
            if Save_Video_Boolean == 1 % Write to the avi file
                frame = getframe(FigureHandle);
                writeVideo(video,frame);        
            end
            
            % pause for appropriate time
            elapsed_time = toc;
            TimeStep = current_time-Voxel_Mesh{1,1,1}.DL.T(h-1); % Pause for appropriate time
            if elapsed_time < TimeStep
                pause(TimeStep-elapsed_time) 
            end
        else % Psych here is some more shenanigans
            plotter = 0;            
        end
    end
    
    % close the video
    if Save_Video_Boolean, close(video); end % Close the video
    
end


    
