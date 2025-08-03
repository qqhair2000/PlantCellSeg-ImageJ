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

The pipeline processes 3D confocal image stacks of plant tissues with flexible preprocessing options.

### Processing Steps:

1. **Preprocessing (choose one):**  
  ### 🧪 Preprocessing (choose one) / 前處理選擇（擇一）

-  **SurfCut2 Lite**  
   Extracts a surface layer from 3D stack; ideal for curved tissues.  
   從 3D 堆疊中擷取表面層，適合彎曲葉片或曲面樣本。

-  **Max Projection**  
   Projects Z-stack using maximum intensity; best for flat tissues.  
   將 Z 軸投影為最大強度影像，適合平坦或已壓平的樣本。

-  **None**  
   Directly segments the current slice; for 2D or preprocessed images.  
   直接對目前影像分割，適用於 2D 或已預處理的影像。

### 📌 Usage Tips / 使用建議

- 若葉片**彎曲嚴重**（例如自然捲曲或有弧形表面）：請選用 **SurfCut2 Lite**
- 若葉片**已壓平或本身較平坦**：可使用 **Max Projection**
- 若你使用的影像是**單張 2D** 或 **已經是處理過的投影圖**：可選擇 **None**

2. **Denoising:** Despeckle + Gaussian blur  
3. **Segmentation:** Marker-controlled watershed (MorphoLibJ)  
4. **ROI Extraction:** Convert label map to vector ROIs  


💡 Upon starting the macro, a dropdown menu allows you to select the preprocessing method, adapting the pipeline to your sample type.

---


## Comparison between SurfCut and SurfCut2 Lite

This project integrates [SurfCut2 Lite](https://github.com/VergerLab/SurfCut2) as a preprocessing step to efficiently and automatically extract the epidermal layer signal from 3D confocal stacks.

### Why choose SurfCut2 Lite?

- **Original SurfCut** [SurfCut](https://github.com/sverger/SurfCut)
  Offers full parameter options and an interactive interface, suitable for in-depth exploration of surface extraction principles and parameter tuning. It is a valuable tool for academic research and method development.

- **SurfCut2 Lite**  
  A lightweight, interface-free version designed for seamless integration into automated ImageJ macro workflows. It greatly saves processing time and improves reproducibility, making it ideal for routine large-scale data analysis.

### Recommendations

- If you need flexible parameter adjustments and want to deeply understand the projection mechanism, the original SurfCut is recommended.  
- If you prioritize speed, automation, and workflow stability, SurfCut2 Lite is preferred.


---

## 📁 Requirements

- Fiji (ImageJ) with the following plugins installed:
  - [MorphoLibJ](https://imagej.net/plugins/morpholibj)  
  - *(Optional)* [SurfCut2 Lite macro](https://github.com/VergerLab/SurfCut2) —  
    included in this pipeline for automated preprocessing  
- Java 8 or higher (standard with Fiji)

## 📖 References

- Verger, S., et al. (2019). SurfCut: A macro tool for surface layer extraction from 3D images. *BMC Biology*, 17, 32.  
  [https://doi.org/10.1186/s12915-019-0657-1](https://doi.org/10.1186/s12915-019-0657-1)

- Legland, D., Arganda-Carreras, I., & Andrey, P. (2016). MorphoLibJ: integrated library and plugins for mathematical morphology with ImageJ. *Bioinformatics*, 32(22), 3532–3534.  
  [https://doi.org/10.1093/bioinformatics/btw413](https://doi.org/10.1093/bioinformatics/btw413)

- Fiji / ImageJ Documentation:  
  [https://imagej.net/](https://imagej.net/)

- SurfCut2 Lite macro:  
  [https://github.com/VergerLab/SurfCut2](https://github.com/VergerLab/SurfCut2)


---

## 📬 License & Acknowledgements

- This pipeline optionally uses [SurfCut](https://github.com/sverger/SurfCut), which remains under its original license.  
- MorphoLibJ is maintained by the INRAE image processing team.  
- This pipeline is intended for academic and research use.
