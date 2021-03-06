%% Pass data from Matlab to Fortran and viceversa
%% Method 1: Text files
% Write data from Fortran to txt file
% Read txt file in Matlab using loadArray based on dlmread
% Timing:
%   Fortran 0.67, Matlab 0.108 seconds
%% Method 2: Binary files
% Write data from Fortran to .bin file
% Read .bin file in Matlab using loadBinary based on fread
% Note: in both methods, always vectorize multidimensional arrays,
% recalling that both Matlab and Fortran store array in column-major order
% Timing:
%   Fortran 0.56, Matlab 0.012 seconds

clear;clc;close all

addpath(fullfile('..'));

% Set some parameters in Matlab
par.na = 1000;
par.nz = 7;
par.howread = 2; % 1=txt format, 2=binary format

par.alpha  = 0.36;
par.a_grid = linspace(0.01,10,par.na)';
par.z_grid = linspace(1,5,par.nz)';

% Export integer parameters to Fortran
int_params_names = {'na','nz','howread'};
num_par = numel(int_params_names);
int_params = ones(num_par,1);
for ii = 1:num_par
    int_params(ii) = par.(int_params_names{ii});
end

% Export real parameters to Fortran
real_params_names = {'alpha'};
num_par = numel(real_params_names);
real_params = ones(num_par,1);
for ii = 1:num_par
    real_params(ii) = par.(real_params_names{ii});
end

disp('Writing files..')
% Dimensions
dimensions = [length(real_params);length(int_params)]; %the dimensions
dlmwrite('dimensions.txt', dimensions, 'delimiter', '\t', 'precision', 17);
dlmwrite('int_params.txt', int_params, 'delimiter', '\t', 'precision', 17);
dlmwrite('real_params.txt', real_params, 'delimiter', '\t', 'precision', 17);

% Write Arrays to files
dlmwrite('a_grid.txt', par.a_grid, 'delimiter', '\t', 'precision', 17);
dlmwrite('z_grid.txt', par.z_grid, 'delimiter', '\t', 'precision', 17);

%% Call the Fortran executable
% The file 'run.exe' is generated by Fortran

disp('Calling the executable now:')
[status, ~] = system('run.exe','-echo');

if status ~= 0
    error('FORTRAN procedure was not executed properly.')
end

%% Read files generated by Fortran

disp('Reading files generated by fortran.')
disp('Please wait...')

siz = [par.na,par.nz];

if par.howread ==1
    % Method 1: txt format
    tic
    for i=1:20
        output = loadArray('output.txt',siz);
    end
    toc
    
elseif par.howread == 2
    % Method 2: binary format
    tic
    for i=1:20
        output = loadBinary('output.bin','double',siz);
    end
    toc
end

disp('Files read!')

%% Plot Fortran results
plot(par.a_grid,output)

% A = randi(10,[100000,1]); % random integer b/w 1 and 10
% 
% % Write to a text file
% dlmwrite('A.txt', A, 'delimiter', '\t', 'precision', 17);
% 
% % Write to a binary file
% fid = fopen('A.bin','wb');
% fwrite(fid,A,'double');
% fclose(fid);
% 
% % %% txt, load
% % tic
% % data1 = load('A.txt');
% % toc
% % 
% % %% txt, dlmread
% % tic
% % data2 = dlmread('A.txt','\t');
% % toc
% % 
% % %% txt, fscanf
% % tic
% % FID = fopen('A.txt','rt');
% % data3 = fscanf(FID,'%f');
% % fclose(FID);
% % toc
% % 
% % %% binary, fread
% % tic
% % FID = fopen('A.bin','rb');
% % data4 = fread(FID,inf,'double');
% % fclose(FID);
% % toc
% % 
% % isequal(A,data4)
% 
% %% Now test my functions
% 
% % Read text data
% 
% siz = size(A);
% tic
% x1 = loadArray('A.txt',siz);
% toc
% 
% tic
% x2 = loadBinary('A.bin', 'double', siz);
% toc







