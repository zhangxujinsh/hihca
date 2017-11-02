% warning off;

opts = hihca_setup('runPhase', 'test', ...
                   'gpus', [1], ...
                   'cnnModel', 'vgg16', ...
                   'cnnModelDir', '../models/pretrained_models/imagenet-vgg-verydeep-16.mat', ...
                   'dataset', 'aircraft', ... % cubcrop, cub, aircraft, cars
                   'datasetDir', '../datasets/fgvc-aircraft-2013b',... % CUB_200_2011/CUB_200_2011; fgvc-aircraft-2013b; cars
                   ...
                   'imageScale', 2, ...
                   'hieLayerName', {'relu5_2', 'relu5_3'}, ...
                   'layerFusion', 'hc', ... % hed
                   'rescaleLayerFactor', [0.5, 1], ...
                   'kernelDegree', 2, ...
                   'homoKernel', true, ...
                   'num1x1Filter', [8192], ...
                   'pretrainFC', 'lr', ...
                   'batchSizeFC', 64, ...
                   ...
                   'numEpochs', 20, ...
                   'batchSize', 16, ...
                   'learningRate', [0.001*ones(1,10), 0.0001*ones(1,10)], ...
                   'weightDecay', 0.0005, ...
                   'momentum', 0.9);

imdb = data_loader(opts);

if strcmp(opts.dataset, 'aircraft')
    % aircraft-variant
    imdb.images.set(imdb.images.set==2) = 1;
    imdb.images.set(imdb.images.set==3) = 2;
else
    % cub, cubcrop, cars
    imdb.images.set(imdb.images.set==3) = 2;
end


if strcmp(opts.runPhase, 'train')
    hihca_train(imdb, opts);
else
    % fine-tune the model first then run testing
    opts.netIDX = opts.numEpochs;    
    hihca_test(imdb, opts);
    
    % train svm classifier (run testing) first then run visualization
    % hihca_visualization(imdb, opts);
end
