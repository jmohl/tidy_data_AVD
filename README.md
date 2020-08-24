## Raw data conversion pipeline

This project converts from proprietary BEETHOVEN data files generated on lab computers into a more analysis friendly MATLAB based table format.
This new format is referred to as tidy_data in other Groh lab related analysis code. 
This code also performs data cleaning, pre-processing, and the definition and extraction of certain features. Important features which are included in this project are:
- Saccade definition and endpoint extraction
- behavioral filtering and defining valid trials
- post-hoc calibration of eye tracking data using visual targets

IMPORTANT NOTE: data, results, and doc folders are not included in github version for privacy and data security reasons. 
These can be found on Fig server for groh lab members under users/mohl/projects/tidy_data_AVD

### Running data pipeline:
-open 'master_script.m'
-change local directory to match location of project folder, including data files
-run script

### File structure
src: Contains all necessary code, including both the code needed to extract beethoven files into matlab and code required to preprocess data.

**Not in repo**
data: not in repo,  contains a copy of all beethoven files generated as part of the recording for the multisensory, multitarget SC project (sometimes referred to as AVD). 
Importantly this includes data from both version 1 and version 2 of the paradigm, which had slightly different features. The code extracts data from both of these paradigms into the same format.
--all beetoven files (.dat.cell1)
--metadata files (.csv)
--CHANGELOG.txt

doc: not in repo, contains relevant documents, including descriptions of the behavioral paradigm

results: not in repo, stores tidy_data files after running the script
