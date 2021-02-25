%% HOW THIS WORKS!
% Defining The Structure:
% 1 - Walls must be rectangular/square. No curved walls/panels are allowed
% 
% There are two ways to define walls or structure
% 1- Method one (easy 2D to 3D):
%       This is the easy way of doing it. If the walls are all of the same
%       height (ususally are), ignore their height and think of them as
%       lines to make it 2D. Lets say walls height is 4 metters, then
%       change "ceilingLevel = 4".
%       -So, now walls are lines, and they have 2
%       ends. You can define them as a CSV file now. Each wall has a start
%       and a end defined by [Xstart,Ystart,Zstart] and [Xend,Yend,Zend].
%       -Ignore Zstart and Zend, they are always zero. 
%       -Lets say the reference point of start is [0,0,0], this is where
%       the first wall starts from, and it end point is at [36,0,0]. The
%       first line in the excel or CSV file then should look like this.
%       0  ;0  ;0     
%       36 ;0  ;0 
%       
%       Where first line of csv or excel is for the start point of wall 1 
%       and next line (line 2) of the excel/csv file is the end
%       point of wall 1. As continues the 3rd line should be the start
%       point of wall 2 and 4th line should be the end point of wall 2.
%       An excel file is attached to the submission to give an examle.
% 
% 
% 3- Defining the Ceiling or floor:
%      - IMPORTANT: MANUAL DEFINITION OF CEILING NEEDS TO BE CLOCKWISE OR
%      COUNTER CLOCKWIESE!
%       - Each piece of ceiling is defined with 4 coreners, ceillFloor.xyz1
%       ceillFloor.xyz2, ceillFloor.xyz3 and ceillFloor.xyz4. Each variable
%       contains x,y,z of first, 2nd, 3rd and 4th corner. This is similar
%       for defining the ground!
% 
%       Here is an example that defines 2 pieces of ceiling panels and 1
%       ground
% 
%     ceillFloor.xyz1 = [0,0,ceilingLevel
%                        31,23,ceilingLevel
%                        0,0,groundLevel
%                         ];
% 
%     ceillFloor.xyz2 = [0,23.9,ceilingLevel
%                         31.83,27.83,ceilingLevel
%                         0,27.54,groundLevel
% 
%                         ];
% 
%     ceillFloor.xyz3 = [36.9,23.9,ceilingLevel
%                         36.9,27.83,ceilingLevel
%                         36.9,27.54,groundLevel
%                         ];
% 
%     ceillFloor.xyz4 = [36.9,0,ceilingLevel
%                         36.9,23.9,ceilingLevel
%                         36.9,0,groundLevel
%                         ];
% 
%  !!!! DONT FORGET THEY NEED TO BE COLOCKWISE OTHER WISE THEY STRUCTURE
%  THAT WILL BE VIEWED IS GOING TO BE A FUNNY MESS !!!
% 
% 4 - Defining Relative Permittivity:
%       Each wall, floor and ground pannel has it's own premittivity. To
%       assign them, set the demoMode to 1, (demoMode =1) it will show you
%       all the walls and their number. Simply assign each wall ceiling and
%       floor a value in "wall.relativePerm". 
%       - The ceiling and floor are appended to the end of the walls, so
%       if you have 2 walls, 2 ceilings and 1 floor you need a total of 5
%       permittivities to be assigned.
%       - Ceilings and floor is always appeneded to the end so the last
%       premittivities are for the ceiling and floor. In this example
%       - wall.relativePerm(end) is the permittivity of floor
%       - wall.relativePerm(end-1) is the permittivity of the second
%       ceiling 
%       - wall.relativePerm(end-2) is the permittivity of the 1st ceiling
% 
% 
% 5- When polarizationSwap == 1 (Antenna has vertical polarization)
% therefore:
%    (S polarization, Vertical polarization, Transverse Electric polarization, Perpendicular polarization) coefficients are used for walls
%    (P Polarization, Horizontal polarization, Transverse Magnetic polarization, Parallel Polarization) coefficients are used for ceiling and floor
% 
% 
% 6- Antenna Gain:
%       Gain of transcievers can be defined mathematically in the
%       "AntennaTemp.m" file. I've done it for a simple dipole antenna. And
%       the gain is pre-calculted in the same file for different angles,
%       depending on which resolution you assing. The example pattern is
%       showing a dipole in x=0,y=0,z=1 direction.
% 
% 7- When polarizationSwap == 0 (Antenna has horizontal polarization)
%    (S polarization, Vertical polarization, Transverse Electric polarization, Perpendicular polarization) coefficients are used for CEILING and FLOOR
%    (P Polarization, Horizontal polarization, Transverse Magnetic polarization, Parallel Polarization) coefficients are used for WALLS
% 
% 
% 8- There can be more than one Tx in the environment Tx = [x,y,z;x2,y2,z2]. However for this to work you need to change the code. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear 
clc

