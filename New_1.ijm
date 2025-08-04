// ====== PlantCellSeg-ImageJ: Full Pipeline Macro (with SurfCut2 Lite) ======

var Rad, Thld, Cut1, Cut2;  // 全域參數 for SurfCut
var imgName, imgDir, imgPath, imgNameNoExt;

print("\\Clear");
var title = getTitle();

// ==== Choose preprocessing method ====
Dialog.create("PlantCellSeg Pipeline");
Dialog.addMessage("Select preprocessing method:");
Dialog.addChoice("Preprocessing:", newArray("SurfCut2 Lite", "Max Projection", "None"), "SurfCut2 Lite");
Dialog.show();
choice = Dialog.getChoice();

var projImage;

// --- Image Preprocessing ---
if (choice == "SurfCut2 Lite") {
    callSurfCut2Lite();
    projImage = "SurfCutProjection_" + title;
} else if (choice == "Max Projection") {
    run("Z Project...", "projection=[Max Intensity]");
    rename("MaxProjection_" + title);
    projImage = "MaxProjection_" + title;
} else if (choice == "None") {
    projImage = title;
}

// --- Segmentation ---
selectWindow(projImage);
run("Despeckle");
run("Despeckle");
run("Gaussian Blur...", "sigma=3");
run("Morphological Segmentation");

// select as border image
call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType", "border"); 
wait(2000);
call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=10.0", "calculateDams=true", "connectivity=4");
wait(2000);
call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Catchment basins");
wait(2000);
call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
wait(2000);
run("Label Map to ROIs", "connectivity=C4 vertex_location=Corners name_pattern=r%03d");

// Clean up intermediate window
if (isOpen("Morphological Segmentation")) {
    selectWindow("Morphological Segmentation");
    close();
}

print("✅ Segmentation completed.");
run("Tile");


// ============================================================================
// ========================== SurfCut2 Lite Functions ==========================
// ============================================================================

function callSurfCut2Lite() {
    print("\\Clear");
    print("=== Running SurfCut2Lite Preprocessing ===");

    Dia_BatchSurfCut_Parameters();
    setBatchMode(true);
    GetImageName();
    ProcessingInfo();
    Preprocessing();
    Denoising(Rad);
    Thresholding();
    EdgeDetection(imgName);
    ZAxisShifting(Cut1, Cut2);
    open(imgPath);
    StackCropping();
    SurfCutZProjections();
    OriginalZProjections();
    close("Mask-0-invert");
    close("Mask-0");
    setBatchMode("exit and display");
    run("Tile");
    print("===== Done =====");
}

function Dia_BatchSurfCut_Parameters() {
    Dialog.create("SurfCut Parameters");
    Dialog.addMessage("1) Choose Gaussian blur radius");
    Dialog.addNumber("Radius\t", 3);
    Dialog.addMessage("2) Choose an intensity threshold\nfor surface detection\n(Between 0 and 255)");
    Dialog.addNumber("Threshold\t", 30);
    Dialog.addMessage("3) Cutting depth parameters");
    Dialog.addNumber("Top\t", 10);
    Dialog.addNumber("Bottom\t", 20);
    Dialog.show();
    Rad = Dialog.getNumber();
    Thld = Dialog.getNumber();
    Cut1 = Dialog.getNumber();
    Cut2 = Dialog.getNumber();
}

function GetImageName() {
    imgDir = File.directory;
    imgName = getTitle();
    imgPath = imgDir + imgName;
    imgNameNoExt = File.nameWithoutExtension();
}

function ProcessingInfo() {
    print("\n-> Processing: " + imgName);
    print("Image path: " + imgPath);
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    print("Date: " + year + "/" + month + "/" + dayOfMonth);
    print("Time: " + hour + ":" + minute + ":" + second);
}

function Preprocessing() {
    print("Pre-processing");
    run("8-bit");
}

function Denoising(Rad) {
    print("Gaussian Blur");
    run("Gaussian Blur...", "sigma=&Rad stack");
}

function Thresholding() {
    print("Threshold segmentation " + Thld);
    setThreshold(Thld, 255);
    run("Convert to Mask", "method=Default background=Dark black");
}

function EdgeDetection(Name) {
    print("Edge detect");
    getDimensions(w, h, channels, slices, frames);
    print("    " + slices + " slices in the stack");
    for (img = 0; img < slices; img++) {
        print("\\Update:    Edge detect projection " + (img + 1) + "/" + slices);
        slice = img + 1;
        selectWindow(Name);
        run("Z Project...", "stop=&slice projection=[Max Intensity]");
    }
    run("Images to Stack", "name=Mask-0 title=[]");
    run("Duplicate...", "title=Mask-0-invert duplicate");
    run("Invert", "stack");
    selectWindow(Name);
    close();
}

function ZAxisShifting(Cut1, Cut2) {
    print("Layer mask creation - Z-axis shift - " + Cut1 + "-" + Cut2);
    selectWindow("Mask-0");
    getDimensions(w, h, channels, slices, frames);

    if (Cut1 == 0) {
        selectWindow("Mask-0-invert");
        run("Duplicate...", "duplicate");
        rename("StackUpShifted");
    } else {
        newImage("AddUp", "8-bit white", w, h, Cut1);
        Slice1 = slices - Cut1;
        selectWindow("Mask-0-invert");
        run("Duplicate...", "title=StackUpSub duplicate range=1-&Slice1");
        run("Concatenate...", "title=[StackUpShifted] image1=[AddUp] image2=[StackUpSub]");
    }

    newImage("AddInv", "8-bit black", w, h, Cut2);
    Slice2 = slices - Cut2;
    selectWindow("Mask-0");
    run("Duplicate...", "title=StackInvSub duplicate range=1-&Slice2");
    run("Concatenate...", "title=[StackInvShifted] image1=[AddInv] image2=[StackInvSub]");

    imageCalculator("Add create stack", "StackUpShifted", "StackInvShifted");
    close("StackUpShifted");
    close("StackInvShifted");
    selectWindow("Result of StackUpShifted");
    rename("Layer Mask");
}

function StackCropping() {
    print("Cropping stack");
    selectWindow(imgName);
    run("Grays");
    imageCalculator("Subtract create stack", imgName, "Layer Mask");
    close("Layer Mask");
}

function SurfCutZProjections() {
    print("SurfCut Z-Projections");
    selectWindow("Result of " + imgName);
    rename("SurfCutStack_" + imgName);
    run("Z Project...", "projection=[Max Intensity]");
    rename("SurfCutProjection_" + imgName);
}

function OriginalZProjections() {
    print("Original Z-Projections");
    selectWindow(imgName);
    run("Z Project...", "projection=[Max Intensity]");
    rename("OriginalProjection_" + imgName);
}
