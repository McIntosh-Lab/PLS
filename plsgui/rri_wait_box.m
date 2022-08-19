%  Create a waitbox for slow processing
%
%  Usage:
%
%     old_pointer = get(gcbf,'Pointer');
%     set(gcbf,'Pointer','watch');
%
%     h = rri_wait_box(msg, [Width Height], title);
%
%     ...
%
%     set(gcbf,'Pointer',old_pointer);
%     delete(h);
%
%  Example:
%
%     old_pointer = get(gcbf,'Pointer');
%     set(gcbf,'Pointer','watch');
%
%     msg = 'Loading PLS results ...    Please wait!';
%     h = rri_wait_box(msg, [0.5 0.1], 'Loading PLS results');
%
%     ...
%
%     set(gcbf,'Pointer',old_pointer);
%     delete(h);
%

%  Created by Wilkin
%  Modified by Jimmy
%
%---------------------------------------------------------------
function h0 = rri_wait_box(varargin);

   Message = varargin{1};
   DiagWH = varargin{2};

   if nargin > 2
      tit = varargin{3};
   else
      tit = '';
   end

   diag_w = DiagWH(1);
   diag_h = DiagWH(2);
   diag_x = (1 - diag_w)/2;
   diag_y = (1 - diag_h)/2;

   diag_pos = [diag_x diag_y diag_w diag_h];
   
   h0 = figure('Units','normal', ...
                'Menubar', 'none', ...
                'Resize', 'off', ...
                'NumberTitle', 'off', ...
                'WindowStyle', 'normal', ...
		'Color', [0.8 0.8 0.8], ...
                'Position', diag_pos, ...
		'Pointer','watch', ...
                'Name', tit, ...
                'Tag', 'WaitDialog');

   x = 0.05;
   y = 0.1;
   w = 0.9;
   h = 0.6;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
		'unit','normal', ...
   		'Position', pos, ...
		'Background', [0.8 0.8 0.8], ...
   		'Style', 'text', ...	
		'fontunit','point', ...
   		'FontSize', 14, ...
   		'String', Message);

%                'fontunit','normal', ...
%                'FontSize', 0.35, ...
%   	         'FontWeight', 'bold', ...

   drawnow;

   return;					% rri_wait_box

