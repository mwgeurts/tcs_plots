function UpdateTable(obj, varargin)
% UpdateTable updates the Dx/Vx values for a DVH table and displays Gamma
% pass rates for each structure. Prior to executing this function, call 
% InitializeData to generate the data cell array. Parameters are passed to
% this function the same way as the DVHViewer class, with the added
% parameter 'row' to indicate which structure Dx value to update (if not
% provided, all values are re-calculated, including Gamma). This function 
% is called automatically during the Calculate() function call.
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
   
% Initialize empty row var
row = [];

% Apply variable input arguments
for i = 1:2:length(varargin)
    
    % If name matches a property
    if strcmpi(varargin{i}, 'data')
        obj.data = varargin{i+1};
    elseif strcmpi(varargin{i}, 'row')
        row = varargin{i+1};
    elseif strcmpi(varargin{i}, 'gamma')
        obj.gamma = varargin{i+1};
    end
end

% If columns is less than three, throw an error
if obj.columns < 3
    
    % This function is not applicable
    if exist('Event', 'file') == 2
        Event(['UpdateTable is not applicable unless the number of table ', ...
            'columns is greater than 2'], 'ERROR'); 
    else
        error(['UpdateTable is not applicable unless the number of table ', ...
            'columns is greater than 2']);
    end
end

% Log start of DVH computation and start timer
if exist('Event', 'file') == 2
    Event('Updating dose volume histogram plot');
    t = tic;
end

% Loop through the data array
for i = 1:size(obj.data, 1)
    
    % If this is the row to edit
    if isempty(row) || i == row
        
        % Format Dx value
        obj.data{i,3} = sprintf('%0.1f', str2double(obj.data{i,3}));
        
        % Loop through DVH arrays
        for j = 1:length(obj.dvh)
            
            % If the number of columns includes this Vx
            if obj.columns >= j + 3
                
                % Reverse DVH orientation (to make y-axis values ascending)
                w = flipud(obj.dvh{j}(:, size(obj.dvh{j}, 2)));
                
                % Remove unique values in DVH (interp1 fails with unique lookup 
                % values)
                [u, v, ~] = unique(flipud(obj.dvh{j}(:, i)));

                % Interpolate DVH to Dx value 
                obj.data{i,j+3} = sprintf('%0.1f', interp1(u, w(v), ...
                    str2double(obj.data{i,3}), 'linear'));
            end
        end
        
        % If Gamma data exists and the number of columns supports it
        if ~isempty(obj.gamma) && obj.columns > 3 + length(obj.dvh)
        
            % Store the Gamma indices within this structure
            g = obj.gamma(obj.structures{i}.mask > 0);
            
            % Store the number of voxels less than 1, relative to the total
            % number of voxels. Note that voxels where Gamma is zero
            % (presumably where it was not calculated)
            obj.data{i,length(obj.dvh)+4} = sprintf('%0.1f%%', sum(g<1) / ...
                length(g) * 100);
        end
    end
end

% If a table UI is present, update it
if ~isempty(obj.table) && isgraphics(obj.table)
    set(obj.table, 'Data', obj.data);
end

% Log completion
if exist('Event', 'file') == 2
    Event(sprintf('Update completed in %0.3f seconds', toc(t)));
end

% Clear temporary variables
clear i j t w u v g;