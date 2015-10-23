% initialize all working directories and test the flowtrace algorithm

% use absolute paths so that MATLAB doesn't get scared
my_wd = pwd;

% add all of the critical functions to the main search path
addpath(genpath( [my_wd, '/libraries'] ));
addpath(genpath( [my_wd, '/sample_output'] ));
addpath(genpath( [my_wd, '/sample_data'] ));
addpath(my_wd);

% run the test code
flowtrace('sample_data',30,'sample_output');

% % uncomment to test passing parameters
% params = struct();
% params.subtract_median=true;
% params.subtract_first=false;
% params.invert_color=false;
% params.take_diff=false;
% params.fade_tails=false;
% params.color_series=true;
% flowtrace('sample_data',30,'sample_output',params);
