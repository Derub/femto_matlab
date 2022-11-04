classdef ConicalEllipticalHelix<CylindricalStructure
    %ELLIPTICALHELIX Conical Structure with two different radii,realized with helix irradiation pattern
    %
    %   Detailed explanation goes here
    
    properties
       win %initial witdh
       hin %initial height
       wfin %final witdh
       hfin %final height
       theta %rotation along symmetry axis
    end
    
    methods
        function obj = ConicalEllipticalHelix(startX,startY,startZ,stopX,stopY,stopZ,vcut,pitch,step,win,hin,wfin,hfin,theta,varargin)
            %CONICALELLIPTICALHELIX Construct an instance of this class
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
         obj.name='Conical elliptical helix';
         
         %once initailized the superclass, let's set the obj properties
         if nargin<10
             obj.win=0.1;
             obj.hin=0.1;
             obj.wfin=0.1;
             obj.hfin=0.1;
             obj.theta=0;
             fprintf('Constant elliptical helix initialized with two identical radii\n');
             
         elseif nargin==10
             obj.win=win;
             obj.hin=win;
             obj.wfin=win;
             obj.hfin=win;
             obj.theta=0;
             fprintf('Constant elliptical helix initialized with two identical radii\n');
             
         elseif nargin==11
             obj.win=win;
             obj.hin=hin;
             obj.wfin=win;
             obj.hfin=hin;
             obj.theta=0;
              
          elseif nargin==12
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hin;
             obj.theta=0;
             
         elseif nargin==13
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hfin;
             obj.theta=0;
             
         elseif nargin==14
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hfin;
             obj.theta=theta;
             
         elseif nargin>14
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hfin;
             obj.theta=theta;
             fprintf('unused input arguments aftert 14th position\n');
                 varargin{1:end}
             
         else
             obj.width=0.1;
             obj.height=0.15;
             obj.theta=0;
          end
         
         %Length computation
         %time computation
        end
        
        function obj=S_plot(obj,ax,varargin) %surface plot of the object
             X=[obj.startX obj.stopX];
            Y=[obj.startY obj.stopY];
            Z=[obj.startZ obj.stopZ];
            ang = linspace(0,2*pi,32);
            Ytemp = [obj.win/2*cos(ang); ...
                obj.wfin/2*cos(ang)];
            Xtemp = [obj.hin/2*sin(ang); ...
                obj.hfin/2*sin(ang)];
            Ztemp=[zeros(1,32); ones(1,32)];
            
            
            
            
           
            pin = [obj.startX; obj.startY; obj.startZ];
            pfin = [obj.stopX; obj.stopY; obj.stopZ];
            pdiff = pfin - pin;
            
            long = sqrt((obj.stopX-obj.startX)^2+(obj.stopY-obj.startY)^2+(obj.stopZ-obj.startZ)^2);
            grp = hgtransform(ax);
            T = makehgtform('translate',[obj.startX obj.startY obj.startZ]);
           
             %%x rotation
            if ((pdiff(1)==0)&&(pdiff(2)==0))
                alpha = 0;
            else
                alpha = atan2(pdiff(2),pdiff(1));
            end 
            
            Rx= makehgtform('xrotate',-alpha);
            
           %%y rotation
           beta = atan2((pdiff(3)),sqrt((pdiff(1))^2+(pdiff(2))^2));
           Ry= makehgtform('yrotate',-beta+pi/2); 
           
           % z rotation
           Rz = makehgtform('zrotate',obj.theta/180*3.14);
            
           
            
            %%dilatation along z
            Sz=makehgtform('scale',[1 1 long]);
            
            
            if nargin==1
                h=surf(Xtemp,Ytemp,Ztemp,'FaceColor','c','FaceAlpha',0.3,'EdgeColor','b','EdgeAlpha',0.5,'Parent',grp);
                
            elseif nargin==2
                h=surf(ax,Xtemp,Ytemp,Ztemp,'FaceColor','c','FaceAlpha',0.3,'EdgeColor','b','EdgeAlpha',0.5,'Parent',grp);
                                 
            elseif nargin>2
                h=surf(ax,Xtemp,Ytemp,Ztemp,'Parent',grp,varargin{:});
                   
            end
            
                      
            h.ButtonDownFcn=@HightlightHitSurf;
            set(grp,'Matrix',T*Ry*Rx*Rz*Sz);
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
           Rcritical = 0;  %if Rmean<Rcritical, velocity must be reduced
            vredux = 0.5;   %if Rmean<Rcritical, fraction of velocity reduction
    
            %%%%% structure %%%%%
            %conical helix along X-axis  
            Ryin = (1/2)*obj.win;
            Ryfin = (1/2)*obj.wfin;

            Rzin = (1/2)*obj.hin;
            Rzfin = (1/2)*obj.hfin;

            xa = 0; Ra = (Ryin+Rzin)/2;
            x1 = []; R1y = []; R1z = []; vel1 =[];
            while (xa <= long)
                xb = xa + obj.step/sqrt(1+(2*pi*Ra/obj.pitch)^2);
                if (Ryfin > Ryin)
                    Rby = Ryin + xb*abs(Ryfin-Ryin)/long;
                else
                    Rby = Ryfin + (long-xb)*abs(Ryfin-Ryin)/long;
                end
                if (Rzfin > Rzin)
                    Rbz = Rzin + xb*abs(Rzfin-Rzin)/long;
                else
                    Rbz = Rzfin + (long-xb)*abs(Rzfin-Rzin)/long;
                end
                if (Ra < Rcritical)
                    vel1 = [vel1 vredux*vcut];
                else
                    vel1 = [vel1 obj.vcut];
                end
                Rb = (Rby+Rbz)/2;
                x1 = [x1 xb]; R1y = [R1y Rby]; R1z = [R1z Rbz];
                xa = xb; Ra = Rb;
            end
            y1 = R1y.*sin(2*pi*x1/obj.pitch);
            z1 = R1z.*cos(2*pi*x1/obj.pitch);
            
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

