% makes synthetic testing dataset to be bundled into WISC_MVPA Apptainer.

% setup
addpath(genpath('/group/mlr-lab/Saskia/WISC_MVPA_Apptainer/WISC_MVPA'));
addpath(genpath('/group/mlr-lab/Saskia/WISC_MVPA_Apptainer/yaml'));
root = '/group/mlr-lab/Saskia/WISC_MVPA_Apptainer/';
cd(root);

% 1. MAKE DATA 

% load Dilkina norms
load([root,'/dilkina_norms.mat']);
% decompose matrix into singular vectors, scaled by their singular values
[U,D] = embed_similarity_matrix(dilkinaNorms,3);
C = rescale_embedding(U,D);
% initialise random number generator with a seed of 1
rng(1);
% get 100 trios of random numbers
weights = rand(100,3);
% initialise output
X = zeros(100,100);
% for 100 features
for i = 1:100
    % make a feature by creating a weighted sum of the 3 singular vectors
    X(:,i) = C(:,1)*weights(i,1) + C(:,2)*weights(i,2) + C(:,3)*weights(i,3);
end
% save
mkdir([root,'/test_data/']);
save([root,'/test_data/sub-01.mat'],'X','-v7.3');

% 2. MAKE METADATA

% load stimuli and cross-validation index
load([root,'/stimuli.mat']);
load([root,'/cross-validation_index.mat']);

% setup targets substructure
% label for ease of identification
targets.label = 'semantic';
% type (in this case, RSM)
targets.type = 'similarity';
% where the data is from 
targets.sim_source = 'DilkinaNormalised';
% similarity metric used to create RSM
targets.sim_metric = 'cosine';
% RSM itself
targets.target = dilkinaNorms;

% setup filters substructure (just row and column filters to mimic normal
% analysis)
% row filter will include all rows
filters(1).label = 'rowFilter';
filters(1).dimension = 1;
filters(1).filter = true(100,1);
% column filter will include all columns - leave unfilled for now
filters(2).label = 'columnFilter';
filters(2).dimension = 2;
filters(2).filter = true(1,100);

% setup fake coordinates. The features are labelled 1-1200 - the x-, y-, and
% z-coordinates take the same value. This means that the coords field will
% be n x 3, as WISC_MVPA expects.
coords.orientation = 'mni';
coords.labels = [];
coords.ijk = [];
coords.ind = [];
coords.xyz = repmat((1:100)',1,3);

% create metadata
metadata(1) = struct('subject',1,'targets',targets,'stimuli',{stimuli},'filters',filters,'coords',coords,'cvind',cvind,'nrow',100,'ncol',100);

% save
save([root,'/test_data/metadata.mat'],'metadata','-v7.3');

% 3. MAKE .YAML

% specify regularization (Brits, beware American spelling)
y.regularization = 'growl2';
% permutation test - set false for tuning
y.PermutationTest = false;
% save results as .mat file
y.SaveResultsAs = 'mat';
% use hyperband
y.SearchWithHyperband = true;

% should we fit the intercept of the model? No (0, default) or yes (1)
y.bias = 0;
% hyperparameters - range to search and distribution
y.lambda.args = {0,6};
y.lambda.distribution = 'uniform';
y.lambda1.args = {0,6};
y.lambda1.distribution = 'uniform';
% hyperband - aggressiveness (default 2), budget (default 32), hyperparameters
y.HYPERBAND.aggressiveness = 2;
y.HYPERBAND.budget = 32; 
y.HYPERBAND.hyperparameters = {'lambda','lambda1'};
% specify lambda sequence - linear (default) or exponential
y.LambdaSeq = 'linear';
% normalize using z-scoring
y.normalize_data = 'zscore';
% normalize the target to the center, i.e. subtract the mean value from
% each target value
y.normalize_target = 'center';
% normalize the data to the training set during training
y.normalize_wrt = 'training_set';

% add data location within apptainer
y.data = {'/test_data/sub-01.mat'};
% specify name of data variable in this file
y.data_var = 'X';
% add metadata location within apptainer
y.metadata = {'/test_data/metadata.mat'};
% specify name of data variable in these files
y.metadata_var = 'metadata';

% use the first cross-validation index of those available
y.cvscheme = 1;
% set cross-validation fold structure for inner loop. Initialise cell array
innerLoopFolds = cell(10,9);
% for each row
for i = 1:10
    % get the numbers 1:10, but with the number i missing
    row = setdiff(1:10,i);
    % fill in the cell array
    innerLoopFolds(i,:) = num2cell(row);
end
% add fold structure to .yaml
y.cvholdout = innerLoopFolds;
% this is a visualization job so there is no final holdout - the final model is trained on all data 
y.finalholdout = 0;
    
% provide information needed to identify the correct row of
% metadata.targets
y.target_label = 'semantic';
y.target_type = 'similarity';
y.sim_source = 'DilkinaNormalised'; % careful - British spelling used for metadata (despite American spelling used for toolbox compatibility!)
y.sim_metric = 'cosine';
% specify number of singular vectors into which to decompose the target
% representational similarity matrix
y.tau = 3;
    
% specify the orientation of the coordinates (should match
% metadata.coords.orientation)
y.orientation = 'mni';

% specify filters (within metadata.filters)
y.filters = {'rowFilter';'columnFilter'};

% specify whether to write coefficients on each feature (0) or not (1,
% default). This is only needed when coefficients will be plotted or
% interpreted
y.SmallFootprint = 1;
% specify naming conventions for data files (in a manner compatible with
% sprintf)
y.subject_id_fmt = 'sub-%02d.mat';
% set path to MATLAB binary (here at the CBU)
y.executable = [root,'/WISC_MVPA/WISC_MVPA'];
% set path to wrapper shell script for MATLAB binary
y.wrapper = [root,'/WISC_MVPA/run_WISC_MVPA.sh'];
    
% set variables that are distributed across jobs (i.e. every job receives
% one copy of data , one copy of the same metadata file, and one configuration of training folds
y.EXPAND = {'data';'metadata';'cvholdout'};
% state which files every job should receive
y.COPY = {'executable';'wrapper'};
% set up input queue (which will be automatically created and recorded in
% queue_input.csv). Each job must receive one data file plus metadata
y.URLS = {'data','metadata'};
    
% write .yaml
% block style is important for setupJobs
mkdir([root,'/tune'])
yaml.dumpFile([root,'/tune/visualize_tune.yaml'],y,'block');


