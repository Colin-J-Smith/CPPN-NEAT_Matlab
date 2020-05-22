% Demo - Demonstration of simulating a beam
%
% input:
%
% output:
%
% notes:
%   See the read_me.txt for a list of parameters that can be changed in
%       different scripts
% 
% author:
%   Travis Hainsworth
%   Spring 2018
%   University of Colorado - Boulder

clear all
close all

%%%% Define a beam based on a Boolean occupancy matrix %%%%
fill = [1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1;];
    
fill = [1 2 ;
        1 2 ;
        1 2 ];


%%%% Simulate and animate the beam %%%%
animate = 1; % 1 for true and 0 for false

overall = tic;
max_deflection = simulate_beam(fill,animate)
t_overall = toc(overall)