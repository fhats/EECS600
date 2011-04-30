function mmplay(M,varargin)
% mmplay(M,OPTIONS) plots the successive frames in matrix M.  The movie
% is given as a matrix of size [m,n,nframes] and is assumed to be
% grayscale and lie in the range [0,1].  OPTIONS specifies additional
% option/value pairs, described below.
%
% INPUTS:
%
% M             movie matrix.
%
% OPTIONS:
%
% 'fps'         frames per second (default 15)
%
% 'scale'       scaling factor for plotting movie pixels.  A scale of 1
%               specifies that one movie pixel should correspond to one
%               screen pixel.  In a scale of two, one movie pixel is
%               plotted with four screen pixels.  If unspecified, the
%               default is the default is to use the current axes
%               dimensions.
%
% 'mode'        plotting mode: 'image' or 'surf'.  'image' uses the
%               function IMAGE to plot the movie without axes.  This is
%               more appropriate for when the movie sizes are large.
%               'surf' uses the function SURF to plot the movie along
%               with the axes.  This mode is only practical when individual
%               pixels are clearly visible.  The default is 'image'.
% 'axismode'    {normal} | index  - In 'surf' mode, determines whether
%               the axis units are in normalized units or are the index
%               units of the movie matrix.
%
% 'imageopts'   option value pairs passed to IMAGE.
%
% 'surfopts'    option value pairs passed to SURF.
%
% 'exportopts'  option value pairs passed to exportfig.  If specified, the
%               figure for each frame in the movie is exported via
%               EXPORTFIG.  See the examples below for useful options.  To
%               write just the movie frames without the matlab axes, use
%               the function MMWRITE.
%
% 'exportdir'   directory for the frame files (default current directory).
%
% 'exportbase'  base file name for framtese files (default 'frame').
%
% 'exportfmt'   format for exported frame files (default 'png').  The
%               options are the same as for the EXPORTFIG which are the
%               same as PRINT.  It is not necessary to specfiy the format
%               again in exportopts.  There are a couple Matlab quirks when
%               exporting to eps files (ie setting exportfmt to 'eps'). If
%               the mode is 'image', the eps images are smoothed, which
%               especially visible for small grid sizes.  I do not know how
%               to turn this off.  When the mode is set to 'surf', there is
%               no distortion, but faint diagonal lines appear across the
%               pixels.  This is apparently a Matlab bug.
%               
%
% Examples:
%
% Play a movie of a Gaussian blob, scaling the pixels by 2
%
%    M = blobmotion(100, [-0.5,-0.5], [1,1], 'dur',1, ...
%        'shape','Gaussian', 'size', 0.25);
%    M = 0.5 + 0.5*M;
%    mmplay(M, 'scale', 2);
%
% Make a smaller blob with visible pixels and index units:
%
%    M = blobmotion(15, [-0.5,-0.5], [1,1], 'dur', 1, ...
%        'shape','Gaussian', 'size', 0.25);
%    M = 0.5 + 0.5*M;
%    mmplay(M, 'mode', 'surf', 'axismode', 'index');
%
% Write 3 inch high, eps movie for inclusion in a publication:
%
%    mmplay(M, 'mode', 'surf', 'exportfmt', 'eps', 'exportopts', ...
%    {'bounds','loose', 'height',3, 'fontmode','fixed', 'fontsize',10});
%
% Write 256x256 frames of movie for including in a presentation:
%
%    pos = get(gcf,'Position');
%    set(gcf, 'Position', [pos(1) pos(2) 256 256]);
%    mmplay(M, 'mode', 'surf', 'exportopts', {'bounds','loose'});
%
% Note that we use loose bounds, because tight bounds will change the
% exported resolution slightly, due to the margins.  Tighter bounds can be
% achieved by settng the margins manually.

% Michael Lewicki March 2004

debugFlag = 0;
nGrayVals = 256;

if (nargin < 1)
  error('Too few input arguments');
end

nframes = size(M,3);

% The code here is based on exportfig
paramPairs = {varargin{:}};
if nargin > 1
  if isstruct(paramPairs{1})
    pcell = LocalToCell(paramPairs{1});
    paramPairs = {pcell{:}, paramPairs{2:end}};
  end
end

% Do some validity checking on param-value pairs
if (rem(length(paramPairs),2) ~= 0)
  error(['Invalid input syntax. Optional parameters and values' ...
	 ' must be in pairs.']);
end

% set default values
def.fps  = 15;
def.scale = [];
def.mode = 'image';
def.axismode = 'normal';
def.imageopts = [];
def.surfopts = [];
def.exportopts = [];
def.exportdir = [];
def.exportbase = 'frame';
def.exportfmt = 'png';

opts = def;

