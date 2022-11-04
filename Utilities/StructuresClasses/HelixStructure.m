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
         obj.name='Helix';
         if nargin==8
             obj.pitch=pitch;
         else
             obj.pitch=0.01;
         end
        end     
    end
end
