# README

The **hunger_MATLAB library** is a MATLAB library for the modelling and offline recognition of stereotyped human gestures on the basis of the information acquired by wearable inertial sensors.

## 1. Installation & Usage

The **hunger_MATLAB library** has been developed with MATLAB R2008a.

It requires a MATLAB distribution. No installation is required.

### Usage with the WHARF Data Set

The WHARF Data set contains labelled accelerometer data recordings (obtained by a single wrist-worn 
tri-axial accelerometer) to be used for the creation and validation of acceleration 
models of simple human gestures.



The Data Set is composed of over 1000 recordings of 14 gestures 
performed by 17 volunteers:


1.  Brush own teeth

2.  Comb own hair
3.  Get up from the bed

4.  Lie down on the bed
5.  Sit down on a chair

6.  Stand up from a chair

7.  Drink from a glass

8.  Eat with fork and knife

9.  Eat with spoon

10. Pour water into a glass

11. Use the telephone

12. Climb the stairs

13. Descend the stairs

14. Walk

More information about the Data Set can be found in the MANUAL.



The MATLAB scripts `displayTrial.m` and `displayModel.m` allow for the visualization 
of the recorded accelerometer data.

To create the models of the gestures, using the modelling sets provided in the MODELS folders, run:

`BuildWHARF`

To validate the models:

1. copy-paste the trials to be analysed in the VALIDATION folder
2. run `ValidateWHARF`
3. check the results in the RESULTS folder

### Info for developers

...under construction...

## 2. Documentation

Detailed information and example usage of the scripts can be
 accessed from within the MATLAB environment with the command:


`help [function_name]`, e.g.
 `help displayModel`

## 3. Licensing

Please refer to the LICENSE.

For further information, please contact the authors.

## 4. Authors contacts

If you want to be informed about library updates and new releases, obtain further information about the provided code, or contribute to its development please write to:

Barbara Bruno - barbara.bruno@unige.it

Fulvio Mastrogiovanni - fulvio.mastrogiovanni@unige.it

Barbara Bruno and Fulvio Mastrogiovanni are with the dept. DIBRIS at the University of Genoa, Italy.
