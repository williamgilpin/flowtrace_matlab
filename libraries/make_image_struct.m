function images = make_image_struct(directory)
% This function takes the name a directory somewhere on the path as input 
% and creates a structure array containing the names of all the tiff files
% in the folder. This structure can later be used to import spectific 
% images by index
%
% Developed by the Prakash Lab at Stanford University

tar_dir = directory; % name of data directory
addpath(genpath(tar_dir));

w = pwd;

% hope down to target, make a structure array with all the image names,
% then hop back to original directory. Indexing is done by by timepoint.
cd(tar_dir)
ims = dir('*.tif*');     
cd ../
N = numel(ims);

images = ims;

cd(w);

end