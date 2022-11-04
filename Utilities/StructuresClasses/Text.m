classdef Text<BasicStructure
    properties
       txt='';
       px;
       direction;
    end
    methods
    function obj = Text(startX,startY,startZ,txt,pixel,direction,vcut)
        %% StartX,StartY,StartZ are the starting points, txt is the txt you want to print, pixel is the single pixel dimention (each letter is 3by4 px) and direction is teh writing direciton (1 to 4, from -180° to 270° on xy plane)
        
         %% Pre Initialization %%
         % Any code not using output argument (obj)
        
         if nargin < 3
            args{1} = 0;
            args{2} = 0;
            args{3} = 0;
            args{4} = 0;
            args{5} = 0;
            args{6} = 0;
            args{7}=1;

            
         elseif (nargin > 2)&&(nargin<7)
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4}=0;
            args{5}=0;
            args{6} = startZ;

            args{7}=1;
         
         
         
            
          elseif nargin == 7
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = 0;
            args{5} = 0;
            args{6} = startZ;
            args{7}=vcut;
         else
                %error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         

        
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement         
         obj = obj@BasicStructure(args{:});
         obj.name='Text';
       
         
         if nargin <3
            obj.txt='X';
            obj.px=0.01;%[um]pixel dimesion fixed to 10 um
            obj.direction=1;% defaul direction
            obj.stopX=obj.startX+3.5*0.1;
            obj.stopY=obj.startY;
            obj.stopZ = obj.startZ;
         elseif nargin ==4
            obj.txt=txt;
            obj.px=0.01;%[um]pixel dimesion fixed to 10 um
            obj.direction=1;% defaul direction
            obj.stopX=startX+length(obj.txt)*3.5*obj.px;
            obj.stopY=startY;
            obj.stopZ = obj.startZ;
         elseif nargin ==5
            obj.txt=txt;
            obj.px=pixel;%[um]pixel dimesion fixed to 10 um
            obj.direction=1;% defaul direction
            obj.stopX=startX+length(obj.txt)*3.5*obj.px;
            obj.stopY=startY;
            obj.stopZ = obj.startZ;   
         elseif nargin > 5
            obj.txt=txt;
            obj.px=pixel;%[um]pixel dimesion fixed to 10 um
            obj.direction=direction;% defaul direction
            
            obj.stopZ = obj.startZ;   
            
            switch obj.direction
             case 3
                 obj.stopX=startX-length(obj.txt)*3.5*obj.px;
                 obj.stopY=startY;
             case 4
                 obj.stopX=startX;
                 obj.stopY=startY+length(obj.txt)*3.5*obj.px;
             case 1
                 obj.stopX=startX+length(obj.txt)*3.5*obj.px;
                 obj.stopY=startY;
             case 2
                 obj.stopX=startX;
                 obj.stopY=startY-length(obj.txt)*3.5*obj.px;
             otherwise
                 obj.stopX=startX;
                 obj.stopY=startY;
            end
         end
         
         
     
         %% Post Initialization %%
         % Any code, including access to object
         
         
         
         
    end
    
    function obj=S_plot(obj,ax,varargin) %surface plot of the object
        [obj,X_GCODE,Y_GCODE,Z_GCODE,~,Shutter_GCODE]=GCODE_write(obj);
        for i=2:length(Shutter_GCODE)
            if Shutter_GCODE(i)==1 s(i)="-"';          
            else s(i)="none";
            end
        end
      grp=hggroup(ax);
        for i=2:length(Shutter_GCODE)
            v=version('-date');
            year=str2double(v(1,end-3:end));
            
            if year<2018
                if nargin==1
                    h=plot3(X_GCODE,Y_GCODE,Z_GCODE,'b');
                elseif nargin>1
                    h=plot3(ax,X_GCODE,Y_GCODE,Z_GCODE,'b');
                end
            else
            if nargin==1
                hold on
                for i=2:length(Shutter_GCODE)
                    h=plot3([X_GCODE(i-1) X_GCODE(i)],[Y_GCODE(i-1) Y_GCODE(i)],[Z_GCODE(i-1) Z_GCODE(i)],'Color','b','LineStyle',s(i),'Parent',grp);
                end
                hold off
            elseif nargin==2
                hold(ax,'on');
                for i=2:length(Shutter_GCODE)
                    h=plot3(ax,[X_GCODE(i-1) X_GCODE(i)],[Y_GCODE(i-1) Y_GCODE(i)],[Z_GCODE(i-1) Z_GCODE(i)],'Color','b','LineStyle',s(i),'Parent',grp);
                end
                hold(ax,'off');
            elseif nargin>2
                h=plot3(ax,X_GCODE,Y_GCODE,Z_GCODE,varargin{:});
            end
            end
        end
       
        
        h.ButtonDownFcn=@HightlightHitSurf;
            
        obj.hGraph=grp;
        grp.UserData=obj.tag;
    end       
        
    function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
            
           %GCODE for txt along x direction
          x_vector=[];
          y_vector=[];
          z_vector=[];
          shutter=[];
          v_vector=[];
          
          px=obj.px;
          v=obj.vcut
          v_pos=obj.vpos
          txt=obj.txt
          

        for iii = 1:length(obj.txt)
            switch upper(txt(iii))
                case ' '
                    x_temp=[0];
                    y_temp=[0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0];
                    vel_temp=[v_pos];
                case '0'
                    x_temp=[px 2*px 3*px 3*px 2*px px 0 0 px 0];
                    y_temp=[0 0 px 3*px 4*px 4*px 3*px px 0 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v v v v_pos];
                case '1'
                    x_temp=[3*px px px 3*px 0];
                    y_temp=[0 0 4*px 3*px 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[1 0 1 1 0];
                    vel_temp=[v v_pos v v v_pos]; 
                 case '2'
                    x_temp=[0 3*px 0 px 2*px 3*px 0];
                    y_temp=[0 0 3*px 4*px 4*px 3*px 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v_pos]; 
                 case '3'
                    x_temp=[3*px 2*px px 0 px 2*px px 0 px 2*px 3*px 0];
                    y_temp=[px 0 0 px 2*px 2*px 2*px 3*px 4*px 4*px 3*px 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v v v v v v_pos]; 
                 case '4'
                    x_temp=[px px 3*px 0 0];
                    y_temp=[0 4*px px px 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 0];
                    vel_temp=[v_pos v v v v_pos]; 
                 case '5'
                    x_temp=px*[3 2 1 0 0 1 3 3 0 0];
                    y_temp=px*[1 0 0 1 2 3 3 4 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v v v v_pos]; 
                  case '6'
                    x_temp=px*[3 2 1 0 1 2 3 3 1 0 0];
                    y_temp=px*[1 2 2 1 0 0 1 3 4 3 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v v v v v_pos]; 
                  case '7'
                    x_temp=px*[3 0 3 3 0 0];
                    y_temp=px*[0 4 4 2 2 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 0 1 0];
                    vel_temp=[v_pos v v v v v_pos]; 
                  case '8'
                    x_temp=px*[2 3 2 1 0 1 2 3 2 1 0 1 0];
                    y_temp=px*[2 1 0 0 1 2 2 3 4 4 3 2 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v v v v v v v_pos]; 
                  case '9'
                    x_temp=px*[3 2 0 0 1 2 3 2 1 0 0];
                    y_temp=px*[1 0 1 3 4 4 3 2 2 3 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v v v v v_pos];
                  case 'A'
                    x_temp=px*[3 1 0 0 3 0];
                    y_temp=px*[0 4 0 1 1 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 0 1 0];
                    vel_temp=[v_pos v v v v v_pos];
                  case 'B'
                    x_temp=px*[1 0 1 3 3 1 0 1 3 0];
                    y_temp=px*[2 1 0 0 4 4 3 2 2 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v v v v_pos];
                  case 'C'
                    x_temp=px*[0 1 2 3 3 2 1 0 0];
                    y_temp=px*[1 0 0 1 3 4 4 3 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v v v_pos];
                  case 'D'
                    x_temp=px*[3 1 0 0 1 3 3 0];
                    y_temp=px*[0 0 1 3 4 4 0 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 0];
                    vel_temp=[v_pos v v v v v v v_pos];
                case 'E'
                     x_temp=px*[0 3 3 0 2 3 0];
                    y_temp=px*[0 0 4 4 2 2 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 0 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);

                case 'F'
                     x_temp=px*[3 3 0 3 0 0];
                    y_temp=px*[0 4 4 2 2 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 0 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'G'
                     x_temp=px*[3 2 1 0 0 1 2 3 2 1 0];
                    y_temp=px*[3 4 4 3 1 0 0 1 2 2 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'H'
                     x_temp=px*[0 0 3 3 3 0 0];
                    y_temp=px*[0 4 4 0 2 2 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 0 1 0 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                  case 'I'
                     x_temp=px*[1 1 0];
                    y_temp=px*[0 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                 case 'L'
                     x_temp=px*[0 3 3 0];
                    y_temp=px*[0 0 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                 case 'M'
                     x_temp=px*[0 0 2 3 3 0];
                    y_temp=px*[0 4 2 4 0 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'N'
                     x_temp=px*[3 3 0 0 0];
                    y_temp=px*[0 4 0 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'O'
                     x_temp=px*[0 1 2 3 3 2 1 0 0 1];
                    y_temp=px*[1 0 0 1 3 4 4 3 1 1];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 0 ];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                 case 'P'
                     x_temp=px*[3 3 1 0 1 3 0];
                    y_temp=px*[0 4 4 3 2 2 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);

                case 'Q'
                     x_temp=px*[0 1 2 3 3 2 1 0 0 1 0 0];
                    y_temp=px*[1 0 0 1 3 4 4 3 1 1 0 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 0 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'R'
                     x_temp=px*[3 3 1 0 1 3 0 0];
                    y_temp=px*[0 4 4 3 2 2 0 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'S'
                     x_temp=px*[3 2 1 0 1 2 3 2 1 0];
                    y_temp=px*[1 0 0 1 2 2 3 4 4 3];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 1 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'T'
                     x_temp=px*[1.5 1.5 3 0 0];
                    y_temp=px*[0 4 4 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 0 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'U'
                     x_temp=px*[3 3 2 1 0 0 0];
                    y_temp=px*[4 1 0 0 1 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'V'
                     x_temp=px*[3 1 0 0];
                    y_temp=px*[4 0 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'Z'
                     x_temp=px*[0 3 0 3 0];
                    y_temp=px*[0 0 4 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'X'
                     x_temp=px*[0 3 0 3 0];
                    y_temp=px*[0 4 4 0 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 0 1 0];                    
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                    
                case 'Y'
                     x_temp=px*[3 1 2 0 0];
                    y_temp=px*[4 0 2 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 0 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'W'
                     x_temp=px*[3 2 1 2 1 0 0];
                    y_temp=px*[4 0 4 4 0 4 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 1 0 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'J'
                     x_temp=px*[3 0 2 2 1 0 0];
                    y_temp=px*[4 4 4 1 0 1 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 0 1 1 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                case 'K'
                     x_temp=px*[3 0 0 0 1 3 0];
                    y_temp=px*[4 1 4 0 2 0 0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0 1 0 1 0 1 0];
                    vel_temp=shutter_temp*(v)+not(shutter_temp)*(v_pos);
                otherwise
                    x_temp=[0];
                    y_temp=[0];
                    z_temp=zeros(1,size(x_temp,2));
                    shutter_temp=[0];
                    vel_temp=[v_pos];
            end


            x_temp=x_temp-(iii*3.5*px);%moving letter to the right x position (included spacing)

            x_vector=[x_vector x_temp];
            y_vector=[y_vector y_temp];
            z_vector=[z_vector z_temp];
            shutter=[shutter shutter_temp];
            v_vector=[v_vector vel_temp];
        end
        
        x1=x_vector; y1=y_vector; z1=z_vector;
                
         pin = [obj.startX; obj.startY; obj.startZ];
         pfin = [obj.stopX; obj.stopY; obj.stopZ];
         pdiff = pfin - pin;
         long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
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
        v_GCODE = v_vector;
        
        Shutter_GCODE= shutter;
        Shutter_GCODE(1) = 0;
        
        
        %GCODE writing time computation
        obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE,obj);
        
        end
    end
end
