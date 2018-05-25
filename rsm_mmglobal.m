% meas = rsm_mmglobal(resp,a)
function meas = rsm_mmglobal(resp,a)

meas = rsm_flatten(resp);

meas = morph(meas,mean(meas,2),a);
