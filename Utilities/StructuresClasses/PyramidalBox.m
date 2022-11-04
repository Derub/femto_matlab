classdef PyramidalBox<BasicStructure
    properties
        win
        hin
        wfin
        hfin
        theta
        ishelix=0;
        iscarpet=0;
        pitch
        dw
        dh
    end
    methods
        function obj = PyramidalBox(startX,startY,startZ,stopX,stopY,stopZ,vcut,win,hin,wfin,hfin,theta,ishelix,varargin)
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
         obj.name='Pyramidal box';
         
         if nargin<8
             obj.win=1;
             obj.hin=1;
             obj.wfin=0.5;
             obj.hfin=0.5;
             obj.theta=0;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
             
         elseif nargin==8
             obj.win=win;
             obj.hin=win;
             obj.wfin=win;
             obj.hfin=win;
             obj.theta=0;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
             
         elseif nargin==9
             obj.win=win;
             obj.hin=hin;
             obj.wfin=win;
             obj.hfin=hin;
             obj.theta=0;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
         
         elseif nargin==10
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hin;
             obj.theta=0;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
             
         elseif nargin==11
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hfin;
             obj.theta=0;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
         
         elseif nargin==12
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hfin;
             obj.theta=theta;
             obj.ishelix=0; obj.iscarpet=1;
             obj.dw=0.01;
             obj.dh=0.1;
             
         elseif nargin==13
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hfin;
             obj.theta=theta;
             obj.ishelix=ishelix; obj.iscarpet=not(ishelix);
             if obj.ishelix
                 obj.pitch=0.01;
             else
                obj.dw=0.01;
                obj.dh=0.1;
             end
             
           elseif nargin==14
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hfin;
             obj.theta=theta;
             obj.ishelix=ishelix; obj.iscarpet=not(ishelix);
             if obj.ishelix
                 obj.pitch=varargin{1};
             else
                obj.dw=varargin{1};
                obj.dh=varargin{1};
             end
            
             elseif nargin==15
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hfin;
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
             
              elseif nargin>15
             obj.win=win;
             obj.hin=hin;
             obj.wfin=wfin;
             obj.hfin=hfin;
             obj.theta=theta;
             obj.ishelix=ishelix; obj.iscarpet=not(ishelix);
             if obj.ishelix
                 obj.pitch=varargin{1};
                 fprintf('unused input arguments aftert 14th position\n');
                 varargin{2:end}
             else
                obj.dw=varargin{1};
                obj.dh=varargin{2};
                fprintf('unused input arguments aftert 15th position\n');
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
            
            
            %original cube vertices creation along x axis
            Ytemp=[-obj.win/2 obj.win/2 obj.win/2 -obj.win/2;...
                obj.win/2 obj.win/2 -obj.win/2 -obj.win/2;...
                obj.wfin/2 obj.wfin/2 -obj.wfin/2 -obj.wfin/2;...
                -obj.wfin/2 obj.wfin/2 obj.wfin/2 -obj.wfin/2];
                
            Ztemp=[-obj.hin/2 -obj.hin/2 obj.hin/2 obj.hin/2;...
                -obj.hin/2 obj.hin/2 obj.hin/2 -obj.hin/2;...
                -obj.hfin/2 obj.hfin/2 obj.hfin/2 -obj.hfin/2;...
                -obj.hfin/2 -obj.hfin/2 obj.hfin/2 obj.hfin/2];
            
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
            set(h,'UserData',obj);
            
            set(grp,'Matrix',T*Rz*Ry*Rx*S);
            obj.hGraph=h;
            h.UserData=obj.tag;
        end
        function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
            
                %GCODE for carpet pyramidal box  along x direction
                
                x1=[]; y1=[]; z1=[];vel1 =[];
                
                pin = [obj.startX; obj.startY; obj.startZ];
                pfin = [obj.stopX; obj.stopY; obj.stopZ];
                pdiff = pfin - pin;
                long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
            x1=[]; y1=[]; z1=[]; vel1=[];shut1=[];
 
            if obj.iscarpet
                wmax = max([obj.win obj.wfin]); hmax = max([obj.hin obj.hfin]);
                nw = floor(wmax/obj.dw); nh = floor(hmax/obj.dh);
                if (obj.win < obj.wfin)
                    dwfin = obj.dw; gapwfin = (obj.wfin-nw*dwfin)/2;
                    dwin = obj.win/nw; gapwin = 0;
                else
                    dwin = obj.dw; gapwin = (obj.win-nw*dwin)/2;
                    dwfin = obj.wfin/nw; gapwfin = 0;
                end
                if (obj.hin < obj.hfin)
                    dhfin = obj.dh; gaphfin = (obj.hfin-nh*dhfin)/2;
                    dhin = obj.hin/nh; gaphin = 0;
                else
                    dhin = obj.dh; gaphin = (obj.hin-nh*dhin)/2;
                    dhfin = obj.hfin/nh; gaphfin = 0;
                end

                for ii = 0:nw                   %floor
                    x1 = [x1 0 long];
                    y1 = [y1 -obj.win/2+gapwin+ii*dwin -obj.wfin/2+gapwfin+ii*dwfin];
                    z1 = [z1 -obj.hin/2+gaphin -obj.hfin/2+gaphfin];
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1 = [shut1 0 1];
                end
                for jj = 1:(nh-1)               %first wall
                    x1 = [x1 0 long];
                    y1 = [y1 -obj.win/2+gapwin -obj.wfin/2+gapwfin];
                    z1 = [z1 -obj.hin/2+gaphin+jj*dhin -obj.hfin/2+gaphfin+jj*dhfin];
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1 = [shut1 0 1];
                end
                for jj = 1:(nh-1)               %second wall
                    x1 = [x1 0 long];
                    y1 = [y1 obj.win/2-gapwin obj.wfin/2-gapwfin];
                    z1 = [z1 -obj.hin/2+gaphin+jj*dhin -obj.hfin/2+gaphfin+jj*dhfin];
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1 = [shut1 0 1];
                end
                for ii = 0:nw                   %roof
                    x1 = [x1 0 long];
                    y1 = [y1 -obj.win/2+gapwin+ii*dwin -obj.wfin/2+gapwfin+ii*dwfin];
                    z1 = [z1 obj.hin/2-gaphin obj.hfin/2-gaphfin];
                    vel1 = [vel1 obj.vpos obj.vcut];
                    shut1 = [shut1 0 1];
                end
            elseif obj.ishelix
                nlap = floor(long/obj.pitch);
            deltaw = ((obj.wfin-obj.win)/2)/nlap; deltah = ((obj.hfin-obj.hin)/2)/nlap;
            xbox=0;
            Lcritical = 0.005;     %if L<Lcritical, velocity must be reduced
            vredux = 0.5;      %if L<Lcritical, fraction of velocity reduction
            
            for ii = 0:nlap-1
                if (((obj.win+2*ii*deltaw)<Lcritical) || ((obj.hin+2*ii*deltaw)<Lcritical))
                    vel1 = [vel1 vredux*obj.vcut vredux*obj.vcut vredux*obj.vcut vredux*obj.vcut];
                else
                    vel1 = [vel1 obj.vcut obj.vcut obj.vcut obj.vcut];
                end
                x1 = [x1, xbox];
                y1 = [y1, obj.win/2+ii*deltaw];
                z1 = [z1, obj.hin/2+ii*deltah-deltah/2];
                xbox = xbox+obj.pitch/4;
                x1 = [x1, xbox];
                y1 = [y1, obj.win/2+ii*deltaw];
                z1 = [z1, -obj.hin/2-ii*deltah-deltah/2];
                xbox = xbox+obj.pitch/4;
                x1 = [x1, xbox];
                y1 = [y1, -obj.win/2-ii*deltaw-deltaw/2];
                z1 = [z1, -obj.hin/2-ii*deltah-deltah/2];
                xbox = xbox+obj.pitch/4;
                x1 = [x1, xbox];
                y1 = [y1, -obj.win/2-ii*deltaw-deltaw/2];
                z1 = [z1, obj.hin/2+ii*deltah+deltah/2];
                xbox = xbox+obj.pitch/4;
                shut1=ones(size(x1));
                shut1(1)=0; shut1(end)=0;
            end
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
        
        theta_rad=obj.theta*pi/180;
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
        v_GCODE = obj.vcut*ones(size(X_GCODE));
        v_GCODE(1) = obj.vpos;

        Shutter_GCODE= shut1;
        Shutter_GCODE(1) = 0;
        
        
        %GCODE writing time computation
        obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE,obj);
    end
    end
end
