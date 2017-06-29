% initialize all working directories and test the flowtrace algorithm

% use absolute paths so that MATLAB doesn't get confused
my_wd = pwd;

% add all of the critical functions to the main search path
addpath(genpath( [my_wd, '/libraries'] ));
addpath(genpath( [my_wd, '/sample_output'] ));
addpath(genpath( [my_wd, '/sample_data'] ));
addpath(my_wd);

% % Run the test code
% Test with images
flowtrace('sample_data/sample_data_tif',30,'sample_output/sample_output_tif');
% Test with a movie file
flowtrace('sample_data/sample_data_mp4.mp4',30,'sample_output/sample_output_mp4');

% % uncomment to test passing parameters
% params = struct();
% params.subtract_median=true;
% params.subtract_first=false;
% params.invert_color=false;
% params.take_diff=false;
% params.fade_tails=false;
% params.color_series=true;
% flowtrace('sample_data',30,'sample_output',params);
