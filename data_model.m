%% This program is an attempt to create a BEM headmodel using fieldtrip
clear all;
close all;
clc;
%% Add path of fieldtrip toolbox
addpath 'C:\Users\Dhruv Anjaria\MATLAB Drive\Fieldtrip\fieldtrip-20190224\fieldtrip-20190224'
ft_defaults;   % initiate fieldtrip
%% Reading MRI file - anatomical data
% The configuration should contain:
%    cfg.method        = 'slice',      plots the data on a number of slices in the same plane
%                        'ortho',      plots the data on three orthogonal slices
%                        'glassbrain', plots a max-projection through the brain
mri = ft_read_mri('standard_mri.mat');  % E:\EEG_DATA\fieldtrip-20190224\fieldtrip-20190224\template\headmodel\standard_mri.mat 
cfg        = [];    % To plot MRI define configuration
cfg.method = 'ortho';
cfg.colorbar = 'no';
ft_sourceplot(cfg, mri);  
ft_determine_coordsys(mri, 'interactive', 'no');
%% Segmentation of the anatomical information into different tissue types
cfg        = [];    % cfg: configuration of the function that was used to create vol
cfg.output       = {'brain','skull','scalp'};
segmentedmri  = ft_volumesegment(cfg, mri);
save segmentedmri segmentedmri
%% Prepare mesh and define number of vertices of tissue
load segmentedmri
cfg        = [];
cfg.tissue = {'brain','skull','scalp'};
cfg.numvertices = [1500 1500 1500];
bnd = ft_prepare_mesh(cfg,segmentedmri); % The bnd field contains information about the mesh
save bnd bnd
% Prepare Headmodel - bemcp method
load bnd
cfg = [];
cfg.method = 'bemcp'; % You can also specify 'openmeeg', 'dipoli', or another method.
cfg.conductivity = [0.3300 0.0041 0.3300];
vol        = ft_prepare_headmodel(cfg,bnd);
save vol vol
%% Visualization plot mesh
load vol
% figure
% ft_plot_mesh(vol.bnd(1), 'facecolor',[0 0 1], 'facealpha', 0.3, 'edgecolor', [1 1 1], 'edgealpha', 0.05);
% hold on;
% ft_plot_mesh(vol.bnd(2),'facecolor',[0 1 1],'edgecolor','none','facealpha',0.4);
% hold on;
% ft_plot_mesh(vol.bnd(3),'edgecolor','none','facealpha', 0.3,'facecolor',[0.4 0.6 0.4]);
%% Electrode placement % FT_CHANNELSELECTION is used to select the channels
load vol
elec = ft_read_sens('standard_1020.elc');  % for electrodes - 97 electrodes - default - 'standard_1020.elc'
save elec elec
% figure;
% ft_plot_mesh(vol.bnd(3), 'edgecolor','none','facealpha',0.3,'facecolor',[0.4 0.6 0.4]);
% hold on;
% ft_plot_sens(elec);     % optional properties - style,marker
%% Fiducial pts
% we dont need to do the following as our elec info already contain fiducial points nas, lpa, rpa
%% Source Placed visualization
load vol   % bnd field exist in vol
cfg = [];
cfg.headmodel = vol;        % head model
cfg.dip.pos = [0 0 0];      % source dipole position
cfg.dip.mom = [1 0 0]';     % source dipole moment
% figure
% ft_plot_mesh(vol.bnd(1),'edgecolor','none','facealpha',0.1,'facecolor',[0.6 0.6 0.8]);
% hold on
% ft_plot_dipole(cfg.dip.pos,cfg.dip.mom);
%% Create source model i.e define grid point and compute leadfield matrix
load vol
load elec
cfg = [];
cfg.xgrid = -87.5:5:87.5;
cfg.ygrid = -125:5:85;
cfg.zgrid = -85:5:95; % These are total 57276 grid points of which only 15460 dipoles inside, 41816 dipoles outside brain.
% To make the grid point look like cube (Tight grid), 15460 dipoles inside, 17948 dipoles outside brain. Total 33408 final grid points
cfg.headmodel = vol;
cfg.elec = elec;
[sourcemodel] = ft_prepare_leadfield(cfg);
% figure
% plot3(sourcemodel.pos(:,1), sourcemodel.pos(:,2), sourcemodel.pos(:,3), '.') % Plot all 33408 grid point
save sourcemodel sourcemodel
%% Compute simulated data for single source
% load vol
% load elec
% cfg = [];
% for z = -65:5:95
%     for y = -125:5:85
%         for x = -87.5:5:87.5    
%             cfg.xgrid = x; cfg.ygrid = y; cfg.zgrid = z; %Dipole location is defined
%             cfg.headmodel = vol; % BEM head model is defined
%             cfg.elec = elec; % Electrode position are defined
%             Gain_prepare = ft_prepare_leadfield(cfg); 
%             Gain = cell2mat(Gain_prepare.leadfield); % Gain matrix
%             if isempty(Gain)==0
%                 M = [1;0;0]; % another unit norm moment vector [0.1155;0.5774;0.8083]
% %%Time specifications:
%                 Fs = 1000;                   % samples per second
%                 dt = 1/Fs;                   % seconds per sample
%                 StopTime = 0.2;              % seconds
%                 t = (0.1:dt:StopTime-dt)';     % seconds
% %%Sine wave:
%                 Fc1 = 60;                     % hertz                    % hertz
%                 x1 = sin(2*pi*Fc1*t);
%                 S(1,:)=x1';
%                 Sim_EEG = Gain*M*S;
%                 filename = "Sim_EEG "+ x +" " + y +" " + z+".csv"
%                 csvwrite (filename, Sim_EEG)
%             end
%          end
%      end
%  end
% %% Compute simulated data for two source
% % load vol
% % load elec
% % %source 1
% % cfg = [];
% % cfg.xgrid = 32.5; cfg.ygrid = -35; cfg.zgrid = -25; %Dipole location is defined
% % cfg.headmodel = vol; % BEM head model is defined
% % cfg.elec = elec; % Electrode position are defined
% % Gain_prepare = ft_prepare_leadfield(cfg); 
% % Gain1 = cell2mat(Gain_prepare.leadfield); % Gain matrix
% % %source2
% % cfg = [];
% % cfg.xgrid = -22.5; cfg.ygrid = 0; cfg.zgrid = -25; %Dipole location is defined
% % cfg.headmodel = vol; % BEM head model is defined
% % cfg.elec = elec; % Electrode position are defined
% % Gain_prepare = ft_prepare_leadfield(cfg); 
% % Gain2 = cell2mat(Gain_prepare.leadfield); % Gain matrix
% % Gain = [Gain1 Gain2];
% % M = [1 0 0 0 0 0; 0 0 0 0 1 0]'; % another unit norm moment vector [0.1155;0.5774;0.8083]
% % %%Time specifications:
% % Fs = 8000;                   % samples per second
% % dt = 1/Fs;                   % seconds per sample
% % StopTime = 0.25;             % seconds
% % t = (0:dt:StopTime-dt)';     % seconds
% % %%Sine wave:
% % Fc1 = 60; 
% % Fc2 = 60;% hertz                    % hertz
% % x1 = sin(2*pi*Fc1*t);
% % x2 = cos(2*pi*Fc2*t);
% % S(1,:)=x1';
% % S(2,:)=x2';
% % corr=(S(1,:)*S(2,:)')/((norm(S(1,:))*norm(S(2,:)))); % correlation of two dipole waveform
% % Sim_EEG = Gain*M*S;
% % %save Sim_EEG_32+5_-35_-25_-22+5_0_-25 Sim_EEG
%% Compute simulated data for two source
load vol
load elec
%source 1
cfg = [];
for z1 = -55:15:65
    for z2 = -55:15:65
    for y1 = -85:15:45
        
        for x = -52.5:15:52.5    
            cfg.xgrid = x; cfg.ygrid = y1; cfg.zgrid = z1; %Dipole location is defined
            cfg.headmodel = vol; % BEM head model is defined
            cfg.elec = elec; % Electrode position are defined
            Gain_prepare = ft_prepare_leadfield(cfg); 
            Gain1 = cell2mat(Gain_prepare.leadfield); % Gain matrix
            cfg = [];
            cfg.xgrid = x; cfg.ygrid = y1; cfg.zgrid = z2; %Dipole location is defined
            cfg.headmodel = vol; % BEM head model is defined
            cfg.elec = elec; % Electrode position are defined
            Gain_prepare = ft_prepare_leadfield(cfg); 
            Gain2 = cell2mat(Gain_prepare.leadfield); % Gain matrix
            
            
            
            if isempty(Gain1)==0 && isempty(Gain2)==0
                Gain = [Gain1 Gain2];
                 M = [1 0 0 0 0 0; 0 0 0 0 1 0]'; % another unit norm moment vector [0.1155;0.5774;0.8083]
                % %%Time specifications:
                 Fs = 1000;                   % samples per second
                 dt = 1/Fs;                   % seconds per sample
                 StopTime = 0.1;             % seconds
                 t = (0:dt:StopTime-dt)';     % seconds
% %%Sine wave:
                 Fc1 = 60; 
                 Fc2 = 60;% hertz                    % hertz
                 x1 = sin(2*pi*Fc1*t);
                 x2 = cos(2*pi*Fc2*t);
                 S(1,:)=x1';
                 S(2,:)=x2';
                 corr=(S(1,:)*S(2,:)')/((norm(S(1,:))*norm(S(2,:)))); % correlation of two dipole waveform
                 Sim_EEG = Gain*M*S;

                filename = "Sim_EEG "+ x +" " + y1 +" " + z1+ " " + x + " " + y1 +" " + z2+ ".csv"
                csvwrite (filename, Sim_EEG)
            end
         end
        
    end
    end
 end
%% create a dipole simulation with one dipole and a custom timecourse
% load vol
% load elec
% cfg      = [];
% cfg.headmodel = vol;          % see above
% cfg.elec = elec;              % see above
% cfg.dip.pos = [32.5 -35 -25];
% cfg.dip.mom = [1 0 0]';       % note, it should be transposed
% cfg.fsample = 250;            % Hz
% time = (1:250)/250;           % manually create a time axis
% signal = sin(10*time*2*pi);   % manually create a signal
% cfg.dip.signal = {signal, signal, signal};  % three trials
% raw2 = ft_dipolesimulation(cfg);
% avg2 = ft_timelockanalysis([], raw2);
% plot(avg2.time, avg2.avg);    % plot the timecourse
% BEM_data = avg2.avg;
% %save BEM_data_32+5_-35_-25.mat BEM_data