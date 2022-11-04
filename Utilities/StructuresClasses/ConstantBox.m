classdef ConstantBox<BasicStructure
    %REAMARK: form V4 this class has struct_witdh instead of width property
    %for compatibility issues with homonimois functions in MATLAB 21a
    %idem with height
    properties
        struct_width 
        struct_height
        theta
        ishelix=0;
        iscarpet=0;
        pitch
        dw
        dh
    end
    methods
        function obj = ConstantBox(startX,startY,startZ,stopX,stopY,stopZ,vcut,struct_width,struct_height,theta,ishelix,varargin)
         %% Pre Initialization %%
         % Any code not using output argument (obj)
         if nargin == 0
            args={};
         elseif nargin == 6
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = stopX;
            args{5} = stopY;
            args{6} = stopZ;
            
         elseif nargin >6
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = stopX;
            args{5} = stopY;
            args{6} = stopZ;
            args{7}=vcut;
%          else
%              error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         obj = obj@BasicStructure(args{:});   
         obj.name='Constant box';
         
         if nargin<8
             obj.struct_width=1;
             obj.struct_height=1;
             obj.theta=0;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
             
         elseif nargin==8
             obj.struct_width=struct_width;
             obj.struct_height=struct_width;
             obj.theta=0;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
             
         elseif nargin==9
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=0;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
             
         elseif nargin==10
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
             
         elseif nargin==11
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.ishelix=ishelix; obj.iscarpet=not(ishelix);
             if obj.ishelix
                 obj.pitch=0.01;
             else
                obj.dw=0.01;
                obj.dh=0.1;
             end
             
         elseif nargin==12
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.ishelix=ishelix; obj.iscarpet=not(ishelix);
             if obj.ishelix
                 obj.pitch=varargin{1};
             else
                obj.dw=varargin{1};
                obj.dh=varargin{1};
             end
             
          elseif nargin==13
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.ishelix=ishelix; obj.iscarpet=not(ishelix);
             if obj.ishelix
                 obj.pitch=varargin{1};
                 fprintf('unused input arguments aftert 14th position\n');
                 varargin{2:end}
             else
                obj.dw=varargin{1};
                obj.dh=varargin{2};
             end
             
            elseif nargi>13
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;
             obj.ishelix=ishelix; obj.iscarpet=not(ishelix);
             if obj.ishelix
                 obj.pitch=varagin{1};
                 fprintf('unused input arguments aftert 14th position\n');
                 varargin{2:end}
             else
                obj.dw=varagin{1};
                obj.dh=varagin{2};
                fprintf('unused input arguments aftert 14th position\n');
                 varargin{3:end}
             end
         end
         
        end    
        function obj=S_plot(obj,ax,varargin) %surface plot of the object
            pin = [obj.startX; obj.startY; obj.startZ];
            pfin = [obj.stopX; obj.stopY; obj.stopZ];
            pdiff = pfin - pin;
            long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
            
            X=[obj.startX obj.stopX];
            Y=[obj.startY obj.stopY];
            Z=[obj.startZ obj.stopZ];
            struct_width=obj.struct_width;
            struct_height=obj.struct_height;
            theta=obj.theta;
            
            %original cube vertices creation along x axis
            Ytemp=[-struct_width/2 struct_width/2 struct_width/2 -struct_width/2;...
                struct_width/2 struct_width/2 -struct_width/2 -struct_width/2;...
                struct_width/2 struct_width/2 -struct_width/2 -struct_width/2;...
                -struct_width/2 struct_width/2 struct_width/2 -struct_width/2];
                
            Ztemp=[-struct_height/2 -struct_height/2 struct_height/2 struct_height/2;...
                -struct_height/2 struct_height/2 struct_height/2 -struct_height/2;...
                -struct_height/2 struct_height/2 struct_height/2 -struct_height/2;...
                -struct_height/2 -struct_height/2 struct_height/2 struct_height/2];
            
            Xtemp=[0 0 0 0;...
                0 0 0 0;...
                1 1 1 1;...
                1 1 1 1];
            
            long = sqrt((obj.stopX-obj.startX)^2+(obj.stopY-obj.startY)^2+(obj.stopZ-obj.startZ)^2);
            
            grp = hgtransform(ax);%definition of Parent transformation group
            
            T = makehgtform('translate',[obj.startX obj.startY obj.startZ]);%translation transformation
            
            S=makehgtform('scale',[long 1 1]); %dilatation along x

          
            %%z rotation
            if ((pdiff(1)==0)&&(pdiff(2)==0))
                alpha = 0;
            else
                alpha = atan2(pdiff(2),pdiff(1));
            end 
            
            Rz= makehgtform('zrotate',alpha);
            
           %%y rotation
           beta = atan2((pdiff(3)),sqrt((pdiff(1))^2+(pdiff(2))^2));
           Ry= makehgtform('yrotate',-beta);
           
           % x rotation
           Rx = makehgtform('xrotate',obj.theta/180*3.14);
            
            
            if nargin==1
                h=patch('XData',Xtemp,'YData',Ytemp,'ZData',Ztemp,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);
            elseif nargin==2
                h=patch(ax,'XData',Xtemp,'YData',Ytemp,'ZData',Ztemp,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);                 
            elseif nargin>2
                h=patch(ax,'XData',Xtemp,'YData',Ytemp,'ZData',Ztemp,'Parent',grp,varargin{:});

            end
            
                      
            h.ButtonDownFcn=@HightlightHitSurf;
            set(grp,'Matrix',T*Rz*Ry*Rx*S);
            obj.hGraph=h;
            h.UserData=obj.tag;
            
        end
        function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
            
            %GCODE for CARPET type box along x direction
           x1=[]; y1=[]; z1=[]; vel1=[]; shut1=[];
          
            pin = [obj.startX; obj.startY; obj.startZ];
             pfin = [obj.stopX; obj.stopY; obj.stopZ];
             pdiff = pfin - pin;
             long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
            
            if obj.iscarpet
                nw = floor(obj.struct_width/obj.dw); nh = floor(obj.struct_height/obj.dh);
                gapw = (obj.struct_width-nw*obj.dw)/2; gaph = (obj.struct_height-nh*obj.dh)/2;
                
                zbox = -obj.struct_height/2+gaph;              %floor
                for ybox = -obj.struct_width/2+gapw:obj.dw:obj.struct_width/2-gapw
                    x1 = [x1 0 long];
                    y1 = [y1 ybox ybox];
                    z1 = [z1 zbox zbox];
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1 = [shut1 0 1];
                end
                ybox = -obj.struct_width/2+gapw;              %first wall
                for zbox = -obj.struct_height/2+gaph+obj.dh:obj.dh:obj.struct_height/2-gaph-obj.dh
                    x1 = [x1 0 long];
                    y1 = [y1 ybox ybox];
                    z1 = [z1 zbox zbox];
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1 = [shut1 0 1];
                end
                ybox =obj.struct_width/2-gapw;               %second wall
                for zbox = -obj.struct_height/2+gaph+obj.dh:obj.dh:obj.struct_height/2-gaph-obj.dh
                    x1 = [x1 0 long];
                    y1 = [y1 ybox ybox];
                    z1 = [z1 zbox zbox];
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1 = [shut1 0 1];
                end
                zbox = obj.struct_height/2-gaph;               %roof
                for ybox = -obj.struct_width/2+gapw:obj.dw:obj.struct_width/2-gapw
                    x1 = [x1 0 long];
                    y1 = [y1 ybox ybox];
                    z1 = [z1 zbox zbox];
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1 = [shut1 0 1];
                end
                
            elseif obj.ishelix
                xbox = 0;
                while (xbox < long)
                    x1 = [x1 xbox];
                    y1 = [y1 obj.struct_width/2];
                    z1 = [z1 obj.struct_height/2];
                    xbox = xbox+obj.pitch/4;
                    x1 = [x1 xbox];
                    y1 = [y1 obj.struct_width/2];
                    z1 = [z1 -obj.struct_height/2];
                    xbox = xbox+obj.pitch/4;
                    x1 = [x1 xbox];
                    y1 = [y1 -obj.struct_width/2];
                    z1 = [z1 -obj.struct_height/2];
                    xbox = xbox+obj.pitch/4;
                    x1 = [x1 xbox];
                    y1 = [y1 -obj.struct_width/2];
                    z1 = [z1 obj.struct_height/2];
                    xbox = xbox+obj.pitch/4;
                end
                vel1 = obj.vcut*ones(size(x1));
                shut1 = ones(size(x1));
            else
                fprintf('Error: choose either CARPET or HELIX')
                x1=[obj.startX obj.stopX];
                y1=[obj.startY obj.stopY];
                z1=[obj.startZ obj.stopZ];
                v=[obj.vpos obj.vpos];
                shut1=[0 0];
            end
                     
                    
        
        %rotation around Z, Y and X
        xyz1 = [x1;y1;z1];
        if ((pdiff(1)==0)&&(pdiff(2)==0))
            alpha = 0;
        else
            alpha = atan2(pdiff(2),pdiff(1));
        end
        theta_rad=obj.theta/180*pi;
        
        beta = atan2((pdiff(3)),sqrt((pdiff(1))^2+(pdiff(2))^2));
        rotZ = [cos(alpha) -sin(alpha) 0; sin(alpha) cos(alpha) 0; 0 0 1];
        rotY = [cos(beta) 0 -sin(beta); 0 1 0; sin(beta) 0 cos(beta)];
        rotX = [1 0 0; 0 cos(theta_rad) -sin(theta_rad); 0 sin(theta_rad) cos(theta_rad)];
        rot = rotZ*rotY*rotX;
        xyz2 = rot*xyz1;
        
        %translation from origin to initial point
        X_GCODE = xyz2(1,:) + obj.startX;
        Y_GCODE = xyz2(2,:) + obj.startY;
        Z_GCODE = xyz2(3,:) + obj.startZ;

        %velocity and shutter and name
        v_GCODE = vel1;
        v_GCODE(1) = obj.vpos;

        Shutter_GCODE= shut1;
        Shutter_GCODE(1) = 0;
        
        %GCODE writing time computation
        obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE,obj);
        
    
        end
        
        function obj=GCODE_compile(obj,fileid,varargin)%compile and write in the file the GCODE
            fprintf("DEBUG: GCODE compile of CONSTANT BOX\n")
            %% overwriting of BasicStructure GCODE_compile method to include advanced options of GCODEs           
            if (obj.advanced_GCODE_mode==1)&&(obj.startX==obj.stopX)&&(obj.startY==obj.stopY)&&(obj.startZ~=obj.stopZ)&&(obj.ishelix==1)
                %if the structure is vertical and the advance GCODE mode is
                %ON
                fprintf("DEBUG: advanced GCODE compile mode\n")
                minArgs=2;
                maxArgs=3;
                narginchk(minArgs,maxArgs)
                
                if nargin<3
                    setup='Line1';
                else
                    setup=varargin{1};
                end
                
                
                %% preable containing the data (you can write them down as a header)
                obj=obj.header_compile(fileid);
                
                %REMARK: in case of advanced GCODE modality, the
                %BasicStructure.header_compile inset an iterator variable
                %% GCODE file writing
                %declaration of setup dependent code lines
                %setup
                
                switch setup
                    case 'Line1'
                        ShutterOn="PSOCONTROL X ON\n";
                        ShutterOff="PSOCONTROL X OFF\n";
                    case 'Capable'
                        ShutterOn="PSOCONTROL X ON\n";
                        ShutterOff="PSOCONTROL X OFF\n";
                    case 'Ant'
                        ShutterOn='PSOCONTROL Z ON\n';
                        ShutterOff='PSOCONTROL Z OFF\n';
                    otherwise
                        fprintf('Wrong Setup input. Choose between ''Line1'',''Ant'' or ''Capable''\n');
                        return
                end
                
                %%%%% GCODE cycle for vertical helix constant box
                %initial position
                fprintf(fileid, ShutterOff);
                fprintf(fileid, 'DWELL 0.1 \n');
                fprintf(fileid, 'LINEAR X%f Y%f Z%f F%f \n',obj.startX,obj.startY,obj.startZ/obj.n,obj.vpos);
                %position on the first corner
                fprintf(fileid, 'LINEAR X%f Y%f Z%f F%f \n',obj.startX+obj.struct_width/2,obj.startY+obj.struct_height,obj.startZ/obj.n,obj.vpos);
                fprintf(fileid, 'DWELL 0.1 \n');
                
                %check on maximum speed
                if ((obj.struct_width<0.1)||(obj.struct_height<0.1))&&(obj.vcut>0.5)
                    v_writing=0.5;
                else
                    v_writing=obj.vcut;
                end
                
                %check direction of the helix
                if obj.startZ>obj.stopZ
                    current_pitch=-obj.pitch;
                else
                    current_pitch=obj.pitch;
                end
                
                %GCODE for cycle declaration
                num_planes=ceil(abs(obj.startZ-obj.stopZ)/obj.pitch);
                fprintf(fileid, ShutterOn);
                fprintf(fileid, 'DWELL 0.01 \n');
                fprintf(fileid, 'FOR $interator_variable=1 TO %d+1 \n',num_planes);
                fprintf(fileid, 'LINEAR X%f Y%f F%f \n',obj.startX-obj.struct_width/2,obj.startY+obj.struct_height,v_writing);
                fprintf(fileid, 'LINEAR X%f Y%f F%f \n',obj.startX-obj.struct_width/2,obj.startY-obj.struct_height,v_writing);
                fprintf(fileid, 'LINEAR X%f Y%f F%f \n',obj.startX+obj.struct_width/2,obj.startY-obj.struct_height,v_writing);
                fprintf(fileid, 'LINEAR X%f Y%f F%f \n',obj.startX+obj.struct_width/2,obj.startY+obj.struct_height,v_writing);
                fprintf(fileid, 'LINEAR X%f Y%f Z(%f+(%f*$interator_variable)) F%f \n',obj.startX+obj.struct_width/2,obj.startY+obj.struct_height,obj.startZ/obj.n,current_pitch/obj.n,v_writing);
                fprintf(fileid, 'NEXT $interator_variable \n',num_planes);
                
                %final positioning
                fprintf(fileid, ShutterOff);
                fprintf(fileid, 'DWELL 0.1 \n');
                fprintf(fileid, 'LINEAR X%f Y%f Z%f F%f \n',obj.startX,obj.startY,obj.stopZ/obj.n,obj.vpos);               
                fprintf(fileid, ShutterOff); %securuty shutter off at the end of structure GCODE
                
            else
                %otherwise the standard method is used
                obj=GCODE_compile@BasicStructure(obj,fileid,varargin{:});
            end
        end
    end
end
