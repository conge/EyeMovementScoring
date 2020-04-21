# EyeMovementScoring
 Matlab scripts to assist scoring eye movement data using the timing information from [Presentation®](https://www.neurobs.com/menu_presentation/menu_features/features_overview)  log files. sample data is provided on [GitHub](https://github.com/conge/EyeMovementScoring/tree/master/data)

* The scripts are designed to assist human to identify reaction time, accuracy of eye movements. Human interaction is needed to accomplish the goal.  
* New scorer must read the two PDFs above first before doing eye movement scoring. Please practice with and experienced scorer before using the scripts indecently.  
* The scripts require Matlab 7.0. They are not tested with other versions of Matlab.

# Files/folders

- data: folder contains sample eye movement data exported from [EyeLink II system](https://www.sr-research.com/eyelink-ii/)
- data/logfiles: the log files from Presentation. The log files recoded the timestamp of the onset and offset of the stimulus the human subjects get while their eye movements were tracked.
- output: the out of the eye movement scoring scripts.
- scripts: Matlab scripts which read in eye movement data and Presentation log data, plot them in graphs and ask user inputs to identify the metrics of fast eye movements (AKA saccades).
- eye_mvt_instructions.pdf: general steps to prepare the data and log files and run the scoring scripts
- eye_mvt_scoring_tutorial.pdf: step-by-step tutorial with screenshots, demonstrate how the scripts extract the eye movement metrics.


# Notes:

* Presentation® is a stimulus delivery and experiment control program for neuroscience
* [The EyeLink II](https://www.sr-research.com/eyelink-ii/) is a head mounted video-based eye tracke from SR Research.

