% This example shows how to capture errors thrown by CODA Matlab functions
% such as coda_open()
function errorhandling(filename)
try
  pf = coda_open(filename);
catch ME
  disp('Got some error from the coda_open() function');
  disp('Will now display the stack trace');
  disp(ME.stack(2))
  disp(ME.stack(1))
  return
end

% Perform any read operations here ...

coda_close(pf);
