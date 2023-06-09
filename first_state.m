load('dcir_fit.mat')

% 변수 및 데이터 정의
R1 = 12.5032;
R2 = 24.4340;
C = 0.00806;

deltaV_exp = data(22).deltaV;
time_exp = data(22).t;

% 모델 함수를 사용하여 전압 값 계산
voltage_model = model_func(time_exp, R1, R2, C, a);

% 데이터와 모델 결과를 그래프로 플롯
plot(time_exp, deltaV_exp, 'b-', time_exp, voltage_model, 'r--');
legend('실험 데이터', '모델 결과');
xlabel('시간');
ylabel('전압');
title('실험 데이터와 모델 결과');


% 모델 함수 정의
function voltage = model_func(time, R1, R2, C, a)
    I = 0.0038;
    a = 1.5117;
    voltage = I * R1 * (R1 + R2) ./ (R1 + R2 .* exp(-a .* time ./ (R1 * C)));
end