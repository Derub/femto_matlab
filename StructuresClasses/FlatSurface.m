classdef FlatSurface<BasicStructure
    properties
       win
       wfin
       shift
       theta
       dw
       isfast
       isprecise
    end
    methods
    function obj = FlatSurface(startX,startY,startZ,stopX,stopY,stopZ,vcut,win,wfin,shift,theta,dw,isfast)
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
         elseif nargin > 6
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = stopX;
            args{5} = stopY;
            args{6} = stopZ;
            args{7}=vcut;
             else
                %error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         obj = obj@BasicStructure(args{:});
         obj.name='Flat surface';
         
         if nargin<8
             obj.win=0.1;
             obj.wfin=obj.win;
             obj.shift=0;
             obj.theta=0;
             obj.dw=0.01;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif nargin==8
             obj.win=win;
             obj.wfin=obj.win;
             obj.shift=0;
             obj.theta=0;
             obj.dw=0.01;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif (nargin<=9)&&(nargin<12)
             obj.win=win;
             obj.wfin=wfin;
             obj.shift=0;
             obj.theta=0;
             obj.dw=0.01;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif nargin==12
             obj.win=win;
             obj.wfin=wfin;
             obj.shift=shift;
             obj.theta=theta;
             obj.dw=dw;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif nargin==13
             obj.win=win;
             obj.wfin=wfin;
             obj.shift=shift;
             obj.theta=theta;
             obj.dw=dw;
             obj.isfast=isfast;
             obj.isprecise=not(obj.isfast);
         elseif nargin>13
             obj.win=win;
             obj.wfin=wfin;
             obj.shift=shift;
             obj.theta=theta;
             obj.dw=dw;
             obj.isfast=isfast;
             obj.isprecise=not(obj.isfast);
             fprintf('unused input arguments after 11th position');
             args{12:end}
         end
             
         %% Post Initialization %%
         % Any code, including access to object
        
                
         
    end
     function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
        %%Code to compile GCODE vectors for either "precise" or "fast" Flat surface    
         
        dwin = obj.dw; %dw for initial width
        dwfin = obj.dw*obj.wfin/obj.win; %dw for final width
        
        x1=[]; y1=[]; z1=[];
        pin = [obj.startX; obj.startY; obj.startZ];
        pfin = [obj.stopX; obj.stopY; obj.stopZ];
        pdiff = pfin - pin;
        long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
        
        if (obj.isfast==1)
            %fast
            xa=0; ya=-obj.win/2; za=0;ii=1;
            while ya<obj.win/2-dwin
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
                xa = long; ya = 2*(ii-1)*dwfin-obj.wfin/2-obj.shift;
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
                ya = (2*ii-1)*dwfin-obj.wfin/2-obj.shift;
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
                xa = 0; ya = (2*ii-1)*dwin-obj.win/2;
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
                ya = 2*ii*dwin-obj.win/2;
                ii=ii+1;
            end
            if obj.win/2-ya<=0.001 %avoid overwriting
                ya = obj.win/2;
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
                xa = long; ya = obj.wfin/2-obj.shift;
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
            else
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
                xa = long; ya = 2*(ii-1)*dwfin-obj.wfin/2-obj.shift;
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
                ya = obj.wfin/2-obj.shift;
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
                xa = 0; ya = obj.win/2;
                x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za];
            end

            shut1 = ones(size(x1));
            vel1 = obj.vcut*ones(size(x1));
            
        elseif (obj.isfast==0)
            %precise
            x1 = [0];
            y1 = [-obj.win/2];
            z1 = [0];
            vel1 = [obj.vpos];
            shut1 = [0];
            ii=1;
            while (y1(2*ii-1)<obj.win/2-dwin)
                x1 = [x1 long 0];
                y1 = [y1 (ii-1)*dwfin-obj.wfin/2-obj.shift ii*dwin-obj.win/2];
                z1 = [z1 0 0];
                vel1 = [vel1 obj.vcut obj.vpos];
                shut1 = [shut1 1 0];
                ii=ii+1;
            end
            x1 = [x1 long 0 long];
            y1 = [y1 (ii-1)*dwfin-obj.wfin/2-obj.shift obj.win/2 obj.wfin/2-obj.shift];
            z1 = [z1 0 0 0];
            vel1 = [vel1 obj.vcut obj.vpos obj.vcut];
            shut1 = [shut1 1 0 1];
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
        
        %close shutter
        X_GCODE=[X_GCODE X_GCODE(end)];
        Y_GCODE=[Y_GCODE Y_GCODE(end)];
        Z_GCODE=[Z_GCODE Z_GCODE(end)];
        v_GCODE=[v_GCODE obj.vpos];
        Shutter_GCODE=[Shutter_GCODE 0];
        
        
        %GCODE writing time computation
        obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE,obj);
        
     end
        
     function obj=S_plot(obj,ax,varargin) %surface plot of the object
         X=[obj.startX obj.stopX];
         Y=[obj.startY obj.stopY];
         Z=[obj.startZ obj.stopZ];
         
         pin = [obj.startX; obj.startY; obj.startZ];
         pfin = [obj.stopX; obj.stopY; obj.stopZ];
         pdiff = pfin - pin;
         long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
         
         %original plane vertices creation
         Xtemp=[0 0 long long];
         Ytemp=[-obj.win/2 +obj.win/2 +obj.wfin/2-obj.shift -obj.wfin/2-obj.shift];
         Ztemp=[0 0 0 0];
         
         grp = hgtransform(ax);%definition of Parent transformation group
            
         T = makehgtform('translate',[obj.startX obj.startY obj.startZ]);%translation transformation
         
         
         
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
           
           %plot
           if nargin==1
                h=patch('XData',Xtemp,'YData',Ytemp,'ZData',Ztemp,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);
            elseif nargin==2
                h=patch(ax,'XData',Xtemp,'YData',Ytemp,'ZData',Ztemp,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);                 
            elseif nargin>2
                h=patch(ax,'XData',Xtemp,'YData',Ytemp,'ZData',Ztemp,'Parent',grp,varargin{:});

            end
            
                      
            h.ButtonDownFcn=@HightlightHitSurf;
            set(grp,'Matrix',T*Rz*Ry*Rx);
            obj.hGraph=h;
            h.UserData=obj.tag;
     end
   
    end
end

