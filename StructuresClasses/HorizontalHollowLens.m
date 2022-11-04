classdef HorizontalHollowLens<BasicStructure
    properties
        struct_width %[mm] lenght of the 'microchannel'
        struct_height %[mm] lenght along z, i.e. the lens aperture
        step %[mm] step along z
        R1 %[mm] first surface 1st order curvature radius
        R2 %[mm] second surface 1st order curvature radius
        alpha1 %[mm] first surface coeffiencts for higher aspherical orders
        alpha2 %[mm] second surface coeffiencts for higher aspherical orders
        rightTap logical
        leftTap logical
        Num %number of segments to interpolate aspherical profile
        filling_separation=0.05; %spacing between straight line inside the lens to help acid access
        compensation_dz=0; % 
    end
    methods
        function obj = HorizontalHollowLens(startX,startY,startZ,stopX,stopY,stopZ,vcut,struct_width,struct_height,step,rightTap,leftTap,R1,R2,alpha1,alpha2,Num,compensation_dz,varargin)
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
            args{6} = startZ;
            
         elseif nargin >6
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = stopX;
            args{5} = stopY;
            args{6} = startZ;
            args{7}=vcut;
%          else
%              error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         obj = obj@BasicStructure(args{:});   
         obj.name='Hollow Lens';
         obj.stopZ=obj.startZ;
         

         
         if nargin<8
             obj.struct_width=0.5;
             obj.struct_height=0.1;
             obj.step=0.002;
             obj.rightTap=0; obj.leftTap=1;
             obj.R1=-0.05;
             obj.R2=0.05;
             obj.alpha1=[];
             obj.alpha2=[];
             obj.Num=30;
             obj.compensation_dz=0;
             
         elseif nargin==8
             obj.struct_width=struct_width;
             obj.struct_height=0.1;
             obj.step=0.002;
             obj.rightTap=0; obj.leftTap=1;
             obj.R1=-0.05;
             obj.R2=0.05;
             obj.alpha1=[];
             obj.alpha2=[];
             obj.Num=30;
             obj.compensation_dz=0;
             
         elseif nargin==9
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=0.002;
             obj.rightTap=0; obj.leftTap=1;
             obj.R1=-0.05;
             obj.R2=0.05;
             obj.alpha1=[];
             obj.alpha2=[];
             obj.Num=30;
             obj.compensation_dz=0;
             
         elseif nargin==10
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=0; obj.leftTap=1;
             obj.R1=-0.05;
             obj.R2=0.05;
             obj.alpha1=[];
             obj.alpha2=[];
             obj.Num=30;
             obj.compensation_dz=0;
             
        elseif nargin==11
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=0; obj.leftTap=1;
             fprintf('Specify both right and left tap flags at once');
             obj.R1=-0.05;
             obj.R2=0.05;
             obj.alpha1=[];
             obj.alpha2=[];
             obj.Num=30;
             obj.compensation_dz=0;
             
         elseif nargin==12
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=rightTap; obj.leftTap=leftTap;
             obj.R1=-0.05;
             obj.R2=0.05;
             obj.alpha1=[];
             obj.alpha2=[];
             obj.Num=30;
             obj.compensation_dz=0;
             
         elseif nargin==13
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=rightTap; obj.leftTap=leftTap;
             obj.R1=R1;
             obj.R2=0.05;
             obj.alpha1=[];
             obj.alpha2=[];
             obj.Num=30;
             obj.compensation_dz=0;
             
      elseif nargin==14
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=rightTap; obj.leftTap=leftTap;
             obj.R1=R1;
             obj.R2=R2;
             obj.alpha1=[];
             obj.alpha2=[];
             obj.Num=30;
             obj.compensation_dz=0;
             
    elseif nargin==15
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=rightTap; obj.leftTap=leftTap;
             obj.R1=R1;
             obj.R2=R2;
             obj.alpha1=alpha1;
             obj.alpha2=[];
             obj.Num=30; 
             obj.compensation_dz=0;
             
     elseif nargin==16
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=rightTap; obj.leftTap=leftTap;
             obj.R1=R1;
             obj.R2=R2;
             obj.alpha1=alpha1;
             obj.alpha2=alpha2;
             obj.Num=30; 
             obj.compensation_dz=0;
             
    elseif nargin==17
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=rightTap; obj.leftTap=leftTap;
             obj.R1=R1;
             obj.R2=R2;
             obj.alpha1=alpha1;
             obj.alpha2=alpha2;
             if rem(Num,2)
                 Num=Num+1; %only even Num is accepted
             end
             obj.Num=Num; 
             obj.compensation_dz=0;
             
   elseif nargin==18
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=rightTap; obj.leftTap=leftTap;
             obj.R1=R1;
             obj.R2=R2;
             obj.alpha1=alpha1;
             obj.alpha2=alpha2;
             if rem(Num,2)
                 Num=Num+1; %only even Num is accepted
             end
             obj.Num=Num; 
             obj.compensation_dz=compensation_dz;
             
     elseif nargin>18
             obj.struct_width=struct_width;
             obj.struct_height=struct_height;
             obj.step=step;
             obj.rightTap=rightTap; obj.leftTap=leftTap;
             obj.R1=R1;
             obj.R2=R2;
             obj.alpha1=alpha1;
             obj.alpha2=alpha2;
             if rem(Num,2)
                 Num=Num+1; %only even Num is accepted
             end
             obj.Num=Num; 
             obj.compensation_dz=compensation_dz;
             fprintf('unused input arguments aftert 17th position\n');
             varargin
             
         end
         
        end    
        function obj=S_plot(obj,ax,varargin) %surface plot of the object
            pin = [obj.startX; obj.startY; obj.startZ];
            pfin = [obj.stopX; obj.stopY; obj.stopZ];
            pdiff = pfin - pin;
            long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
           
            
            grp = hgtransform(ax);%definition of Parent transformation group
            
            k=0;
            
             x_patch=[];
            y_patch=[];
            z_patch=[];
        %first aspheric surface
            c = 1./obj.R1;
            z_surf1_temp = linspace(-obj.struct_height/2,+obj.struct_height/2,5); %mm
            x_surf1_temp = c*z_surf1_temp.^2./(1+sqrt(1-(1+k)*c.^2.*z_surf1_temp.^2));
            
            if ~isempty(obj.alpha1)
                for ii = 1:numel(obj.alpha1)
                    x_surf1_temp = x_surf1_temp + obj.alpha1(ii).*(z_surf1_temp).^(2*ii);
                end
            end

            y_surf1_temp=zeros(1,numel(x_surf1_temp));
    
    
                %replica of the vector to generate channel structure

                x_surf1=repelem(x_surf1_temp,2);
                z_surf1=repelem(z_surf1_temp,2);
                y_surf1(1:2:2*numel(y_surf1_temp)) = y_surf1_temp;
                y_surf1(2:2:end+1)=1*ones(1,numel(y_surf1_temp));
    

    
            for i=1:numel(x_surf1)/2-1
                x_patch=[x_patch x_surf1(1+(i-1)*2:4+(i-1)*2)'];
                z_patch=[z_patch z_surf1(1+(i-1)*2:4+(i-1)*2)'];
                y_patch=[y_patch [y_surf1(1+(i-1)*2); y_surf1(2+(i-1)*2); y_surf1(4+(i-1)*2); y_surf1(3+(i-1)*2)]];
            end

            %second aspheric surface
                c = 1./obj.R2;
                z_surf2_temp = linspace(-obj.struct_height/2,+obj.struct_height/2,5); %mm
                x_surf2_temp = c.*z_surf2_temp.^2./(1+sqrt(1-(1+k)*c.^2.*z_surf2_temp.^2));

            if ~isempty(obj.alpha2)
                for ii = 1:numel(obj.alpha2)
                    x_surf2_temp = x_surf2_temp + obj.alpha2(ii).*(z_surf2_temp).^(2*ii);
                end
            end
    
    
            x_surf2_temp=x_surf2_temp+long;
            y_surf2_temp=zeros(1,numel(x_surf2_temp));
    
    
            %replica of the vector to generate channel structure

            x_surf2=repelem(x_surf2_temp,2);
            z_surf2=repelem(z_surf2_temp,2);
            y_surf2(1:2:2*numel(y_surf2_temp)) = y_surf2_temp;
            y_surf2(2:2:end+1)=1*ones(1,numel(y_surf2_temp));

            for i=1:numel(x_surf2)/2-1
                x_patch=[x_patch x_surf2(1+(i-1)*2:4+(i-1)*2)'];
                z_patch=[z_patch z_surf2(1+(i-1)*2:4+(i-1)*2)'];
                y_patch=[y_patch [y_surf2(1+(i-1)*2); y_surf2(2+(i-1)*2); y_surf2(4+(i-1)*2); y_surf2(3+(i-1)*2)]];
            end
    
            %bottom and top planes
            x_patch=[x_patch [x_surf1(1); x_surf1(2); x_surf2(2); x_surf2(1)] [x_surf1(end-1); x_surf1(end); x_surf2(end); x_surf2(end-1)]];
            y_patch=[y_patch [y_surf1(1); y_surf1(2); y_surf2(2); y_surf2(1)] [y_surf1(end-1); y_surf1(end); y_surf2(end); y_surf2(end-1)]];
            z_patch=[z_patch [z_surf1(1); z_surf1(2); z_surf2(2); z_surf2(1)] [z_surf1(end-1); z_surf1(end); z_surf2(end); z_surf2(end-1)]];
    
            
            %lateral taps
            x_patch_tap1=[];
            y_patch_tap1=[];
            z_patch_tap1=[];
            x_patch_tap2=[];
            y_patch_tap2=[];
            z_patch_tap2=[];
            
            
            if obj.rightTap
                x_patch_tap1=[x_surf1_temp x_surf2_temp];
                y_patch_tap1=[y_surf1_temp y_surf2_temp];
                z_patch_tap1=[z_surf1_temp flip(z_surf2_temp)];
                y_patch_tap1=y_patch_tap1-0.5;
            end
            if obj.leftTap
                x_patch_tap2=[x_surf1_temp x_surf2_temp];
                y_patch_tap2=[y_surf1_temp+1 y_surf2_temp+1];
                z_patch_tap2=[z_surf1_temp flip(z_surf2_temp)];
                y_patch_tap2=y_patch_tap2-0.5;
            end
    
        %translation of y vector to the axis of the lens
        y_patch=y_patch-0.5;

        if nargin==1
            hGraph(1)=patch('XData',x_patch,'YData',y_patch,'ZData',z_patch,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);
            hGraph(2)=patch('XData',x_patch_tap1,'YData',y_patch_tap1,'ZData',z_patch_tap1,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);
            hGraph(3)=patch('XData',x_patch_tap2,'YData',y_patch_tap2,'ZData',z_patch_tap2,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);
            
        elseif nargin==2
            hGraph(1)=patch(ax,'XData',x_patch,'YData',y_patch,'ZData',z_patch,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);
            hGraph(2)=patch(ax,'XData',x_patch_tap1,'YData',y_patch_tap1,'ZData',z_patch_tap1,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);
            hGraph(3)=patch(ax,'XData',x_patch_tap2,'YData',y_patch_tap2,'ZData',z_patch_tap2,'FaceColor','cyan','FaceAlpha',0.3,'EdgeColor','blue','EdgeAlpha',0.5,'Parent',grp);
         
        elseif nargin>2
            hGraph(1)=patch(ax,'XData',x_patch,'YData',y_patch,'ZData',z_patch,'Parent',grp);
            hGraph(2)=patch(ax,'XData',x_patch_tap1,'YData',y_patch_tap1,'ZData','Parent',grp);
            hGraph(3)=patch(ax,'XData',x_patch_tap2,'YData',y_patch_tap2,'ZData','Parent',grp);
          
        end
      
        T = makehgtform('translate',[obj.startX obj.startY obj.startZ]);%translation transformation

    	S=makehgtform('scale',[1 obj.struct_width 1]); %dilatation along y

        
        theta=atan((obj.stopY-obj.startY)/(obj.stopX-obj.startX));
        Rz= makehgtform('zrotate',theta);
 
        hGraph(1).ButtonDownFcn=@HightlightHitSurf;
        hGraph(2).ButtonDownFcn=@HightlightHitSurf;
        hGraph(3).ButtonDownFcn=@HightlightHitSurf;
        
        set(grp,'Matrix',T*Rz*S);
        obj.hGraph=hGraph;    
         h.UserData=obj.tag;   
           
        end
        
        function [obj,X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE]=GCODE_write(obj)
            
          %generation of vectors 
        X_GCODE=[];
        Y_GCODE=[];
        Z_GCODE=[];
        Shutter_GCODE=[];
        
         pin = [obj.startX; obj.startY; obj.startZ];
            pfin = [obj.stopX; obj.stopY; obj.stopZ];
            pdiff = pfin - pin;
        long = sqrt((pdiff(1))^2+(pdiff(2))^2+(pdiff(3))^2);
        k=0;
        %vector generation
        %first aspheric surface
            c = 1./obj.R1;
            z_surf1_temp = linspace(-obj.struct_height/2,+obj.struct_height/2,obj.Num); %mm
            x_surf1_temp = (c*z_surf1_temp.^2./(1+sqrt(1-(1+k)*c.^2.*z_surf1_temp.^2)));
             
            
            for ii = 1:numel(obj.alpha1)
                obj.alpha1(ii)
                x_surf1_temp = x_surf1_temp + obj.alpha1(ii).*(z_surf1_temp).^(2*ii);

            end
            
            if obj.compensation_dz~=0  
                obj.compensation_dz
                z_surf1_temp=obj.VoxelZCompensation(obj.compensation_dz,obj.R1,obj.alpha1,obj.Num,obj.struct_height);
            end

            y_surf1_temp=zeros(1,numel(x_surf1_temp));
            shutter_surf1_temp1=ones(1,numel(x_surf1_temp));

            %replica of the vector to generate channel structure

            x_surf1=repelem(x_surf1_temp,2);
            z_surf1=repelem(z_surf1_temp,2);
            y_surf1(1:2:2*numel(y_surf1_temp)) = y_surf1_temp;
            y_surf1(2:2:end+1)=1*ones(1,numel(y_surf1_temp));
            shutter_surf1(1:2:2*numel(shutter_surf1_temp1)) = zeros(1,numel(shutter_surf1_temp1));
            shutter_surf1(2:2:end+1) = shutter_surf1_temp1;

        %second aspheric surface
            c = 1./obj.R2;
            z_surf2_temp = linspace(-obj.struct_height/2,+obj.struct_height/2,obj.Num); %mm
            x_surf2_temp = real(c*z_surf2_temp.^2./(1+sqrt(1-(1+k)*c.^2.*z_surf2_temp.^2)));


            for ii = 1:numel(obj.alpha2)
                x_surf2_temp = x_surf2_temp + obj.alpha2(ii).*(z_surf2_temp).^(2*ii);
            end

            if obj.compensation_dz~=0        
                z_surf2_temp=obj.VoxelZCompensation(-obj.compensation_dz,obj.R2,obj.alpha2,obj.Num,obj.struct_height);
                z_surf2_temp=z_surf2_temp+obj.compensation_dz;
            end

            x_surf2_temp=x_surf2_temp+long;
            y_surf2_temp=zeros(1,numel(x_surf2_temp));
            shutter_surf2_temp=ones(1,numel(x_surf2_temp));

            %replica of the vector to generate channel structure

            x_surf2=repelem(x_surf2_temp,2);
            z_surf2=repelem(z_surf2_temp,2);
            y_surf2(1:2:2*numel(y_surf2_temp)) = y_surf2_temp;
            y_surf2(2:2:end+1)=1*ones(1,numel(y_surf2_temp));
            shutter_surf2(1:2:2*numel(shutter_surf2_temp)) = zeros(1,numel(shutter_surf2_temp));
            shutter_surf2(2:2:end+1) = shutter_surf2_temp;

        %bottom lens side
            x_bottom=x_surf1(1):0.001:x_surf2(1);
            z_bottom=z_surf1(1)*ones(1,size(x_bottom,2));
            y_bottom_temp=zeros(1,numel(x_bottom));
            shutter_bottom_temp=ones(1,numel(x_bottom));

            %replica of the vector to generate channel structure

            x_bottom=repelem(x_bottom,2);
            z_bottom=repelem(z_bottom,2);
            y_bottom(1:2:2*numel(y_bottom_temp)) = y_bottom_temp;
            y_bottom(2:2:end+1)=(1)*ones(1,numel(y_bottom_temp));
            shutter_bottom(1:2:2*numel(shutter_bottom_temp)) = zeros(1,numel(shutter_bottom_temp));
            shutter_bottom(2:2:end+1) = shutter_bottom_temp;

        %top lens side
            x_top=x_surf1(end):0.001:x_surf2(end);
            z_top=z_surf1(end)*ones(1,size(x_top,2));
            y_top_temp=zeros(1,numel(x_top));
            shutter_top_temp=ones(1,numel(x_top));

            %replica of the vector to generate channel structure

            x_top=repelem(x_top,2);
            z_top=repelem(z_top,2);
            y_top(1:2:2*numel(y_top_temp)) = y_top_temp;
            y_top(2:2:end+1)=1*ones(1,numel(y_top_temp));
            shutter_top(1:2:2*numel(shutter_top_temp)) = zeros(1,numel(shutter_top_temp));
            shutter_top(2:2:end+1) = shutter_top_temp;




        x_left_tap=[];
        y_left_tap=[];
        z_left_tap=[];
        shutter_left_tap=[];

        %laft tap
        if obj.leftTap
           x_left_tap(1:2:obj.Num)=x_surf1_temp(1:2:obj.Num);
           x_left_tap(2:2:obj.Num)=x_surf2_temp(2:2:obj.Num);
           z_left_tap=z_surf2_temp;
           y_left_tap=zeros(1,numel(x_left_tap));
           shutter_left_tap=ones(1,numel(x_left_tap)); shutter_left_tap(1)=0;

        end

        x_right_tap=[];
        y_right_tap=[];
        z_right_tap=[];
        shutter_right_tap=[];

        %right tap
        if obj.rightTap
           x_right_tap(1:2:obj.Num)=x_surf1_temp(1:2:obj.Num);
           x_right_tap(2:2:obj.Num)=x_surf2_temp(2:2:obj.Num);
           z_right_tap=z_surf2_temp;
           y_right_tap=1*ones(1,numel(x_right_tap)); 
           shutter_right_tap=ones(1,numel(x_right_tap)); shutter_right_tap(1)=0;

        end

        %filing
        M=floor(long/obj.filling_separation);
        x_fill=[];
        y_fill=[];
        z_fill=[];
        shutter_fill=[];

        for j=1:M
            x_fill=[x_fill long/(M+1)*j long/(M+1)*j long/(M+1)*j+0.002 long/(M+1)*j+0.002 long/(M+1)*j+0.004 long/(M+1)*j+0.004];
            y_fill=[y_fill 0 1 0 1 0 1 ];
            shutter_fill=[shutter_fill 0 1 0 1 0 1 ];
            z_fill=[z_fill 0 0 0 0 0 0];
        end

        %genration of overall vectors at origin
        X_GCODE=[x_bottom x_surf1 x_surf2 x_right_tap x_left_tap x_fill x_top];
        Z_GCODE=[z_bottom z_surf1 z_surf2 z_right_tap z_left_tap z_fill z_top ];
        Y_GCODE=[y_bottom y_surf1 y_surf2 y_right_tap y_left_tap y_fill y_top];
        Shutter_GCODE=[shutter_bottom shutter_surf1 shutter_surf2 shutter_right_tap shutter_left_tap shutter_fill shutter_top];



        %starting and ending points
        X_GCODE=[0 X_GCODE 0];
        Z_GCODE=[0 Z_GCODE 0];
        Y_GCODE=[0 Y_GCODE 0];
        Shutter_GCODE=[0 Shutter_GCODE 0];
    

        %shift of y_temp starting point on the optical axis and scaling along y direction

        Y_GCODE=obj.struct_width*Y_GCODE;
        Y_GCODE=Y_GCODE-0.5*obj.struct_width;

        %z axis rotation
        theta=atan((obj.stopY-obj.startY)/(obj.stopX-obj.startX));
        R_z=[cos(theta) -sin(theta); sin(theta) cos(theta)];

        V=R_z*[X_GCODE;Y_GCODE];
        X_GCODE=V(1,:);
        Y_GCODE=V(2,:);

        %translation
        X_GCODE=X_GCODE+ obj.startX;
        Y_GCODE=Y_GCODE+ obj.startY;
        Z_GCODE=Z_GCODE+ obj.startZ;


        %velocoty vector definition
        v_GCODE=[];
        v_GCODE(Shutter_GCODE==0)=obj.vpos;
        v_GCODE(Shutter_GCODE==1)=obj.vcut;  

        
        %GCODE writing time computation
        obj.Writing_Time=GCODE_duration(X_GCODE,Y_GCODE,Z_GCODE,v_GCODE,Shutter_GCODE,obj);
        
    
        end
        
        function obj=header_compile(obj,fileid,varargin)%compile and write in the file the structure header
             
              %% preable containing the data (you can write them down as a header)
          fprintf(fileid, '//%s\n',obj.name);
          %initialization with common properties
          fprintf(fileid, '//vcut=%f startX=%f startY=%f startZ=%f stopX=%f stopY=%f stopZ=%f ',obj.vcut,obj.startX,obj.startY,obj.startZ,obj.stopX,obj.stopY,obj.stopZ);
          %write specific porperties of the calling object
          SpecificProperties=setdiff(properties(class(obj)),properties(BasicStructure));
          if ~isempty(SpecificProperties)
              for i=1:numel(SpecificProperties)
                  
                  if (SpecificProperties{i}=="alpha1")
                        str=strcat("alpha1=[",num2str(obj.alpha1(1)),",",num2str(obj.alpha1(2)),",",num2str(obj.alpha1(3)),"] ");
                  elseif (SpecificProperties{i}=="alpha2")
                      str=strcat("alpha2=[",num2str(obj.alpha2(1)),",",num2str(obj.alpha2(2)),",",num2str(obj.alpha2(3)),"] ");
                  else
                      eval(sprintf('PropValue=obj.%s;',SpecificProperties{i}));
                      str=strcat(SpecificProperties{i},'=',num2str(PropValue)," ");
                  end
                  fprintf(fileid,str);
                  
              end
          end
          fprintf(fileid,'\n');
              
        end
        
        function z_comp=VoxelZCompensation(obj,z_voxel,R,alpha,Num,l)
            %% mathematical compensation of z writing points
            %it evaluate the concavity ofthe aspheric surface and once the second
            %derivative is negative, it shift the writing voxel by a fixed ammount to
            %compensate it enlogment
            nargin
            c = 1./R;
            k=0;

            %computatin of second derivative to evaluate concavity
            z_surf = linspace(-l/2,+l/2,Num); %mm

            x_der= 2*c*z_surf./(sqrt(1-(1+k)*c.^2.*z_surf.^2)+(1-(1+k)*c.^2.*z_surf.^2));

            for ii = 1:numel(alpha)
                x_der = x_der + alpha(ii)*(2*ii).*(z_surf).^(2*(ii)-1);
            end
            
            z_comp=z_surf;
            z_comp(x_der<0)=z_comp(x_der<0)+z_voxel;
 

            end
    end
end
