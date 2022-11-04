classdef ConstantEllipticalHelix<CylindricalStructure
    %ELLIPTICALHELIX Cylindrical Structure with two different radii,realized with helix irradiation pattern
    %
    %   Detailed explanation goes here
        %REAMARK: form V4 this class has struct_witdh instead of width property
    %for compatibility issues with homonimois functions in MATLAB 21a
    %idem with height
    
    properties
       struct_width
       struct_height
       theta
    end
    
    methods
        function obj = ConstantEllipticalHelix(startX,startY,startZ,stopX,stopY,stopZ,vcut,pitch,step,struct_width,struct_height,theta)
            %ELLIPTICALHELIX Construct an instance of this class
            %   Detailed explanation goes here
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
         obj.name='Constant elliptical helix';
         
         %once initailized the superclass, let's set the obj properties
         if nargin==10
             obj.struct_width=struct_width;
             obj.struct_height=struct_width;
             obj.theta=0;
             fprintf('Constant elliptical helix initialized with two identical radii');
         elseif nargin==11
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=0;
          elseif nargin==12
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.theta=theta;   
         else
             obj.struct_width=0.1;
             obj.struct_height=0.15;
             obj.theta=0;
          end
         
         %Length computation
         %time computation
        end
        
        function obj=S_plot(obj,ax,varargin) %surface plot of the object
             X=[obj.startX obj.stopX];
            Y=[obj.startY obj.stopY];
            Z=[obj.startZ obj.stopZ];
            r=[obj.struct_height/2 obj.struct_height/2]; %cylinder is firslty with same radii and then scaled
            n=round((obj.struct_height*pi)/obj.step);
            n=min(n,15);
            [Xtemp,Ytemp,Ztemp]=cylinder(r,n);
           
            pin = [obj.startX; obj.startY; obj.startZ];
            pfin = [obj.stopX; obj.stopY; obj.stopZ];
            pdiff = pfin - pin;
            
            long = sqrt((obj.stopX-obj.startX)^2+(obj.stopY-obj.startY)^2+(obj.stopZ-obj.startZ)^2);
            grp = hgtransform(ax);
            T = makehgtform('translate',[obj.startX obj.startY obj.startZ]);
           
             %%z rotation
            if ((pdiff(1)==0)&&(pdiff(2)==0))
                alpha = 0;
            else
                alpha = atan2(pdiff(2),pdiff(1));
            end 
            
            Rz= makehgtform('zrotate',alpha);
            
           %%y rotation
           beta = atan2((pdiff(3)),sqrt((pdiff(1))^2+(pdiff(2))^2));
           Ry= makehgtform('yrotate',-beta+pi/2); 
           
           % x rotation
           Rx = makehgtform('xrotate',obj.theta/180*3.14);
            
           
            
            %%dilatation along z
            Sz=makehgtform('scale',[1 1 long]);
            Sy=makehgtform('scale',[1 obj.struct_width/obj.struct_height 1]);
            
            if nargin==1
                h=surf(Xtemp,Ytemp,Ztemp,'FaceColor','c','FaceAlpha',0.3,'EdgeColor','b','EdgeAlpha',0.5,'Parent',grp);
                
            elseif nargin==2
                h=surf(ax,Xtemp,Ytemp,Ztemp,'FaceColor','c','FaceAlpha',0.3,'EdgeColor','b','EdgeAlpha',0.5,'Parent',grp);
                                 
            elseif nargin>2
                h=surf(ax,Xtemp,Ytemp,Ztemp,'Parent',grp,varargin{:});
                   
            end
            
                      
            h.ButtonDownFcn=@HightlightHitSurf;
            set(grp,'Matrix',T*Rz*Ry*Rx*Sy*Sz);
            obj.hGraph=h;
            h.UserData=obj.tag;
        end
        
               
        function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
            %GCODE vectors generation for helix along X-axis   
            
            x1=[]; y1=[]; z1=[]; vel1=[]; shut1=[];
          
            pin = [obj.startX; obj.startY; obj.startZ];
             pfin = [obj.stopX; obj.stopY; obj.stopZ];
             pdiff = pfin - pin;
             long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
             
          %helix along X-axis
            Ry = obj.struct_width/2;
            Rz = obj.struct_height/2;
            Rmean = (Ry+Rz)/2;
            dx = obj.step/sqrt(1+(2*pi*Rmean/obj.pitch)^2);
            x1 = [0:dx:long];
            y1 = Ry*sin(2*pi*x1/obj.pitch);
            z1 = Rz*cos(2*pi*x1/obj.pitch);
            
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

        Shutter_GCODE= ones(size(X_GCODE));
        Shutter_GCODE(1) = 0;
        
        %GCODE writing time computation
        obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE,obj);
        end
        
    end
end

