clear all; clc ;
currentPath=pwd;
addpath(genpath([currentPath filesep 'core']));
addpath(genpath([currentPath filesep 'utils']));
addpath(genpath([currentPath filesep 'plugins']));
mkdir([currentPath filesep 'output_img'])
for itr = 1:100
%% Basic CellGen Example
% This is a basic CellGen example 
% The synthetic image generated here consists of a single type of cell
% (one subpopulation) consisting of a nucleus and cytoplasm that shown
% a local cell density influenced marker level.
% The cells are 'stained' for 2 markers
% 1) DAPI - a nuclear marker (colored in gray)
% 2) Marker2 - local cell density dependent cytoplasm marker (colored in yellow)

%% cellgen_data
% CellGen requires the user to specify a structure 'cellgen_data' to
% specify how images shall be generated. 'cellgen_data' contains the
% following fields described in more detail below
%   1) image_size: a vector specifying the size in pixels of the image
%   2) number_of_cells: The number of cells in the image
%   3) subpopulations : A description of the rendering of the individual
%   subpopulations (biological cell types). 'subpopulations' is a MATLAB 
%    (as opposed to biological) cell array, with each element being a class of type
%   'Subpopulation'. The subpopulation class contains specifications of
%   objects (nuclei and cytoplasm), markers (DAPI, Cytoplasm marker) In this case 
%   only one subpopulation is specified).
%   4) overlap: An object of type 'Overlap_Specification' that determines
%   what overlap between cell is allowed
%   5) image_artifacts: a cell array, specifying a sequence of operations
%   that are performed to produce effects simulating imaging artifacts 
%   (e.g. non-uniform illumination) on the whole image 

%% Set basic parameter 
% 1)Set Image Size (in pixels)
cellgen_data.cellgen_image_size=[128,128];


% 2)Set Number of cell per image
cellgen_data.number_of_cells=10;
% Note: If CellGen cannot fit in any more cells (and still meet the
% overlap conditions) it will generate an image with the maximum number of
% cells it fits in


% You can specify the fractions of cells in the image from the different
% subpopulations (however in this case there is only one subpopulation)
cellgen_data.population_fractions=[1];

%% subpopulations
% 3)Create Subpopulation Cell Array
% Subpopulations, i.e. different cells types are the central structure of
% CellGen. You can have as many subpopulations as you like, each one is
% stores as an element in a cell array.
subpop=cell(0);

% Note: the contents of 'subpop' will eventually be assigned to 
% 'cellgen_data.subpopulations. The use of the temporary variable
% 'subpop' is for ease of reading

% Define Subpopulation 1
subpop{1}=Subpopulation();

%Set the Model Placement
% Placement refers to the position of cell in an image.
% Cells in different subpopulations can display different patterns of 
% placement (e.g, one type of cells may be clustered or placed randomly)
% Placement for cells in a subpopulation are specified through the
% placement property in subpopulation, which you need to set the the
% appropriate placement model.
% Models for placments are classes of type CellGen_Placement_Model, and
% are implemented via plugins (usually placed in the 'plugins/placement/'
% directory).
% Here we choose to have cells placed randomly, and so choose the
% 'Random_Placement' model
subpop{1}.placement=Random_Placement();
% The placement models follow the typical model specification (see CellGen_Model, Parameter),
% and the user settable parameters can be found in the plugin file. These
% parameters follow the standard set framework. 
set(subpop{1}.placement,'boundary',10); % the boundary is the number of pixels around the edge of the image where no cells are placed

%% Set the Object Shape
% Object 1
%Set the Object Shape
% Users are required to add and name the objects on a
% subpopulation basis. This is done using the add_object function. 
add_object(subpop{1},'Nuc');
% This will create objects of the specified name inside the objects property of
% the subpopulation object. Thus in this case we have
% subpop{1}.objects.Nuc
% Next we need to choose an appropriate model to render the shape of this
% object. The available shape models are inside tye directory 'plugins/shape/'. For
% organizational purposes, these plugins are placed in sub-directories
% (cytoplasm, nucleus and other). 

% We choose to use Nucleus_Model; which creates an
% elliptical nucleus
subpop{1}.objects.Nuc.model=Nucleus_Model;
set(subpop{1}.objects.Nuc.model,'radius',6);%nuclear radius in pixels
set(subpop{1}.objects.Nuc.model,'eccentricity',0.5);% Gives a fairly elliptical shape
set(subpop{1}.objects.Nuc.model,'randomness',0.1); %0 is no noise, and 1 is all noise, so this cell is fairly smooth

