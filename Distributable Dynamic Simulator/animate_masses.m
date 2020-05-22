% animate_masses - plot the evolution of a tabularized set of point masses
%   as they evolves over time.
% On input:
%     tabularized_masses (cell array): A cell array of mass handles from
%       Tabularize_Voxels.m
%     FigureHandle (1x1 Figure): Optional arguement for plotting to
%       a specific figure
%     Save_Video_Boolean (bool): Optional arguement for saving an avi of
%       the animation
%
% On output:
%
% Author:
%     Travis Hainsworth
%     CUB
%     Spring 2018
%

function animate_masses(table, FigureHandle, Save_Video_Boolean)
    if nargin < 2, FigureHandle = figure(); end % open the next possible figure
    if nargin < 3, Save_Video_Boolean = 0; end  % don't save the video
    
    if Save_Video_Boolean == 1 % Create the avi file
        video = VideoWriter('mesh_animation.avi');
        open(video);
    end
    
    % if there isn't any depth in z direction make the problem 2d
    if length(table{1,1,1}.Rest) == 2, d3 = 0;
    else       d3 = 1; end
    
    % define axis limits CURRENTLY MAKES SQUARE AXIS
    % note that mesh.X is position in the points reference frame so you
    % must add mesh.Rest
% %     mx_X = max(max([table{:,1,1}.X])); % max value of all of the point masses in the global frame
% %     mx_R = max(max([table{:,1,1}.Rest]));
% %     mx = mx_X + mx_R; % There should be a cleaner way to do this...
% %     mn_X = min(min([table{:,1,1}.X])); 
% %     mn_R = min(min([table{:,1,1}.Rest]));
% %     mn = mn_X + mn_R;
% %     
% %     if d3 == 1
% %         AxisLimits = [mn-1 mx+1 mn-1 mx+1 mn-1 mx+1];
% %     else
% %         AxisLimits = [mn-1 mx+1 mn-1 mx+1];
% %     end
    
    % set the current figure handle    
    set(0,'CurrentFigure',FigureHandle);
    
    % Determine how many time steps there are    
    NumSteps = length(table{1,1,1}.T);
    counter  = 0;
    plotter = 1;
    for h = 2:NumSteps-1 %start at 2 for pausing time definition and end at minus 1 to avoid the blank finish
        % Shenanigans
        if plotter == 1
            counter = counter + 0.1;
        end
        current_time = table{1,1,1}.T(h);
        if current_time > counter
            plotter = 1;
            
            % End of Shenanigans
            tic
            clf(FigureHandle);    
    % %         axis(AxisLimits)
            hold on

            % plot all of the points
            i = 0;
            while 1 == 1
                i = i+1;
                try
                    if d3 == 1
                            % 3d
                            p = table{i,1,1}.X(h,:); 
                            plot3(p(1),p(2),p(3),'o','color',table{i,1,1}.color,'linewidth',6)
                            grid on
                        else
                            % 2d
                            p = table{i,1}.X(h,:); 
                            plot(p(1),p(2),'o','color',table{i,1}.color,'linewidth',6)
                    end
                catch
                    break
                end
            end

            title_string = sprintf('Time = %d',current_time);
            title(title_string);

            drawnow

            % get animation info
            if Save_Video_Boolean == 1 % Write to the avi file
                frame = getframe(fig);
                writeVideo(video,frame);        
            end
            %fprintf('Time: %d\n', table{1,1,1}.T(h));
            % pause for appropriate time
            elapsed_time = toc;
            TimeStep = current_time-table{1,1,1}.T(h-1); % Pause for appropriate time
            if elapsed_time < TimeStep
                pause(TimeStep-elapsed_time) % Doesn't work as expected, though the pause is necessary for the plot to actually show up. TODO
            end
        else % Psych here is some shenanigans
            plotter = 0;            
        end
    end
    
    % close the video
    if Save_Video_Boolean, close(video); end % Close the video
    
end


    
