%% System setup
clc;clear all;close all;

ai = initialize_bionic_leaf;
DIO = digitalio('mcc', '0');
addline(DIO,(1),'out');
relaybox(1) = digitalio('mcc','1');%This line adds a digital I/O device (USB-ERB24) with ID=2.
pumpset1 = addline(relaybox(1), 0:7,0, 'out',{'pump1';'pump2';'pump3';'pump4';'pump5';'pump6';'pump7';'pump8'});
pumpstatus = 'off';
putvalue(relaybox(1).Line(1), 1);
putvalue(relaybox(1).Line(2), 1);
%Experiment settings
growth_cycle_duration = 60*10; %In seconds


%Set length of experiment, in overestimated seconds
n_limit=3600*24; 
%Initialize data collection matrices

data.points.od = zeros(n_limit,2);
data.points.time = zeros(n_limit,1);
data.points.blank = zeros(n_limit,2);
data.points.rawreads = zeros(n_limit,2);
data.cycles.growth_rate = zeros(n_limit,2);
data.cycles.start_od = zeros(n_limit,2);
data.cycles.end_od = zeros(n_limit,2);
data.cycles.start_point = zeros(n_limit,2);
data.cycles.end_point = zeros(n_limit,2);
data.points.pump = zeros(n_limit,1);

%Live plot updating period (in seconds)
plot_update = 1;

%Output to file (backing up) period (in seconds)
output_period = 10;
output_filename = 'Ralstonia_salt_Evolvulator_Lumedia_test_August16_no_pumps-detector1';

%Get start time
start_time = datenum(clock);
cycle_start_time = start_time;
count = 0;
offcount = 0;

for n=1:n_limit
    
    %Acquire datas
    start(ai);
    
    %Duration will be determined by how many seconds the pause is.
    
    putvalue(DIO,1)
    pause(5)

    [rawdata,sample_time,abstime,events] = getdata(ai);
    putvalue(DIO,0)

    start(ai);
    [blank_rawdata,blank_sample_time,blank_abstime,blank_events] = getdata(ai);

    %Take median of samples as data point
    sample_data = mean(rawdata) - mean(blank_rawdata);

    disp('Raw Data...')
    disp(mean(rawdata))

    disp('Blank Data...')
    disp(mean(blank_rawdata))

    disp('Corrected Data is...')
    disp(sample_data)
    
    %disp('Averaged Read is...')
    %disp(mean(sample_data))
    
    
    disp(pumpstatus)
    disp(count)
    disp(offcount)
    
    pause(30)

   
    %Obtain relative time (in seconds) since start of experiment
    relative_time = (datenum(abstime)-start_time)*24*3600;
    
    %Record values to data matrix
    data.points.time(n,1) = relative_time;
    data.points.od(n,:) = sample_data;
    data.points.blank(n,:) = mean(blank_rawdata);
    data.points.rawdata(n,:) = mean(rawdata);
    
    if mod(n, output_period)==0
       save([output_filename '.mat']) 
    end

end
