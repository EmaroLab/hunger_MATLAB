# hunger_MATLAB

The **hunger_MATLAB library** is a MATLAB library for the modelling and offline recognition of stereotyped human gestures on the basis of the information acquired by one wearable inertial sensor.

## 1. Installation & Usage

The **hunger_MATLAB library** has been developed with MATLAB R2008a.

It requires a MATLAB distribution. No installation is required.

### Usage with the WHARF Data Set

The WHARF Data set contains labelled accelerometer data recordings (obtained by a single wrist-worn 
tri-axial accelerometer) to be used for the creation and validation of acceleration 
models of simple human gestures.

The Data Set is composed of over 1000 recordings of 14 gestures performed by 17 volunteers. More information about the Data Set can be found in the MANUAL.

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

The Bimanual Data Set has been collected by Divya Shah, Ernesto Denicia and Tiago Pimentel in partial fulfillment of the requirements for the course Software Architectures for Robotics, offered at the University of Genoa within the European Master on Advanced Robotics (EMARO+) master programme.
