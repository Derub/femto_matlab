% converter form GCODE_Vector to .obj file to import on Blender

name="test2";

filename=name+".obj";
fid = fopen( filename, 'wt' );
fprintf(fid,"o  laserpath \n")

%load the GCODE matrix as "GCODE"
fprintf("REMARK: the GCODE_vector has to be written as (X,Y,Z,Velocity,Shutter,...)\n")
who

%%
for i=1:size(GCODE,1)
    fprintf(fid,"v  %f %f %f \n",GCODE(i,1),GCODE(i,2),GCODE(i,3))
end

for i=1:size(GCODE,1)
    if (i<size(GCODE,1))&&(GCODE(i+1,5)==1)&&(GCODE(i,5)==0)       
          fprintf(fid,"\n l %d", i) 
    elseif GCODE(i,5)==1
          fprintf(fid," %d", i)          
    end
end

fclose(fid);