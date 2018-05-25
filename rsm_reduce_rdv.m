% Minimal reduce operation handle. Unpack (rsm_flatten) inputs, and call pdist
% with the specified distancemetric (default 'euclidean'). Any weight inputs are
% ignored.
%
% reducer = rsm_reduce_rdv(sumfun)
%
% 20171115 J Carlin
function reducer = rsm_reduce_rdv(distancemetric)

if ~exist('distancemetric','var') || isempty(distancemetric)
    distancemetric = 'euclidean';
end

reducer = @(varargin)reducerdv(distancemetric,varargin{:});

function rdv = reducerdv(metric,r,w)

rdv = pdist(rsm_flatten(r)',metric)';
