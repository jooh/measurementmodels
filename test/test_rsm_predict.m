% Test rsm_predict, rsm_mapred_euc, rsm_mapred_mean.
%
% For full test suite, see rsm_runtests.
%
% 20171115 J Carlin
ncon = 4;
response = {rand(40,20,4),rand(80,100,4)};
w = rand(1,2);

% test default args (weight during map and do all compute at reduce stage)
[rdv,m] = rsm_predict(response,w);
assert(all(size(rdv) == [nchoosek(ncon,2),1]),'output rdv is wrong shape');
assert(all(size(m) == [ncon,1]),'output m is wrong shape');

% test euclidean variant
[eucmap,eucred] = rsm_mapred_euc;
rdvalt = rsm_predict(response,w,eucmap,{eucred});
% have to tolerate some rounding error
assert(max(rdv-rdvalt)<1e-12,'rsm_mapred_euc does not match default euclidean compute');

% test mean variant
[mmap,mred] = rsm_mapred_mean;
malt = rsm_predict(response,w,mmap,{mred});
assert(max(m-malt)<1e-12,'rsm_mapred_mean does not match default mean compute');

