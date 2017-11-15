% flatten the input x to 2D by collapsing dimensions 1:end-1. Cell array inputs
% are unpacked and a single matrix is returned. Useful for unpacking high-D model
% responses (e.g. {x by y by filter by image}) to 2D.
%
% x = rsm_flatten(x)
%
% 20171109 J Carlin
function x = rsm_flatten(x)

if iscell(x)
    for n = 1:numel(x)
        x{n} = rsm_flatten(x{n});
    end
    x = cat(1,x{:});
    return
end

if ndims(x)>2
    sz = size(x);
    nfeat = prod(sz(1:end-1));
    x = reshape(x,[nfeat,sz(end)]);
end
