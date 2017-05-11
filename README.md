## MATLAB UI class for displaying TCS plots

by Mark Geurts <mark.w.geurts@gmail.com>
<br>Copyright &copy; 2017, University of Wisconsin Board of Regents

ImageViewer is a MATLAB class that creates TCS plots of CT and Dose data. One ImageViewer object is created for each plot (in the T, C, or S dimension). Image and dose data is passed to this object using the same structure format detailed in the [tomo_extract](https://github.com/mwgeurts/tomo_extract) functions `LoadImage.m` and  `LoadPlanDose.m`. In addition, a slider UI handle can optionally be linked to the TCS image to control what slice is currently being viewed.

For more information on how this class is used, or to see it in action, see the application [CheckTomo](https://github.com/mwgeurts/checktomo).

This program is free software: you can redistribute it and/or modify it  under the terms of the GNU General Public License as published by the   Free Software Foundation, either version 3 of the License, or (at your  option) any later version.

This program is distributed in the hope that it will be useful, but  WITHOUT ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General  Public License for more details.  You should have received a copy of the GNU General Public License along  with this program. If not, see http://www.gnu.org/licenses/.
