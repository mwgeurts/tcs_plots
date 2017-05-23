function Calculate(obj, varargin)
% Calculate computes the relative volume cumulative dose volume histogram
% for a set of structures and one or more dose volumes. See the DVHViewer
% class for more information.
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

% Log start of DVH computation and start timer
Event('Computing dose volume histograms');
t = tic;

% Apply variable input arguments
for i = 1:2:length(varargin)
    
    % If name matches a property
    if strcmpi(varargin{i}, 'structures')
        obj.structures = varargin{i+1};
    elseif strcmpi(varargin{i}, 'doseA')
        obj.dose{1} = varargin{i+1};
    elseif strcmpi(varargin{i}, 'doseB')
        obj.dose{2} = varargin{i+1};
    elseif strcmpi(varargin{i}, 'type')
        obj.type = varargin{i+1};
    elseif strcmpi(varargin{i}, 'volume')
        obj.volume = varargin{i+1};
     elseif strcmpi(varargin{i}, 'legend')
        obj.legend = varargin{i+1};
    end
end

% Loop through the dose arrays
for i = 1:length(obj.dose)
    
    % If the dose variable contains a valid data array
    if ~isempty(obj.dose{i}) && isfield(obj.dose{i}, 'data') && ...
            size(obj.dose{i}.data, 1) > 0 && iscell(obj.structures)

        % If the image size differs between the structure mask and dose
        if ~isequal(size(obj.dose{i}.data), size(obj.structures{1}.mask))

            % Log an error
            if exist('Event', 'file') == 2
                Event(['The dose volume must be the same size as each ', ...
                    'structure set mask when computing DVH'], 'ERROR');
            else
                error(['The dose volume must be the same size as each ', ...
                    'structure set mask when computing DVH']);
            end
        end

        % Store the maximum value in the reference dose
        m = max(max(max(obj.dose{i}.data)));

        % Initialize array for DVH values
        obj.dvh{i} = zeros(obj.bins, length(obj.structures) + 1);

        % Defined the last column to be the x-axis, ranging from 0 to the
        % maximum dose
        obj.dvh{i}(:, length(obj.structures) + 1) = 0:m / (obj.bins-1):m;

        % Loop through each reference structure
        for j = 1:length(obj.structures)

            % Compute differential histogram
            obj.dvh{i}(1:end-1,j) = histcounts(obj.dose{i}.data(...
                obj.structures{j}.mask > 0), ...
                obj.dvh{i}(:, length(obj.structures) + 1));

            % If the type is relative
            if strcmpi(obj.volume, 'relative')

                % Normalize histogram to relative volume
                obj.dvh{i}(:,j) = obj.dvh{i}(:,j) / ...
                    sum(obj.dvh{i}(:,j)) * 100;

            % If the type is absolute
            else

                % Multiply by voxel size
                obj.dvh{i}(:,j) = obj.dvh{i}(:,j) * prod(obj.dose{i}.width);
            end

            % If the type is cumulative
            if strcmpi(obj.type, 'cumulative')

                % Compute cumulative histogram
                obj.dvh{i}(:,j) = flipud(cumsum(flipud(obj.dvh{i}(:,j))));
            end
        end
    end
end

% If a DVH axes is provided, update it
if ~isempty(obj.axis) && isgraphics(obj.axis, 'Axes')
    obj.UpdatePlot();
end

% If a DVH table is provided, update it
if ~isempty(obj.table) && isgraphics(obj.table)
    obj.UpdateTable();
end

% Log completion of function
Event(sprintf(['Dose volume histograms completed successfully in ', ...
    '%0.3f seconds'], toc(t)));

% Clear temporary variables
clear i j t m;