%% Ray Tracing Engine Parameters    

optimizationMode = 0;   % if 1, then reduces the Rx mesh size to measurement locations only
plotMode = 1;           % Ray Tracing engine plot mode
demoMode = 1;           % Ray Tracing Engine Plot Mode

losFlag = 1; 
reflectionFlag = 1;                     % whether or not calculate First reflections
secondReflectionFlag = 1;
reflectExaggerationFac = 1e0;          % Must be 1 unless to emphasize reflection for demonstration purposes
                                    % whether or not calculate LoS
disableIncidentAngle = 0;               % 1 Disables the incident angle calculation, if disableIncidentAngle= 1
solidIncidentAngle = 45;                % if disableIncidentAngle =1, then assign this which overwrites all the incident angles! This is unnecessary feature
polarizationSwap = 1;               % (See notes in HOW THIS WORSK)  % 1, Applies TE to walls and TM to ceiling. 0, applies TM to the walls and TE to the ceiling

imageRSSIScale = 5;         % increase this if number of meshes nodes are small
grayScaleImage = 0;

freq = 59.6e9;  % frequency in hertz
% freq = 2.45e9;  % frequency in hertz
lightVel = 3e8;
lambda = lightVel./freq;
refDistance = 1;            % Reference distance from Tx
FPSLRefLoss = 0;

antennaGainRes = 40;
antennaEffiLoss = -11.5;         % dB antenna efficiency, missmatch and loss all together

ceilingEnable = 0; % Allowing to define ceiling and floor
groundLevel = 0;
ceilingLevel = 406;  % Height of the ceiling

mesh_.xNodeNum = 40;   % Keep the x and y mesh size the same, increase the size for better resolution and especially if you're increasing the frequency
mesh_.yNodeNum = 40;
mesh_.zNodeNum = 1;

%% Antenna Gain pattern calculation

[TxAntennaGainAE] = AntennaTemp (antennaGainRes,demoMode) + antennaEffiLoss;  % TxAntennaGainAE needs to be in dB
RxAntennaGainAE = TxAntennaGainAE;

Tx.xyz = [ 2, 2, 1]; % Location of the transmitter (s)
Tx.power =  67; % power of the transmitter dB(m) % start from 47 at 2.4 GHz
% start from 2 at 60 GHz and decrease by 20 for duct
% start from 2 at 60 GHz and decrease by 2 for duct

% Defining the boundary of the analysis (something like a boundary condition) 
boundary = [-1,5
            -1,5
            -1,25];    

% Walls to be defined in a clockwise or counter clockwise manner
%% CLOCK WISE WALL DEFINITION        

% Reads the structure from an excel file (see in this code section at the
% top)
[wallxyz1, wallxyz2, wallxyz3, wallxyz4,wallX,wallY,wallZ] = CSV23D_V1(demoMode,groundLevel,ceilingLevel,Tx.xyz);

wall.xyz1 = wallxyz1;
wall.xyz2 = wallxyz2;
wall.xyz3 = wallxyz3;
wall.xyz4 = wallxyz4;

wall.X = wallX;
wall.Y = wallY;
wall.Z = wallZ;


% Define the ceiling of the structure manually if required walls can be
% defined the same fashion
if ceilingEnable == 1

    ceillFloor.xyz1 = [0,0,ceilingLevel
                       36.9,4,ceilingLevel
                       0,0,groundLevel
                        ];

    ceillFloor.xyz2 = [0,4,ceilingLevel
                       36.9,0,ceilingLevel
                       0,4,groundLevel
                        ];

    ceillFloor.xyz3 = [36.9,4,ceilingLevel
                        0,0,ceilingLevel
                        36.9,4,groundLevel
                        ];

    ceillFloor.xyz4 = [36.9,0,ceilingLevel
                        0,4,ceilingLevel
                        36.9,0,groundLevel
                        ];
else
    
    ceillFloor.xyz1 = [];
    ceillFloor.xyz2 = [];
    ceillFloor.xyz3 = [];
    ceillFloor.xyz4 = [];
                    
end

wall.relativePerm = 6*ones(size(wall.xyz1,1)+size(ceillFloor.xyz1,1),1);

%% Adding Ceillilng and Floor to the structure
for i = 1:size(ceillFloor.xyz1,1)
    wall.xyz1 = [wall.xyz1;ceillFloor.xyz1(i,:)];
    wall.xyz2 = [wall.xyz2;ceillFloor.xyz2(i,:)];
    wall.xyz3 = [wall.xyz3;ceillFloor.xyz3(i,:)];
    wall.xyz4 = [wall.xyz4;ceillFloor.xyz4(i,:)];
end

% RayTracingEng_V01
RayTracingEng_V02



