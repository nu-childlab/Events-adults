# Events Adults
A collection of experiments based on examining comparisons of dynamic events.

This experiment also uses Psychtoolbox version 3.0.12. For more information, see [the github page](https://github.com/Psychtoolbox-3/Psychtoolbox-3).

## How to Run
Put the experiment script you want to run in a folder, along with the two images and the appropriate parameters file(s). Go to the Matlab command line, use cd to navigate to the directory with the script, and run it.

##Design Notes
The general premise of these experiments is that a red star and a blue heart will each jump on the screen, with the number of jumps, the height of the jumps, and the time it takes to complete all the jumps being parameters specified in a csv file of parameters. They also spend a short time stopped between jumps, marked by an interjump interval parameter in the script, but not the parameters files.

There are two types of animation stimuli. One is sequential jumping, where the star jumps, followed by the heart, such that only one shape os in motion at a time. The other is simultaneous jumping, so that both shapes jump at the same time. Each of these blocks contained 4 sub-blocks, which differed only in the question asked: "Did the star jump HIGHER than the heart?", "Did the star jump MORE TIMES than the heart?", "Did the star jump LONGER than the heart?", and "Did the star jump MORE than the heart?". The order of these sub-blocks was randomized. the larger blocks are contained in separate files.

The shapes' jumps were calculated using a sine curve, which slowed the shape at the peak of the jump to give the impression of realistic jumping. The script creates a sine curve representing an appropriate number of frames (e.g. it calculates a series of positive y values (range 0-1) based on x (range 1-number of frames), where x is the number of frames and y = sin(x)). The maximum height is multiplied by the sine curve value, such that the sine curve acts like a percentage and dictates what percentage of the full height the shape has achieved.

#Experiments
The experiment files are Matlab scripts using Psychtoolbox version 3.0.12. For more information, see [the github page](https://github.com/Psychtoolbox-3/Psychtoolbox-3).

##Events 1v1
The initial experiment of the Events study. There experiment structure consists of 2 blocks, each of which contains 4 sub-blocks, for a total of 8 blocks. Each block contains 30 trials, so the total experiment contains 240 trials.

##Events 1v2
This experiment is nearly identical to the first. The parameters used were changed to improve the ratios between the various parameters. Additionally, the simultaneous and sequential conditions were combined into the same script, and the initial condition is specified at the start of the experiment along wiht subject number.

##Events 2
This experiment is similar to Events1v2. The parameters and movement are the same, but the background and question have changed. Instead of the blue sky and green grass from the first experiments, Events 2 splits the screen into a pink left half and a blue right half, and asks to compare whether the star has MOVED higher/longer/more times/more than the heart.

##Events 3
This experiment is similar to Events 2, but the sine curve that had contributed a sense of "jumping" is removed. There is one version with pauses between each up-and-down movement cycle, and one version without pauses.

#Image Files
The image files (“blue heart.png” and “red star.png”) are used for all experiments. They should be in the same folder as the experiment script when you run the experiment.

#Parameters Files
* eventsparameters.csv
  * Used for Events1v1, and for no other events experiment.
* eventsparametersv2.csv
  * An updated version of the parameters. Used for Events1v2, Events2, and both versions of Events3. It’s likely to be used for other events experiments as well.
* eventsparameterstest.csv
  * A shortened version of the parameters list with only one trial. Used for testing in Events1v2, Events2, and Events3. Use s999 as the subject number to run this list.
* eventsparameters_inclSameTrials.csv
  * Not used in any experiment. I think it includes trials where the star and heart are equal in some factor.

