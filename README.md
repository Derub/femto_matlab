# femto_matlab
Matlab based codes for FLM fabrications, implemented for working platforms of IFN-CNR Fast Group. 

The codes are meant to be interfaced with an Aereotech system that accepts G-Code based instructions. Specificities depends on the different FLM platforms.

The laser written structures (i.e. laser paths) are considered as a set of movements of the stages represented by a matrix called GCODE_array, given in the following shape:

GCODE_array=[x,y,z,velocity,shutter,wait,motion,radius,angle]

Description of each vector:
x, y, z: arrays of 3D coordinates that define the variuos points connected to create a laserpath. 
REMARK:z can be empty and the structure will be written only along xy plane

velocityt: speed of the stage movement

shutter: flag for the shutter. If 1, the point is reached with open shutter, if 0 with closed shutter

wait: Wait is a pause before the movement. can be 'auto', 'nowait' or an array of positive values. in case of auto, for every command the compiler insert a wait (0.1 in case of shutter closure, 0.01 ms otherwise). If nowait, no wait is added between commands or shutters. If an array, each linear is evaluated depending on the value of wait_gcode. The wait time is a delay before the motion and after the laser switch (i.e. the order is shutter-wait-motion)

motion: can be "linear" or an array of 1,0,-1 indicating with 0 a LINEAR movement, with 1 and -1 a XY cirular movement in clockwise or counterclockwise direction

radius: radius for circular movement. It is not considered for linear motion, but conventionally it should set to 0.

angle [optional]: angle of the in line half waveplate, controlled conventionally by the fourth axis A of Aereotech system. It can be used to rotate the writing laser polarization or to change the laser power using a combination of half waveplate and polarizer
