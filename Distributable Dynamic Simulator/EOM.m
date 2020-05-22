% Create_EOM


function s_dot = EOM(t,s,table,Gravity,Solver)

   d3 = length(table{1,1}.Rest)-2;
   Num_Points = length(table); % Only interested in the first output (num rows)
   
   %%%% define s_dot in terms of s and the table data %%%%
   if Solver == 1       
       s_dot = zeros(size(s));
   elseif Solver == 2 % Symbolic solver
       s_dot = sym('a',size(s));
   else % fprintf solver
       % Open file
       ID = fopen('EOM_written.m','w');
       % create header
       fprintf(ID,'function s_dot=EOM_written(t,s)\n');
       % Pre allocate s_dot
       fprintf(ID,'s_dot=single(zeros(%d,1));\n',length(s));
   end
   
   count = 1;
   
   for i = 1:Num_Points
       % Don't move fixed points or massless points
       if table{i,1,1}.clamped == 1 || table{i,1,1}.m == 0
           s_dot(count:count+3+2*d3) = zeros(4+2*d3,1);
           if Solver == 3
               fprintf(ID,'s_dot(%d:%d) = ', count, count+3+2*d3);
               zero_print(ID,4+2*d3,1);
           end
       else                           
           %%% velocity term is easy
           s_dot(count:count+1+d3) = s(count+2+d3:count+3+2*d3);
           if Solver == 3
               fprintf(ID,'s_dot(%d:%d) = s(%d:%d);\n',count,count+1+d3,count+2+d3,count+3+2*d3);
           end

           %%% acceleration term is less easy
           spring = zeros(2+d3,1);                                   
           damp = spring; 
           if Solver == 3
               fprintf(ID,'spring = ');
               array_print(ID,spring,1);
               fprintf(ID,'damp = ');
               array_print(ID,damp,1);
           end
           % loop through all of the neighbors
           j = 1; % start at 1 (you don't want to look at yourself)
           while 1 == 1
               j = j+1;
               try
                   % Sum the vector forces from every possible connection
                   % (see HW 2 hint)
                   k = table{i,j,2}; b = table{i,j,3}; %material = table{i,j,4}; 

                   % Get index of neighboring point
                   ind = cell_find(table{i,j,1},table{:,1,1});

                   B = s((ind-1)*(4+2*d3)+1:(ind-1)*(4+2*d3)+2+d3); % Position of neighbor
                   A = s(count:count+1+d3);           % Position of point
                   BA = B-A; 
                   if norm(BA) ~= 0 % If this happens then the points are atop each other, so we'll just skip it for a time step, then let it correct itself
                       BA_init = table{i,j,1}.Rest'-table{i,1,1}.Rest';   
                       BA_hat = BA/norm(BA);  

                       Bd = s((ind-1)*(4+2*d3)+3+d3:(ind-1)*(4+2*d3)+4+2*d3);% Velocity of neighbor
                       Ad = s(count+2+d3:count+3+2*d3); % Velocity of point
                       BAd = Bd-Ad;

                       Fk = k*(norm(BA)-norm(BA_init))*BA_hat;             
                       Fd = b*(dot(BAd,BA_hat))*BA_hat;                    

                       spring = spring+Fk;                                 
                       damp = damp+Fd;  
                       
                       if Solver == 3
                           fprintf(ID,'BA = s(%d:%d)-s(%d:%d);\n',(ind-1)*(4+2*d3)+1,(ind-1)*(4+2*d3)+2+d3,count,count+1+d3);
                           fprintf(ID,'BAnorm = ');
                           norm_print(ID,'BA',d3,1);
                           fprintf(ID,'BA_hat = BA/BAnorm;\n');
                           % check which material is being used
                           if (table{i,j,5} > 3)%2) && (mod(table{i,j,5},2) == 0)% added the time initial length (volumetric expansion)
                               fprintf(ID,'Fk = %f*(BAnorm- %f - 0.05*t)*BA_hat;\n',k,norm(BA_init)); 
                           else % unactuated voxel
                               fprintf(ID,'Fk = %f*(BAnorm- %f)*BA_hat;\n',k,norm(BA_init));
                           end
                           if b ~= 0
                               fprintf(ID,'BAd= s(%d:%d)-s(%d:%d);\n',(ind-1)*(4+2*d3)+3+d3,(ind-1)*(4+2*d3)+4+2*d3,count+2+d3,count+3+2*d3);
                               fprintf(ID,'Fd = %f*',b);
                               dot_print(ID,'BAd','BA_hat',d3,0);
                               fprintf(ID,'*BA_hat;\n');
                           else
                               fprintf(ID,'Fd = 0.0;\n');
                           end
                           fprintf(ID,'spring = spring+Fk;\ndamp = damp+Fd;\n');
                       end
                   end
               catch
                   break
               end
           end   
           static = table{i,1,1}.Static_Force; % Continual forces on a point
           s_dot(count+2+d3:count+3+2*d3) = (spring+damp+static)/table{i,1,1}.m+Gravity;
           if Solver == 3
               fprintf(ID,'s_dot(%d:%d) = (spring+damp+',count+2+d3,count+3+2*d3);
               array_print(ID,static,0);
               fprintf(ID,')/%f+',table{i,1,1}.m);
               array_print(ID,Gravity,1);
           end
       end
       %%%% Update count
       count = count + 4 + 2*d3;
   end
   
   if Solver == 3 % Close the file for fprintf method
       fprintf(ID,'end');
       fclose(ID);
   end
   
%%%% Helper function %%%%
% find doesn't work on a row/col of a cell array :(
function index = cell_find(point,varargin)
    for index = 1:length(varargin)
        if point == varargin{index}
            break
        end
    end
end
% need to be able to fprintf arrays
function array_print(ID,array,End_of_line)
    fprintf(ID,'[');
    for ii = 1:length(array)
        fprintf(ID,'%f',array(ii));
        if ii == length(array)
            fprintf(ID,']');
        else
            fprintf(ID,';');
        end
    end
    if End_of_line == 1
        fprintf(ID,';\n');
    end
end
% try fprintf the zeros instead of using function zeros
function zero_print(ID,size,End_of_line)
    fprintf(ID,'[');
    for ii = 1:size-1
        fprintf(ID,'0.0;');
    end
    fprintf(ID,'0.0]');
    if End_of_line == 1
        fprintf(ID,';\n');
    end
end
% fprintf the norm instead of using the function
function norm_print(ID,array_name,d3,End_of_line)
    fprintf(ID,'sqrt(');
    for ii = 1:2+d3-1
        fprintf(ID,array_name);
        fprintf(ID,'(%d)^2+',ii);
    end
    fprintf(ID,array_name);
    fprintf(ID,'(%d)^2)',2+d3);
    if End_of_line == 1
        fprintf(ID,';\n');
    end
end
function dot_print(ID,A_name,B_name,d3,End_of_line)
    fprintf(ID,'(');
    for ii = 1:2+d3
        fprintf(ID,A_name);
        fprintf(ID,'(%d)*',ii);
        fprintf(ID,B_name);
        fprintf(ID,'(%d)',ii);
        if ii == 2+d3
            fprintf(ID,')');
        else
            fprintf(ID,'+');
        end
    end
    if End_of_line == 1
        fprintf(ID,';\n');
    end
end
end
