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

---

## 🧪 Pipeline Overview

1. *(Optional)* **SurfCut** – Surface projection from 3D stack  
2. **Max Projection** – Z-stack to 2D via maximum intensity  
3. **Denoising** – Despeckle + Gaussian blur  
4. **Segmentation** – Marker-controlled watershed (MorphoLibJ)  
5. **ROI Extraction** – Convert label map to vector ROIs  

---

## Comparison between SurfCut and SurfCut2 Lite

This project integrates [SurfCut2 Lite](https://github.com/VergerLab/SurfCut2) as a preprocessing step to efficiently and automatically extract the epidermal layer signal from 3D confocal stacks.

### Why choose SurfCut2 Lite?

- **Original SurfCut** ([VergerLab/SurfCut](https://github.com/VergerLab/SurfCut))  
  Offers full parameter options and an interactive interface, suitable for in-depth exploration of surface extraction principles and parameter tuning. It is a valuable tool for academic research and method development.

- **SurfCut2 Lite**  
  A lightweight, interface-free version designed for seamless integration into automated ImageJ macro workflows. It greatly saves processing time and improves reproducibility, making it ideal for routine large-scale data analysis.

### Recommendations

- If you need flexible parameter adjustments and want to deeply understand the projection mechanism, the original SurfCut is recommended.  
- If you prioritize speed, automation, and workflow stability, SurfCut2 Lite is preferred.


---

## 📁 Requirements

- Fiji with the following installed:  
  - [MorphoLibJ plugin](https://imagej.net/plugins/morpholibj)  
  - *(Optional)* [SurfCut macro](https://github.com/sverger/SurfCut)  

---

## 📖 References

- Verger et al., *BMC Biology*, 2019 – SurfCut  
- Legland et al., *MorphoLibJ*, 2016  
- Fiji / ImageJ documentation  

---

## 📬 License & Acknowledgements

- This pipeline optionally uses [SurfCut](https://github.com/sverger/SurfCut), which remains under its original license.  
- MorphoLibJ is maintained by the INRAE image processing team.  
- This pipeline is intended for academic and research use.
