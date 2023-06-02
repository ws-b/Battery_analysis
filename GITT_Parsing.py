import os
import re
import pandas as pd
import numpy as np

# Folder path containing the files
win_folder_path = 'G:\\공유 드라이브\\Battery Software Lab\\Data\\Hyundai_dataset\\GITT\\FCC_(6)_GITT\\'
win_save_path = 'G:\\공유 드라이브\\Battery Software Lab\\Processed_data\\Hyundai_dataset\\GITT\FCC_(6)_GITT\\'
mac_folder_path = ''
mac_save_path = ''

folder_path = win_folder_path
save_path = win_save_path

file_lists = [f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f)) and f.endswith('.txt')]
file_lists.sort()

dataframes = []  # 각 파일의 데이터를 저장할 리스트

for file_list in file_lists:
    with open(folder_path + file_list, "r") as f:
        text = f.read()

    # 데이터를 라인으로 분리
    lines = text.split("\n")

    # 필요없는 라인의 인덱스
    exclude_lines = list(range(1, 15)) + [16]

    # 각 라인을 분석하여 DataFrame을 만듭니다.
    data = []
    for i, line in enumerate(lines, start=1):  # 행 번호는 1부터 시작
        if i not in exclude_lines and line.strip():  # 공백 라인 제외
            # 탭(\t)으로 열을 분리
            columns = re.split('\t+', line)
            data.append(columns)

    df = pd.DataFrame(data[1:], columns=data[0])  # 첫 행을 열 이름으로 사용

    df.columns = df.columns.str.replace(' ', '')
    df = df.replace('\s+', '', regex=True)

    # 데이터 타입 변환
    df['전류(A)'] = pd.to_numeric(df['전류(A)'], errors='coerce')
    df['전압(V)'] = pd.to_numeric(df['전압(V)'], errors='coerce')

    # 조건 리스트
    conditions = [
        (df['전류(A)'] < 0),
        (df['전류(A)'] > 0),
        (df['전류(A)'] == 0)
    ]

    # 각 조건에 대응하는 결과값 리스트
    choices = ['D', 'C', 'R']

    # np.select를 사용하여 새로운 열 '전류 상태' 추가
    df['전류 상태'] = np.select(conditions, choices, default='Unknown')

    df.to_csv(save_path + file_list.replace('.txt', '.csv'), index=False, encoding='utf-8-sig')
