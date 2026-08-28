# visual_connectivity

This repository include code to reproduce analyses from our manuscript titled:

__Electrical perturbation reveals a directional architecture for communication across human visual streams__

María Guadalupe Yáñez-Ramos, Gabriela Ojeda Valencia, Harvey Huang, Nicholas M. Gregg, Jordan Bilderbeek, Morgan Montoya, Kendrick Kay, Gregory A. Worrell, Kai J. Miller, Dora Hermes

Contact: 
- Yanez-Ramos.MariaGuadalupe@mayo.edu
- Hermes.Dora@mayo.edu

## Data and code availability

Analysis code is provided in this GitHub repository.

The corresponding preprocessed and derived data will be available through the associated OSF project:

**OSF:** 

Participants are identified using anonymized identifiers (`sub-01` through `sub-23`).

## Recommended project structure

To reproduce the analyses, organize the code and data using the following directory structure:

visual_connectivity/
├── README.md
├── participants.tsv
├── code/
└── derivatives/
    ├── ccep_connectivity/
    │   ├── sub-01/
    │   ├── ...
    │   └── sub-23/
    │
    ├── preproc_synth/
    │   ├── sub-01/
    │   ├── sub-11/
    │   └── sub-17/
    │
    ├── loc_info/
    │   ├── sub-01/
    │   ├── ...
    │   └── sub-23/
    │
    └── freesurfer/
        ├── sub-01/
        ├── ...
        └── sub-23/


See the README provided with the OSF data deposit for additional information about the derivative files and coordinate spaces.


## Clone the repository

Because this repository includes external dependencies as Git submodules, clone it using:

git clone --recurse-submodules https://github.com/MultimodalNeuroimagingLab/visual_connectivity.git

If the repository has already been cloned without its submodules, run:

git submodule update --init --recursive


## Dependencies

External dependencies included as Git submodules include:

mnl_ieegBasics
vistasoft

Additional external MATLAB functions distributed with the repository are located under:

code/external/


## Running the analyses

After downloading the code and arranging the OSF data according to the directory structure above, open:

code/vc_00principalCode_2share.m

This script provides the recommended order for reproducing the CCEP analyses and indicates how to run the synthetic-task analyses.

Run the main script section by section rather than executing the entire file at once. Several visualization steps generate memory-intensive figures. After saving or inspecting each figure, close it before continuing to the next section.


## The main workflow includes:
Loading subject-level CCEP connectivity data.
Organizing significant and non-significant responses by visual pathway.
Adding stimulation-pair information.
Computing pathway-level connectivity measures.
Generating effective-connectivity summary figures.
Rendering CCEP responses on cortical surfaces.
Preparing response-level tables.
Generating violin plots and fitting linear mixed-effects models.
Generating circular connectograms.
Generating the connectivity matrix.
Calculating the percentage of significant responses.
The synthetic-task analyses.


## MATLAB and computing environment

The complete project requires approximately 62 GB of disk space, including the preprocessed and derived data, analysis code, and external dependencies.

The analysis pipeline was tested using MATLAB R2024a on Apple silicon macOS systems, including:

MacBook Pro, Apple M4 Max, 128 GB RAM
Mac Studio, Apple M3 Ultra, 96 GB RAM
Apple M1 Max system

Testing was performed under macOS Tahoe 26.6.2.

Because several cortical rendering and connectivity-figure steps can require substantial memory, systems with sufficient RAM are recommended.


## Notes

The repository contains analysis code and configuration files. Preprocessed and derived participant data are distributed separately through OSF.

The anonymized participant identifiers used in the code correspond directly to the directory names in the OSF data release.
