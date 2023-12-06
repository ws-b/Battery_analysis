clc; clear; close all;


%% Interface

data_folder = '/Users/wsong/Library/CloudStorage/GoogleDrive-wsong@kentech.ac.kr/공유 드라이브/Battery Software Lab/Data/Hyundai_dataset/RPT3/HNE_FCC(6)_RPT3_10,-10degC';

% Replace 'RAW' with 'Processed_Data' in the path
save_path = strrep(data_folder, 'Data', 'Processed_data');

% Create the directory if it doesn't exist
if ~exist(save_path, 'dir')
   mkdir(save_path)
end

I_1C = 0.00477; %[A]
n_hd = 14; % headline number used in 'readtable' option. WonA: 14, Maccor: 3.
sample_plot = 1;

%% Engine
slash = filesep;
files = dir([data_folder slash '*.txt']); % select only txt files (raw data)

for file_num = 1:length(files)
    fullpath_now = [data_folder slash files(file_num).name]; % path for i-th file in the folder
    data_now = readtable(fullpath_now,'FileType','text',...
                    'NumHeaderLines',n_hd,'readVariableNames',0); % load the data

    data1.I = data_now.Var7;
    data1.V= data_now.Var8;
    data1.t2 = data_now.Var2; % experiment time, format in duration
    data1.t1 = data_now.Var4; % step time, format in duration
    data1.cycle = data_now.Var3; 
    data1.T = data_now.Var13;

     % datetime
     data1.t = seconds(data1.t2);

     % absolute current
     data1.I_abs = abs(data1.I);

     % type
     data1.type = char(zeros([length(data1.t),1]));
     data1.type(data1.I>0) = 'C';
     data1.type(data1.I==0) = 'R';
     data1.type(data1.I<0) = 'D';

     % step
     data1_length = length(data1.t);
     data1.step = zeros(data1_length,1);
     m  =1;
     data1.step(1) = m;
        for j = 2:data1_length
            if data1.type(j) ~= data1.type(j-1)
                m = m+1;
            end
            data1.step(j) = m;
        end

     %  check for error, if any step has more than one types
     vec_step = unique(data1.step);
     num_step = length(vec_step);
     for i_step = 1:num_step
          type_in_step = unique(data1.type(data1.step == vec_step(i_step)));
          
          if size(type_in_step,1) ~=1 || size(type_in_step,2) ~=1
              disp('ERROR: step assignent is not unique for a step')
              return
          end
     end


    % plot for selected samples
    if ismember(sample_plot,i)
        figure
        title(strrep(files(i).name(1:end-4), '_', '\_')) % Replace '_' with '\_' in the title
        hold on
        
        yyaxis left
        plot(data1.t/3600,data1.V,'-')
        xlabel('time (hours)')
        ylabel('voltage (V)')
        
        yyaxis right
        plot(data1.t/3600,data1.I/I_1C,'-')
        ylabel('C rate')
    end


    % make struct (output format)
    data_line = struct('V',zeros(1,1),'I',zeros(1,1),'t',zeros(1,1),'indx',zeros(1,1),'type',char('R'),...
    'steptime',zeros(1,1),'T',zeros(1,1),'cycle',0);
    data = repmat(data_line,num_step,1);

    % fill in the struc
    n = 1; 
    for i_step = 1:num_step

        range = find(data1.step == vec_step(i_step));
        data(i_step).V = data1.V(range);
        data(i_step).I = data1.I(range);
        data(i_step).t = data1.t(range);
        data(i_step).indx = range;
        data(i_step).type = data1.type(range(1));
        data(i_step).steptime = data1.t1(range);
        data(i_step).T = data1.T(range);
        data(i_step).cycle = data1.cycle(range(1));

        % display progress
            if i_step> num_step/10*n
                 fprintf('%6.1f%%\n', round(i_step/num_step*100));
                 n = n+1;
            end
    end

    % save output data
    save_fullpath = [save_path slash files(file_num).name(1:end-4) '.mat'];
    save(save_fullpath,'data')
    
    
    %RPT- formation
    
    Cycle = 4; 
    indices = [];
    for j = 1:length(data)
        if data(j).cycle == 4
            indices = [indices, j];
            index1 = indices(end);
            disp(['Value found at index ', num2str(j)]);
        end
    end
    
    if isempty(indices)
        error('No cycles with the specified value found.');
    end
    
    fields = fieldnames(data);
    FORMATION = repmat(struct(), index1, 1);
    for i = 1:index1
        for j = 1:length(fields)
            fieldName = fields{j};
            FORMATION(i).(fieldName) = data(i).(fieldName);
        end
    end
    
    % RPT-OCV
    Vmax = 4.2 ; %Vmin = 2.5;
    cutoff1 = 0.05; %-0.05;
    indices = [];
    for j = 1:length(data)
        data(j).Iavg = mean(data(j).I);
        if abs(Vmax - data(j).V(end)) < 0.001 && abs(cutoff1 - data(j).Iavg/I_1C) < 0.001 && j > index1   
            indices = [indices, j];
            index2 = indices(1);
            disp(['Value found at index ', num2str(j)]);
        end
    end
    
    if isempty(indices)
        error('No cycles with the specified value found.');
    end
    
    fields = fieldnames(data);
    OCV = repmat(struct(), index2, 1);
    for i = index1:index2+1
        for j = 1:length(fields)
            fieldName = fields{j};
            OCV(i).(fieldName) = data(i).(fieldName);
        end
    end
    
    %RPT-CRATE
    Crate = -6; %Crate = -6; %AHC = 6
    indices = [];
    for j = 1:length(data)
        data(j).Iavg = mean(data(j).I);
        if abs(Crate - data(j).Iavg/I_1C) < 0.01
            disp(['Value found at index ', num2str(j)]);
            indices = [indices, j];
            index3 = indices(1);
        end
    end
    
    if isempty(indices)
        error('No cycles with the specified value found.');
    end
    
    fields = fieldnames(data);
    CRATE = repmat(struct(), index3, 1);
    for i = index2+1:index3+1
        for j = 1:length(fields)
            fieldName = fields{j};
            CRATE(i).(fieldName) = data(i).(fieldName);
        end
    end
    
    %RPT-DCIR
    Vmax = 4.2; %Vmin = 2.5; %AHC =0.01;
    cutoff2 = 0.2;
    indices = [];
    for j = 1:length(data)
        if abs(Vmax - data(j).V(end)) < 0.001 && abs(cutoff2 - data(j).Iavg/I_1C) < 0.001 && j > index2 && j < index3
            disp(['Value found at index ', num2str(j)]);
            indices = [indices, j];
            index4 = indices(1);
        end
    end
    
    if isempty(indices)
        error('No cycles with the specified value found.');
    end
    
    fields = fieldnames(data);
    DCIR = repmat(struct(), index4, 1);
    for i = index2+1:index4+1
        for j = 1:length(fields)
            fieldName = fields{j};
            DCIR(i).(fieldName) = data(i).(fieldName);
        end
    end
    
    %RPT 범위
    FORMATION = FORMATION(1:index1);
    OCV = OCV(index1:index2+1);
    CRATE = CRATE(index4+1:index3+1);
    DCIR = DCIR(index2+1:index4+1);    


    % Save FORMATION data set
    save_fullpath = [save_path slash files(file_num).name(1:end-4) '_FORMATION.mat'];
    save(save_fullpath, 'FORMATION');

    % Save OCV data set
    save_fullpath = [save_path slash files(file_num).name(1:end-4) '_OCV.mat'];
    save(save_fullpath, 'OCV');

    % Save CRATE data set
    save_fullpath = [save_path slash files(file_num).name(1:end-4) '_CRATE.mat'];
    save(save_fullpath, 'CRATE');

    % Save DCIR data set
    save_fullpath = [save_path slash files(file_num).name(1:end-4) '_DCIR.mat'];
    save(save_fullpath, 'DCIR');


    % FORMATION 데이터 세트에 대한 그래프 그리기
    all_times = vertcat(FORMATION.t);
    all_voltages = vertcat(FORMATION.V);
    all_currents = vertcat(FORMATION.I);
    
    
    
    figure;
    hold on;
    title('FORMATION');
    xlabel('Time (hours)');
    yyaxis left;
    ylabel('Voltage (V)');
    plot(all_times/3600, all_voltages, '-');
    
    yyaxis right;
    ylabel('C rate'); 
    plot(all_times/3600, all_currents/I_1C, '-');
    hold off;
    
    % OCV 데이터 세트에 대한 그래프 그리기
    all_times = vertcat(OCV.t);
    all_voltages = vertcat(OCV.V);
    all_currents = vertcat(OCV.I);
    
    figure;
    hold on;
    title('OCV');
    xlabel('Time (hours)');
    yyaxis left;
    ylabel('Voltage (V)');
    plot(all_times/3600, all_voltages, '-');
    
    yyaxis right;
    ylabel('C rate'); 
    plot(all_times/3600, all_currents/I_1C, '-');
    hold off;
    
    % CRATE 데이터 세트에 대한 그래프 그리기
    all_times = vertcat(CRATE.t);
    all_voltages = vertcat(CRATE.V);
    all_currents = vertcat(CRATE.I);
    
    figure;
    hold on;
    title('CRATE');
    xlabel('Time (hours)');
    yyaxis left;
    ylabel('Voltage (V)');
    plot(all_times/3600, all_voltages, '-');
    
    yyaxis right;
    ylabel('C rate'); 
    plot(all_times/3600, all_currents/I_1C, '-');
    hold off;
    
    % DCIR 데이터 세트에 대한 그래프 그리기
    all_times = vertcat(DCIR.t);
    all_voltages = vertcat(DCIR.V);
    all_currents = vertcat(DCIR.I);
    
    figure;
    hold on;
    title('DCIR');
    xlabel('Time (hours)');
    yyaxis left;
    ylabel('Voltage (V)');
    plot(all_times/3600, all_voltages, '-');
    
    yyaxis right;
    ylabel('C rate'); 
    plot(all_times/3600, all_currents/I_1C, '-');
    hold off;

end





