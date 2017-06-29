function images = make_image_struct(directory)
% This function takes the name a directory somewhere on the path as input 
% and creates a structure array containing the names of all the image files
% in the folder. This structure can later be used to import spectific 
% images by index
%
% Supports tiffs, bitmaps, jpegs, pngs, and gif image formats
% 
% Developed by the Prakash Lab at Stanford University

tar_dir = directory; % name of data directory
addpath(genpath(tar_dir));

w = pwd;

% hop down to target, make a structure array with all the image names,
% then hop back to original directory. Indexing is done by by timepoint.
cd(tar_dir)

% supported file types:
all_ims = {};

file_types = {'*.tif*','*.bmp','*.png','*.jp*g','*.gif'};
for ii=1:length(file_types)
    ims_ii = dir(file_types{ii});
    if ~isempty(ims_ii)
        all_ims{end+1} = ims_ii;
    end
end
ims = mergestruct(all_ims{:});

cd ../
N = numel(ims);

images = ims;

cd(w);

end