% Minimal map handle to unpack (with rsm_flatten) and linearly scale the
% responses in resp by applying w as a scale factor. Useful as an input to e.g.
% rsm_predict.
%
% resp =rsm_mapweights(resp,w)
%
% 20171114 J Carlin
function resp =rsm_mapweights(resp,w)

resp = rsm_flatten(resp) * w;
