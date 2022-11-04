function [CompiledFileName]=GCODE_Compile(file_name,n,mode,setup,varargin)
%Function to compile GCODE as a series of movement.
%Updates: V5 - introduciton of LINEAR A using an extender GCODE array with
%a nineth column. Remark: this optio is available only with a GCODE array
%passed as a single matrix
%
%New sintax that accept either separated arrays or a single GCODE matrix.
%SINTAX: 
%[CompiledFileName]=GCODE_Compile(name,n,mode,setup,x_GCODE,y_GCODE,z_GCODE,v_GCODE, shutter_GCODE,wait_GCODE,motion_GCODE,radius_GODE, *incipit*)
% or [CompiledFileName]=GCODE_Compile(name,n,mode,setup,GCODE_array, *incipit*)
%
% Updates: V3 - Introduced XY plane G2 G3 movements
%
%   x_GCODE,y_GCODE,z_GCODE: series of 3D coordinates of points array that
%   define the variuos points connected by LINEAR movements. 
%   REMARK:z_GCODE can be empty and the structure will be written only along xy
%   plane
%
%   v_GCODE: speed of the linear movement
%
%   shutter_GCODE: flag for the shutter. If 1, the linear point is reached
%   with open shutter, if 0 with closed shutter
%
%   wait_CODE: Wait is a pause before the movement. can be 'auto', 'nowait' or an array of positive values. in case of
%   auto,  for every command the
%   compiler insert a wait (0.1 in case of
%   shutter closure, 0.01 ms otherwise). If nowait, no wait is added between
%   commands or shutters. If an array, each linear is evaluated depending
%   on the value of wait_gcode. The wait time is a delay before the motion
%   and after the laser switch (i.e. the order tir shutter-wait-motion)
%
%   motion_GCODE: can be "linear" or an array of 1,0,-1 indicating with 0 a LINEAR movement, with 1
%   and -1 a XY cirular movement in clockwise or counterclockwise direction
%
%   radius_GCODE: radius for circular movement
%
%   n: refractive index of the media 
%
%   mode:'incremental' or 'absolute'
%
%   setup:'Line1', 'AntGalvo' , 'Bee' ,'Capable' or 'Ant'
%
%   incipit: (optional) inital comment for the description of the code
%

%%check number of arguments to the function


    minArgs=5;
    maxArgs=13;
    narginchk(minArgs,maxArgs)
    
%check if we are using separated array or a single matrix for GCODE array input
if size(varargin{1},2)>1 && size(varargin{1},2)<=8  %case of GCODE matrix passed as a whole
    x_GCODE=varargin{1}(:,1)';
    y_GCODE=varargin{1}(:,2)';
    z_GCODE=varargin{1}(:,3)';
    v_GCODE=varargin{1}(:,4)';
    shutter_GCODE=varargin{1}(:,5)';
    wait_GCODE=varargin{1}(:,6)';
    motion_GCODE=varargin{1}(:,7)';
    radius_GCODE=varargin{1}(:,8)';
    angle_GCODE=[];
    if nargin==5
        incipit=strcat('Generic GCODE for setup ',setup) 
    elseif nargin==6
        incipit=varargin{2}
    else
        incipit=varargin{2}
        fprintf("Unused arguments after the 6th one")
    end
elseif size(varargin{1},2)==9 %case of A axis movement
    x_GCODE=varargin{1}(:,1)';
    y_GCODE=varargin{1}(:,2)';
    z_GCODE=varargin{1}(:,3)';
    v_GCODE=varargin{1}(:,4)';
    shutter_GCODE=varargin{1}(:,5)';
    wait_GCODE=varargin{1}(:,6)';
    motion_GCODE=varargin{1}(:,7)';
    radius_GCODE=varargin{1}(:,8)';
    angle_GCODE=varargin{1}(:,9)';
    if nargin==5
        incipit=strcat('Generic GCODE for setup ',setup) 
    elseif nargin==6
        incipit=varargin{2}
    else
        incipit=varargin{2}
        fprintf("Unused arguments after the 6th one")
    end
        
