function mmwrite(M, varargin)
% mmwrite(M, FRAMEDIR) writes the frames contained in the matrix M to the
% FRAMEDIR directory.  If FRAMEDIR is not given, the frame files are
% written to the current directory.  Pre-existing files are overwritten.
% FRAMEDIR can be followed by parameter/value pairs:
%
% 'basename'    base name for frame files (default 'frame')
%
% 'framedir'    directory to write the files to (default current)
%
% 'fmt'         format of frame files (see FMT in the IMWRITE function,
%               default 'png').
%
% 'fmtopts'     options for IMWRITE (default is the defaults of IMWRITE).
%
% 'scale'       pixel scale factor N (default 1).  This scales the image by
%               a factor of N, by replacing each pxiel with a NxN pixels of
%               the same value.  This is useful for scaling up movies on
%               small grids and avoiding scaling artifacts in pdflatex.

% Michael Lewicki, March 2004

debugFlag = 0;

if (nargin < 1)
  error('Too few input arguments');
end

% The code here is based on exportfig
paramPairs = {varargin{:}};
if nargin > 2
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

def.basename = 'frame';
def.framedir = [];
def.fmt = 'png';
def.fmtopts = [];
def.scale = 1;

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
        case 'basename',  opts.basename = val;
        case 'framedir',  opts.framedir = val;
        case 'fmt',       opts.fmt = val;
        case 'fmtopts',   opts.fmtopts = val;
        case 'scale',     opts.scale = val;
    end
end

if opts.scale > 1
    for t = 1:size(M,3)
        Ms(:,:,t) = repelt(squeeze(M(:,:,t)), opts.scale);
    end
    M = Ms;
end

if ~isempty(opts.framedir)
    cmd = sprintf('mkdir %s', opts.framedir);
    [w,s] = system(cmd);
    basefile = sprintf('%s/%s', opts.framedir, opts.basename);
else
    basefile = opts.basename;
end

for i = 1:size(M,3)
    fname = sprintf('%s_%03d.%s',basefile, i, opts.fmt);

    if debugFlag
        fprintf('Writing frame %i to %s\n', i, fname);
    end
    
    if ~isempty(opts.fmtopts)
        imwrite(M(:,:,i), fname, opts.fmt, opts.fmtopts{:});
    else
        imwrite(M(:,:,i), fname, opts.fmt);
    end
end

% A function to convert a struct to {field1,val1,field2,val2,...}
% (from exportfig)

function c = LocalToCell(s)
f = fieldnames(s);
v = struct2cell(s);
opts = cell(2,length(f));
opts(1,:) = f;
opts(2,:) = v;
c = {opts{:}};