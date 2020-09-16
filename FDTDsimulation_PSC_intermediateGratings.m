%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returns the ideal Jsc calculated from FDTD simulation
%
% Parameters:
% Inputs: dBetweenGratings - Inter-grating pattern distance
%         thisBoundary            - Polygon vertices
% 
% Output: JscIdeal                - Jsc calculated from FDTD simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function JscIdeal = FDTDsimulation_PSC_complementaryGratings (dBetweenGratings, polygonVertices)
warning('off', 'MATLAB:polyshape:repairedBySimplify');
%% Initialization
nm = 10^-9;
dBetweenGratings = dBetweenGratings*nm;

%% Open Lumerical FDTD session
% FDTD_session=appopen('fdtd');
FDTD_session=appopen('fdtd', '-hide');

% Set path = matlab file's path
appputvar(FDTD_session,'path',pwd);

%% Open IPV simulation file
appevalscript(FDTD_session,'load(path + "\MAPbI3_IPV.fsp");');
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
appputvar(FDTD_session,'polygon_FTO',Pin);

%% Create the polygon in the FDTD session
appevalscript(FDTD_session, 'addpoly;');
appevalscript(FDTD_session, 'set("vertices",polygon_FTO);');

% Position and name the polygon
appevalscript(FDTD_session, 'set("x",0);');
appevalscript(FDTD_session, 'set("y",0);');
appevalscript(FDTD_session, 'set("z",0);');
appevalscript(FDTD_session, 'set("name", "FTO_pattern");');

% Set material to FTO
appevalscript(FDTD_session, 'set("material","FTO");');

% Move to bottomGrating structure group
appevalscript(FDTD_session, 'addtogroup("bottomGrating");');

%% Make TiO2 surface patterned
% Get TiO2 thickness from simulation file
appevalscript(FDTD_session, 'select("TiO2");');
appevalscript(FDTD_session, 'TiO2_yspan = get("y span");');
TiO2_thickness = appgetvar(FDTD_session,'TiO2_yspan');

% Make polybuffer for the TiO2 layer
Pout = polybuffer(PinOpen,'lines',TiO2_thickness);
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
appputvar(FDTD_session,'polygon_TiO2',boundaryNew);

% Create the polygon in the FDTD session
appevalscript(FDTD_session, 'addpoly;');
appevalscript(FDTD_session, 'set("vertices",polygon_TiO2);');

% Position and name the polygon
appevalscript(FDTD_session, 'set("x",0);');
appevalscript(FDTD_session, 'set("y",0);');
appevalscript(FDTD_session, 'set("z",0);');
appevalscript(FDTD_session, 'set("name", "TiO2_pattern");');

% Set material to TiO2
appevalscript(FDTD_session, 'set("material","TiO2");');

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
appevalscript(FDTD_session, 'set("name","topGrating_right");');

%% Transfer polygon vertices to FDTD session
appputvar(FDTD_session,'polygon_Au',PinOpen);

%% Create the polygon in the FDTD session
% Find Au ymin
appevalscript(FDTD_session, 'select("Au");');
appevalscript(FDTD_session, 'Au_ymin = get("y min");');

% Create Polygon
appevalscript(FDTD_session, 'addpoly;');
appevalscript(FDTD_session, 'set("vertices",polygon_Au);');

% Position and name the polygon
appevalscript(FDTD_session, 'set("x",(distx/2));');
appevalscript(FDTD_session, 'set("y",Au_ymin);');
appevalscript(FDTD_session, 'set("z",0);');
% Rotate the gratting
appevalscript(FDTD_session, 'set("first axis", "x");');
appevalscript(FDTD_session, 'set("rotation 1", 180);');

appevalscript(FDTD_session, 'set("name", "Au_pattern");');

% Set material to ITO
appevalscript(FDTD_session, 'set("material","Au (Gold) - Johnson and Christy");');

% Move to bottomGrating structure group
appevalscript(FDTD_session, 'addtogroup("topGrating_right");');

%% Make SpiroOMeTAD surface patterned
% Get SpiroOMeTAD thickness from simulation file
appevalscript(FDTD_session, 'select("SpiroOMeTAD");');
appevalscript(FDTD_session, 'SpiroOMeTAD_yspan = get("y span");');
SpiroOMeTAD_thickness = appgetvar(FDTD_session,'SpiroOMeTAD_yspan');

% Make polybuffer for the MoOx layer
clear Pout boundaryNew boundaryNew_temp boundaryNewOpen;
Pout = polybuffer(PinOpen,'lines',SpiroOMeTAD_thickness);
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
appputvar(FDTD_session,'polygon_SpiroOMeTAD',boundaryNew);

% Create the polygon in the FDTD session
appevalscript(FDTD_session, 'addpoly;');
appevalscript(FDTD_session, 'set("vertices",polygon_SpiroOMeTAD);');

% Position and name the polygon
appevalscript(FDTD_session, 'set("x",(distx/2));');
appevalscript(FDTD_session, 'set("y",Au_ymin);');
appevalscript(FDTD_session, 'set("z",0);');
% Rotate the gratting
appevalscript(FDTD_session, 'set("first axis", "x");');
appevalscript(FDTD_session, 'set("rotation 1", 180);');

appevalscript(FDTD_session, 'set("name", "SpiroOMeTAD_pattern");');

% Set material to SpiroOMeTAD
appevalscript(FDTD_session, 'set("material","SpiroOMeTAD");');

% Move to bottomGrating structure group
appevalscript(FDTD_session, 'addtogroup("topGrating_right");');

%% Make copies on both sides
appevalscript(FDTD_session, 'select("topGrating_right");');
appevalscript(FDTD_session, 'copy(-distx);');
appevalscript(FDTD_session, 'set("name", "topGrating_left");');

%% Make new structure group to group all bottom gratings
appevalscript(FDTD_session, 'addstructuregroup;');
appevalscript(FDTD_session, 'set("name","topGrating_all");');

% Select all the grating pattern groups
appevalscript(FDTD_session, 'select("topGrating_right");');
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
appevalscript(FDTD_session, 'AM15GSpectra_MAPbI3;');
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
