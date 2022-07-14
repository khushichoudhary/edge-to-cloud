#!/usr/bin/env python3

# Runs plankifier ML model on the edge device

# Runs count.sh on the VM device

from Pegasus.api import Workflow
wf = Workflow("main-sh", infer_dependencies = True)

from Pegasus.api import File, Job

#Run on Edge device
modelfullnames = '/srv/plankifier/trained-models/conv2/keras_model.h5'
weightnames = '/srv/plankifier/trained-models/conv2/bestweights.hdf5'
testdirs = '/srv/plankifier/camera-images'
thresholds = 0.6
ensMethods = 'unanimity'
predname = './predict'
output_file = File(f"predict_{ensMethods}abs{thresholds}.txt")

edge_job = (
    Job("python.py")
    .add_args("-modelfullnames", modelfullnames, "-weightnames", weightnames,"-testdirs", testdirs,"-thresholds", thresholds, "-ensMethods", ensMethods, "-predname", predname)
    .add_outputs(output_file)
    .add_condor_profile(
    requirements='DC_ID == "dc-1" && TARGET.Arch == "AARCH64"'
    )
    .add_env(
    "LD_PRELOAD",
    "/usr/lib/aarch64-linux-gnu/libgomp.so.1 /usr/local/lib/python3.7/dist-packages/sklearn/__check_build/../../scikit_learn.libs/libgomp-d22c30c5.so.1.0.0",
)
)
wf.add_jobs(edge_job)

# Executable
from Pegasus.api import TransformationCatalog, Transformation
tc = TransformationCatalog()
wf.add_transformation_catalog(tc)
python_py = Transformation(
    site = "condorpool",
    name = "python.py",
    pfn = "/srv/plankifier/predict.py",
    is_stageable = False,
)
tc.add_transformations(python_py)

#Run on Cloud
count_file = File("counts.txt")
cloud_job = (
    Job("count.sh")
    .add_args(output_file,count_file)
    .add_inputs(output_file)
    .add_outputs(count_file)
)
wf.add_jobs(cloud_job)

# Executable
cloud = Transformation(
    site = "condorpool",
    name = "count.sh",
    pfn = "/home/cc/plankifier-wf/bin/count.sh",
    is_stageable = True,
) 
tc.add_transformations(cloud)

w = Transformation(
    "worker",
    namespace="pegasus",
    site="condorpool",
    pfn="https://download.pegasus.isi.edu/arm-worker-packages/pegasus-worker-5.0.2-aarch64_deb_10.tar.gz",
    is_stageable=True,
)
tc.add_transformations(w)
wf.plan()
wf.run().wait()
