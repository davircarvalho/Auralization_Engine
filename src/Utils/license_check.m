function [result, missing] = license_check(required_licenses)
% required_licenses: cell containing the 'License feature names' 
%                    you want to check (see documentation for 'license()')

% result:           logical value 1: indicates there is nothing missing
%                   logical value 0: one or more are missing
% missing:          cell containing the name of the missing licenses


% for documentation on license names check 
% required_licenses = {'image_toolbox',...
%                 'matlab',...
%                 'signal_blocks',...
%                 'signal_toolbox'};
            
%% Test if they required licenses exist            
N = length(required_licenses);
toolbox_exists = zeros(1,N);
missing = cell(1,N);
for k =1:N
    toolbox_exists(k) = license('test', required_licenses{k});
    if ~toolbox_exists(k)
        missing{k} = ['- ' required_licenses{k} ' '];
    end
end

%% prepare output
if ~all(toolbox_exists)
    result = false; % do not run what's next because something is missing
else 
    result = true; % everything seems fine, please continue
end

% squeeze empty cells
missing = missing(~cellfun('isempty',missing));
end