clc; clear; close all;

%% Interface
% Define paths for data storage and access
data_folder = '/Users/wsong/Library/CloudStorage/GoogleDrive-wsong@kentech.ac.kr/공유 드라이브/Battery Software Lab/Processed_data/Hyundai_dataset/FCC_dOCV_4C_231107';
load_path = '/Users/wsong/Library/CloudStorage/GoogleDrive-wsong@kentech.ac.kr/공유 드라이브/Battery Software Lab/Processed_data/Hyundai_dataset/RPT3/HNE_FCC(6)_RPT3_10,-10degC';
save_path = '/Users/wsong/Downloads/figure';
I_1C = 0.00477; % Current in Amperes (A)
slash = filesep; % File separator for the current platform

%% Engine
% Read .mat files from specified directories
files = dir([data_folder filesep '*.mat']);
load_files = dir([load_path filesep '*_OCV.mat']);
for i = 1:length(files)
    fullpath_now = [data_folder filesep files(i).name];
    load(fullpath_now); % Load current file
    loadpath_now = [load_path filesep load_files(i).name];
    load(loadpath_now); % Load corresponding OCV file
    
    % Calculate capacities
    OCV(4).Q = abs(trapz(OCV(4).t,OCV(4).I))/3600; % Total capacity in Ampere-hours (Ah)
    OCV(4).cumQ = abs(cumtrapz(OCV(4).t,OCV(4).I))/3600; % Cumulative capacity in Ah

    OCV(4).soc = OCV(4).cumQ/OCV(4 ).Q; % State of Charge (SOC)
    
    V_rest = data(5).V(end); % Resting voltage at the end of the test
        
    % Remove duplicates from OCV(4).V
    [V_unique, ia, ~] = unique(OCV(4).V);
    soc_unique = OCV(4).soc(ia);
    
    % Interpolate SOC value corresponding to V_rest
    soc_at_V_rest = interp1(V_unique, soc_unique, V_rest, 'linear');
    disp(['V_rest = ', num2str(V_rest)]);
    disp(['SOC = ', num2str(soc_at_V_rest)]); % Display the interpolated SOC value


    % Concatenate data from all files
    all_t = []; % Time
    all_V = []; % Voltage
    all_I = []; % Current

    for j = 1:9
        all_t = [all_t; data(j).t / 3600]; % Convert time to hours
        all_V = [all_V; data(j).V]; % Voltage data
        all_I = [all_I; data(j).I / I_1C]; % Normalize current by 1C rate
    end

    % Figure 1: Voltage & Current vs Time
    figure;
    yyaxis left;
    plot(all_t, all_V, 'b', 'LineWidth', 2); % 파란색, 굵은 선
    ylabel('Voltage (V)', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([2.3, 4.5]); % y축 범위 설정
    yyaxis right;
    plot(all_t, all_I, 'r', 'LineWidth', 2); % 빨간색, 굵은 선
    ylabel('Current (C-rate)', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Time (Hours)', 'FontSize', 12, 'FontWeight', 'bold');
    title(['Voltage & Current vs Time for ' strjoin(strsplit(files(i).name,'_'),' ')], 'FontSize', 14, 'FontWeight', 'bold');
    legend('Voltage', 'Current'); % 범례 추가
    saveas(gcf, fullfile(save_path, ['file_' num2str(i) '_1.jpg'])); 
        
    % Figure 2: Voltage vs Elapsed Time
    figure;
    plot(data(5).steptime - data(5).steptime(1), data(5).V, 'b', 'LineWidth', 2); % 파란색, 굵은 선
    durationFormat = 's';
    data(5).steptime.Format = durationFormat;
    xlabel('Elapsed Time (Sec)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Voltage (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title(['Voltage vs Elapsed Time for ' strjoin(strsplit(files(i).name,'_'),' ')], 'FontSize', 14, 'FontWeight', 'bold');
    saveas(gcf, fullfile(save_path, ['file_' num2str(i) '_2.jpg']));
    
    % Figure 3: dV/dt vs Elapsed Time
    figure;
    window_size = 20; % 이동 평균 창 크기
    dvdt = diff(data(5).V) ./ diff(data(5).t); % dV/dt 계산
    dvdt_mov = movmean(dvdt, window_size); % dV/dt의 이동 평균
    dvdt_mov_mVmin = dvdt_mov * 1000; % dV/dt를 mV/sec로 변환
    
    plot(data(5).steptime(2:end) - data(5).steptime(1), dvdt_mov_mVmin, 'r', 'LineWidth', 2); % 빨간색, 굵은 선
    data(5).steptime.Format = durationFormat;
    xlabel('Elapsed Time (Sec)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('dV/dt (mV\cdotsec^{-1})', 'FontSize', 12, 'FontWeight', 'bold');
    title(['dV/dt vs Elapsed Time for ' strjoin(strsplit(files(i).name,'_'),' ')], 'FontSize', 14, 'FontWeight', 'bold');
    ylim([-6 1]); % y축 범위 설정
    xlim([seconds(0), seconds(1800)]); % x축 범위 설정
    saveas(gcf, fullfile(save_path, ['file_' num2str(i) '_3.jpg']));
end