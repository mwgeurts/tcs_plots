classdef ImageViewer < handle
% ImageViewer is a MATLAB class that creates TCS plots of CT and Dose data.
% One ImageViewer object is created for each plot (in the T, C, or S
% dimension). Image and dose data is passed to this object using the same
% structure format detailed in the tomo_extract functions LoadImage.m and 
% LoadPlanDose.m. In addition, a slider UI handle can optionally be linked
% to the TCS image to control what slice is currently being viewed.
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
    tcsview = 'T'
    background = []
    overlay = []
    backgroundrange = []
    overlayrange = []
    alpha = 0.3
    structures = []
    structuresonoff = []
    slider = []
    slice = []
    zoom = 'on'
    pixelval = 'on'
    cbar = 'on'
end

% Define constructor/destructor function
methods

    % Constructor function
    function obj = ImageViewer(varargin)
        % Inputs are provided to this function in name/value pairs,
        % where the name is an odd integer of nargin and equals the
        % string value of one of the properties above, and value is the
        % value to be stored.

        % Log action
        if exist('Event', 'file') == 2
            Event('Constructing image viewer');
        end

        % Loop through inputs
        for i = 1:2:nargin

            % If name matches a property
            if strcmpi(varargin{i}, 'axis')
                obj.axis = varargin{i+1};
            elseif strcmpi(varargin{i}, 'tcsview')
                obj.tcsview = varargin{i+1};
            elseif strcmpi(varargin{i}, 'background')
                obj.background = varargin{i+1};
            elseif strcmpi(varargin{i}, 'overlay')
                obj.overlay = varargin{i+1};
            elseif strcmpi(varargin{i}, 'backgroundrange')
                obj.backgroundrange = varargin{i+1};
            elseif strcmpi(varargin{i}, 'overlayrange')
                obj.overlayrange = varargin{i+1};
            elseif strcmpi(varargin{i}, 'alpha')
                obj.alpha = varargin{i+1};
            elseif strcmpi(varargin{i}, 'structures')
                obj.structures = varargin{i+1};
            elseif strcmpi(varargin{i}, 'structuresonoff')
                obj.structuresonoff = varargin{i+1};
            elseif strcmpi(varargin{i}, 'slider')
                obj.slider = varargin{i+1};
            elseif strcmpi(varargin{i}, 'slice')
                obj.slice = varargin{i+1};
            elseif strcmpi(varargin{i}, 'zoom')
                obj.zoom = varargin{i+1};
            elseif strcmpi(varargin{i}, 'pixelval')
                obj.pixelval = varargin{i+1};
            elseif strcmpi(varargin{i}, 'cbar')
                obj.cbar = varargin{i+1};
            end
        end

        % At least the axis must be defined here
        if isempty(obj.axis) || ~isgraphics(obj.axis, 'Axes')
            if exist('Event', 'file') == 2
                Event(['An axis handle must be passed when creating ', ...
                    'an ImageViewer object'], 'ERROR');
            else
                error(['An axis handle must be passed when creating ', ...
                    'an ImageViewer object']);
            end
        end

        % Start by hiding this display
        set(allchild(obj.axis), 'visible', 'off'); 
        set(obj.axis, 'visible', 'off');

        % If a slider was included, hide it too
        if ~isempty(obj.slider) && ishandle(obj.slider)
            set(obj.slider, 'visible', 'off');
        end

        % If a colorbar is on, turn that off too
        if strcmpi(obj.cbar, 'on')
            colorbar(obj.axis, 'off');
        end

        % If background data is provided, continue to auto-initialize
        % the image viewer
        obj = obj.Initialize();
    end

    % Destructor function
    function delete(obj)

        % Hide this display
        set(allchild(obj.axis), 'visible', 'off'); 
        set(obj.axis, 'visible', 'off');

        % Remove zoom limits
        obj.axis.XLim = [0 1];
        obj.axis.YLim = [0 1];

        % If a slider was included, hide it too
        if ~isempty(obj.slider) && ishandle(obj.slider)
            set(obj.slider, 'visible', 'off');
        end

        % If a colorbar is on, turn that off too
        if strcmpi(obj.cbar, 'on')
            colorbar(obj.axis, 'off');
        end
    end

    % Hide function
    function Hide(obj)

        % Hide this display
        set(allchild(obj.axis), 'visible', 'off'); 
        set(obj.axis, 'visible', 'off');

        % If a slider was included, hide it too
        if ~isempty(obj.slider) && ishandle(obj.slider)
            set(obj.slider, 'visible', 'off');
        end

        % If a colorbar is on, turn that off too
        if strcmpi(obj.cbar, 'on')
            colorbar(obj.axis, 'off');
        end
    end 
end

end