% Add a cytoplasmic object
add_object(subpop{1},'Cyto');
% We choose a cytoplasmic model that creates an elliptical shaped nucleus at
% around some other object (in our case the nucleus 'Nuc')
subpop{1}.objects.Cyto.model=Centered_Cytoplasm_Model;
set(subpop{1}.objects.Cyto.model,'radius',10);%cell radius in pixels
set(subpop{1}.objects.Cyto.model,'eccentricity',0.7);
set(subpop{1}.objects.Cyto.model,'centered_around',subpop{1}.objects.Nuc); % draws cytoplasm around the nucleus
set(subpop{1}.objects.Cyto.model,'randomness',0.3);

% Note:
% 1) In the centered around, we need to point to another object. We refer
% to the object itself (subpop{1}.objects.Nuc) NOT its model
% (subpop{1}.objects.Nuc.model)
% 2) The onus for selecting appropriate models is on the script writer. In
% particular the different object models need to be connected in some way
% (otherwise, the cytoplasm and nucleus of the same cell will be in
% completely different locations). Thus you need to be careful to choose
% one independant model (here the Cytoplasm_Model) that anchors the
% position of the cell, while all other models need to be connected to this
% object (either directy or indirectly).

%% Define Markers
%Setup Markers
% As described in the tutorial, users next add, name  anc choose colors
% for the markers on asubpopulation basis. 
% This is done using the add_marker function. (In
% contrast to the GUI you will have to do this for every subpopulation,
% since we assume different subpopulations can be stained with different
% markers)
% Marker 1
add_marker(subpop{1},'DAPI', Colors.Yellow); % nuclear marker
% This wil create the object subpop{1}.markers.DAPI
% As described in the tutorial, marker distribution is specified on an object by object basis.
% In our case this involves defining subvariables subpop{1}.markers.DAPI.Nuc and
% subpop{1}.markers.DAPI.Cyto which are automatically created by the
% defintion of the marker
% Marker 2
add_marker(subpop{1},'Marker2', Colors.Yellow); % Cell density dependent marker

% In contrast to the shape, marker distribution on an object is specified
% in terms of a series of elementary operations. So the standard workflow
% is to define each operation and add it to the queue of operations for the
% specific marker-object pair. The available operations are present as
% plugins in the 'plugins/markers/' directory.

% As described in the tutorial the first operation typically sets the overall level
% of a marker in the object, while the subsequent operations redistribute
% the intensity distribution within the object.

% Note: We do not define the last two markers on the nucleus, this will
% set their level to be zero in the nucleus (but since the nucleus is
% contained inside the cytoplasm --see compositing -- they need not be
% completely dark)
%% Set Markers Parameters according to the dependencies

%%%%%% DAPI
% DAPI is only present in the nucleus. It shows a slight variation from
% cell to cell and some non-uniform texture
op=Constant_Marker_Level();
% Set a constant marker level (uniform across entire object, but varying from cell to cell)
set(op,'mean_level',0.5);% The marker level for a cell is sampled from a normal distribution with this mean
set(op,'sd_level',0.1); % and this standard deviation
subpop{1}.markers.DAPI.Nuc.AddOperation(op);

