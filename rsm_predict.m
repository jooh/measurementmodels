% generate model predictions using a map-reduce pattern. First we iterate over
% the model layers (cell array entries in response), calling resp{x} =
% mapfun(resp{x},weights) on each. Then we iterate over the entries in cell
% array redfun, calling redfun{y}(resp) in each case.
%
% For instance, the default predictions (linear weighting and population-average
% and Euclidean RDV returns is achieved by)
%
% mapfun=@rsm_mapweights
% redfun={@(r,w)pdist(rsm_flatten(r)')',@(r,w)mean(rsm_flatten(r))'};
%
% Another option is to use the function handles from rsm_mapred_euc,
% which are probably more performant if only an RDV return is desired (more
% processing is put in the map part, which tends to speed things up if you are
% working with a large model).
%
% varargout = rsm_predict(response,weights,[mapfun],[redfun])
%
% 20171109 J Carlin
function varargout = rsm_predict(response,weights,mapfun,redfun)

% input handling
if ~exist('mapfun','var') || isempty(mapfun)
    mapfun = @rsm_mapweights;
end
if ~exist('redfun','var') || isempty(redfun)
    redfun={rsm_reduce_rdv('euclidean'),rsm_reduce_sum(@mean)};
end
if ~iscell(redfun)
    redfun = {redfun};
end
nweight = numel(weights);
nresp = numel(response);
assert(nweight >= nresp,'need at least nresp weights');

% map
wresp = cell(size(response));
for respind = 1:nresp
    wresp{respind} = mapfun(response{respind},weights(respind));
end

% reduce
for redind = 1:nargout
    % pass any additional weights beyond nresp to reducer
    varargout{redind} = redfun{redind}(wresp,weights((nresp+1):end));
end
