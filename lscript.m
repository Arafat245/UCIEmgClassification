parentDir = './';
dataDir = 'DatabaseUCI';

allImages = imageDatastore(fullfile(parentDir,dataDir),...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');
files = allImages.Files;
labels = allImages.Labels;

%%
netCNN = googlenet;

%%
layerName = "pool5-7x7_s1";

%%
numFiles = numel(files);
sequences = cell(numFiles,1);
%%
for i = 1:numFiles
        fprintf("Reading file %d of %d...\n", i, numFiles)
        
        image = imread(char(files(i)));
        sequences{i,1} = activations(netCNN,image,layerName,'OutputAs','columns');
end

%%
numObservations = numel(sequences);
idx = randperm(numObservations);
N = floor(0.8 * numObservations);

idxTrain = idx(1:N);
sequencesTrain = sequences(idxTrain);
labelsTrain = labels(idxTrain);

idxValidation = idx(N+1:end);
sequencesValidation = sequences(idxValidation);
labelsValidation = labels(idxValidation);

%%
numFeatures = size(sequencesTrain{1},1);
numClasses = numel(categories(labelsTrain));

layers = [
    sequenceInputLayer(numFeatures,'Name','sequence')
    bilstmLayer(2000,'OutputMode','last','Name','bilstm')
    dropoutLayer(0.5,'Name','drop')
    fullyConnectedLayer(numClasses,'Name','fc')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];

%%
miniBatchSize = 32;
numObservations = numel(sequencesTrain);
numIterationsPerEpoch = floor(numObservations / miniBatchSize);

options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',10, ...
    'InitialLearnRate',1e-4, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{sequencesValidation,labelsValidation}, ...
    'ValidationFrequency',numIterationsPerEpoch, ...
    'Plots','training-progress', ...
    'Verbose',true);

%%
[netLSTM,info] = trainNetwork(sequencesTrain,labelsTrain,layers,options);

