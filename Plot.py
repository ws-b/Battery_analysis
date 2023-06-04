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
    time = data['시험_시간(s)'].tolist()
    current = data['전류(A)'].tolist()
    voltage = data['전압(V)'].tolist()

    # Create a new figure with a specific size (optional)
    plt.figure(figsize=(12, 8))

    # Plot Current
    plt.plot(time, current, label='Current(A)')
    plt.ylabel('Current (A)')

    # Create a second y-axis
    ax2 = plt.twinx()

    # Plot Voltage on the second y-axis
    ax2.plot(time, voltage, color='r', label='Voltage(V)')
    ax2.set_ylabel('Voltage (V)')

    # Set the x-axis label
    plt.xlabel('Time (s)')

    # Set the title of the plot (optional)
    plt.title('Time / Voltage, Current graph')

    # Display the legend
    plt.legend()

    # Show the plot
    plt.show()