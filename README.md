# PlantCellSeg-ImageJ

A modular and practical **ImageJ/Fiji pipeline** for segmenting *plant epidermal cells* from 3D confocal microscopy images.  
This workflow includes **optional preprocessing with SurfCut** to better handle curved tissues such as leaves, and uses **MorphoLibJ** for morphological segmentation.

---

## 📌 Features

- 🔬 Designed for **plant epidermal tissue** (e.g., leaf surface)
- 🧼 **SurfCut support (optional)** for surface flattening
- 🧠 Morphological segmentation using **MorphoLibJ**
- 📏 ROI extraction for quantitative shape analysis
- 🔁 ImageJ macro-based, reproducible and extensible



## 🧪 Pipeline Overview

1. *(Optional)* **SurfCut** – Surface projection from 3D stack
2. **Max Projection** – Z-stack to 2D via maximum intensity
3. **Denoising** – Despeckle + Gaussian blur
4. **Segmentation** – Marker-controlled watershed (MorphoLibJ)
5. **ROI Extraction** – Convert label map to vector ROIs



## 📁 Requirements

- Fiji with the following installed:
- MorphoLibJ plugin
- (Optional) SurfCut macro



## 📖 References

- Verger et al., BMC Biology, 2019 – SurfCut
- Legland et al., MorphoLibJ, 2016
- Fiji / ImageJ documentation



## 📬 License & Acknowledgements

-This pipeline optionally uses SurfCut, which remains under its original license.
-MorphoLibJ is maintained by the INRAE image processing team.
-This pipeline is intended for academic and research use.
