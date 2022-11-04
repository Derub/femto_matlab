# femto_matlab
Matlab based codes for FLM fabrications, implemented for working platforms of IFN-CNR Fast Group. 

The codes are meant to be interfaced with an Aereotech system that accepts G-Code based instructions. Specificities depends on the different FLM platforms.

The laser written structures (i.e. laser paths) are considered as a set of movements of the stages represented by a matrix called GCODE_array, given in the following shape:

GCODE_array=[x,y,z,velocity,shutter,wait,motion,radius,angle]

Description of each vector:

