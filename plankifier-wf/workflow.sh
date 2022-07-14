#!/bin/bash

set -e

# Run on the Edge Device
# Inputs are available in the Docker container.
# Output is a file called predict_{ensMethods}abs{thresholds}.txt
./predict.py \
    -modelfullnames './trained-models/conv2/keras_model.h5' \
    -weightnames './trained-models/conv2/bestweights.hdf5' \
    -testdirs './camera-images' \
    -thresholds 0.6 \
    -ensMethods 'unanimity' \
    -predname './predict'

# Run on the Cloud
bin/count.sh predict_unanimityabs0.6.txt counts.txt
