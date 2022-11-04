classdef BasicStructure<matlab.mixin.Heterogeneous&handle
    properties
        name='Generic Basic Structure'
        vpos=2%[mm/s] positioning speed when laser writing the structure
        vcut=1%[mm/s] laser on speed when laser writing the structure
        n=1.46 %fused silica refr index
        startX=0
        stopX=1
        startY=0
        stopY=1
        startZ=0
        stopZ=1
        Length double
        Writing_Time double
        hGraph  
        version = 'v.'
        selected  logical 
        long_wait_time=0.1;%[ms] standard long wait time during laser 
        short_wait_time=0.01;%[ms] standard short wait time during laser 
        tag
        GCODE_wait_mode="auto"
        advanced_GCODE_mode=0
    end
    methods
        function obj = BasicStructure(startX,startY,startZ,stopX,stopY,stopZ,vcut)%BasicStructure constructor
            
            if nargin == 0
                obj.startX=0;
                obj.startY=0;
                obj.startZ=0;
                obj.stopX=1;
                obj.stopY=1;
                obj.stopZ=1;
                obj.vcut=1;
                
             elseif nargin ==6
                obj.startX=startX;
                obj.startY=startY;
                obj.startZ=startZ;
                obj.stopX=stopX;
                obj.stopY=stopY;
                obj.stopZ=stopZ;
                obj.vcut=1;
                
             elseif nargin >6
                obj.startX=startX;
                obj.startY=startY;
                obj.startZ=startZ;
                obj.stopX=stopX;
                obj.stopY=stopY;
                obj.stopZ=stopZ;
                obj.vcut=vcut;
                
           else
             %error('Wrong number of input arguments')
            end
           obj.n=1.46;
           obj.hGraph = gobjects;
        end
        
        function obj=S_plot(obj,ax,varargin) %surface plot of the object
            X=[obj.startX obj.stopX];
            Y=[obj.startY obj.stopY];
            Z=[obj.startZ obj.stopZ];
            if nargin==1
                h=plot3(X,Y,Z,'b');
                                
            elseif nargin==2
                h=plot3(ax,X,Y,Z,'b');
                                 
            elseif nargin>2
                 h=plot3(ax,X,Y,Z,varargin{:});
                 
            end
            obj.hGraph=h;
            h.UserData=obj.tag;
        end
        
        function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)%generates matrix of GCODE points
            X_GCODE=[obj.startX obj.stopX obj.stopX];
            Y_GCODE=[obj.startY obj.stopY obj.stopY];
            Z_GCODE=[obj.startZ obj.stopZ obj.stopZ];
            v_GCODE=[obj.vpos obj.vcut obj.vpos];
            Shutter_GCODE=[0 1 0];
            
            obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE,obj);
        end
        
        function obj=header_compile(obj,fileid,varargin)%compile and write in the file the structure header
             
              %% preable containing the data (you can write them down as a header)
          fprintf(fileid, '//%s\n',obj.name);
          %initialization with common properties
          fprintf(fileid, '//vcut=%f startX=%f startY=%f startZ=%f stopX=%f stopY=%f stopZ=%f ',obj.vcut,obj.startX,obj.startY,obj.startZ,obj.stopX,obj.stopY,obj.stopZ);
          %write specific porperties of the calling object
          SpecificProperties=setdiff(properties(class(obj)),properties(BasicStructure));
          if ~isempty(SpecificProperties)
              for i=1:numel(SpecificProperties)
                  eval(sprintf('PropValue=obj.%s;',SpecificProperties{i}));
                  str=strcat(SpecificProperties{i},'=',num2str(PropValue)," ");
                  fprintf(fileid,str);
              end
          end
          fprintf(fileid,'\n');
              
        end
        
        function obj=GCODE_compile(obj,fileid,varargin)%compile and write in the file the GCODE
          %% code that take GCODE_write (proper for each subclass) and compile and
          %%write down the GCDOE file
          
          % depending on the obj.GCODE_wait_mode the GCODE includes or not
          % the DWELL before and after the shutter switch

          minArgs=2;
          maxArgs=3;
          narginchk(minArgs,maxArgs)
          
          if nargin<3
              setup='Line1';
          else
              setup=varargin{1};
          end
          
          [obj,x_GCODE,y_GCODE,z_GCODE,v_GCODE,shutter_GCODE]=obj.GCODE_write();
          
          % declaration of wait_GCODE array
          if strcmp(obj.GCODE_wait_mode,"auto")
              wait_GCODE=-1*ones(size(x_GCODE));
          elseif strcmp(obj.GCODE_wait_mode,"nowait")
              wait_GCODE=zeros(size(x_GCODE));
          end
          
          %% preable containing the data (you can write them down as a header)
          obj=obj.header_compile(fileid);          

        %% GCODE compiling

        %declaration of setup dependent code lines
        switch setup
            case 'Line1'
                ShutterOn='PSOCONTROL X ON\n';
                ShutterOff='PSOCONTROL X OFF\n';
            case 'Ant'
                ShutterOn='PSOCONTROL Z ON\n';
                ShutterOff='PSOCONTROL Z OFF\n';
            case 'Capable'
                ShutterOn='PSOCONTROL X ON\n';
                ShutterOff='PSOCONTROL X OFF\n';
            otherwise
                fprintf('Wrong Setup input. Choose between ''Line1'',''Capable'' and ''Ant''\n');
                return
        end

 %code writing cycle

    M=size(shutter_GCODE);

    for i=1:M(2)
        if shutter_GCODE(i)==0
            fprintf(fileid, ShutterOff);
            if wait_GCODE(i)==-1
                fprintf(fileid, 'DWELL 0.1 \n');
            end
            

            fprintf(fileid, 'LINEAR X%f ',x_GCODE(i));

            if ((i>1)&&(y_GCODE(i)~=y_GCODE(i-1)))||(i==1)
                fprintf(fileid, 'Y%f ',y_GCODE(i));
            end
            if ~isempty(z_GCODE)
                if (i>1)&&(z_GCODE(i)~=z_GCODE(i-1))||(i==1)
                    fprintf(fileid, 'Z%f ',z_GCODE(i)/obj.n);
                end
            end
            if (i>1)&&(v_GCODE(i)~=v_GCODE(i-1))||(i==1)
                fprintf(fileid, 'F%f',v_GCODE(i));
            end
            
            fprintf(fileid, ' \n',v_GCODE(i));

            if wait_GCODE(i)==-1
                fprintf(fileid, 'DWELL 0.1 \n');
            elseif wait_GCODE(i)~=0
                fprintf(fileid, 'DWELL %f \n',wait_GCODE(i));
            end
        elseif shutter_GCODE(i)==1
            
            if (i==1)||(shutter_GCODE(i-1)==0)
                fprintf(fileid, ShutterOn);
                if wait_GCODE(i)==-1
                    fprintf(fileid, 'DWELL 0.1 \n');%if the shutter was close
                elseif wait_GCODE(i)~=0
                    fprintf(fileid, 'DWELL %f \n',wait_GCODE(i));
                end
            else
                if wait_GCODE(i)==-1
                    fprintf(fileid, 'DWELL 0.01 \n');%if it was already opened
               elseif wait_GCODE(i)~=0
                    fprintf(fileid, 'DWELL %f \n',wait_GCODE(i));
                end
            end

            fprintf(fileid, 'LINEAR X%f ',x_GCODE(i));

            if (i>1)&&(y_GCODE(i)~=y_GCODE(i-1))||(i==1)
                fprintf(fileid, 'Y%f ',y_GCODE(i));
            end
            if ~isempty(z_GCODE)
                if (i>1)&&(z_GCODE(i)~=z_GCODE(i-1))||(i==1)
                    fprintf(fileid, ' Z%f ',z_GCODE(i)/obj.n);
                end
            end
            if (i>1)&&(v_GCODE(i)~=v_GCODE(i-1))||(i==1)
                fprintf(fileid, 'F%f',v_GCODE(i));
            end
            fprintf(fileid, ' \n',v_GCODE(i));

        end
    end
    fprintf(fileid, ShutterOff); %security shutter off at teh end of structure GCODE

        end
        
        function h=GCODE_plot(obj,ax,shopen,shclose,pmove,show_velocity,show_if,show_dir,phold)%GCODE plotter (needs GCODE_write)
            %options:
            %shopen: print in blue where shutter is open
            %shclose: print in red where the shutter is closed
            %pmove: plot stages movement
            %pwanted: show structure as written in the glass
            %show_velocity: color line depending on velocity
            %show_init_fin: ad markers at start and end of lines
            %phold: hold the previous plot
            %xy_view
            %xz_view
            %yz_view
            
            
            
            %%create GCODE of the object
            [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=obj.GCODE_write;
            
            dataObjs = get(ax, 'Children'); %handles to low-level graphics objects in axes           
            
            if show_if
                markers='o';
            else
                markers='none';
            end
            
            
            if shopen==1
                color='blue';
            end
            
            
            
            if show_velocity~=0
                %show_velocity could be either 0 or the max value of the
                %stage cut velocity af all structures plottet
                
                color=[obj.vcut/show_velocity obj.vcut/show_velocity 1-obj.vcut/show_velocity]; %normalize the structure velocity to the max velocity between all plotted structures
                
             
            end
            
            
            
            
            if isempty(dataObjs)   
                
                xlabel 'X [mm]'
                ylabel 'Y [mm]'
                zlabel 'Z [mm]'            
            else
                if phold==0
                    cla(ax);
                end
                hold on 
            end
            
            if pmove
                n=obj.n;
            else
                n=1;
            end
            
            %get handles to already existing lines
            hGraphObj=allchild(ax);
            if strcmp(class(hGraphObj),'matlab.graphics.chart.primitive.Line')
                hLines=hGraphObj;
            elseif strcmp(class(hGraphObj),'matlab.graphics.primitive.Group')
                hLines=hGraphObj.Children;
            else
                hLines=[];
            end
                
            
            %plot in blue the lines with shutter open
            h=hggroup(ax);
            if shopen||show_velocity
                if Shutter_GCODE(1)==1
                    if~isempty(hLines)
                        h_line=line(ax,[hLines(1).XData(end) X_GCODE(1)],[hLines(1).YData(end) Y_GCODE(1)],[hLines(1).ZData(end)/n Z_GCODE(1)/n],'Marker',markers,'Color',color,'Parent',h);
                    end
                end
                for ii=2:numel(Shutter_GCODE)
                    if Shutter_GCODE(ii)==1
                        if (Shutter_GCODE(ii-1)==0) %if the shutter was closed draw a new line
                            h_line=line(ax,[X_GCODE(ii-1) X_GCODE(ii)],[Y_GCODE(ii-1) Y_GCODE(ii)],[Z_GCODE(ii-1)/n Z_GCODE(ii)/n],'Marker',markers,'Color',color,'Parent',h);
                        elseif (Shutter_GCODE(ii-1)==1) %if the shutter was open, it add new points to the line
                            h_line.XData=[h_line.XData X_GCODE(ii)];
                            h_line.YData=[h_line.YData Y_GCODE(ii)];
                            h_line.ZData=[h_line.ZData Z_GCODE(ii)/n];
                        end
                    end
                end
            end
                        
            if show_dir
                index=find(Shutter_GCODE,1);
                plot3(X_GCODE(index-1),Y_GCODE(index-1),Z_GCODE(index-1),'*');
                
                index=find(Shutter_GCODE,1,'last');
                plot3(X_GCODE(index),Y_GCODE(index),Z_GCODE(index),'d');
                
                fprintf('* marker for starting point, diamond marker for final point\n')
            end
            
            if shclose||show_velocity
                %if shclose, movements diplayed in red
                %if show_velocity, movements hidden in white
                if shclose==1
                    color='red';
                else
                    color='white';
                end
                
                %first closed shutter movement from previous structure
                if Shutter_GCODE(1)==0
                    
                    if~isempty(hLines)
                        line(ax,[hLines(1).XData(end) X_GCODE(1)],[hLines(1).YData(end) Y_GCODE(1)],[hLines(1).ZData(end)/n Z_GCODE(1)/n],'Marker',markers,'Color',color,'Parent',h);
                    end
                end
                
                for i=1:numel(Shutter_GCODE)-1
                    if Shutter_GCODE(i+1)==0
                        line(ax,[X_GCODE(i) X_GCODE(i+1)],[Y_GCODE(i) Y_GCODE(i+1)],[Z_GCODE(i)/n Z_GCODE(i+1)/n],'Marker',markers,'Color',color,'Parent',h);                      
                    end
                end
            end
            hold off
            fprintf('GCODE of %s plotted\n',obj.name);
            

        end
        
        function hObj=ChangeSurfColor(obj,flag)
            %if flag is not used or >1, the color is switched
            %otherwise flag=0 means blues surface, flag=1 means yellow
            %surface
            
           
            if nargin<2
                flag=2; %the user whant to switch the color
            else
                if isa(obj.hGraph,'matlab.graphics.chart.primitive.Surface')||isa(obj.hGraph,'matlab.graphics.primitive.Patch')
                    for i=1:numel(obj.hGraph)
                        color=obj.hGraph.FaceColor;
                        if flag==0
                            obj.hGraph(i).FaceColor='cyan';
                            obj.hGraph(i).EdgeColor='blue';
                            hObj=[];

                        elseif flag==1
                            obj.hGraph(i).FaceColor='yellow';
                            obj.hGraph(i).EdgeColor='yellow';
                            hObj=findobj(obj);
                        else   
                            if (color==[1 1 0])
                                obj.hGraph(i).FaceColor='cyan';
                                obj.hGraph(i).EdgeColor='blue';
                                hObj=[];
                            elseif (color==[0 1 1])
                                obj.hGraph(i).FaceColor='yellow';
                                obj.hGraph(i).EdgeColor='yellow';
                                hObj=findobj(obj);
                            end
                        end
                    end
                elseif isa(obj.hGraph,'matlab.graphics.chart.primitive.Line')
                    color=obj.hGraph.Color;
                    if flag==0
                        obj.hGraph.Color=[0 0 1];
                            hObj=[];
                    elseif flag==1
                         obj.hGraph.Color=[1 1 0];
                            hObj=findobj(obj);
                    else   
                        if (color==[1 1 0])||(flag==0)
                            obj.hGraph.Color=[0 0 1];
                            hObj=[];
                        elseif (color==[0 0 1])||(flag==0)
                            obj.hGraph.Color=[1 1 0];
                            hObj=findobj(obj);
                        end
                    end
                elseif isa(obj.hGraph,'matlab.graphics.primitive.Group') 
                    
                    lines=obj.hGraph.Children;
                    color=lines.Color;
                    for i=1:size(lines,1)
                       
                        if flag==0
                            lines(i).Color=[0 0 1];
                                hObj=[];
                        elseif flag==1
                            
                             lines(i).Color=[1 1 0];
                                hObj=findobj(obj);
                        else   
                            if (color==[1 1 0])||(flag==0)
                                lines(i).Color=[0 0 1];
                                hObj=[];
                            elseif (color==[0 0 1])||(flag==0)
                                lines(i).Color=[1 1 0];
                                hObj=findobj(obj);
                            end
                        end 
                    end
                end
            end
       
        
        end
        
        function t=GCODE_duration(x_GCODE,y_GCODE,z_GCODE,v_GCODE,shutter_GCODE,obj)
            %this program compute the duration of a GCODE program taking as input the
            %Bellini's style vectors


            d_vector=(((x_GCODE(1:end-1)-x_GCODE(2:end)).^2)+((y_GCODE(1:end-1)-y_GCODE(2:end)).^2)+(((z_GCODE(1:end-1)-z_GCODE(2:end))/obj.n).^2)).^(1/2);

            t_vector=d_vector./v_GCODE(2:end);

            shutter_switch=shutter_GCODE(2:end)-shutter_GCODE(1:end-1);
            n_shutter_open=sum(shutter_switch==1);
            t_shutter=nnz(~shutter_GCODE)*2*obj.long_wait_time+n_shutter_open*obj.long_wait_time+(nnz(shutter_GCODE)-n_shutter_open)*obj.short_wait_time;
            %fprintf('Shutter Time= %f\n',t_shutter);
            t_write=sum(t_vector);
            t=t_write+t_shutter;
        end
    end
    methods(Sealed)
        function varargout = findobj(obj,varargin)
            [varargout{1:nargout}] = findobj@handle(obj,varargin{:});
        end
    end
end
