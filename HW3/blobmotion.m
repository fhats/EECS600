function M = blobmotion(n, x0, dx, varargin)
% M = blobmotion(N, X0, DX, OPTIONS) renders the motion of a blob which can
% be a Gaussian or bar (see the 'shape' option below).  The rendered motion
% is returned in a 3D matrix.  The pixel values are scaled so that the
% center has value 1.  Note that the rendering does not do antialiasing.
% If high precision at small grid sizes is desired, render at a larger grid
% size and downsample.
%
% INPUTS:
% N             grid size.  A scalar specifies a grid size of N x N.  A
%               vector specifies a grid of N(1) columns by N(2) rows.
%
% X0            starting location of blob in normalized coordinates.  For a
%               square grid, (0,0) is the center, (-1,1) is the lower left
%               corner, and (1,1) is the upper right.  For non-square grid
%               the upper right is (width/height,1), and the upper left is
%               (-width/height,1).
% 
% DX            velocity vector (with respect to x0).  The magnitude of
%               DX specifies the speed, and is the distance moved in one
%               second in normalized coordinates.
%
% OPTIONS can be the following parameter value/pairs:
% 'fps'         frames per second of the movie M (default 15)
%
% 'dur'         duration of the movie in seconds (default 1)
%
% 'shape'       shape of the blob.  Can be 'Gaussian', 'grating', or 'bar'
%               (default 'Gaussian').  The parameters for the shapes are:
%
%     Guassian:
%     'Sigma'   shape of Gaussian blob in normalized units (default 0.1).
%               A scalar value describes a circular Gaussian; A value of
%               [sigma1, sigma2, theta] describes the major and minor
%               standard deviations and axis rotation, counter clockwise
%               from the positive x axis.  A [2,2] matrix specifies the
%               Gaussian covariance matrix directly.
% 
%     bar:
%     'size'    vector containing bar width and height in normalized units.
%
%     'angle'   angle of bar, counter clockwise from the positive x axis.
%               An angle of 0 gives and a size of [0.1,0.3] gives a
%               vertical bar.
%
% Some options for debuging motion signals:
%
% 'plotBlobCenters'    true | {false} - plot the blob center points.
%
% 'plotBarBoundaries'  true | {false} - plot the real-valued bar boundaries
%
%
% OUTPUT:
% M             a matrix movie containing the frames of the blob motion.
%
% Examples:
%
%     M = blobmotion(50, [-1,-1], [2,2]);
%     mmplay(M);
%
% Generates a Gaussian blob that moves from the lower left to the upper
% right.  The default settings specify a blob with std dev of 10% of the
% grid and a movie duration of 1 second at 15 frames per second.
%
%
%     M = blobmotion(50, [-0.5,0], [1,0], 'shape','bar');
%
% Generates a right drifting vertical bar.
%
%
% NOTES
%
% At small grid sizes, there can be significant variation in the pixel
% intensity values due to the alignment of the blob and the grid.
% For example:
%
%     M = blobmotion(15, [0,0], [1,1], 'fps', 7);
%     mmplay(M,'fps',2);
%
% results in a blob that moves exactly one pixel up and one pixel right
% each from, so the values of the blob itself don't change.  If we change
% the framerate, however, there is significant variation in the blob from
% frame to frame:
%
%     M = blobmotion(10, [0,0], [1,1], 'fps', 15);
%     mmplay(M,'fps',2);
%

% Michael Lewicki, March 2004

% TODO:
% - add antialiasing code
% 'antialias'   scale factor F for doing antialias.  If specified, the
%               motion is rendered on a grid of size N*F and then
%               downsampled to size N.

% Other ideas:
% - add a Gabor blob
% - add circle and ellipse code, but thresholding a Gaussian
% - allow specification of duration in frames

debugFlag = 0;

if (nargin < 3)
  error('Too few input arguments');
end

if length(n) == 1
    nr = n; nc = n;
else
    nr = n(2); nc = n(1);
end

