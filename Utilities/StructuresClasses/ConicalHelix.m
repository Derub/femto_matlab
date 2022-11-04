classdef ConicalHelix<CylindricalStructure
    properties
        
        diameter_in
        diameter_fin
    end
    methods
        function obj = ConicalHelix(startX,startY,startZ,stopX,stopY,stopZ,vcut,pitch,step,d_in,d_fin)
         %Constructor for ConicalHelix class object
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
         obj.name='Conical circular helix';
        if nargin==11
             obj.diameter_in=d_in;
             obj.diameter_fin=d_fin;
         else
             obj.diameter_in=0.1;
             obj.diameter_fin=0.1;
         end
         
         %Length computation
         %time computation
        end
    
        function obj=S_plot(obj,ax,varargin) %surface plot of the object
            X=[obj.startX obj.stopX];
            Y=[obj.startY obj.stopY];
            Z=[obj.startZ obj.stopZ];
            r=[obj.diameter_in/2 obj.diameter_fin/2];
            n=round((obj.diameter_in*pi)/obj.step);
            n=min(n,15);
            [Xtemp,Ytemp,Ztemp]=cylinder(r,n);
           
            
            long = sqrt((obj.stopX-obj.startX)^2+(obj.stopY-obj.startY)^2+(obj.stopZ-obj.startZ)^2);
            grp = hgtransform(ax);
            T = makehgtform('translate',[obj.startX obj.startY obj.startZ]);
            S=makehgtform('scale',[1 1 long]);
            
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
            
                %GCDOE for conical circular helix
                    Rcritical = 0.002;       %if R<Rcritical, velocity must be reduced
                    vredux = 0.5;        %if R<Rcritical, fraction of velocity reduction

                    Rin = (1/2)*obj.diameter_in;
                    Rfin = (1/2)*obj.diameter_fin;
                    x1 = []; R1 = []; vel1 =[];
                    xa = 0; Ra = Rin;
                    
                    pin = [obj.startX; obj.startY; obj.startZ];
                    pfin = [obj.stopX; obj.stopY; obj.stopZ];
                    pdiff = pfin - pin;
                    long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);

                    while (xa <= long)
                        xb = xa + obj.step/sqrt(1+(2*pi*Ra/obj.pitch)^2);
                        if (Rfin > Rin)
                            Rb = Rin + xb*abs(Rfin-Rin)/long;
                        else
                            Rb = Rfin + (long-xb)*abs(Rfin-Rin)/long;
                        end
                        if (Ra < Rcritical)
                            vel1 = [vel1 vredux*vcut];
                        else
                            vel1 = [vel1 obj.vcut];
                        end
                        x1 = [x1 xb]; R1 = [R1 Rb];
                        xa = xb; Ra = Rb;
                    end
                    y1 = R1.*sin(2*pi*x1/obj.pitch);
                    z1 = R1.*cos(2*pi*x1/obj.pitch);

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
        obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE,obj);
                   
           
        end
    end
end