import os
import pandas as pd
import matplotlib.pyplot as plt


# Folder path containing the files
win_folder_path = 'G:\\공유 드라이브\\Battery Software Lab\\Processed_data\\Hyundai_dataset\\GITT\FCC_(6)_GITT\\'
mac_folder_path = ''

folder_path = win_folder_path

file_lists = [f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f)) and f.endswith('.csv')]
file_lists.sort()


#for file_list in file_lists:
    file_list = file_lists[0]
    file = open(folder_path + file_list, "r")

    # Read the CSV file into a DataFrame
    data = pd.read_csv(folder_path + file_list, encoding='utf-8')

    plt.figure(figsize=(12, 8))

    # 전류(A) 그래프
    plt.plot(data['시험_시간(s)'], data['전류(A)'], label='전류(A)')
    plt.ylabel('전류 (A)')

    # 두 번째 y축 생성
    plt.twinx()

    # 전압(V) 그래프
    plt.plot(data['시험_시간(s)'], data['전압(V)'], color='r', label='전압(V)')
    plt.ylabel('전압 (V)')

    plt.xlabel('시험 시간 (s)')
    plt.title('시험 시간에 따른 전류와 전압')
    plt.legend()
    plt.show()