% The code here is based on exportfig
paramPairs = {varargin{:}};
if nargin > 3
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
def.fps = 15;
def.dur = 1;
def.shape = 'Gaussian';
def.Sigma = 0.1;
def.angle = 90;
def.size = [0.3, 0.1];
def.plotBlobCenters = 'false';
def.plotBarBoundaries = 'false';

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
        case 'fps',                opts.fps = val;
        case 'dur',                opts.dur = val;
        case 'shape',              opts.shape = val;
        case 'sigma',              opts.Sigma = val;
        case 'angle',              opts.angle = val;
        case 'size',               opts.size = val;
        case 'plotblobcenters',    opts.plotBlobCenters = val;
        case 'plotbarboundaries',  opts.plotBarBoundaries = val;
	otherwise
	    error('Unknown parameter name');
    end
end

nframes = opts.fps * opts.dur;
if nframes > 1
    tstep = opts.dur/nframes;
    tset = 0:tstep:opts.dur;
else
    tset = 0;
end
        
if length(opts.Sigma) == 1
    Sigma = [opts.Sigma^2, 0; 0, opts.Sigma^2];
elseif length(opts.Sigma) == 3
    theta = opts.Sigma(3);
    [s11,s21] = pol2cart(theta, opts.Sigma(1)^2);
    [s21,s22] = pol2cart(theta+pi/2, opts.Sigma(2)^2);
    Sigma = [s11,s21;s21,s22];
elseif size(opts.Ssigma) == [2,2]
    Sigma = opts.Sigma;
else
    error('Invalid size for Sigma\n');
end

[px,py] = mmpixelcoords(nr,nc);
X = [px(:),py(:)];

M = zeros(nr,nc,nframes);

if strcmp(opts.shape, 'Gaussian')
    z0 = mvnpdf([0,0], [0,0], Sigma);
else
    z0 = 1;
end

if strcmp(opts.plotBlobCenters, 'true')
    mmplay(0.5 + M(:,:,1), 'mode', 'surf');
    hold on;
    for i = 1:nframes
        t = tset(i);
        mu = x0 + dx*t;
        plot(mu(1), mu(2), 'yd');
    end
    hold off
end

for i = 1:nframes
    t = tset(i);
    mu = x0 + dx*t;

    switch lower(opts.shape)
        case 'gaussian'
            Z = mvnpdf(X, mu, Sigma);
        case 'bar'
            Z = barfn(X, mu, opts.size, opts.angle, nr, nc, ...
                opts.plotBarBoundaries);
        otherwise
            error('Unknown shape value');
    end

    Z = Z / z0;                  % normalize by the center value
    Z = reshape(Z,nr,nc);
    M(:,:,i) = Z;

    % To convert a frame to a movie:
    % I = repmat(Z,[1,1,3]);
    % M(i) = im2frame(I);

    if debugFlag
        fprintf('t=%g mu=[%g, %g]\n', t,mu(1),mu(2));
    end
end

% an oriented bar
function Z = barfn(X, mu, barsize, theta, nr, nc, plotBoundaries)

w = barsize(1); h = barsize(2);

% rotate by -theta around mu to get coordinates aligned to bar
[TH, R] = cart2pol(X(:,1) - mu(1),X(:,2) - mu(2));
[xp,yp] = pol2cart(TH - pi*theta/180, R);

Xp = [xp,yp];

baridx = find(...
    Xp(:,1) <=  w/2 & Xp(:,1) >= -w/2 & ...
    Xp(:,2) <=  h/2 & Xp(:,2) >= -h/2);
Z = zeros(size(X,1),1);
Z(baridx) = 1;

if strcmp(plotBoundaries,'true')
    M = reshape(Z,nr,nc);
    mmplay(0.5 + M, 'mode', 'surf');
    hold on;
    bx = [-w/2, -w/2, w/2,  w/2, -w/2];
    by = [-h/2,  h/2, h/2, -h/2, -h/2];
    [bth,br]  = cart2pol(bx,by);
    [rbx,rby] = pol2cart(bth + pi*theta/180, br);

    line(mu(1) + rbx, mu(2) + rby, 'Color', 'b', 'LineWidth', 2);
    plot(mu(1), mu(2), 'bd');
    hold off
    drawnow;
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
