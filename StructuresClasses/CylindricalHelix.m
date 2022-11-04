classdef CylindricalHelix<CylindricalStructure
    properties       
        diameter
    end
    methods
        function obj = CylindricalHelix(startX,startY,startZ,stopX,stopY,stopZ,vcut,pitch,step,d)
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
            args{7}={};
         elseif nargin == 7
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = stopX;
            args{5} = stopY;
            args{6} = stopZ;
            args{7}=vcut;
         elseif nargin >9 
            
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = stopX;
            args{5} = stopY;
            args{6} = stopZ;
            args{7}=vcut;
            args{8}=pitch;
            args{9}=step;
%          else
%              error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         obj = obj@CylindricalStructure(args{:});   
         obj.name='Constant circular helix';
         if nargin==10
             obj.diameter=d;
        else
             obj.diameter=0.1;
         end
         
         %Length computation
         %time computation
        end
    
        function obj=S_plot(obj,ax,varargin) %surface plot of the object
            
            X=[obj.startX obj.stopX];
            Y=[obj.startY obj.stopY];
            Z=[obj.startZ obj.stopZ];
            r=[obj.diameter/2 obj.diameter/2];
            n=round((obj.diameter*pi)/obj.step);
            n=min(n,15);
            [Xtemp,Ytemp,Ztemp]=cylinder(r,n);
           
            
            long = sqrt((obj.stopX-obj.startX)^2+(obj.stopY-obj.startY)^2+(obj.stopZ-obj.startZ)^2);
            grp = hgtransform(ax);
            T = makehgtform('translate',[obj.startX obj.startY obj.startZ]);
           
             %%xy plane rotation
            if obj.startY==obj.stopY
                beta=sign(obj.stopX-obj.startX)*pi/2;
            else
                beta=-atan((obj.stopX-obj.startX)/((obj.stopY-obj.startY)));
            end
            Rz= makehgtform('zrotate',beta);
            
            %%yz plane rotation
            
           if obj.startZ==obj.stopZ
                alpha=-sign(obj.stopY-obj.startY)*(pi/2);
                if obj.startY==obj.stopY
                    alpha=pi/2;
                end
            else
                 alpha=(pi/2-sign(obj.stopZ-obj.startZ)*pi/2)-atan(((obj.stopY-obj.startY)/cos(beta))/(obj.stopZ-obj.startZ));
           end
           Rx = makehgtform('xrotate',alpha);
            
           
            
            %%dilatation along z
            S=makehgtform('scale',[1 1 long]);
            if nargin==1
                h=surf(Xtemp,Ytemp,Ztemp,'FaceColor','c','FaceAlpha',0.3,'EdgeColor','b','EdgeAlpha',0.5,'Parent',grp);
                
            elseif nargin==2
                h=surf(ax,Xtemp,Ytemp,Ztemp,'FaceColor','c','FaceAlpha',0.3,'EdgeColor','b','EdgeAlpha',0.5,'Parent',grp);   
               
            elseif nargin>2
                h=surf(ax,Xtemp,Ytemp,Ztemp,'Parent',grp,varargin{:});
                   
            end
            
                      
            h.ButtonDownFcn=@HightlightHitSurf;
            set(grp,'Matrix',T*Rz*Rx*S);
            obj.hGraph=h;
            h.UserData=obj.tag;
        end
        
               
        function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
            %GCODE vectors generation for helix along X-axis
            
                R = (1/2)*obj.diameter;
                
                pin = [obj.startX; obj.startY; obj.startZ];
                pfin = [obj.stopX; obj.stopY; obj.stopZ];
                pdiff = pfin - pin;
                long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
            
                dx = obj.step/sqrt(1+(pi*obj.diameter/obj.pitch)^2);

                x1 = [0:dx:long];
                y1 = obj.diameter/2*sin(2*pi*x1/obj.pitch);
                z1 = obj.diameter/2*cos(2*pi*x1/obj.pitch);

                %rotation around Z, Y and X
                xyz1 = [x1;y1;z1];
                if ((pdiff(1)==0)&&(pdiff(2)==0))
                    alpha = 0;
                else
                    alpha = atan2(pdiff(2),pdiff(1));
                end
                beta = atan2((pdiff(3)),sqrt((pdiff(1))^2+(pdiff(2))^2));
                rotZ = [cos(alpha) -sin(alpha) 0; sin(alpha) cos(alpha) 0; 0 0 1];
                rotY = [cos(beta) 0 -sin(beta); 0 1 0; sin(beta) 0 cos(beta)];
                rot = rotZ*rotY;
                xyz2 = rot*xyz1;

                %translation from origin to initial point
                X_GCODE = xyz2(1,:) + obj.startX;
                Y_GCODE = xyz2(2,:) + obj.startY;
                Z_GCODE = xyz2(3,:) + obj.startZ;

                %velocity and shutter and name
                v_GCODE = obj.vcut*ones(size(X_GCODE));
                v_GCODE(1) = obj.vpos;

                Shutter_GCODE= ones(size(X_GCODE));
                Shutter_GCODE(1) = 0;

                  
        %GCODE writing time computation
        obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Y_GCODE,v_GCODE,Shutter_GCODE,obj);           
              
                
                
            
        end
        
        function obj=GCODE_compile(obj,fileid,varargin)%compile and write in the file the GCODE
            %% code that take GCODE_write (proper for each subclass) and compile and write down the GCDOE file
            
            if (obj.advanced_GCODE_mode==1)&&(obj.startX==obj.stopX)&&(obj.startY==obj.stopY)&&(obj.startZ~=obj.stopZ)
                %if the structure is vertical and the advance GCODE mode is
                %ON
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
                
                %%%%% GCODE cycle for vertical helix cylinder
                %initial position
                fprintf(fileid, ShutterOff);
                fprintf(fileid, 'DWELL 0.1 \n');
                fprintf(fileid, 'LINEAR X%f Y%f Z%f F%f \n',obj.startX,obj.startY,obj.startZ/obj.n,obj.vpos);
                %position on the circle
                fprintf(fileid, 'LINEAR X%f Y%f Z%f F%f \n',obj.startX+obj.diameter/2,obj.startY,obj.startZ/obj.n,obj.vpos);
                fprintf(fileid, 'DWELL 0.1 \n');
                
                %check on maximum speed
                if (obj.diameter<0.1)&&(obj.vcut>0.5)
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
                fprintf(fileid, 'G3 P0 Q100 R%f F%f \n', obj.diameter/2, v_writing);
                fprintf(fileid, 'G3 P100 Q200 R%f F%f \n', obj.diameter/2, v_writing);
                fprintf(fileid, 'G3 P200 Q359 R%f F%f \n', obj.diameter/2, v_writing);
                fprintf(fileid, 'LINEAR X%f Y%f Z(%f+(%f*$interator_variable)) F%f \n',obj.startX+obj.diameter/2,obj.startY,obj.startZ/obj.n,current_pitch/obj.n,v_writing);
                fprintf(fileid, 'NEXT $interator_variable \n',num_planes);
                
                %final positioning
                fprintf(fileid, ShutterOff);
                fprintf(fileid, 'DWELL 0.1 \n');
                fprintf(fileid, 'LINEAR X%f Y%f Z%f F%f \n',obj.startX,obj.startY,obj.stopZ/obj.n,obj.vpos);               
                fprintf(fileid, ShutterOff); %securuty shutter off at the end of structure GCODE
                
            else
                %otherwise the standard method is used
                obj=GCODE_compile@CylindricalStructure(obj,fileid,varargin{:});
            end
        end
        
    end
end