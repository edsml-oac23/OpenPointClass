###  Fork Notice
This is a research fork of [uav4geo/OpenPointClass](https://github.com/uav4geo/OpenPointClass)  
with added support for **multispectral point cloud features**.

### What it does?
OpenPointClass — Spectral
Spectrally-augmented point clouds for semantic segmentation (UAV LiDAR + multispectral)

This fork extends the original OpenPointClass (OPC) to accept per-point spectral features alongside the geometric neighborhood descriptors computed from XYZ. The goal is to make low-cost UAV LiDAR + multispectral missions more useful: geometry tells you shape (planarity, linearity, etc.), while spectra hint at material/vegetation. Together they improve class separability without the cost of airborne hyperspectral systems.

main branch → vanilla OPC (geometry only).

feature/spectral-implementation branch → adds spectral point features (this work).

Results here should be read as conservative regarding spectral gains. The C++ integration is minimal by design; deeper feature design and parameterization may further improve performance.

What’s new (this fork)
We add point-wise features read from LAS and forwarded into the learner:

nir, red_fused, green_fused, red_edge, ndvi

(optional) c2m = height above ground (a relative Z; can be computed externally)

Naming note: keep these field names exactly as above in your .las files.

OPC still computes its geometric multi-scale features from XYZ. Your spectral bands are additional inputs to the classifier.


### Why it matters?

### How to use it