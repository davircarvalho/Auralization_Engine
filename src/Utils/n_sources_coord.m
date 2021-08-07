%% positions according to number of required source
function [azi, ele] = n_sources_coord(n)
switch n 
    case 1
        azi = 0;
        ele = 0;
    case 2
        azi = [-30, 30];
        ele = [  0,  0];
    case 3
        azi = [-30, 0, 30];
        ele = [  0, 0,  0];
    case 4
        azi = [-110, -40, 40, 110];
        ele = [   0,   0,  0,   0];
    case 5
        azi = [-110, -40, 0, 40, 110];
        ele = [   0,   0, 0,  0,   0];
    case 6 
        azi = [-110, -40, -20, 20, 40, 110];
        ele = [   0,   0,   0,  0,  0,   0];
    case 7
        azi = [-150, -110, -30, 0, 30, 110, 150];
        ele = [   0,    0,   0, 0,  0,   0,   0];        
    otherwise
        azi = linspace(-179, 179, n);
        ele = zeros(1, n);        
end
end