%Perlin Texture (scale the intensity from the last step by a noisy texture,
%to make it look more realistic)
op=Perlin_Texture();
set(op,'add_or_multiply','Multiply');% Scale the intensity by noise (multiply) or add noise to the existing intensity
set(op,'amplitude',0.2);% the amplitude of the noise (0 is not noise, and you probably don't want to go much beyond 1, since intensities are in the [0-1] range)
set(op,'length_scale',4); % This descibes the length scale over which intensity varies. 2 is low wave-length (coarse variation) and 6 is very fine high frequency (fine variation)
set(op,'frequency_falloff',0.5); % Each higher frequency component amplitude is smaller by this scaling factor
set(op,'noise_type','Standard 1/f'); % The type of noise. 1/f is smoother than Turbulent
subpop{1}.markers.DAPI.Nuc.AddOperation(op);



%%%%%%% Marker2
% The level of this marker is dependant on local cell density. We also
% throw in a marker gradient as we move out from the nucleus to the edge of
% the cell and some noisy texture to make it appear more realistic

op=Cell_Density_Dependant_Marker_Level();
% Set the marker level in nucleus be decided by the distance to nearest
% other cell. Internally, for each cell,  average distance to nearest other
% cell is calculated, and nuclear intensity varies with this distance
set(op,'increasing_or_decreasing','Increasing'); % Does the marker level increase or decrease with local cell density
set(op,'falloff_radius',40); % The distance (in pixels) that the nearest cell must be on average for intensity to fall off by a factor of 1/e
set(op,'falloff_type','Gaussian'); % Functional form of dependance of intensity on the average distance to nearest cell
set(op,'min_level',0);% The lowest level the marker can drop to (for example if it is infinitely far away from other cells)
set(op,'max_level',1.4);% Max level (theoretically) possible, if cells were on top of each other (increasing this increases brightness across all cells)
subpop{1}.markers.Marker2.Cyto.AddOperation(op);

op=Distance_To_Shape_Marker_Gradient();
% Intensity at a pixel decreases with distance of that pixel to another
% object (the nucleus 'Nuc' here)
set(op,'distance_to',subpop{1}.objects.Nuc); % distance is measure wrt the nucleus 'Nuc'
set(op,'falloff_type','Gaussian'); % the intensity fall off functional form
set(op,'falloff_radius',30); % The number of pixels over which intensity falls by 1/e
set(op,'increasing_or_decreasing','Decreasing');  % whether intensity increases or decreases based on the distance
subpop{1}.markers.Marker2.Cyto.AddOperation(op);

% Throw in some noise
op=Perlin_Texture();
set(op,'add_or_multiply','Multiply');
set(op,'amplitude',0.5);
set(op,'length_scale',2);
set(op,'frequency_falloff',1);
set(op,'noise_type','Standard 1/f');
subpop{1}.markers.Marker2.Cyto.AddOperation(op);

%% Set the Composite Type
subpop{1}.compositing=Default_Compositing();
% Compositing governs the rendering of markers when multiple objects, with
% some expression of the same marker, overlap. For example, suppose a
% marker is present in the nucleus and the cytoplasm. The nucleus is
% contained in the cytoplasm, thus the marker level in the nucleus is a composite
% of its expression from the the nucleus and the cytoplasm. 
% Presently we support just one compositing model, called default compositing. This
% model determines, at run-time, which objects contain which others
% (cytoplasm contains nucleus). The user can then specify the weight given
% to the container (the contained object gets 1-container_weight)
set(subpop{1}.compositing,'container_weight',0);
% In this example the cytoplasm will get 0 weight and nucleus full weight
% nuclear region. Note in the cytoplasmic region where there is no overlap,
% only the model of the marker in the cytoplasm comes into play, and no
% compositing is required.
%% Set the Cell Artifacts 
% Add rendering artifacts at a cell by cell level
% Cell artifacts are added using the add_cell_artifact function. Like
% markers, they are defined by a series of operations. Thee operations are
% plugins places in the 'plugins/cell_artifacts/' directory.
%Set the Cell Artifacts
op=Out_Of_Focus_Cells(); % Makes a specified fracton of cells blurred, to mimic an out of focal plane effect
set(op,'fraction_blurred',0.3); % 30% cells blurred
set(op,'blur_radius',3); % blur radius in pixels. 1 is pretty small, 4 produces a clear out of focus effect
subpop{1}.add_cell_artifact(op);

%% Set the subpopulation
cellgen_data.subpopulations=subpop;

%% 4) Set Overlap (not set here,defaults used)
% We can also specify if cells are allowed to overlap, and to what
% extent. This spans subpopulations, and is stored in the overlap parameter
% of the cellgen_data structure.
% This is done by specifying a series of rules for maximum allowed overlap:
% Each rule consists of two parts
% 1) A list (stored as a cell) of objects on which the overlap is measured
% 2) The maximum allowed overlap between these objects, measured as a
% fraction of their areas

overlap=Overlap_Specification;
overlap.AddOverlap({subpop{1}.objects.Cyto,...
  subpop{1}.objects.Cyto},0.1);
% The percentage of overlap could be adjusted here

cellgen_data.overlap=overlap;
% Not declaring the placement means the default behavior of not allowing 
% cells to overlap is used


%% 5) Set image artifact
% radius image gradient is used here because the microscope tend to have 
% lower illumination on the corner

op=Radial_Image_Gradient();
set(op,'falloff_radius',50);
set(op,'max_multiplier',1);
set(op,'min_multiplier',0);
set(op,'falloff_type','Linear');
cellgen_data.image_artifacts={op};



%% Output image
cellgen_result=[];

%cellgen_result contains generated single channel image/RGB image and 
%index of segmented target for both nucleus and cytoplasm
cellgen_result=cellgen_engine(cellgen_data,1);


%plot generated single channel uint16 image with yellow colormap
filename=[ currentPath filesep 'output_img' filesep 'image_' sprintf(['%0' num2str(4) 'd'], itr) '.png'];
imwrite(uint16(round(cellgen_result(1).channel_images.Yellow*65535)),filename);

%plot mask 
mask = zeros(cellgen_data.cellgen_image_size(1),cellgen_data.cellgen_image_size(2));
for i = 1:cellgen_data.number_of_cells
    mask(cellgen_result.mask_of_object_by_cell(i).Cyto>0)=i;
end
filename_mask=[ currentPath filesep 'output_img' filesep 'mask_' sprintf(['%0' num2str(4) 'd'], itr) '.png'];
imwrite(mask,filename_mask);

end 