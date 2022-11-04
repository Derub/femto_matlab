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
         obj.name='Circular helix';
         if nargin==9
             obj.step=step;
         else
             obj.step=0.01;
         end
        end
        
        
    end
end
