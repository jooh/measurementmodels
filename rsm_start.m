% rsm_start()
function rsm_start()

rsmdir = fileparts(mfilename('fullpath'));
if ~any(strfind(path,rsmdir))
    fprintf('adding RSM dir to path: %s\n',rsmdir);
    addpath(rsmdir);
end
