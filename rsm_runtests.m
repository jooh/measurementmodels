% run tests (.m files in test/). If headless, we exit Matlab with the
% appropriate codes (non-zero if a test failed). This is useful for e.g. Git
% pre-commit hooks.
%
% rsm_runtests(headless)
%
% 20171115 J Carlin
function rsm_runtests(headless)

if ~exist('headless','var') || isempty(headless)
    headless = false;
end

rsm_start;

testdir = fullfile(fileparts(mfilename('fullpath')),'test');

tests = dir(fullfile(testdir,'*.m'));

runner = @runit;
if headless
    runner = @runitcrashit;
end

ntest = numel(tests);
for n = 1:ntest
    runit(fullfile(testdir,tests(n).name));
end
fprintf('%d tests completed successfully.\n',ntest);
if headless
    exit(0);
end

function runit(scriptpath)
% avoid sharing name space between tests
run(scriptpath);

function runitcrashit(scriptpath)

try
    runit(scriptpath);
catch err
    fprintf('TEST FAILED: %s\n',scriptpath)
    fprintf('%s\n',err.msg);
    exit(1);
end
