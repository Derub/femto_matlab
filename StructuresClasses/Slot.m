classdef Slot<BasicStructure
    properties
       struct_width
       theta
       struct_height
       isfast
       isprecise
       dw
       dh
    end
    methods
    function obj = Slot(startX,startY,startZ,stopX,stopY,stopZ,vcut,struct_width,struct_height,dw,dh,theta,isfast,varargin)
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
         obj.name='Slot';
         
         if nargin<8
             obj.struct_width=0.1;
             obj.struct_height=obj.struct_width;
             obj.dw=0.01;
             obj.dh=0.01;
             obj.theta=0;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif nargin==8
             obj.struct_width=struct_width;
             obj.struct_height=obj.struct_width;
             obj.dw=0.01;
             obj.dh=0.01;
             obj.theta=0;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif nargin==9
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.dw=0.01;
             obj.dh=0.01;
             obj.theta=0;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif nargin==10
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.dw=dw;
             obj.dh=dw;
             obj.theta=0;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif nargin==11
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.dw=dw;
             obj.dh=dh;
             obj.theta=0;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif nargin==12
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.dw=dw;
             obj.dh=dh;
             obj.theta=theta;
             obj.isfast=1;
             obj.isprecise=not(obj.isfast);
         elseif nargin==13
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.dw=dw;
             obj.dh=dh;
             obj.theta=theta;
             obj.isfast=isfast;
             obj.isprecise=not(obj.isfast);
         elseif nargin>13
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.dw=dw;
             obj.dh=dh;
             obj.theta=theta;
             obj.isfast=isfast;
             obj.isprecise=not(obj.isfast);
             fprintf('unused input arguments after 11th position\n');
             varargin
         end
             
         %% Post Initialization %%
         % Any code, including access to object
        
                
         
    end
     function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
        %%Code to compile GCODE vectors for either "precise" or "fast" Slot
        
        x1=[]; y1=[]; z1=[];
        pin = [obj.startX; obj.startY; obj.startZ];
        pfin = [obj.stopX; obj.stopY; obj.stopZ];
        pdiff = pfin - pin;
        long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
        
        
        if ((obj.struct_width==0)||(obj.dw==0))
            nw = 1; gapw = 0;
            ya = 0;
        else
            nw = 1+ceil(obj.struct_width/obj.dw);
            gapw = ((nw-1)*obj.dw-obj.struct_width)/2;
            ya = -obj.struct_width/2-gapw;
        end
        if ((obj.struct_height==0)||(obj.dh==0))
            nh = 0; gaph = 0;
            za = 0;
        else
            nh = 1+ceil((obj.struct_height-obj.dh)/(2*obj.dh));
            gaph =(((nh-1)*2*obj.dh+obj.dh)-obj.struct_height)/2;
            za = -obj.struct_height/2-gaph;
        end
        
        x1=[]; y1=[]; z1=[]; shut1=[];
        
        if (obj.isfast==1)
            %fast
            for ii=1:nw
                xa = 0; shut = 0;
                for jj=1:nh
                    x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za]; shut1=[shut1, shut];
                    xa = long; shut = 1;
                    x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za]; shut1=[shut1, shut];
                    za = za+obj.dh;
                    x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za]; shut1=[shut1, shut];
                    xa = 0;
                    x1 = [x1, xa]; y1=[y1, ya]; z1=[z1, za]; shut1=[shut1, shut];
                    za = za+obj.dh;
                end
                ya = ya+obj.dw;
                za = -obj.struct_height/2-gaph;
            end
            vel1 = obj.vcut*ones(size(x1));
            
        elseif (obj.isfast==0)
            %precise
            vel1 = [];
            for ii=1:nw
                for jj=1:nh
                    x1=[x1, 0, long];
                    y1=[y1, ya, ya];
                    z1=[z1, za, za]; za=za+obj.dh;
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1=[shut1,0,1];
                    x1=[x1, 0, long];
                    y1=[y1, ya, ya];
                    z1=[z1, za, za]; za=za+obj.dh;
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1=[shut1,0,1];
                end
                ya = ya+obj.dw;
                za = -obj.struct_height/2-gaph;
            end
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
           
           %plot
           if nargin==1
                h=patch('XData',Xtemp,'YData',Ytemp,'ZData',Ztemp,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp,'LineStyle','--','LineWidth',1,'Marker','+');
            elseif nargin==2
                h=patch(ax,'XData',Xtemp,'YData',Ytemp,'ZData',Ztemp,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp,'LineStyle','--','LineWidth',1,'Marker','+');                 
            elseif nargin>2
                h=patch(ax,'XData',Xtemp,'YData',Ytemp,'ZData',Ztemp,'Parent',grp,varargin{:});

            end
            
                      
            h.ButtonDownFcn=@HightlightHitSurf;
            set(grp,'Matrix',T*Rz*Ry*Rx*S);
            obj.hGraph=h;
            h.UserData=obj.tag;
     end
   
    end
end

