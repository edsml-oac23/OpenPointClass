<div align="center">

# OpenPointClass — Spectral

### Spectrally-augmented point clouds for semantic segmentation (UAV LiDAR + multispectral)

This is a research fork of [`uav4geo/OpenPointClass`](https://github.com/uav4geo/OpenPointClass) with added support for **multispectral point cloud features**.

</div>

---

## Why This Matters

Many UAVs carry **LiDAR + multispectral cameras** together, but analysis tend to be made separately. This proposal is an starting point to exploit **low-cost UAV LiDAR + multispectral** missions **without needing expensive hyperspectral sensors**. This fork lets you:

* Use both **shape + reflectance** in one fast, CPU-friendly model
* Improve separation of classes like:

  * **Shrub vs. Roof** (both planar, but different spectra)
  * **Tree vs. Chayote vine** (similar structure, different NDVI)

No voxelization. No rasterization. Just better 3D segmentation.

---

## What It Does

This fork extends the original **OpenPointClass (OPC)** to accept **per-point spectral features** (e.g., NIR, Red Edge, NDVI) **alongside** OPC’s native geometric descriptors (like planarity, linearity, omnivariance).

> **Important clarification**:
> This extension does not perform data fusion. The fusion of LiDAR and multispectral data must be done **externally**, prior to using this tool. We recommend using **PDAL** for this task, as it enables robust, scalable point cloud processing and attribute injection.

The notebook included in the project provides step-by-step guidance on how to perform the fusion using PDAL, including normalization, NDVI computation, and colorization of the point cloud.

This C++ extension assumes that spectral attributes are already present in the input `.las` file. It does not include functionality for image-to-point registration, raster sampling, or co-registration — these steps are expected to be completed beforehand.

---

## Docker (recommended)

Use Docker to avoid environment conflicts and to keep runs reproducible across machines.

**A) Baseline (vanilla OPC, geometry-only):**

* Pull upstream image and run it, mounting your repo and data:

  ```bash
  docker pull uav4geo/openpointclass:latest
  docker run --rm -it --cpus=4 \
    -v "$PWD":/workspace -v /path/to/data:/data \
    uav4geo/openpointclass:latest bash
  ```
* Inside the container, use the **prebuilt** executables `/build/pctrain` and `/build/pcclassify` on geometry-only `.las`.
  *(This establishes the baseline with the authors’ binaries.)*

**B) Spectral runs (this fork, compiled inside the container):**

* In the same running container, compile this fork’s spectral branch and use the built binaries:

  ```bash
  cd /workspace
  git checkout feature/spectral-implementation
  cmake -S . -B build-spec -DCMAKE_BUILD_TYPE=Release
  cmake --build build-spec -j"$(nproc)"
  # Use: /workspace/build-spec/pctrain and /workspace/build-spec/pcclassify
  ```

**Notes:**

* Mounts (`/workspace`, `/data`) ensure models, logs, and predictions persist outside the container.
* On WSL, use Linux paths (e.g., `/mnt/c/...`).
* Log which binary you used (`/build/...` vs `/workspace/build-spec/...`) to keep baseline vs spectral runs clearly separated.

---

## Branches Overview

| Branch                            | Purpose                                                  |
| --------------------------------- | -------------------------------------------------------- |
| `main`                            | Vanilla OPC — geometry-only features (original baseline) |
| `feature/spectral-implementation` | This work: adds spectral features to the classifier      |

> **Note**: Results using this fork should be seen as **conservative**. The C++ integration is minimal; deeper fusion strategies (e.g., attention, normalization) could further boost performance.

---

## What’s New (This Fork)

We add the following **per-point spectral features** from a fused `.las` file directly into the classifier:

* `nir`
* `red_fused`
* `green_fused`
* `red_edge`
* `ndvi`
* (optional) `c2m` = height above ground (relative Z). We suggest using Cloud Compare to calculate it.

### Naming Note

Keep the field names **exactly as above** in your `.las` files.
Avoid spaces, capitalization, or typos (e.g., use `red_fused`, not `RedFused` or `red-fused`).

> OPC still computes its **multi-scale geometric features** from `X,Y,Z`.
> These spectral bands are **additional inputs** — no changes to the core feature engine.




## How to Use It

### 1. Prepare Your Data

Ensure your `.las` files contain these dimensions:

```
X, Y, Z, Intensity, ReturnNumber, NumberOfReturns, Classification,
nir, red_fused, green_fused, red_edge, ndvi, (optional: c2m)
```

We use ASPRS class codes:

* `2` = ground
* `3` = chayote
* `4` = shrubs
* `5` = trees
* `6` = buildings
* `14` = wires

### 2. Build the Binary

Inside your dev container:

```bash
cd /workspace
git checkout feature/spectral-implementation

cmake -S . -B build-spec -DCMAKE_BUILD_TYPE=Release -DWITH_GBT=ON
cmake --build build-spec -j$(nproc)
```

### 3. Train with Spectral Features

```bash
/workspace/build-spec/pctrain "/data/02_data_labeled/TRAIN_small.las" \
  --classes 2,3,4,5,6,14 --trees 200 --depth 28 --scales 8 --radius 0.16 \
  -o "/data/03_models/spec_rf.bin" \
  --eval "/data/02_data_labeled/VAL_small.las" \
  --eval-result "/data/04_predictions/spec_rf_eval.las"
```

### 4. Classify Test Set

```bash
/workspace/build-spec/pcclassify \
  "/data/02_data_labeled/TEST_small.las" \
  "/data/04_predictions/spec_rf_TEST.las" \
  "/data/03_models/spec_rf.bin"
```

---

## Project Structure (Expected)

Put your data under:

```
opc_process/
  02_data_labeled/     ← TRAIN/VAL/TEST_small.las
  03_models/           ← saved .bin models
  04_predictions/      ← output .las files
  06_tuning_stats/     ← JSON stats from training
  07_Notebook/         ← Jupyter notebooks (optional)
```

---

## Notebook Support

Use the provided notebook (`IRP_base_code.ipynb`) to:

* Stream large LAS files safely
* Run training & evaluation
* Compute metrics (OA, F1, IoU)
* Plot results

Set:

```python
BIN = "spec"  # for spectral build
```

---

## License

Same as upstream: **GNU Affero General Public License (AGPL) v3**
See [LICENSE](LICENSE) for details.

---

## Credits

* **Original OPC**: [uav4geo/OpenPointClass](https://github.com/uav4geo/OpenPointClass)
* **This fork**: Oscar Calva (edsml-oac23) — part of MSc IRP at Imperial College London

---

> **Questions or ideas?**
> Open an issue or reach out. Let’s build better tools for **open, accessible 3D environmental analysis**.
