


function t=GCODE_duration(varargin)
%this program compute the duration of a GCODE program taking as input the
%Bellini's style vectors
if nargin==1
    if size(varargin{1},2)~=8
        fprintf('Wrong input dimensions. Expected array in the shape of [x_GCODE,y_GCODE,z_GCODE,v_GCODE, shutter_GCODE,wait_GCODE,motion_GCODE,radius_GODE], n by 8 matrix \n ')
        return 
    else
        x_GCODE=varargin{1}(:,1);
        y_GCODE=varargin{1}(:,2);
        z_GCODE=varargin{1}(:,3);
        v_GCODE=varargin{1}(:,4);
        shutter_GCODE=varargin{1}(:,5);   
        wait_GCODE=varargin{1}(:,6);
    end
elseif nargin<5
    fprintf('Too few inputs. Format accepted is: (GCODE_array) or (x_GCODE,y_GCODE,z_GCODE,v_GCODE,shutter_GCODE,[wait_GCODE]) \n')
    return
elseif  nargin==5
   x_GCODE=varargin{1};
   y_GCODE=varargin{2};
   z_GCODE=varargin{3};
   v_GCODE=varargin{4};
   shutter_GCODE=varargin{5};   
   wait_GCODE=[];
elseif  nargin==6
   x_GCODE=varargin{1};
   y_GCODE=varargin{2};
   z_GCODE=varargin{3};
   v_GCODE=varargin{4};
   shutter_GCODE=varargin{5};   
   wait_GCODE=varargin{6};
else
    fprintf('Too many inputs. Format accepted is: (GCODE_array) or (x_GCODE,y_GCODE,z_GCODE,v_GCODE,shutter_GCODE,[wait_GCODE]) \n')
end

long_wait_time=0.1;
short_wait_time=0.01;

d_vector=(((x_GCODE(1:end-1)-x_GCODE(2:end)).^2)+((y_GCODE(1:end-1)-y_GCODE(2:end)).^2)+((z_GCODE(1:end-1)-z_GCODE(2:end)).^2)).^(1/2);

t_vector=d_vector./v_GCODE(2:end);

if ~isempty(wait_GCODE)
    t_shutter=sum(wait_GCODE);
else
    shutter_switch=shutter_GCODE(2:end)-shutter_GCODE(1:end-1);
    n_shutter_open=sum(shutter_switch==1);
    t_shutter=nnz(~shutter_GCODE)*2*long_wait_time+n_shutter_open*long_wait_time+(nnz(shutter_GCODE)-n_shutter_open)*short_wait_time;
end

t_write=sum(t_vector);
t=t_write+t_shutter;

end