% Map-reduce pattern to estimate mean responses. Returns the
% following handles, which are suitable as plugins to e.g. rsm_predict:
%
% sqsum = mmap(resp,w);
% % weight ND matrix resp by w (after applying rsm_flatten), return sum over
% features and size of feature dim
%
% mreduce(respc,w)
% % sum the means in respc, divide by the sum of the feature dim sizes. w input
% is ignored.
%
% [mmap,mreduce] = rsm_mapred_mean()
% 
% 20171114 J Carlin
function [mmap,mreduce] = rsm_mapred_mean()

mmap = @map;
mreduce = @reduce;

function sc = map(resp,w)

resp = rsm_mapweights(resp,w);
sc = {sum(resp,1),size(resp,1)};

function m = reduce(xc,w)

xc = vertcat(xc{:});
m = (sum(vertcat(xc{:,1})) ./ sum(vertcat(xc{:,2})))';
