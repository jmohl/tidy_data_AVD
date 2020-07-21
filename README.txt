This project converts from proprietary BEETHOVEN data files generated on lab computers into a more analysis friendly MATLAB based table format.
This new format is referred to as tidy_data in other Groh lab related analysis code. 
This code also performs data cleaning, pre-processing, and the definition and extraction of certain features. Important features which are included in this project are:
- Saccade definition and endpoint extraction
- behavioral filtering and defining valid trials
- post-hoc calibration of eye tracking data using visual targets

IMPORTANT NOTE: data, results, and doc folders are not included in github version for privacy and data security reasons. 
These can be found on Fig server for groh lab under users/mohl/projects/tidy_data_AVD

IN ORDER TO RUN ANALYSIS:
-open 'master_script.m'
-change local directory to match location of project folder
-run

Directory structure for complete project:
data: contains a copy of all beethoven files generated as part of the recording for the multisensory, multitarget SC project (sometimes referred to as AVD). IMPORTANTLY this includes data from both version 1 and version 2 of the paradigm, which had slightly different features. The code extracts data from both of these paradigms into the same format.
--all beetoven files (.dat.cell1)
--metadata files (.csv)
--CHANGELOG.txt

src: contains all necessary code

doc: contains relevant documents, including descriptions of the behavioral paradigm

results: stores tidy_data files after running the script
