function flowtrace(image_dir, frames_to_merge, out_dir, params)
% This function takes the sliding maximum intensity projection of
% either a movie or a series of ordered image files in an image directory
% 
% Code written by William Gilpin, 2015-2017. Please report issues on GitHub
%
% Inputs
% ------
% image_dir : str
%     either the path to the directory containing time series images
%     or the full path to a movie file of time series images
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
% color_series : bool
%     For each set of frames being merged, apply a gradient of color to frames 
%       further in the past so that each pathline has a color gradient corresponding
%       to time.
% fade_tails : bool
%      For each pathline, fade the frames further in the past so that the
%      pathline has an intensity gradient corresponding to time.
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
if ~isfield(params,'subtract_first')
    params.subtract_first=false;
end
if ~isfield(params,'color_series')
    params.color_series=false;
end
if ~isfield(params,'fade_tails')
    params.fade_tails=false;
end

% Check if the input is a movie file
[~,~,file_ext] = fileparts(image_dir);
if ~isempty(file_ext)
    movie_flag = 1; 
else
    movie_flag = 0;
end

if ~movie_flag
    images = make_image_struct(image_dir);
    N = numel(images);
    frame0 = imread(images(1).name);
else
    v = VideoReader(image_dir);
    N = v.NumberOfFrames;
    frame0 = read(v, 1);
end

frame0=im2double(frame0);
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
    
    % display progress
    if mod(ii,floor(N/20))==0
        disp(['Completed ' num2str(ii) ' of ' num2str((N-frames_to_merge))]);
    end
    
    if ii == 1
        for jj = 1:frames_to_merge
            if ~movie_flag
                im = imread(images(jj).name);
            else
                im = read(v, jj);
            end
            im = im2double(im);
            stack(:,:,jj,:) = im;
        end
    else
        
        if ~movie_flag
            im = imread(images(ii+frames_to_merge-1).name);
        else
            im = read(v, ii+frames_to_merge-1);
        end
        
        im = im2double(im);
        % processing function goes here
%         stack = circshift(stack,-1,3); % only works R2014a and later
        stack = circshift(stack,[0 0 -1]);
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
        
    if (params.color_series || params.fade_tails)
        if params.color_series
            bgclr = [90 10 250]/255;
            fgclr = [255 153 0]/255;
        elseif params.fade_tails
            bgclr = [0 0 0];
            fgclr = [1 1 1];
        end
        all_clr = zeros(frames_to_merge, 3);
        for qq=1:3
            all_clr(:,qq) = linspace(bgclr(qq),fgclr(qq), frames_to_merge);
        end
        
        maxdim = length(size(stack2));
        stack2 = cat(maxdim+1,stack2,stack2,stack2);
        
        sz = size(stack2);
        extrude_clr = repmat(all_clr,1,1,sz(1), sz(2));
        extrude_clr = permute(extrude_clr,[4 3 1 2]);
        
        stack2 = stack2.*extrude_clr;
        
    end
    
    if params.invert_color
        max_proj = min(stack2,[], 3);
        max_proj = 1.0 - max_proj;
    else 
        max_proj = max(stack2,[], 3);
    end

    
    max_proj = squeeze(max_proj);

    % Save images
    if ~movie_flag
        imname = [images(ii).name(1:end-4), '_streamlines', '_frames', num2str(frames_to_merge), '.tif'];
    else
        imname = ['frame_', num2str(ii), '_streamlines', '_frames', num2str(frames_to_merge), '.tif'];
    end
        
    savestr = fullfile(out_dir, imname);
    imwrite(max_proj, savestr, 'Compression','None');
end

end



