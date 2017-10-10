function WriteFile(obj, filename, n)
% WriteFile saves a computed DVH to an Excel .csv file. The first row 
% contains the file name, the second row contains column headers for each 
% structure (including the volume in cc in parentheses), with each 
% subsequent row containing the percent volume of each structure at or 
% above the dose specified in the first column (in Gy).  The resolution is 
% determined by dividing the maximum dose by the number of bins.
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

% Extract file name
[~, file, ext] = fileparts(filename);

% Log event and start timer
if exist('Event', 'file') == 2
    Event(sprintf('Writing dose volume histogram to %s', ...
        strcat(file, ext)));
    t = tic;
end

% Open a write file handle to the file
fid = fopen(filename, 'w');

% If a valid file handle was returned
if fid > 0

    % Write the file name in the first row, starting with a hash
    fprintf(fid, '#,%s\n', strcat(file, ext));

    % Write the structure names and volumes in the second row
    for i = 1:length(obj.structures)
        fprintf(fid, ',%s (%i)(volume: %0.2f)', ...
            obj.structures{i}.name, i, ...
            obj.structures{i}.volume); 
    end
    fprintf(fid, '\n');

    % Circshift dvh to place dose in first column
    dvh = circshift(obj.dvh{n}, [0 1])';

    % Write dvh contents to file
    fprintf(fid, [repmat('%g,', 1, size(dvh,1)), '\n'], dvh);

    % Close file handle
    fclose(fid);

% Otherwise MATLAB couldn't open a write handle
else

    % Throw an error
    if exist('Event', 'file') == 2
        Event(sprintf('A file handle could not be opened to %s', ...
            filename), 'ERROR');
    else
        error('A file handle could not be opened to %s', filename);
    end
end

% Log completion of function
if exist('Event', 'file') == 2
    Event(sprintf(['Dose volume histograms written successfully in ', ...
        '%0.3f seconds'], toc(t)));
end

% Clear temporary variables
clear t fid i file ext dvh
