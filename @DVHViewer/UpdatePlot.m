function UpdatePlot(obj, varargin)
% UpdatePlot re-plots the provided DVH with new DVH data, structure colors,
% legend text, or structure display cell data. This function is called 
% automatically during the Calculate() function call.
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
% with this program. If not, see http://www.gnu.org/licenses/

% Log start of DVH computation and start timer
if exist('Event', 'file') == 2
    Event('Updating dose volume histogram plot');
    t = tic;
end

% Apply variable input arguments
for i = 1:2:length(varargin)
    
    % If name matches a property
    if strcmpi(varargin{i}, 'data')
        obj.data = varargin{i+1};
    elseif strcmpi(varargin{i}, 'legend')
        obj.legend = varargin{i+1};
    elseif strcmpi(varargin{i}, 'structures')
        obj.structures = varargin{i+1};
    elseif strcmpi(varargin{i}, 'dvhA')
        obj.dvh{1} = varargin{i+1};
    elseif strcmpi(varargin{i}, 'dvhB')
        obj.dvh{2} = varargin{i+1};
    elseif strcmpi(varargin{i}, 'xlabel')
        obj.xlabel = varargin{i+1};
    end
end

% Select image handle
axes(obj.axis)

% Initialize flag to indicate when the first line is plotted
f = true;

% Store line plot styles
styles = {'-', '--', ':', '-.'};

% Clear and turn on plot
cla(obj.axis)
set(obj.axis, 'visible', 'on');

% Loop through each structure 
for i = 1:length(obj.structures)  
    
    % If the statistics display column is true/checked, plot the DVH
    if obj.data{i,2}
        
        % Loop through each DVH dataset
        for j = 1:length(obj.dvh)
        
            % If the reference DVH contains a non-zero value
            if ~isempty(obj.dvh{j}) && max(obj.dvh{j}(:,i)) > 0

                % Plot the reference dose as a solid line in the color
                % specified in the structures cell array
                plot(obj.dvh{j}(:, end), obj.dvh{j}(:,i), styles{1+mod(j-1, ...
                    length(styles))}, 'Color', obj.structures{i}.color/255);
 
                % If this was the first contour plotted
                if f

                    % Disable the first flag
                    f = false;

                    % Hold the axes to allow overlapping plots
                    hold on;
                end
            end
        end
    end
end

% Stop holding the plot
hold off;

% Turn on major gridlines
grid on;

% If the legend is enabled and matches the data
if ~isempty(obj.legend) && length(obj.legend) == length(obj.dvh)
    
    % Add legend
    legend(obj.legend, 'Location', 'southwest');
end

% Set x-axis label
xlabel(obj.xlabel);

% If the type is relative
if strcmpi(obj.volume, 'relative')

    % If the type is cumulative
    if strcmpi(obj.type, 'cumulative')
        
        % Set the y-axis limit between 0% and 100%
        ylim([0 100]);
        
        % Set y-axis label
        ylabel(['Cumulative ', obj.ylabel, ' (%)']);
    else
        
        % Set y-axis label
        ylabel(['Differential ', obj.ylabel, ' (%)']);
    end
    
% If the type is absolute
else
    
    % If the type is cumulative
    if strcmpi(obj.type, 'cumulative')
        
        % Set y-axis label
        ylabel(['Cumulative ', obj.ylabel, ' ', obj.yunit]);
    else
        
        % Set y-axis label
        ylabel(['Differential ', obj.ylabel, ' ', obj.yunit]);
    end
end

% Log completion of function
if exist('Event', 'file') == 2
    Event(sprintf(['Dose volume histograms plotted successfully in ', ...
        '%0.3f seconds'], toc(t)));
end

% Clear temporary variables
clear i j t f;
