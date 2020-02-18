%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the fitness of the population (used for Genetic Algorithm)
%
% Parameters:
% Inputs: dBetweenGratings - Inter-grating pattern distance
%         binaryImage             - Meshed polygon represented as a logical
%                                   image
% 
% Output: fitnessValue            - PCE(experimental) - PCE(simulated)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%$$

function fitnessValue = FitnessFunction (dBetweenGratings, binaryImage)
% Reconstruct vertices from binary image
polygonVertices = ReconstructPolygon(binaryImage);

%% Indoor photovoltaic device characteristics
% doi: https://doi.org/10.1016/j.nanoen.2019.01.061
                                                    %%%%%%%%%%%%%%%%%%%%%
% Open circuit voltage. Units: (V)                  %                   %
Voc = 0.587;                                        %    Change these   %
% Fill Factor. Units: (%)                           %     values for    %
FF = 65.2;                                          %     using this    %
% Short circuit current density. Units: (uA/cm2)    %      code for     %
JscExp = 117.1;                                     %     different     %
% Power conversion efficiency. Units: (%)           %     solar cell    %
PCEexp = 16;                                        %     structures    %
% Simulated Jsc from FDTD. Units: (uA/cm2)          %                   %
JscSim = 155.116;                                   %%%%%%%%%%%%%%%%%%%%%

%% Calculate other parameters from experimental values
% Internal Quantum Efficiency of the active layer
IQE = JscExp/JscSim;
% Input power from the light spectrum. Units: (uW/cm2)
Pin = ( Voc*FF*JscExp ) / PCEexp;

%% Check for center of gravity
% Split vertices of the reconstructed polygon
x_vertices = polygonVertices(:,1);
y_vertices = polygonVertices(:,2);

% Offset the polygon to have a vertex at (0,0)
if min(y_vertices) < 0
    y_vertices = y_vertices + abs(min(y_vertices));
else
    y_vertices = y_vertices - abs(min(y_vertices));
end

if min(x_vertices) < 0
    x_vertices = x_vertices + abs(min(x_vertices));
else
    x_vertices = x_vertices - abs(min(x_vertices));
end

% Find the centroid
[x_centroid, ~] = polygoncentroid(x_vertices,y_vertices);

% If the centroid falls within the base of the polygon, then it is a balanced polygon
CenterOfMass_balanced = nnz(x_centroid >= min(x_vertices(y_vertices == min(y_vertices))) & x_centroid <= max(x_vertices(y_vertices == min(y_vertices))));

if CenterOfMass_balanced == 1
    %% Run FDTD simulation and obtain Jsc,ideal
    % Jsc,ideal obtained through FDTD simulation
    JscIdeal = FDTDsimulation (dBetweenGratings, polygonVertices);
    % Experimental Jsc that is expected
    JscNew = IQE * JscIdeal;
    %% Find new PCE using the Jsc from new structure
    PCEsim = ( Voc*FF*JscNew ) / Pin;
   
    %% Set the fitnessValue
    % Fitness = difference between reference PCE and simulated PCE
    % Minimization problem (find minima of fitnessValue)
    fitnessValue = PCEexp - PCEsim; 
else
    fitnessValue = 100;
end

end