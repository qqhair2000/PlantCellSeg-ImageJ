// ====== PlantCellSeg-ImageJ: Full Pipeline Macro (with SurfCut2 Lite) ======

var Rad, Thld, Cut1, Cut2;  // 全域參數 for SurfCut
var imgName, imgDir, imgPath, imgNameNoExt;

//clean roi manager list
if (roiManager("count") > 0) {
    roiManager("Deselect");
    roiManager("Delete");
}
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
run("Duplicate...", "title=" + projImage + "_backup");

run("Despeckle");
run("Despeckle");
run("Gaussian Blur...", "sigma=3");

//get bitdepth
bitDepth1 = bitDepth();
var defaultTol = 10;
if (bitDepth1 == 16) {
    defaultTol = 2000;
}

//Segmentation Parameters
Dialog.create("Segmentation Parameters");
Dialog.addMessage(
	"Tolerance ：\n" +
    "8-bit  default：10\n" +
    "16-bit default：2000\n"
    );
Dialog.addNumber("Tolerance (default = " + defaultTol + ")", defaultTol);
//Dialog.addCheckbox("Show Watershed Lines (dams)", true);
//Dialog.addChoice("Connectivity", newArray("4", "8"), "4");
Dialog.show();
tol = Dialog.getNumber();
//showDams = Dialog.getCheckbox();
//print(showDams);
//conn = Dialog.getChoice();

run("Morphological Segmentation");

// select as border image
call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType", "border"); 
wait(2000);
call("inra.ijpb.plugins.MorphologicalSegmentation.segment", 
    "tolerance=" + tol, 
    "calculateDams=true", 
    "connectivity=4");
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


print(" Segmentation completed.");
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
// Retrieves the directory, name, and path of the currently opened image for later use

function GetImageName() {
    imgDir = File.directory;
    imgName = getTitle();
    imgPath = imgDir + imgName;
    imgNameNoExt = File.nameWithoutExtension();
}
// Prints information about the current image processing session (filename, path, date and time)

function ProcessingInfo() {
    print("\n-> Processing: " + imgName);
    print("Image path: " + imgPath);
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    print("Date: " + year + "/" + month + "/" + dayOfMonth);
    print("Time: " + hour + ":" + minute + ":" + second);
}
// Converts the image to 8-bit grayscale to ensure compatibility for further processing

function Preprocessing() {
    print("Pre-processing");
    run("8-bit");
}
// Applies Gaussian blur for denoising; Rad parameter controls blur radius (sigma)

function Denoising(Rad) {
    print("Gaussian Blur");
    run("Gaussian Blur...", "sigma=&Rad stack");
}
// Applies thresholding to create a binary mask from the image using the specified threshold value

function Thresholding() {
    print("Threshold segmentation " + Thld);
    setThreshold(Thld, 255);
    run("Convert to Mask", "method=Default background=Dark black");
}
// Performs edge detection by creating maximum intensity projections across slices and generates binary mask stacks
// 利用堆疊最大強度投影製作邊緣偵測，產生二值遮罩堆疊
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
// Creates a layer mask by shifting binary masks along the Z-axis according to top (Cut1) and bottom (Cut2) depth parameters
// 透過Z軸位移上下遮罩（Cut1與Cut2）產生分層遮罩
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
// Crops the original stack using the previously created layer mask to isolate the target region
// 利用分層遮罩裁剪原始堆疊，保留目標區域
function StackCropping() {
    print("Cropping stack");
    selectWindow(imgName);
    run("Grays");
    imageCalculator("Subtract create stack", imgName, "Layer Mask");
    close("Layer Mask");
}
// Generates a maximum intensity projection from the cropped stack, producing the SurfCut projection image
// 從裁剪後的堆疊製作最大強度投影，產生SurfCut投影影像
function SurfCutZProjections() {
    print("SurfCut Z-Projections");
    selectWindow("Result of " + imgName);
    rename("SurfCutStack_" + imgName);
    run("Z Project...", "projection=[Max Intensity]");
    rename("SurfCutProjection_" + imgName);
}
// Generates a maximum intensity projection from the original image stack for comparison purposes
// 從原始堆疊製作最大強度投影，作為對照影像
function OriginalZProjections() {
    print("Original Z-Projections");
    selectWindow(imgName);
    run("Z Project...", "projection=[Max Intensity]");
    rename("OriginalProjection_" + imgName);
}
list = getList("image.titles");
print("Currently open images:");
for (i = 0; i < list.length; i++) {
    print(" - " + list[i]);
}
