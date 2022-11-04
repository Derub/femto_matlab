classdef AblationBoxMultistep<BasicAblationStructure
        %REAMARK: form V4 this class has struct_witdh instead of width property
    %for compatibility issues with homonimois functions in MATLAB 21a
    %idem with height
    properties
        struct_width
        struct_height
        theta
        theta_walls
        incl_walls= [0 0 0 0];
        pitch = 0.001; %vertical step along z
        dw = 0.001; %horizontal step for box "bottom"
        r %junction radius
        N_boxes %number of vertical boxes piled up
       clockwise logical %flag to determine if the box is written clockwise or counterclockwise
        
    end
    methods
        function obj = AblationBoxMultistep(startX,startY,startZ,stopZ,vcut,struct_width,struct_height,theta,theta_walls,incl_walls,r,N_boxes,clockwise,varargin)
         %% Pre Initialization %%
         % Any code not using output argument (obj)
         if nargin == 0
            args={};
         elseif nargin == 4
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = [];
            args{5} = [];
            args{6} = stopZ;
            
         elseif nargin >4
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = [];
            args{5} = [];
            args{6} = stopZ;
            args{7}=vcut;
%          else
%              error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         
         obj = obj@BasicAblationStructure(args{:});   
         obj.name='Ablation box';
         
         if nargin<6
             obj.struct_width=0.05;
             obj.struct_height=0.05;
             obj.theta=0;
             obj.theta_walls=0;
             obj.incl_walls=[0 0 0 0];
             obj.r=0.01;
             obj.N_boxes=1;
             obj.clockwise=1;
           
             
         elseif nargin==6
             obj.struct_width=struct_width;
             obj.struct_height=struct_width;
             obj.theta=0;
             obj.theta_walls=0;
             obj.incl_walls=[0 0 0 0];
             obj.r=0.01;
             obj.N_boxes=1;
             obj.clockwise=1;
             
         elseif nargin==7
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=0;
             obj.theta_walls=0;
             obj.incl_walls=[0 0 0 0];
             obj.r=0.01;
             obj.N_boxes=1;
             obj.clockwise=1;
             
         elseif nargin==8
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.theta_walls=0;
             obj.incl_walls=[0 0 0 0];
             obj.r=0.01;
             obj.N_boxes=1;
             
         elseif nargin==9
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.theta_walls=theta_walls;
             obj.incl_walls=[0 0 0 0];
             obj.r=0.01;
             obj.N_boxes=1;
             obj.clockwise=1;
             
         elseif nargin==10
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.theta_walls=theta_walls;
             if size(incl_walls)==[1 4]
                obj.incl_walls=incl_walls;
             else
                 obj.incl_walls=[0 0 0 0];
                 fprintf('Wrong number of input for incl_walls parameter. use a 1x4 logic array\n');
             end
             obj.r=0.01;
             obj.N_boxes=1;
             obj.clockwise=1;
             
          elseif nargin==11
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.theta_walls=theta_walls;
             if size(incl_walls)==[1 4]
                obj.incl_walls=incl_walls;
             else
                 obj.incl_walls=[0 0 0 0];
                 fprintf('Wrong number of input for incl_walls parameter. use a 1x4 logic array\n');
             end
             obj.r=r;
             obj.N_boxes=1;
             obj.clockwise=1;
             
             elseif nargin==12
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.theta_walls=theta_walls;
             if size(incl_walls)==[1 4]
                obj.incl_walls=incl_walls;
             else
                 obj.incl_walls=[0 0 0 0];
                 fprintf('Wrong number of input for incl_walls parameter. use a 1x4 logic array\n');
             end
             obj.r=r;
             if N_boxes<1
                 obj.N_boxes=1;
             else
                 obj.N_boxes=N_boxes;
             end
             obj.clockwise=1;
             
             elseif nargin==13
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.theta_walls=theta_walls;
             if size(incl_walls)==[1 4]
                obj.incl_walls=incl_walls;
             else
                 obj.incl_walls=[0 0 0 0];
                 fprintf('Wrong number of input for incl_walls parameter. use a 1x4 logic array\n');
             end
             obj.r=r;
             if N_boxes<1
                 obj.N_boxes=1;
             else
                 obj.N_boxes=N_boxes;
             end
             obj.clockwise=clockwise;
             
             
            elseif nargi>13
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.theta_walls=theta_walls;
             if size(incl_walls)==[1 4]
                obj.incl_walls=incl_walls;
             else
                 obj.incl_walls=[0 0 0 0];
                 fprintf('Wrong number of input for incl_walls parameter. use a 1x4 logic array\n');
             end
             obj.r=r;
             if N_boxes<1
                 obj.N_boxes=1;
             else
                 obj.N_boxes=N_boxes;
             end
            fprintf('unused input arguments aftert 13th position\n');
            varargin{3:end}
             
         end
        end
                
        function obj=S_plot(obj,ax,varargin) %surface plot of the object
              
            hGraph=gobjects(obj.N_boxes,1);
            
            for i=1:obj.N_boxes
                
                if nargin==1
                    
                   
                    hGraph(i)=obj.S_plot_single_box(obj.startX+obj.incl_walls(1)*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.startY+obj.incl_walls(2)*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.startZ+((i-1)*(obj.stopZ-obj.startZ)/obj.N_boxes),...
                        obj.startZ+((i)*(obj.stopZ-obj.startZ)/obj.N_boxes),...
                        obj.struct_width-(obj.incl_walls(1)+obj.incl_walls(3))*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.struct_height-(obj.incl_walls(2)+obj.incl_walls(4))*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.theta,obj.theta_walls,obj.incl_walls(:));
                    
                elseif nargin==2
                   hGraph(i)=obj.S_plot_single_box(obj.startX+obj.incl_walls(1)*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.startY+obj.incl_walls(2)*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.startZ+((i-1)*(obj.stopZ-obj.startZ)/obj.N_boxes),...
                        obj.startZ+((i)*(obj.stopZ-obj.startZ)/obj.N_boxes),...
                        obj.struct_width-(obj.incl_walls(1)+obj.incl_walls(3))*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.struct_height-(obj.incl_walls(2)+obj.incl_walls(4))*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.theta,obj.theta_walls,obj.incl_walls(:),ax);                
                elseif nargin>2
                    hGraph(i)=obj.S_plot_single_box(obj.startX+obj.incl_walls(1)*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.startY+obj.incl_walls(2)*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.startZ+((i-1)*(obj.stopZ-obj.startZ)/obj.N_boxes),...
                        obj.startZ+((i)*(obj.stopZ-obj.startZ)/obj.N_boxes),...
                        obj.struct_width-(obj.incl_walls(1)+obj.incl_walls(3))*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.struct_height-(obj.incl_walls(2)+obj.incl_walls(4))*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                        obj.theta,obj.theta_walls,obj.incl_walls(:),ax,varargin);
                end            
            
            end
            
            %store of header of parent group in obj.hGraph
            
            obj.hGraph=hGraph;
        end
            
            
        
        
        function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
            
            %creation empty arrays
            X_GCODE=[]; 
               Y_GCODE=[];
               Z_GCODE=[];
               v_GCODE=[];
               Shutter_GCODE=[];
               
            %cycle to write each box and combine a single set of arrays
            for i=1:obj.N_boxes
  
                [obj,X_GCODE_temp,Y_GCODE_temp,Z_GCODE_temp,v_GCODE_temp,Shutter_GCODE_temp]=GCODE_write_single_box(obj,obj.startX+obj.incl_walls(1)*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                    obj.startY+obj.incl_walls(2)*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                    obj.startZ+((i-1)*(obj.stopZ-obj.startZ)/obj.N_boxes),...
                    obj.startZ+((i)*(obj.stopZ-obj.startZ)/obj.N_boxes),...
                    obj.struct_width-(obj.incl_walls(1)+obj.incl_walls(3))*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi),...
                    obj.struct_height-(obj.incl_walls(2)+obj.incl_walls(4))*(i-1)*obj.struct_width/obj.N_boxes*tan(obj.theta_walls/180*pi));
                
               X_GCODE=[X_GCODE X_GCODE_temp]; 
               Y_GCODE=[Y_GCODE Y_GCODE_temp];
               Z_GCODE=[Z_GCODE Z_GCODE_temp];
               v_GCODE=[v_GCODE v_GCODE_temp];
               Shutter_GCODE=[Shutter_GCODE Shutter_GCODE_temp];
            end 
            
            
            %GCODE writing time computation
            obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE,obj);
        end
        
        function hGraph=S_plot_single_box(obj,startX,startY,startZ,stopZ,struct_width,struct_height,theta,theta_walls,incl_walls,ax,varargin) %surface plot of the object
            
            long=stopZ-startZ;
            
            Xtemp=[0 0 incl_walls(1)*tan(theta_walls*pi/180)*long incl_walls(1)*tan(theta_walls*pi/180)*long; ...
                0 struct_width struct_width-incl_walls(3)*tan(theta_walls*pi/180)*long 0+incl_walls(1)*tan(theta_walls*pi/180)*long;...
                struct_width struct_width struct_width-incl_walls(3)*tan(theta_walls*pi/180)*long struct_width-incl_walls(3)*tan(theta_walls*pi/180)*long;...
                0 struct_width struct_width-incl_walls(3)*tan(theta_walls*pi/180)*long 0+incl_walls(1)*tan(theta_walls*pi/180)*long;...
                0+incl_walls(1)*tan(theta_walls*pi/180)*long 0+incl_walls(1)*tan(theta_walls*pi/180)*long struct_width-incl_walls(3)*tan(theta_walls*pi/180)*long struct_width-incl_walls(3)*tan(theta_walls*pi/180)*long];
            Ytemp=[0 struct_height struct_height-incl_walls(4)*tan(theta_walls*pi/180)*long incl_walls(2)*tan(theta_walls*pi/180)*long;...
                struct_height struct_height struct_height-incl_walls(4)*tan(theta_walls*pi/180)*long struct_height-incl_walls(4)*tan(theta_walls*pi/180)*long;...
                0 struct_height struct_height-incl_walls(4)*tan(theta_walls*pi/180)*long incl_walls(2)*tan(theta_walls*pi/180)*long;...
                0 0 incl_walls(2)*tan(theta_walls*pi/180)*long  incl_walls(2)*tan(theta_walls*pi/180)*long;
                incl_walls(2)*tan(theta_walls*pi/180)*long struct_height-incl_walls(4)*tan(theta_walls*pi/180)*long struct_height-incl_walls(4)*tan(theta_walls*pi/180)*long incl_walls(2)*tan(theta_walls*pi/180)*long];
            Ztemp=[0 0 1 1;...
                0 0 1 1;...
                0 0 1 1;...
                0 0 1 1;...
                1 1 1 1];
            
            grp = hgtransform;%definition of Parent transformation group
            
            S=makehgtform('scale',[1 1 long]); %dilatation along z
            
            switch obj.clockwise
                case 0
                    lineStyle=':';
                otherwise
                    lineStyle='-';
            end
            
            if nargin==10
                hGraph=patch('XData',Xtemp','YData',Ytemp','ZData',Ztemp','FaceColor','red','FaceAlpha',0.3,'EdgeColor','red','EdgeAlpha',0.7,'LineStyle',lineStyle,'Parent',grp);
            elseif nargin==11
                hGraph=patch(ax,'XData',Xtemp','YData',Ytemp','ZData',Ztemp','FaceColor','red','FaceAlpha',0.3,'EdgeColor','red','EdgeAlpha',0.7,'LineStyle',lineStyle,'Parent',grp);                 
            elseif nargin>11
                hGraph=patch(ax,'XData',Xtemp','YData',Ytemp','ZData',Ztemp','Parent',grp);

            end
            % z rotation
           Rz = makehgtform('zrotate',obj.theta/180*3.14);
            T = makehgtform('translate',[startX startY startZ]);%translation transformation
            set(grp,'Matrix',T*Rz*S);
            
            
        end 
        
       function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write_single_box(obj,startX,startY,startZ,stopZ,struct_width,struct_height)
           delta_l = obj.pitch*tan(obj.theta_walls/180*pi); 
            xi = startX;             %x initial      
            yi = startY;             %y initial
            xf = xi+struct_width;          %x final
            yf = yi+struct_height;          %y final
            x1 = xi+obj.r;           %smoothing curvature centers
            x2 = xf-obj.r;           %smoothing curvature centers
            y1 = yi+obj.r;           %smoothing curvature centers
            y2 = yf-obj.r;           %smoothing curvature centers
            z  = startZ;             %current value of z
            lz=stopZ-startZ;
            
            incl_x1=obj.incl_walls(1);
            incl_y1=obj.incl_walls(2);
            incl_x2=obj.incl_walls(3);
            incl_y2=obj.incl_walls(4);
            
            direction=2*obj.clockwise-1 %transform teh flag in a 1 or -1 multiplier
            
            points = [xi,yi,z];  %first point
            for ii=1:floor(lz/obj.pitch)
                if incl_x1                  
                    xi = xi + delta_l;
                    x1 = xi + obj.r;
                end
                if incl_x2
                    xf = xf - delta_l;
                    x2 = xf - obj.r;
                end
                if incl_y1
                    yi = yi + delta_l;
                    y1 = yi + obj.r;
                end
                if incl_y2
                    yf = yf - delta_l;
                    y2 = yf - obj.r;
                end
                
                
                    points = [points; x1,yi,z];
                    z = z + obj.pitch;
                    points = [points; x2,yi,z];
                    for jj=1:19
                        x = x2+jj*obj.r/20;
                        y = (2*y1-sqrt(4*y1^2 -4*(x^2-2*x*x2+x2^2+y1^2-obj.r^2)))/2;
                        points = [points; x,y,z];
                    end
                    points = [points; xf,y1,z];
                    points = [points; xf,y2,z];
                    for jj=1:19
                        x = xf-jj*obj.r/20;
                        y = (2*y2+sqrt(4*y2^2 -4*(x^2-2*x*x2+x2^2+y2^2-obj.r^2)))/2;
                        points = [points; x,y,z];
                    end
                    points = [points; x2,yf,z];
                    points = [points; x1,yf,z];
                    for jj=1:19
                        x = x1-jj*obj.r/20;
                        y = (2*y2+sqrt(4*y2^2 -4*(x^2-2*x*x1+x1^2+y2^2-obj.r^2)))/2;
                        points = [points; x,y,z];
                    end
                    points = [points; xi,y2,z];
                    points = [points; xi,y1,z];
                    for jj=1:19
                        x = xi+jj*obj.r/20;
                        y = (2*y1-sqrt(4*y1^2 -4*(x^2-2*x*x1+x1^2+y1^2-obj.r^2)))/2;
                        points = [points; x,y,z];
                    end
              
                
            end
             if obj.clockwise
                   
                   points(:,1)=flip(points(:,1));
                   points(:,2)=flip(points(:,2));
                   
                   points(:,3)=[points(4:end,3); points(end,3); points(end,3); points(end,3)]
                   
               end
        %Bottom
        points_b=[];
            for ii=1:floor((min(abs(x1-x2),abs(y1-y2)))/obj.dw)/2
                points_b = [points_b; x1,yi,z];
                xi = xi + obj.dw;
                x1 = xi + obj.r;
                xf = xf - obj.dw;
                x2 = xf - obj.r;
                yi = yi + obj.dw;
                y1 = yi + obj.r;
                yf = yf - obj.dw;
                y2 = yf - obj.r;
                points_b = [points_b; x2,yi,z];
                for jj=1:19
                    x = x2+jj*obj.r/20;
                    y = (2*y1-sqrt(4*y1^2 -4*(x^2-2*x*x2+x2^2+y1^2-obj.r^2)))/2;
                    points_b = [points_b; x,y,z];
                end
                points_b = [points_b; xf,y1,z];
                points_b = [points_b; xf,y2,z];
                for jj=1:19
                    x = xf-jj*obj.r/20;
                    y = (2*y2+sqrt(4*y2^2 -4*(x^2-2*x*x2+x2^2+y2^2-obj.r^2)))/2;
                    points_b = [points_b; x,y,z];
                end
                points_b = [points_b; x2,yf,z];
                points_b = [points_b; x1,yf,z];
                for jj=1:19
                    x = x1-jj*obj.r/20;
                    y = (2*y2+sqrt(4*y2^2 -4*(x^2-2*x*x1+x1^2+y2^2-obj.r^2)))/2;
                    points_b = [points_b; x,y,z];
                end
                points_b = [points_b; xi,y2,z];
                points_b = [points_b; xi,y1,z];
                for jj=1:19
                    x = xi+jj*obj.r/20;
                    y = (2*y1-sqrt(4*y1^2 -4*(x^2-2*x*x1+x1^2+y1^2-obj.r^2)))/2;
                    points_b = [points_b; x,y,z];
                end
            end
             
            points=[points; points_b];
        
        %Internal bottom
            if abs(x1-x2)>= abs(y1-y2)
                points = [points; x1,yi,z];
                for ii=0:ceil(2*obj.r/obj.dw)
                    points = [points; x2+obj.r,yi,z];
                    yi = yi + obj.dw;
                    points = [points; x1-obj.r,yi,z];
                end
                points = [points; x2+obj.r,yi,z];
            end
            if abs(x1-x2)<abs(y1-y2)
                points = [points; xi,y2+obj.r,z];
                points = [points; xi,y1-obj.r,z];
                for ii=0:ceil(2*obj.r/obj.dw)
                    points = [points; xi,y1-obj.r,z];
                    xi = xi+obj.dw;
                    points = [points; xi,y2+obj.r,z];
                end
                points = [points; xi,y1-obj.r,z];
            end
            
            
            
            
        X_GCODE=points(:,1)';
        Y_GCODE=points(:,2)';
        Z_GCODE=points(:,3)';
        v_GCODE=ones(size(X_GCODE))*obj.vcut;
        v_GCODE(1)=obj.vpos;
        Shutter_GCODE=ones(size(X_GCODE));
        Shutter_GCODE(1)=0; Shutter_GCODE(end)=0;
            
            
            
        end
    end
    

    end


