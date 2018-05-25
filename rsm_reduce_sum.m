% Minimal reduce operation handle. Unpack (rsm_flatten) inputs, and apply sumfun
% (default @mean) with no additional inputs. Any weight inputs are ignored.
%
% reducer = rsm_reduce_sum(sumfun)
%
% 20171115 J Carlin
function reducer = rsm_reduce_sum(sumfun)

if ~exist('sumfun','var') || isempty(sumfun)
    sumfun = @mean;
end

reducer = @(varargin)reducesum(sumfun,varargin{:});

function m = reducesum(sumfun,r,w)

m = sumfun(rsm_flatten(r))';