elseif size(varargin{1},2)==1 %case of columns passed one by one
    if nargin<12
        fprintf("ERROR: wrong number of inputs. The function expects a series of row vectors containing the GCODE array componets or a single GCODE array matrix. Check sintax");
        return
    elseif nargin>=12
        x_GCODE=varargin{1};
        y_GCODE=varargin{2};
        z_GCODE=varargin{3};
        v_GCODE=varargin{4};
        shutter_GCODE=varargin{5};
        wait_GCODE=varargin{6};
        motion_GCODE=varargin{7};
        radius_GCODE=varargin{8};
        angle_GCODE=[];
        if nargin==12
            incipit=strcat('Generic GCODE for setup ',setup) 
        elseif nargin==13
            incipit=varargin{9}
        end
    end
end

%% check validity of the inputs

if (ischar(wait_GCODE)||isstring(wait_GCODE))
    if strcmp(wait_GCODE,"auto")
        wait_GCODE=-1*ones(size(x_GCODE));
    elseif strcmp(wait_GCODE,"nowait")
        wait_GCODE=zeros(size(x_GCODE));
    else
        fprintf("Wrong input as wait_GCODE parameter. Use 'auto' keyword or input an array of positive values")
        return
    end
end

if (ischar(motion_GCODE)||isstring(motion_GCODE))
    if strcmp(motion_GCODE,"linear")
        motion_GCODE=zeros(size(x_GCODE));
        radius_GCODE=zeros(size(x_GCODE));
    else
        fprintf("Wrong input as wait_GCODE parameter. Use 'linear' keyword or input an array")
        return
    end
end

if size(x_GCODE)~=size(y_GCODE)
    fprintf("ERROR: X array and Y array do not have the same size")
    return    
elseif size(x_GCODE)~=size(z_GCODE)
    if ~isempty(z_GCODE)        
        fprintf("ERROR: X array and Z array do not have the same size")
        return
    end
     
elseif size(x_GCODE)~=size(v_GCODE)
    fprintf("ERROR: X array and velocities array do not have the same size")
    return 
elseif size(x_GCODE)~=size(shutter_GCODE)
    fprintf("ERROR: X array and shutter array do not have the same size")
    return 
elseif size(x_GCODE)~=size(wait_GCODE)
    fprintf("ERROR: X array and wait array do not have the same size")
    return
elseif size(x_GCODE)~=size(motion_GCODE)
    fprintf("ERROR: X array and motion array do not have the same size")
    return    
elseif size(x_GCODE)~=size(radius_GCODE)
    fprintf("ERROR: X array and radius array do not have the same size")
    return    
elseif size(x_GCODE)~=size(angle_GCODE)
    if ~isempty(angle_GCODE)        
        fprintf("ERROR: X array and A array do not have the same size")
        return
    end
    
end

if ~isempty(angle_GCODE) 
    if find(motion_GCODE~=0)
        fprintf("ERROR: G2 or G3 used. Polarization follow not compatible with circular motion")
        return
    end
end

%% check of the extension of the name file
if not(strcmp(file_name(end-3:end),'.pgm'))
    file_name = strcat(file_name,'.pgm');
end

%% ask for overwriting
if exist(file_name,'file')
  promptMessage = sprintf('This file already exists:\n%s\nDo you want to overwrite it?', file_name);
  titleBarCaption = 'Overwrite?';
  buttonText = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
  
  if strcmpi(buttonText, 'No')
    % User does not want to overwrite. 
    % End the program
    fprintf('\n User chose not to overwrite. Please change file name\n');
    CompiledFileName=[];
    return
  end
end

%% file creation and header writing

fid = fopen(file_name, 'wt');

