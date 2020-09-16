%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returns the ideal Jsc calculated from FDTD simulation
%
% Parameters:
% Inputs: dBetweenGratings - Inter-grating pattern distance
%         thisBoundary            - Polygon vertices
% 
% Output: JscIdeal                - Jsc calculated from FDTD simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function JscIdeal = FDTDsimulation_2FBT (dBetweenGratings, polygonVertices)
warning('off', 'MATLAB:polyshape:repairedBySimplify');
%% Initialization
nm = 10^-9;
dBetweenGratings = dBetweenGratings*nm;

%% Open Lumerical FDTD session
FDTD_session=appopen('fdtd');

% Set path = matlab file's path
appputvar(FDTD_session,'path',pwd);

%% Open IPV simulation file
appevalscript(FDTD_session,'load(path + "\PPDT2FBT_IPV.fsp");');
appevalscript(FDTD_session, 'switchtolayout;');

%% BOTTOM GRATING STRUCTURE:
%% Make bottom gratting group
appevalscript(FDTD_session, 'addstructuregroup;');
appevalscript(FDTD_session, 'set("name","bottomGrating");');

%% Transfer polygon vertices to FDTD session
% Reduce the number of vertices
pgon = polyshape(polygonVertices(:,1),polygonVertices(:,2));
Pin_temp = pgon.Vertices;
Pin_temp = rmmissing(Pin_temp);
% Close PinOpen polygon
[PinOpen(:,1), PinOpen(:,2)] = closePolygonParts(Pin_temp(:,1), Pin_temp(:,2));
% Reduce number of vertices
PinOpen = reducepoly(PinOpen);
% Close PinOpen polygon
[Pin(:,1), Pin(:,2)] = closePolygonParts(PinOpen(:,1), PinOpen(:,2));
% Send vertices data to FDTD session
appputvar(FDTD_session,'polygon_ITO',Pin);

%% Create the polygon in the FDTD session
appevalscript(FDTD_session, 'addpoly;');
appevalscript(FDTD_session, 'set("vertices",polygon_ITO);');

% Position and name the polygon
appevalscript(FDTD_session, 'set("x",0);');
appevalscript(FDTD_session, 'set("y",0);');
appevalscript(FDTD_session, 'set("z",0);');
appevalscript(FDTD_session, 'set("name", "ITO_pattern");');

% Set material to ITO
appevalscript(FDTD_session, 'set("material","ITO");');

% Move to bottomGrating structure group
appevalscript(FDTD_session, 'addtogroup("bottomGrating");');

%% Make PFN surface patterned
% Get PFN thickness from simulation file
appevalscript(FDTD_session, 'select("PFN");');
appevalscript(FDTD_session, 'PFN_yspan = get("y span");');
PFN_thickness = appgetvar(FDTD_session,'PFN_yspan');

% Make polybuffer for the PFN layer
Pout = polybuffer(PinOpen,'lines',PFN_thickness);
Pout = rmholes(Pout);  % Remove holes
boundaryNew_temp = Pout.Vertices;
boundaryNew_temp = rmmissing(boundaryNew_temp);
% Close boundaryNew_temp polygon
[boundaryNewOpen(:,1), boundaryNewOpen(:,2)] = closePolygonParts(boundaryNew_temp(:,1), boundaryNew_temp(:,2));
% Reduce number of vertices
boundaryNewOpen = reducepoly(boundaryNewOpen);
% Close boundaryNewOpen polygon
[boundaryNew(:,1), boundaryNew(:,2)] = closePolygonParts(boundaryNewOpen(:,1), boundaryNewOpen(:,2));

% Transfer polybuffer vertices to FDTD session
appputvar(FDTD_session,'polygon_PFN',boundaryNew);

% Create the polygon in the FDTD session
appevalscript(FDTD_session, 'addpoly;');
appevalscript(FDTD_session, 'set("vertices",polygon_PFN);');

% Position and name the polygon
appevalscript(FDTD_session, 'set("x",0);');
appevalscript(FDTD_session, 'set("y",0);');
appevalscript(FDTD_session, 'set("z",0);');
appevalscript(FDTD_session, 'set("name", "PFN_pattern");');

% Set material to PFN (PFO is same as PFN)
appevalscript(FDTD_session, 'set("material","PFO");');

% Move to bottomGrating structure group
appevalscript(FDTD_session, 'addtogroup("bottomGrating");');

%% Make copies on both sides
% Offset in x axis for the copies
dx = abs(max(PinOpen(:,1)))+abs(min(PinOpen(:,1))) + dBetweenGratings;
appputvar(FDTD_session,'distx',dx);

appevalscript(FDTD_session, 'select("bottomGrating");');
appevalscript(FDTD_session, 'copy(distx);');
appevalscript(FDTD_session, 'set("name", "bottomGrating_right");');
appevalscript(FDTD_session, 'select("bottomGrating");');
appevalscript(FDTD_session, 'copy(-distx);');
appevalscript(FDTD_session, 'set("name", "bottomGrating_left");');

%% Make new structure group to group all bottom gratings
appevalscript(FDTD_session, 'addstructuregroup;');
appevalscript(FDTD_session, 'set("name","bottomGrating_all");');

% Select all the grating pattern groups
appevalscript(FDTD_session, 'select("bottomGrating");');
appevalscript(FDTD_session, 'shiftselect("bottomGrating_right");');
appevalscript(FDTD_session, 'shiftselect("bottomGrating_left");');

