function h_surf=GCODE_array_3Dplot(GCODE_array)
fprintf("GCODE array accepted format [X Y Z speed shutter wait curvature radius]\n")
if size(GCODE_array,2)<5
    fprintf("GCODE array has less than 5 columns [X Y Z Vel Shutt]. Please check the input data\n")
    return
elseif size(GCODE_array,2)>6
    fprintf("Plot of arcs not implemented yet. All movement will be considered as LINEAR\n")
end
fig=figure;
col=[];
col=[GCODE_array(2:end,5); GCODE_array(1,5)];
col=-1*col;
col=1+col;
col_RGB=zeros(size(col,1),3);
Alpha=zeros(size(col,1),1);
col_RGB(col==1,3)=1;
col_RGB(col==0,1)=1;
Alpha(col==1)=1;
Alpha(col==0)=1;
h_surf=surf([GCODE_array(:,1) GCODE_array(:,1)],...
    [GCODE_array(:,2) GCODE_array(:,2)],...
    [GCODE_array(:,3) GCODE_array(:,3)],...
    [col col],...
    'AlphaData',[Alpha Alpha],...
    'facecol','no',...
    'edgecol','flat',...
    'edgealpha','flat',...
    'linew',1);

end