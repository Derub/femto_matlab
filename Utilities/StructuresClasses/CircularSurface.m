classdef CircularSurface<BasicStructure
    properties

       theta
       dw
    end
    methods
    function obj = CircularSurface(startX,startY,startZ,stopX,stopY,stopZ,vcut,theta,dw)
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
         obj.name='Circular surface';
         
         if nargin<8
             obj.theta=0;
             obj.dw=0.01;
             
             
         elseif nargin==8
             obj.theta=theta;
             obj.dw=0.01;
             
         elseif (nargin==9)
             obj.theta=theta;
             obj.dw=dw;
             
         elseif nargin>9
             obj.theta=theta;
             obj.dw=dw;
             fprintf('unused input arguments after 12th position');
             args{9:end}  
                         
         
         end
             
         %% Post Initialization %%
         % Any code, including access to object
        
                
         
    end
     function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
        %%Code to compile GCODE vectors for either "precise" or "fast" Flat surface    
         

%         
%         x1=[]; y1=[]; z1=[];
        pin = [obj.startX; obj.startY; obj.startZ];
        pfin = [obj.stopX; obj.stopY; obj.stopZ];
        pdiff = pfin - pin;
        long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
        diam=long;
        r=diam/2;

        if (obj.dw==0)
            obj.dw=long/10;
        end
        x1=[0:obj.dw:long];

        y1=sqrt(r^2-(x1-r).^2);

        y1(1:2:end)=-y1(1:2:end);
        z1 =  zeros(size(x1)); 
        shut1 = ones(size(x1));
        vel1 = obj.vcut*ones(size(x1));

         
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
         long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2); %corresponding to structure diameters
         
         %MODDED
        
        r=long/2;

        
         %creation of the mesh in (0,0,0) along xy plane
        Tcirc=[pi,0:2*pi/40:pi];
        Xtemp=r*cos(Tcirc)+r;
        Ytemp=r*sin(Tcirc);
        Ztemp = zeros(size(Xtemp));
         
        
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
                h(1)=patch('XData',[Xtemp; Xtemp]','YData',[Ytemp; -Ytemp]','ZData',[Ztemp; Ztemp]','FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);
                %h(2)=plot3([0 2*r], [0 0], [0 0],'b','Parent',grp);
            elseif nargin==2
                h(1)=patch(ax,'XData',[Xtemp; Xtemp]','YData',[Ytemp; -Ytemp]','ZData',[Ztemp; Ztemp]','FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);   
                %h(2)=plot3(ax,[0 2*r], [0 0], [0 0],'b','Parent',grp);
            elseif nargin>2
                h(1)=patch(ax,'XData',[Xtemp; Xtemp]','YData',[Ytemp; -Ytemp]','ZData',Ztemp,'Parent',grp,varargin{:});
                %h(2)=plot3(ax,[0 2*r], [0 0], [0 0],'Parent',grp,varargin{:});
            end
            
                      
            %h(1).ButtonDownFcn=@HightlightHitSurf;
            %h(2).ButtonDownFcn=@HightlightHitSurf;
            
            set(grp,'Matrix',T*Rz*Ry*Rx);
            obj.hGraph=h(1);
            h(1).UserData=obj.tag;
            %h(2).UserData=obj.tag;
     end
   
    end
end

