% Map-reduce pattern to estimate Euclidean distance matrix. Returns the
% following handles, which are suitable as plugins to e.g. rsm_predict:
%
% sqsum = eucmap(resp,w);
% % weight ND matrix resp by w (after applying rsm_flatten), estimate sum of
% squares for all pairwise comparisons 
%
% eucred(respc,w)
% % vertically concatenate all the inputs in cell array respc, sum and 
% square root. w input is ignored.
%
% [eucmap,eucred] = rsm_mapred_euc()
% 
% 20171109 J Carlin
function [eucmap,eucred] = rsm_mapred_euc()

eucmap = @map;
eucred = @reduce;

function sqsum = map(resp,w)

resp = rsm_mapweights(resp,w);
cons = allpairwisecontrasts(size(resp,2));
sqsum = sum((resp * cons').^2);

function euc = reduce(respc,w)

euc = sqrt(sum(vertcat(respc{:}),1))';
