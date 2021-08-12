# MultiMosaic
Repository for JBO Submission for Multi-Channel SURF Based Mosaicking

Methods and software described in manuscript submitted to JBO (2021). Written in Matlab R2021a (Mathworks). Requires Computer Vision Toolbox. Parallel Computing toolbox, with a GPU and appropriate CUDA installations, is recommended for faster processing.

Included in this repository is an implementation of graph-cut based stitching, as done by Kose et al., which greatly increases the quality of mosaics. This implementation is based on a Matlab wrapper by Shai Bagon:
https://github.com/shaibagon/GCMex

Our software and algorithm is free to use under the GPL 3.0. We only ask that you cite [a] and [b] in any resulting work. The graph-cut based stitching is under patent protection, and can be used for research purposes. Those authors have asked that you cite [c-g] in any resulting works if their method is used. Our method can be used without graph-cut stitching; in this case, frames will simply be layered.

**Mosaicking algorithm:**

[a] Multichannel correlation improves the noise tolerance of real-time hyperspectral microimage mosaicking. Ryan T. Lang et al., Journal of Biomedical Optics, vol. 24, no. 12, December 2019, 126002.

[b] Methods for Mosaicking Video-Rate Multiplexed Microendoscopy to Enable Analysis of Tumor Heterogeneity. Ryan T. Lang et al., Journal of Biomedical Optics (under review).

**Graph-cut based stitching implementation:**

[c] Automated video-mosaicking approach for confocal microscopic imaging in vivo: an approach to address challenges in imaging living tissue and extend field of view. Kivanc Kose et al., Scientific Reports, vol. 7, no. 10759, September 2017

[d] Matlab Wrapper for Graph Cut. Shai Bagon. in https://github.com/shaibagon/GCMex, December 2006.

**Graph-cut minimization theory and methods:**

[e] Efficient Approximate Energy Minimization via Graph Cuts Yuri Boykov, Olga Veksler, Ramin Zabih, IEEE transactions on PAMI, vol. 20, no. 12, p. 1222-1239, November 2001.

[f] What Energy Functions can be Minimized via Graph Cuts? Vladimir Kolmogorov and Ramin Zabih. IEEE Transactions on Pattern Analysis and Machine Intelligence (PAMI), vol. 26, no. 2, February 2004, pp. 147-159.

[g] An Experimental Comparison of Min-Cut/Max-Flow Algorithms for Energy Minimization in Vision. Yuri Boykov and Vladimir Kolmogorov. In IEEE Transactions on Pattern Analysis and Machine Intelligence (PAMI), vol. 26, no. 9, September 2004, pp. 1124-1137.

### 1) Install

Clone the repository and run compile_gc.m (in GCmex2.0 directory) to build the MEX libraries and enable graph-cut based stitching.

The MultiMosaic.mlapp file has been tested on Windows 10 / Matlab R2021a. It requires the Computer Vision Toolbox.

Make sure all content in the repo are included in the Matlab path.

### 2) Loading Data

The Load Raw Data file option will allow importation of multi-channel sequential image frames. There are three options:
* ...From Directory - Choose a directory with multiple sub-folders. Each sub-folder in this directory will be treated as a data channel, and within each sub-directory should be an equal number of sequential images labelled "frame#.tif", where the # is replaced by the image number tag starting at 0. The last folder alphabetically should have composite images (i.e. false-colored for visualization). If there are no composite images, copy the sub-folder with the best reference channel to create the composite folder before loading data.
* ...From File - This is only used to load an .h5 file that was previously saved with MultiMosaic. Use the save raw data function to create these files containing video frames. Loading data from an .h5 file is much faster than the other options.
* ...From HyperViewer - Data saved with the Spring Lab HyperViewer2 software (https://github.com/springlabnu/hyperviewer2) will be read with this option. HyperViewer2 will output unmixed endmember maps from hyperspectral imaging. Each frame is stored in a sub-folder and labeled sequentially. Within the sub-folders, this function only looks for images (channels) matching fluorophore names:\
`{R = regexp(greyChannels(k).name,'(AF610|AF633|AF647|AF660|AF680|AF700|AF750|Cy7|Sulforhodamine-101|Acridine-Orange)','match','once');}`\
You may need to add partial matching strings to this list for different channel names (line 427).

### 3) Calculating Frame-Pair Alignments

Use the Registration tab to calculate frame-pair alignments. Crop the data to remove unwanted frames or areas from the images. Flatfield Correction will normalize each pixel by the average of that pixel for all frames, removing vignetting effects (crucial to make seamless mosaics). The alignment kernel can be selected from cross-correlation (2019 JBO Method), standard SURF features with MLESAC outlier elimination, or SURF features with our custom match filtering cost function described in the 2021 publication. Matrix type defines what transformation should be calculated between frames.

### 4) Refining and Correcting Alignments

Refine alignments with the Alignment Editor tab. First, if cross-correlation was used for alignments, Alignment -> Auto-Fix Alignments will use the SURF cost function method to find acceleration outliers (bad alignments) and recalculate. The Matched Point Density plot will allow the user to manually select a group of features for Affine alignment - move the rectangle to select a match hotspot and click Re-Calculate Transform. For stubborn frame pairs, use the Manual Match option to manually input matching points.

### 5) Stitching Mosaic

When alignments are satisfactory, use the Stitching tab to produce composite mosaic images. Only use Graph-Cut Stitching in accordance with the terms by the authors who developed it (listed above). The program will prompt the user to stitch individual channels in addition to the composite frames. Use Save Mosaic Image to export final images (recommended to use .tiff file extension for lossless images).