% Move to bottomGrating_all structure group
appevalscript(FDTD_session, 'addtogroup("bottomGrating_all");');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TOP GRATING STRUCTURE:
appevalscript(FDTD_session, 'unselectall;');
%% Make bottom gratting group
appevalscript(FDTD_session, 'addstructuregroup;');
appevalscript(FDTD_session, 'set("name","topGrating");');

%% Transfer polygon vertices to FDTD session
appputvar(FDTD_session,'polygon_Ag',PinOpen);

%% Create the polygon in the FDTD session
% Find Ag ymin
appevalscript(FDTD_session, 'select("Ag");');
appevalscript(FDTD_session, 'Ag_ymin = get("y min");');

% Create Polygon
appevalscript(FDTD_session, 'addpoly;');
appevalscript(FDTD_session, 'set("vertices",polygon_Ag);');

% Position and name the polygon
appevalscript(FDTD_session, 'set("x",0);');
appevalscript(FDTD_session, 'set("y",Ag_ymin);');
appevalscript(FDTD_session, 'set("z",0);');
% Rotate the gratting
appevalscript(FDTD_session, 'set("first axis", "x");');
appevalscript(FDTD_session, 'set("rotation 1", 180);');

appevalscript(FDTD_session, 'set("name", "Ag_pattern");');

% Set material to ITO
appevalscript(FDTD_session, 'set("material","Ag (Silver) - CRC Copy 1");');

% Move to bottomGrating structure group
appevalscript(FDTD_session, 'addtogroup("topGrating");');

%% Make PFN surface patterned
% Get MoOx thickness from simulation file
appevalscript(FDTD_session, 'select("MoOx");');
appevalscript(FDTD_session, 'MoOx_yspan = get("y span");');
MoOx_thickness = appgetvar(FDTD_session,'MoOx_yspan');

% Make polybuffer for the MoOx layer
clear Pout boundaryNew boundaryNew_temp boundaryNewOpen;
Pout = polybuffer(PinOpen,'lines',MoOx_thickness);
Pout = rmholes(Pout);  % Remove holes
boundaryNew_temp = Pout.Vertices;
boundaryNew_temp = rmmissing(boundaryNew_temp);
% Close boundaryNew_temp polygon
[boundaryNewOpen(:,1), boundaryNewOpen(:,2)] = closePolygonParts(boundaryNew_temp(:,1), boundaryNew_temp(:,2));
% Reduce number of vertices
boundaryNewOpen = reducepoly(boundaryNewOpen);
% Close boundaryNewOpen polygon
[boundaryNew(:,1), boundaryNew(:,2)] = closePolygonParts(boundaryNewOpen(:,1), boundaryNewOpen(:,2));

% Transfer polybuffer vertices to FDTD session
appputvar(FDTD_session,'polygon_MoOx',boundaryNew);

% Create the polygon in the FDTD session
appevalscript(FDTD_session, 'addpoly;');
appevalscript(FDTD_session, 'set("vertices",polygon_MoOx);');

% Position and name the polygon
appevalscript(FDTD_session, 'set("x",0);');
appevalscript(FDTD_session, 'set("y",Ag_ymin);');
appevalscript(FDTD_session, 'set("z",0);');
% Rotate the gratting
appevalscript(FDTD_session, 'set("first axis", "x");');
appevalscript(FDTD_session, 'set("rotation 1", 180);');

appevalscript(FDTD_session, 'set("name", "MoOx_pattern");');

% Set material to PFN (PFO is same as PFN)
appevalscript(FDTD_session, 'set("material","MoOx");');

% Move to bottomGrating structure group
appevalscript(FDTD_session, 'addtogroup("topGrating");');

%% Make copies on both sides
appevalscript(FDTD_session, 'select("topGrating");');
appevalscript(FDTD_session, 'copy(distx);');
appevalscript(FDTD_session, 'set("name", "topGrating_right");');
appevalscript(FDTD_session, 'select("topGrating");');
appevalscript(FDTD_session, 'copy(-distx);');
appevalscript(FDTD_session, 'set("name", "topGrating_left");');

%% Make new structure group to group all bottom gratings
appevalscript(FDTD_session, 'addstructuregroup;');
appevalscript(FDTD_session, 'set("name","topGrating_all");');

% Select all the grating pattern groups
appevalscript(FDTD_session, 'select("topGrating");');
appevalscript(FDTD_session, 'shiftselect("topGrating_right");');
appevalscript(FDTD_session, 'shiftselect("topGrating_left");');

% Move to bottomGrating_all structure group
appevalscript(FDTD_session, 'addtogroup("topGrating_all");');

%% Set FDTD span
appputvar(FDTD_session,'FDTDspan',dx*2);
appevalscript(FDTD_session, 'select("FDTD");');
appevalscript(FDTD_session, 'set("x span", FDTDspan);');

%% Save the file with a different name
appevalscript(FDTD_session,'save("tmp_FDTD");');

%% Run the file
appevalscript(FDTD_session, 'run;');

%% Run the LED script
appevalscript(FDTD_session, 'whiteLED_1000lxSpectra;');
% Get the result
appevalscript(FDTD_session, 'JscFDTD = Jsc_1000lx;');
JscIdeal = appgetvar(FDTD_session,'JscFDTD');

%close FDTD session
appevalscript(FDTD_session, 'switchtolayout;');
appclose(FDTD_session);

%% Delete the temporary file
if exist('tmp_FDTD.fsp', 'file')==2
  delete('tmp_FDTD.fsp');
end

end