switch setup
    case 'Line1'
        
        fprintf(fid, '//SETUP LINE1\n');
        fprintf(fid, '//n= %f\n',n);
        fprintf(fid, 'ENABLE X Y Z\n');
        fprintf(fid, 'METRIC\n');
        fprintf(fid, 'SECONDS\n');
        fprintf(fid, 'WAIT MODE NOWAIT\n');
        fprintf(fid, 'VELOCITY ON\n');
        fprintf(fid, 'PSOCONTROL X RESET\n');
        fprintf(fid, 'PSOCONTROL X OFF\n');
        
        if strcmp(mode,'absolute')
            fprintf(fid, 'ABSOLUTE\n');
        elseif strcmp(mode,'incremental')
            fprintf(fid, 'INCREMENTAL\n');
        else
            fprintf('Wrong mode input. Choose between ''absolute'' and ''incremental''\n');
            return
        end
        
        fprintf(fid, '\n');
        fprintf(fid, '\n');
        
        
        fprintf('Header for Line1 succesfully printed\n');
        fclose(fid);
    case 'Ant'
        
         fprintf(fid, '//SETUP ANT\n');
         fprintf(fid, '//n= %f\n',n);
        fprintf(fid, 'ENABLE X Y Z\n');
        fprintf(fid, 'ABSOLUTE\n');
        fprintf(fid, 'METRIC\n');
        fprintf(fid, 'SECONDS\n');
        fprintf(fid, 'G359     ''NON aspetta tra una riga e l''altra \n');
        fprintf(fid, 'VELOCITY ON\n');
        
        if strcmp(mode,'absolute')
            fprintf(fid, 'ABSOLUTE\n');
        elseif strcmp(mode,'incremental')
            fprintf(fid, 'INCREMENTAL\n');
        else
            fprintf('Wrong mode input. Choose between ''absolute'' and ''incremental''\n');
            return
        end
        
        fprintf(fid, 'PSOCONTROL Z RESET\n');
        fprintf(fid, 'PSOOUTPUT Z CONTROL 0 1\n');
        fprintf(fid, 'PSOCONTROL Z OFF\n');
        fprintf(fid, '\n');
        fprintf(fid, '\n');
               
        fprintf('Header for Ant succesfully printed\n');
        
    case 'Capable'
        fprintf(fileid, '//SETUP CAPABLE\n');
        fprintf(fileid, 'ENABLE X Y Z\n');
        fprintf(fileid, 'ABSOLUTE\n');
        fprintf(fileid, 'METRIC\n');
        fprintf(fileid, 'SECONDS\n');
        fprintf(fileid, 'G359     ''NON aspetta tra una riga e l''altra \n');
        fprintf(fileid, 'VELOCITY ON\n');
        if strcmp(mode,'absolute')
            fprintf(fid, 'ABSOLUTE\n');
        elseif strcmp(mode,'incremental')
            fprintf(fid, 'INCREMENTAL\n');
        else
            fprintf('Wrong mode input. Choose between ''absolute'' and ''incremental''\n');
            return
        end
        fprintf(fileid, 'PSOCONTROL X RESET\n');
        fprintf(fileid, 'PSOOUTPUT X CONTROL 3 0\n');
        fprintf(fileid, 'PSOCONTROL X OFF\n');
        fprintf(fileid, '\n');
        fprintf(fid, '\n');
               
        fprintf('Header for Capable succesfully printed\n');    
    
    case 'AntGalvo'
        
         fprintf(fid, '//SETUP ANT and GALVO SHUTTER\n');
         fprintf(fid, '//n= %f\n',n);
        fprintf(fid, 'ENABLE X Y Z\n');
        fprintf(fid, 'ABSOLUTE\n');
        fprintf(fid, 'METRIC\n');
        fprintf(fid, 'SECONDS\n');
        fprintf(fid, 'G359     ''NON aspetta tra una riga e l''altra \n');
        fprintf(fid, 'VELOCITY ON\n');
        
        if strcmp(mode,'absolute')
            fprintf(fid, 'ABSOLUTE\n');
        elseif strcmp(mode,'incremental')
            fprintf(fid, 'INCREMENTAL\n');
        else
            fprintf('Wrong mode input. Choose between ''absolute'' and ''incremental''\n');
            return
        end
        
        fprintf(fid, 'PSOCONTROL Z RESET\n');
        fprintf(fid, 'PSOOUTPUT Z CONTROL 0 1\n');
        fprintf(fid, 'PSOCONTROL Z ON\n');
        fprintf(fid, '\n');
        fprintf(fid, '\n');
               
        fprintf('Header for Ant with Galvo Shutter succesfully printed\n');
        
   case 'Bee'
        
         fprintf(fid, '//SETUP BEE and GALVO SHUTTER\n');
         fprintf(fid, '//n= %f\n',n);
        fprintf(fid, 'ENABLE X Y Z\n');
        fprintf(fid, 'ABSOLUTE\n');
        fprintf(fid, 'METRIC\n');
        fprintf(fid, 'SECONDS\n');
        fprintf(fid, 'G359     ''NON aspetta tra una riga e l''altra \n');
        fprintf(fid, 'VELOCITY ON\n');
        
        if strcmp(mode,'absolute')
            fprintf(fid, 'ABSOLUTE\n');
        elseif strcmp(mode,'incremental')
            fprintf(fid, 'INCREMENTAL\n');
        else
            fprintf('Wrong mode input. Choose between ''absolute'' and ''incremental''\n');
            return
        end
        
        fprintf(fid, 'PSOCONTROL Z RESET\n');
        fprintf(fid, 'PSOOUTPUT Z CONTROL 1 1\n');
        fprintf(fid, 'PSOCONTROL Z ON\n');
        fprintf(fid, '\n');
        fprintf(fid, '\n');
               
        fprintf('Header for Bee with Galvo Shutter succesfully printed\n');
    otherwise
        fprintf('Wrong Setup input. Choose between ''Line1'', ''AntGalvo'', ''Bee'', ''Capable'' and ''Ant''\n');
        return
