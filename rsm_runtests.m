function rsm_runtests()

rsm_start;

testdir = fullfile(fileparts(mfilename('fullpath')),'test');

tests = dir(fullfile(testdir,'*.m'));

ntest = numel(tests);
for n = 1:ntest
    runit(fullfile(testdir,tests(n).name));
end
fprintf('%d tests completed successfully.\n',ntest);

function runit(scriptpath)
% avoid sharing name space between tests
run(scriptpath);
