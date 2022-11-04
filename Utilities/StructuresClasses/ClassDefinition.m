%% script to define classes for mainwriting

classdef BasicStructure
    properties
        vcut
        startX
        stopX
        startY,stopY
        startZ,stopZ
        Length
        approx_writing_time
    end
    methods
        function obj = BasicStructure(startX,startY,startZ,stopX,stopY,stopZ,vcut)
             if nargin == 0
                obj.startX=0;
                obj.startY=0;
                obj.startZ=0;
                obj.stopX=1;
                obj.stopY=1;
                obj.stopZ=1;
                obj.vcut=1;
                
             elseif nargin == 6
                obj.startX=startX;
                obj.startY=startY;
                obj.startZ=startZ;
                obj.stopX=stopX;
                obj.stopY=stopY;
                obj.stopZ=stopZ;
                obj.vcut=1;
                
             elseif nargin ==7
                obj.startX=startX;
                obj.startY=startY;
                obj.startZ=startZ;
                obj.stopX=stopX;
                obj.stopY=stopY;
                obj.stopZ=stopZ;
                obj.vcut=vcut;
                
           else
             error('Wrong number of input arguments')
           end
        end
    end
end

classdef StraighLine<BasicStructure
    methods
    function obj = StraighLine(startX,startY,startZ,stopX,stopY,stopZ,vcut)
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
         elseif nargin == 3
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = stopX;
            args{5} = stopY;
            args{6} = stopZ;
            args{7}=vcut;
         else
             error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         obj = obj@BasicStructure(args{:});
         
         %% Post Initialization %%
         % Any code, including access to object
         obj.Length=sqrt((args{1}(1)-args{2}(1))^2+(args{1}(2)-args{2}(2))^2+(args{1}(3)-args{2}(3))^2);
         obj.approx_writing_time= obj.Lenght/obj.vcut;        
         
    end
    end
end

classdef HelixStructure<BasicStructure
    properties
        pitch
    end
    methods
        function obj = HelixStructure(startX,startY,startZ,stopX,stopY,stopZ,vcut,pitch)
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
         elseif nargin == 3
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = stopX;
            args{5} = stopY;
            args{6} = stopZ;
            args{7}=vcut;
         else
             error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         obj = obj@BasicStructure(args{:});   
         
         if nargin==8
             obj.pitch=pitch;
         else
             obj.pitch=0.01;
         end
         
    end
end


classdef CylindricalStructure<HelixStructure
    properties
        step
    end
    methods
        function obj = CylindricalStructure(startX,startY,startZ,stopX,stopY,stopZ,vcut,pitch,step)
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
         elseif nargin ==9 
              elseif nargin == 7
            args{1} = startX;
            args{2} = startY;
            args{3} = startZ;
            args{4} = stopX;
            args{5} = stopY;
            args{6} = stopZ;
            args{7}=vcut;
            args{8}=pitch;
            
         else
             error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         obj = obj@HelixStructure(args{:});   
         
         if nargin==9
             obj.step=step;
         else
             obj.step=0.01;
         end
         
    end
end



classdef ConicalHelix<CylindricalStructure
    properties
        diameter_in
        diameter_fin
    end
    methods
        function obj = CylindricalStructure(startX,startY,startZ,stopX,stopY,stopZ,vcut,pitch,step,d_in,d_fin)
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
         else
             error('Wrong number of input arguments')
         end
                  
         %% Object Initialization %%
         % Call superclass constructor before accessing object
         % You cannot conditionalize this statement
         obj = obj@HelixStructure(args{:});   
         
         if nargin==10
             obj.diameter_in=d_in;%case of cylindrical Hellix: d_in=d_fin
             obj.diameter_fin=d_in
         elseif nargin==11
             obj.diameter_in=d_in;
             obj.diameter_fin=d_fin;
         else
             obj.diameter_in=0.1;
             obj.diameter_fin=0.1;
         end
         
         %Length computation
         %time computation
    end
    end
end



classdef EllipticalConicalHelix<CylindricalStructure
    properties
        win
        hin
        wfin
        hfin
        theta
    end
end

classdef EllipticalHelix<CylindricalStructure
    properties
        witdh
        height
        theta
    end
end

classdef BoxHelix<HelixStructure
    properties 
        witdh
        height
        theta
        dw
        dh
    end
end




