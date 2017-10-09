function InitializeData(obj, varargin)
% InitalizeData reads in a cell array of structures and creates a uitable 
% compatible cell array for displaying structure statistics. If an atlas is 
% also provided, the structure names will be matched to the atlas and the 
% Dx/Vx values will be used from the atlas.  If not provided, default 
% values will be applied to all structures.
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2017 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% Log beginning of DVH initialization and start timer
if exist('Event', 'file') == 2
    Event('Initalizing DVH table data');
    t = tic;
end

% Apply variable input arguments
for i = 1:2:length(varargin)
    
    % If name matches a property
    if strcmpi(varargin{i}, 'structures')
        obj.structures = varargin{i+1};
    elseif strcmpi(varargin{i}, 'table')
        obj.table = varargin{i+1};
    elseif strcmpi(varargin{i}, 'atlas')
        obj.atlas = varargin{i+1};
    end
end

% Initialize empty return cell array
obj.data = cell(length(obj.structures), obj.columns);

% Loop through each structure
for i = 1:length(obj.structures)
    
    % Set structure name (in color) and volume
    obj.data{i,1} = sprintf(['<html><font id="%s" color="rgb(%i,%i,%i)"', ...
        '>%s</font></html>'], obj.structures{i}.name, ...
        obj.structures{i}.color(1), ...
        obj.structures{i}.color(2), ...
        obj.structures{i}.color(3), ...
        obj.structures{i}.name);

    % If more than two columns are requested
    if obj.columns > 2
    
        % Set the default Dx (50%)
        obj.data{i,3} = '50.0';

    end

    % If an atlas was also provided to InitializeStatistics
    if ~isempty(obj.atlas)   
        
        % Hide unmatched contours
        obj.data{i,2} = false;

        % Loop through each atlas structure
        for j = 1:size(obj.atlas, 2)

            % Compute the number of include atlas REGEXP matches
            in = regexpi(obj.structures{i}.name, ...
                obj.atlas{j}.include);

            % If the atlas structure also contains an exclude REGEXP
            if isfield(obj.atlas{j}, 'exclude') 

                % Compute the number of exclude atlas REGEXP matches
                ex = regexpi(obj.structures{i}.name, ...
                    obj.atlas{j}.exclude);
            else
                % Otherwise, return 0 exclusion matches
                ex = [];
            end

            % If the structure matched the include REGEXP and not the
            % exclude REGEXP (if it exists)
            if size(in, 1) > 0 && size(ex, 1) == 0

                % If more than two columns are requested
                if obj.columns > 2

                    % Use the atlas Dx
                    obj.data{i,3} = sprintf('%0.1f', obj.atlas{j}.dx);
                end

                % Show matched contours
                obj.data{i,2} = true;

                % Stop the atlas for loop, as the structure was matched
                break;
            end
        end

        % Clear temporary variables
        clear in ex;
    
    % Otherwise, no atlas was given
    else
        
        % Show all contours
        obj.data{i,2} = true;
    end
end

% If a table UI is present, update it
if ~isempty(obj.table) && isgraphics(obj.table)
    set(obj.table, 'Data', obj.data);
end

% Log completion and duration required
if exist('Event', 'file') == 2
    Event(sprintf(['Structure table initialization completed successfully', ...
        ' in %0.3f seconds'], toc(t)));
end

% Clear temporary variables 
clear i j t;
