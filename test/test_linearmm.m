% test rsm_fitmean, rsm_fitmean, etc. Basically linear ways to achieve a global
% MM style fit.
%
% For full test suite, see rsm_runtests.
%
% TODO: 
% * non-negative fit
% * effect of adding noise
%
% 20171121 J Carlin
%
% test_linearmm()

function test_linearmm()

nlayer = 10;
nfeat = repmat(50,[1,nlayer]);
precision = 1e-12;
mmyhatprecision = 0.02; % 1-correlation threshold
% much less stable, especially when we simulate collinearity
mmweightprecision = 0.1; % 1-correlation threshold
% make sure weights are well away from zero so the parameter estimates remain
% positive even with measurement effect in there.
weights = 1+rand(nlayer,1);

% run tests for the standard case
logstr('running test with fixed nfeat over layers...\n');
runtests(weights,precision,mmyhatprecision,mmweightprecision,nfeat);
logstr('succeeded.\n')

% what about if the dimensionality varies between layers?
nfeat = ceil(rand(1,nlayer) * 1000);
logstr('running test with varied nfeat over layers...\n');
runtests(weights,precision,mmyhatprecision,mmweightprecision,nfeat);
logstr('succeeded.\n')

function runtests(weights,precision,mmyhatprecision,mmweightprecision,nfeat);

%% Test linear fit methods
ncon = 24;
eucsq = @(x,y)sum((bsxfun(@minus,x,y)).^2,2);
% can also explore correlation distance, which doesn't work
metric = eucsq;
% so to start with, can we recover the weights (ie, is scaling the responses
% equivalent to scaling the rdvs)
% insert a common factor to insert a bit of collinearity. Doesn't actually
% matter.
commonfactor = rand(ncon,max(nfeat));
for layind = 1:numel(weights)
    % model RDV before scaling
    responses = (rand(ncon,nfeat(layind)) + commonfactor(:,1:nfeat(layind)))/2;
    modelrdv(:,layind) = pdist(responses,metric)';
    % then measurement with scaling to construct data
    measurements{layind} = responses * weights(layind);
    meanrdv(:,layind) = pdist(mean(responses,2), metric)';
end
measurements = horzcat(measurements{:});
datardv = pdist(measurements, metric)';

% if we know the weights, we should be able to perfectly predict the data rdv
% as a linear combination of the layers
assert(corr(datardv, modelrdv * weights.^2)>(1-precision),...
    'data generation failed');

% to find the weights, we use OLS regression
b = modelrdv \ datardv;
% and that should perfectly recover the true weights
assert(max(abs(sqrt(b)-weights)) < precision,...
    'linear map does not recover model weights');
% and if we know the weights, you can predict the data rdv (bit redundant)
assert(corr(datardv,modelrdv * b)>(1-precision),...
    'linear fit did not account for data');

%% Test measurement model regression
% Translate the measurements toward their average (which NB is different from
% the average of the raw model responses before weighting).
measurements_av = rsm_mmglobal(measurements,.5);
% Construct a new rdv which includes measurement effect
datardv_av = pdist(measurements_av, metric)';

% handle the case where we know the true population mean effect
% First treat the overall mean RDV as a linear combination of the layer RDVs
truemeanrdv = pdist(mean(measurements,2), metric)';
assert(max(truemeanrdv - (meanrdv * weights.^2))<precision,...
    'mean RDV differs from linear reconstruction');

% Now let's fit a contrived case where we know what the population mean is like
% but we need to find the weights on the layers
b_av = rsm_fitmean(datardv_av,modelrdv,truemeanrdv);
% big weight on truemeanrdv is somewhat expected since this regressor tends to
% be on a smaller scale than the others.
% The pattern regressors end up getting rescaled by the inclusion of the mean
% reg of course, but the parameter estimates should still be basically the same
% (just rescaled)
assert(corr(weights,sqrt(b_av(1:end-1)))>(1-precision),...
    'rsm_fitmean with true mean did not recover weights');
% test that we can account for the measured data
% should be 1 by regression
assert(corr(datardv_av,[modelrdv,truemeanrdv] * b_av)>(1-precision),...
    'linear fit did not account for measurement-effect data');

% now let's go for the full solution - see if we can get convergence when
% weighting individual layer pattern and mean RDMs
b_avfit = rsm_fitmean(datardv_av,modelrdv,meanrdv);

% reconstruct meanrdv first
fitmeanrdv = meanrdv * b_avfit(1:end-1);
% (which will have some imperfect correlation with truemeanrdv but the main
% thing is how close we got to reconstructing the data:
mmpredict = [modelrdv,fitmeanrdv] * b_avfit;

r_mm_yhat = corr(datardv_av,mmpredict);
assert(r_mm_yhat>(1-mmyhatprecision),...
    'rsm_fitmean with fitted mean did not recover data rdv (r=%.3f)',r_mm_yhat);
% these mm reconstructions jump around a bit. As low as r=0.95, as high
% as 0.99. Actually, this was caused by initialising with all ones. Initialising
% with rand gives much better fits

% NB, use mmweightprecision - need to be much more tolerant of reconstruction error
% here
r_mm_weights = corr(weights,sqrt(b_avfit(1:end-1)));
assert(r_mm_weights>(1-mmweightprecision),...
    'rsm_fitmean with fitted mean did not recover weights (r=%.3f)',r_mm_weights);