end

%% GCODE compiling

%declaration of setup dependent code lines
switch setup
    case 'Line1'
        ShutterOn='PSOCONTROL X ON\n';
        ShutterOff='PSOCONTROL X OFF\n';
    case 'Ant'
        ShutterOn='PSOCONTROL Z ON\n';
        ShutterOff='PSOCONTROL Z OFF\n';
    case 'AntGalvo'
        ShutterOn='PSOCONTROL Z OFF\n';
        ShutterOff='PSOCONTROL Z ON\n';
    case 'Capable'
        ShutterOn='PSOCONTROL X ON\n';
        ShutterOff='PSOCONTROL X OFF\n';
    otherwise
        fprintf('Wrong Setup input. Choose between ''Line1'',''AntGalvo'',''Capable'' and ''Ant''\n');
        return
end
    
%incipit at the program
    fid = fopen(file_name, 'at'); 
    fprintf(fid, '//');
    fprintf(fid, incipit);
    fprintf(fid, '\n');
    fclose(fid);

 %code writing cycle
 
    fid = fopen(file_name, 'at'); %opening the file
    
    %fprintf(fid, "MSGDISPLAY 1,"start #TS"");  %MSGDISPLAY 1,"start #TS"
    
    M=size(shutter_GCODE);

    for i=1:M(2)
        if shutter_GCODE(i)==0
            fprintf(fid, ShutterOff);
            if wait_GCODE(i)==-1
                fprintf(fid, 'DWELL 0.1 \n');
            elseif wait_GCODE(i)~=0
                fprintf(fid, 'DWELL %f \n',wait_GCODE(i));
                
            end
            
            if (motion_GCODE(i)==0)||(motion_GCODE(i)==1)||(motion_GCODE(i)==-1)
                
                switch motion_GCODE(i)
                    case 0
                        motion_script="LINEAR";
                    case -1
                        motion_script="G2";
                    case 1
                        motion_script="G3";
                end
                fprintf(fid, motion_script);
                fprintf(fid, ' X%f ',x_GCODE(i));
            
                if ((i>1)&&(y_GCODE(i)~=y_GCODE(i-1)))||(i==1)
                    fprintf(fid, 'Y%f ',y_GCODE(i));
                end

                if ~isempty(z_GCODE)
                    if (i>1)&&(z_GCODE(i)~=z_GCODE(i-1))||(i==1)
                        fprintf(fid, 'Z%f ',z_GCODE(i)/n);
                    end
                end
                
                if ~isempty(angle_GCODE)
                    if ((i>1)&&(angle_GCODE(i)~=angle_GCODE(i-1))||(i==1))&& ~isnan(angle_GCODE(i))
                        fprintf(fid, ' A%f ',angle_GCODE(i));
                    end
                end  
                
                if motion_GCODE(i)~=0
                    if radius_GCODE(i)==0
                        fprintf("ERROR: circular motion with 0 radius at line %d. 1mm used instead\n")
                        fprintf(fid, ' R1 ');
                    else
                        fprintf(fid, ' R%f ',radius_GCODE(i));
                    end
                end

                if (i>1)&&(v_GCODE(i)~=v_GCODE(i-1))||(i==1)
                    fprintf(fid, 'F%f',v_GCODE(i));
                end
            
                fprintf(fid, ' \n',v_GCODE(i));
            end
            if wait_GCODE(i)==-1
                fprintf(fid, 'DWELL 0.1 \n');
            end
        elseif shutter_GCODE(i)==1
            
            if (i==1)||(shutter_GCODE(i-1)==0)
                fprintf(fid, ShutterOn);
                if wait_GCODE(i)==-1
                    fprintf(fid, 'DWELL 0.1 \n');%if the shutter was close
                elseif wait_GCODE(i)~=0
                    fprintf(fid, 'DWELL %f \n',wait_GCODE(i));
                end
            else
                if wait_GCODE(i)==-1
                    fprintf(fid, 'DWELL 0.01 \n');%if it was already opened
               elseif wait_GCODE(i)~=0
                    fprintf(fid, 'DWELL %f \n',wait_GCODE(i));
                end
            end
            if (motion_GCODE(i)==0)||(motion_GCODE(i)==1)||(motion_GCODE(i)==-1)
                
                switch motion_GCODE(i)
                    case 0
                        motion_script="LINEAR";
                    case -1
                        motion_script="G2";
                    case 1
                        motion_script="G3";
                end
                fprintf(fid, motion_script);
                fprintf(fid, ' X%f ',x_GCODE(i));
                
                if (i>1)&&(y_GCODE(i)~=y_GCODE(i-1))||(i==1)
                    fprintf(fid, 'Y%f ',y_GCODE(i));
                end
                if ~isempty(z_GCODE)
                    if (i>1)&&(z_GCODE(i)~=z_GCODE(i-1))||(i==1)
                        fprintf(fid, ' Z%f ',z_GCODE(i)/n);
                    end
                end
                if ~isempty(angle_GCODE)
                    if ((i>1)&&(angle_GCODE(i)~=angle_GCODE(i-1))||(i==1))&& ~isnan(angle_GCODE(i))
                        fprintf(fid, ' A%f ',angle_GCODE(i));
                    end
                end                
                
                if motion_GCODE(i)~=0
                    if radius_GCODE(i)==0
                        fprintf("ERROR: circular motion with 0 radius at line %d. 1mm used instead\n")
                        fprintf(fid, ' R1 ');
                    else
                        fprintf(fid, ' R%f ',radius_GCODE(i));
                    end
                end
                
                if (i>1)&&(v_GCODE(i)~=v_GCODE(i-1))||(i==1)
                    fprintf(fid, 'F%f',v_GCODE(i));
                end
                fprintf(fid, ' \n',v_GCODE(i));
            end          
            
        end
    end
    fprintf(fid, ShutterOff); %security shutter of at the end of the program
    
    %MSGDISPLAY 1,"finish #TS"
    
    fclose(fid);
    
    fprintf(1,'GCODE succesfully written\n');
    CompiledFileName=file_name;
    
    end