% Process param-value pairs
args = {};
for k = 1:2:length(paramPairs)
    param = lower(paramPairs{k});
    if ~ischar(param)
        error('Optional parameter names must be strings');
    end
    val = paramPairs{k+1};
  
    switch param
        case 'fps',            opts.fps = val;
        case 'scale',          opts.scale = val;
        case 'mode',           opts.mode = val;
        case 'axismode',       opts.axismode = val;
        case 'imageopts',      opts.imageopts = val;
        case 'surfopts',       opts.surfopts = val;
        case 'exportopts',     opts.exportopts = val;
        case 'exportdir',      opts.exportdir = val;
        case 'exportbase',     opts.exportbase = val;
        case 'exportfmt',      opts.exportfmt = val;
	otherwise
	    error('Unknown parameter name');
    end
end

% Set figure properties for flash-free animation
set(gcf, 'DoubleBuffer', 'on');

nr=size(M,1); nc=size(M,2);
ar = nc/nr;
h = 1/(nr-1);

if strcmp(lower(opts.mode),'surf')
    [lx,ly] = mmlatticecoords(nr,nc);
    lz = zeros(size(lx));
end

if ~isempty(opts.exportdir)
    cmd = sprintf('mkdir %s', opts.exportdir);
    [w,s] = system(cmd);
    exportbasefile = sprintf('%s/%s', export.dir, opts.exportbase);
else
    exportbasefile = opts.exportbase;
end

for i=1:nframes
    t0=clock;
    switch lower(opts.mode)
        case 'image'
            if i > 1
                set(imageh,'CData', nGrayVals*M(:,:,i));
            else
                imageh = image(nGrayVals*M(:,:,i), 'EraseMode','none');
                axis off; colormap(gray(nGrayVals));
                if ~isempty(opts.scale)
                    fpos = get(gcf,'Position');
                    fw = fpos(3); fh = fpos(4);
                    mw = opts.scale*nc; mh = opts.scale*nr;
                    if (mw > fw || mh > fh)
                        set(gcf,'Position', [fpos(1), fpos(2), mw, mh]);
                    end
                    hm = (fw-mw)/2; vm = (fh-mh)/2;

                    set(gca,'Units', 'pixels', 'Position', [hm vm mw mh]);
                else
                    axis image;
                end
                if ~isempty(opts.imageopts)
                    set(imageh,opts.imageopts{:});
                end
                drawnow;
                sumdt=0; tstart=clock;
            end

        case 'surf'
            % Use grayscale because Matlab eps does not support rgb color
            % c = repmat(M(:,:,i), [1,1,3]);

            c = M(:,:,i);

            if i > 1
                set(surfh,'CData', c);
            else
                surfh = surf(lx,ly,lz,c,'EraseMode','none');
                set(gca,'View',[0,90]);
                axis on; axis equal;
                set(gca,'CLim', [0,1])
                colormap(gray(nGrayVals));

                % Don't draw pixel borders if pixels are too small
                origunits = get(gca,'Units');
                set(gca,'Units', 'pixels');
                ap = get(gca, 'Position');
                xpixelsize = ap(3)/nc;
                if xpixelsize < 4
                    shading flat;
                end
                set(gca,'Units',origunits);

                xlim = [-ar-h, ar+h];
                ylim = [ -1-h,  1+h];
                set(gca,'XLim', xlim,'YLim', ylim);
                grid off; box off;
                set(gca,'TickDir', 'out');

                if strcmp(opts.axismode, 'index')
                    nxt = length(get(gca,'XTick'));
                    nyt = length(get(gca,'YTick'));
                    xtlab = 1:ceil(nc/nxt):nc;
                    ytlab = 1:ceil(nr/nyt):nr;
                    xt = 2*(xtlab-1)/(nc-1) - 1;
                    yt = 2*(ytlab-1)/(nr-1) - 1;
                    set(gca,'XTick', xt, 'XTickLabel', xtlab);
                    set(gca,'YTick', yt, 'YTickLabel', ytlab);
                end

                if ~isempty(opts.surfopts)
                    set(surfh,opts.surfopts{:});
                end
                drawnow;
                sumdt=0; tstart=clock;
            end
            
        otherwise
            error('Unknown mode');
    end
    drawnow;
    
    if ~isempty(opts.exportopts)
        % Export the frame to a file using EXPORTFIG
        exportfile=sprintf('%s_%03d.%s',exportbasefile, i, opts.exportfmt);
        opts.exportopts = {'format', opts.exportfmt, opts.exportopts{:}};
        fprintf('Exporting frame %d to %s\n', i, exportfile);
        exportfig(gcf, exportfile, opts.exportopts{:});
    end

    while (1)
        dt = etime(clock,t0);
        if (dt >= 1/opts.fps)
            sumdt = sumdt + dt;
            break;
        end
    end
end

if debugFlag
    fprintf('dur = %g secs   avg fps = %g\n', ...
        etime(clock,tstart), size(M,3)/sumdt);
end