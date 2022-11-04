classdef StraightLine<BasicStructure
    properties
       
    end
    methods
    function obj = StraightLine(startX,startY,startZ,stopX,stopY,stopZ,vcut)
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
         obj.name='Straight line';
         %% Post Initialization %%
         % Any code, including access to object
         obj=obj.LengthCompute();
           
         
    end
    
    function obj=LengthCompute(obj)
        Length=sqrt((obj.startX-obj.stopX)^2+(obj.startY-obj.stopY)^2+(obj.startZ-obj.stopZ));
        obj.Length=Length;
    end
    

    end
end
