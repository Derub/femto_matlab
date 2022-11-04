classdef BasicAblationStructure<BasicStructure
    properties
        
       
    end
    methods
  function obj = BasicAblationStructure(startX,startY,startZ,stopX,stopY,stopZ,vcut)%BasicStructure constructor
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
            obj.name='Ablation Basic Structure';
           
        end
   
        
        function obj=S_plot(obj,ax,varargin) %surface plot of the object
            X=[obj.startX obj.stopX];
            Y=[obj.startY obj.stopY];
            Z=[obj.startZ obj.stopZ];
            if nargin==1
                h=plot3(X,Y,Z,'r');
                                
            elseif nargin==2
                h=plot3(ax,X,Y,Z,'r');
                                 
            elseif nargin>2
                 h=plot3(ax,X,Y,Z,varargin{:});
                 
            end
            obj.hGraph=h;
        end
 
        function hObj=ChangeSurfColor(obj,flag)
            %if flag is not used or >1, the color is switched
            %otherwise flag=0 means blues surface, flag=1 means yellow
            %surface
            class(obj.hGraph)
           
           
            if nargin<2
                flag=2; %the user whant to switch the color
            else
                if isa(obj.hGraph,'matlab.graphics.chart.primitive.Surface')|isa(obj.hGraph,'matlab.graphics.primitive.Patch')
                    for i=1:numel(obj.hGraph)
                        color=obj.hGraph(i).FaceColor;
                        if flag==0
                            obj.hGraph(i).FaceColor='r';
                            obj.hGraph(i).EdgeColor='r';
                            hObj=[]

                        elseif flag==1
                            obj.hGraph(i).FaceColor=[0.9290 0.6940 0.1250];
                            obj.hGraph(i).EdgeColor='yellow';
                            hObj=findobj(obj);
                        else   
                            if (color==[1 1 0])
                                obj.hGraph(i).FaceColor='r';
                                obj.hGraph(i).EdgeColor='r';
                                hObj=[];
                            elseif (color==[0 1 1])
                                obj.hGraph(i).FaceColor=[0.9290 0.6940 0.1250];
                                obj.hGraph(i).EdgeColor='yellow';
                                hObj=findobj(obj);
                            end
                        end
                    end
                elseif isa(obj.hGraph,'matlab.graphics.chart.primitive.Line')
                    color=obj.hGraph.Color;
                    if flag==0
                        obj.hGraph.Color=[1 0 0];
                            hObj=[];
                    elseif flag==1
                         obj.hGraph.Color=[1 1 0];
                            hObj=findobj(obj);
                    else   
                        if (color==[1 1 0])|(flag==0)
                            obj.hGraph.Color=[1 0 0];
                            hObj=[];
                        elseif (color==[1 0 0])|(flag==0)
                            obj.hGraph.Color=[1 1 0];
                            hObj=findobj(obj);
                        end
                    end
                elseif isa(obj.hGraph,'matlab.graphics.primitive.Group') 
                    
                    lines=obj.hGraph.Children;
                    color=lines.Color;
                    for i=1:size(lines,1)
                       
                        if flag==0
                            lines(i).Color=[1 0 0];
                                hObj=[];
                        elseif flag==1
                            
                             lines(i).Color=[1 1 0];
                                hObj=findobj(obj);
                        else   
                            if (color==[1 1 0])|(flag==0)
                                lines(i).Color=[1 0 0];
                                hObj=[];
                            elseif (color==[1 0 0])|(flag==0)
                                lines(i).Color=[1 1 0];
                                hObj=findobj(obj);
                            end
                        end 
                    end
                end
            end
       
        
        end
    end
    
end
