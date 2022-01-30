function out_pos = equiangular_coordinates(res, radius, ele_max, ele_min)
% generate 3d grid with arbitrary spatial resolution 
if nargin<1
    res = 1; % angle resolution
    radius = 1;
end
if nargin<2
    radius = 1;
end
if nargin <3 
    ele_max = 90;
    ele_min = -90;
end
base_azi = 0:res:360-res;
base_ele = sort([0:res:ele_max , 0-res:-res:ele_min]);

ele = repmat(base_ele, [length(base_azi), 1]);
azi = repmat(base_azi, [1,length(base_ele)]);
r = ones(length(ele(:)), 1) * radius;
% ele = ele(:);
% azi = azi(:);
out_pos = [azi(:), ele(:), r];
end
