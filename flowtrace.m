function sliding_zproj(image_dir, frames_to_merge, out_dir, params)
% This function takes the sliding maximum intensity projection of
% a series of ordered image files in an image directory
% 
% Developed by William Gilpin, Vivek Prakash, and Manu Prakash, 2015
%
% Inputs
% ------
% image_dir : str
%     The path to the directory containing time series images
% frames_to_merge : int
%     The number of frames to merge together
% out_dir : str
%     The path to the directory into which processed images are written
% params : struct
%     A structure containing optional keyword arguments that adjust
%     The behavior of the algorithm
% 
% Parameters
% ----------
% subtract_median : bool
%     For each frame, subtract the median of all the frames being
%     merged together into it
% invert_color : bool
%     Take the minimum intensity projection then invert the color. Useful
%     for images of dark particles on a light background
% take_diff : bool
%     Take the pairwise difference between all of the images in the time
%     series.
% subtract_first : bool
%     For each set of freams being merged, subtract the first frame from
%     the entire stack
%     
%
% Examples
% --------
% % Run with default parameters
% >> flowtrace('sample_data',30,'sample_output/output_data_10frames')
%
% % Run with special parameters
% >> params=struct()
% >> params.subtract_median=true
% >> flowtrace('sample_data',30,'sample_output',params)
%
%
% FUTURE: color diff, check handling of color images


% If params not specified use all defaults
if nargin==3
   params = struct(); 
end

% Set defaults of kwargs
if ~isfield(params,'subtract_median')
    params.subtract_median=false;
end
if ~isfield(params,'take_diff')
    params.take_diff=false;
end
if ~isfield(params,'invert_color')
    params.invert_color=false;
end
if ~isfield(params,'take_diff')
    params.take_diff=false;
end
if ~isfield(params,'subtract_first')
    params.subtract_first=false;
end
if ~isfield(params,'color_series')
    params.color_series=false;
end

images = make_image_struct(image_dir);
N = numel(images);

frame0 = imread(images(1).name);
frame0=im2double(frame0);
% processing function goes here

sz = size(frame0);

if (length(sz)==3) && sz(3)==3
   rgb_flag = true;
else
   rgb_flag = false;
end

if rgb_flag
    stack = zeros(sz(1), sz(2), frames_to_merge, 3);
else
    stack = zeros(sz(1), sz(2), frames_to_merge);
end

for ii = 1:(N-frames_to_merge)
    
    if ii == 1
        for jj = 1:frames_to_merge
            im = imread(images(jj).name);
            im = im2double(im);
            % processing function goes here
            stack(:,:,jj,:) = im;
        end
    else
        im = imread(images(ii+frames_to_merge-1).name);
        im = im2double(im);
        % processing function goes here
        stack = circshift(stack,-1,3);
        stack(:,:,end,:) = im;
    end
    
    stack2 = stack;

    % Various optional operations:
    
    if params.take_diff
        stack2=diff(stack2, 3);
    end
    
    if params.subtract_median
        med_im = median(stack,3);
        stack2 = bsxfun(@minus,stack2,med_im); 
        % Uncomment if RAM use is an issue:
        %  parfor jj=1:frames_to_merge
        %      stack2(:,:,jj) = stack2(:,:,jj)-med_im;
        %  end
    end
    
    if params.subtract_first
        stack2 = bsxfun(@minus,stack2,stack2(:,:,1)); 
        % Uncomment if RAM use is an issue:
        %  parfor jj=1:frames_to_merge
        %      stack2(:,:,jj) = stack2(:,:,jj)-med_im;
        %  end
    end
    
    if params.invert_color
        max_proj = min(stack2,[], 3);
        max_proj = 1.0 - max_proj;
    else 
        max_proj = max(stack2,[], 3);
    end

    % Save image
    imname = [images(ii).name(1:end-4), '_streamlines', '_frames', num2str(frames_to_merge), '.tif'];
    savestr = fullfile(out_dir, imname);
    imwrite(max_proj, savestr, 'Compression','None');
end

end



