classdef DVHViewer < handle
% DVHViewer is a MATLAB class that creates a DVH plots RTSS and Dose data.
% Image and dose data is passed to this object using the same structure 
% format detailed in the tomo_extract functions LoadStructures.m and 
% LoadPlanDose.m. This class can support up to two different dose volumes.
% In addition, this class can support a table that lists all structure 
% names/colors, provide input to show/hide structures, as well as to 
% compute and display the Dx/Vx values or Gamma pass rates for each 
% structure.
%
% For more information on how this class is used, or to see it in action,
% see the application CheckTomo at https://github.com/mwgeurts/checktomo.
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
    
% Define image viewer properties
properties (Access = protected)
    axis
    dose = []
    dvh = []
    structures = []
    table = []
    columns = 2
    data = []
    gamma = []
    atlas = []
    type = 'cumulative'
    volume = 'relative'
    legend = []
    bins = 1001
end

% Define constructor/destructor function
methods

    % Constructor function
    function obj = DVHViewer(varargin)
        % Inputs are provided to this function in name/value pairs,
        % where the name is an odd integer of nargin and equals the
        % string value of one of the properties above, and value is the
        % value to be stored.

        % Log action
        if exist('Event', 'file') == 2
            Event('Constructing DVH viewer');
        end

        % Loop through inputs
        for i = 1:2:nargin

            % If name matches a property
            if strcmpi(varargin{i}, 'axis')
                obj.axis = varargin{i+1};
            elseif strcmpi(varargin{i}, 'doseA')
                obj.dose{1} = varargin{i+1};
            elseif strcmpi(varargin{i}, 'doseB')
                obj.dose{2} = varargin{i+1};
            elseif strcmpi(varargin{i}, 'dvhA')
                obj.dvh{1} = varargin{i+1};
            elseif strcmpi(varargin{i}, 'dvhB')
                obj.dvh{2} = varargin{i+1};
            elseif strcmpi(varargin{i}, 'structures')
                obj.structures = varargin{i+1};
            elseif strcmpi(varargin{i}, 'table')
                obj.table = varargin{i+1};
            elseif strcmpi(varargin{i}, 'columns')
                obj.columns = varargin{i+1};
            elseif strcmpi(varargin{i}, 'data')
                obj.data = varargin{i+1};
            elseif strcmpi(varargin{i}, 'gamma')
                obj.gamma = varargin{i+1};
            elseif strcmpi(varargin{i}, 'atlas')
                obj.atlas = varargin{i+1};
            elseif strcmpi(varargin{i}, 'type')
                obj.type = varargin{i+1};
            elseif strcmpi(varargin{i}, 'volume')
                obj.volume = varargin{i+1};
            elseif strcmpi(varargin{i}, 'legend')
                obj.legend = varargin{i+1};
            elseif strcmpi(varargin{i}, 'bins')
                obj.bins = varargin{i+1};
            end
        end

        % At least the the dose and structures must be defined here
        if isempty(obj.structures) || isempty(obj.dose{1})
            if exist('Event', 'file') == 2
                Event(['Dose and structure inputs must be passed when ', ...
                    'creating a DVHViewer object'], 'ERROR');
            else
                error(['Dose and structure inputs must be passed when ', ...
                    'creating a DVHViewer object']);
            end
        end

        % Start by hiding this display
        set(allchild(obj.axis), 'visible', 'off'); 
        set(obj.axis, 'visible', 'off');

        % If tabular data was not provided, initialize one
        if isempty(obj.data)
            obj.InitializeData();
        end
        
        % If DVH data is not computed, compute it
        if isempty(obj.dvh) || (iscell(obj.dose) && length(obj.dose) > 1 && ...
                ~isempty(obj.dose{2}) && isempty(obj.dvh{2}))
           obj.Calculate();
        end
    end

    % Destructor function
    function delete(obj)

        % Hide this display
        if ~isempty(obj.axis) && isgraphics(obj.axis, 'Axes')
            set(allchild(obj.axis), 'visible', 'off'); 
            set(obj.axis, 'visible', 'off');
        end
        
        % Clear the table contents
        if ~isempty(obj.table) && isgraphics(obj.table)
            set(obj.table, 'Data', cell(16, obj.columns));
        end
    end

    % Hide function
    function Hide(obj)

        % Hide this display
        if ~isempty(obj.axis) && isgraphics(obj.axis, 'Axes')
            set(allchild(obj.axis), 'visible', 'off'); 
            set(obj.axis, 'visible', 'off');
        end
        
        % Clear the table contents
        if ~isempty(obj.table) && isgraphics(obj.table)
            set(obj.table, 'Data', cell(16, obj.columns));
        end
    end 
end

end