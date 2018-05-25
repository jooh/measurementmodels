% fit data as linear combination of pattern rdv(s) and meanrdv(s). If you enter a
% single single mean rdv we do standard multiple regression fit. If you enter
% multiple mean RDVs we assume they are yoked to the pattern rdvs, and we
% perform iterative fitting to boil all those means down to a single set of
% estimates (ie, we fit the patterns, weight the betas to construct a single
% mean rdv, fit that with multiple regression, keep iterating until the
% parameter estimates converge).
%
% NB we assume all inputs can be linearly combined, ie, are squared euclidean or
% similar.
%
% b = rsm_fitmean(datardv,patternrdv,meanrdv,startb)
function b = rsm_fitmean(datardv,patternrdv,meanrdv,startb)

[ndis,npattern] = size(patternrdv);
[ndismean,nmean] = size(meanrdv);
[ndisdata,ndata] = size(datardv);
assert(ndata==1,'only support for a single data rdv at present');
assert(all(ndis == [ndismean,ndisdata]),...
    'datardv,patternrdv and meanrdv must have same number of rows');
assert(all(patternrdv(:))>=0 && all(meanrdv(:)>=0),...
    'patternrdv and meanrdv must be non-negative');

if nmean==1
    % easy
    b = [patternrdv meanrdv] \ datardv;
    return
end

if ~exist('startb','var') || isempty(startb)
    startb = rand([npattern,1]);
end


convcrit = 1-1e-12;
niter = 0;
b = startb;
done = false;
while ~done
    niter = niter+1;
    assert(niter < 1e3,'did not converge');
    % keep track of the old betas
    startb = b;
    % fix mean to current pattern betas
    newmean = meanrdv * startb(1:npattern);
    % get new betas (including one final b for the pooled mean
    b = rsm_fitmean(datardv,patternrdv,newmean);
    if (corr(b(1:npattern),startb(1:npattern))^2 > convcrit)
        done = true;
    end
end
