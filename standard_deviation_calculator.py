import math
import struct
from collections import deque
import matplotlib.pyplot as plt

input_file = 'INPUT_VALUES.csv'
output_file = 'EXPECTED_VALUES.csv'

sample_dim = 5

temperature_window = deque([0.0] * sample_dim, maxlen=sample_dim)
humidity_window = deque([0.0] * sample_dim, maxlen=sample_dim)

temperature_results = []
humidity_results = []
temp_windows = []
humid_windows = []

def binary_string_to_float(string):
    binary_bytes = int(string, 2).to_bytes(4, byteorder='big')
    float_value = struct.unpack('>f', binary_bytes)[0]
    return float_value


def float_to_binary_string(float_value):
    packed = struct.pack('>f', float_value)
    binary_string = ''.join(f'{byte:08b}' for byte in packed)
    return binary_string


def standard_deviation(values):
    dif_window = deque(maxlen=sample_dim)
    values_sum = sum(values)
    average = values_sum / sample_dim
    for value in values:
        temp = (value - average) ** 2
        dif_window.append(temp)
    avg = sum(dif_window) / sample_dim
    return math.sqrt(avg)


def process_file(file_path):
    with open(file_path, "r") as file:
        count = 0
        for line in file:
            values = line.strip().split(",")
            timestamp = values[0]
            temperature = binary_string_to_float(values[1])
            humidity = binary_string_to_float(values[2])
            # print(timestamp, temperature, humidity)
            temperature_window.append(temperature)
            humidity_window.append(humidity)
            print(f"Temperature Window: {list(temperature_window)}")
            print(f"Humidity Window: {list(humidity_window)}")
            st_dev_temperature = standard_deviation(temperature_window)
            st_dev_humidity = standard_deviation(humidity_window)
            print(f"Standard deviation temperature: {st_dev_temperature}")
            print(f"Standard deviation humidity: {st_dev_humidity}")
            print("-" * 30)
            with open(output_file, "a") as f:
                f.write(
                    f"{count}, {float_to_binary_string(st_dev_temperature)}, {float_to_binary_string(st_dev_humidity)}\n")
            count += 1


def plot_results():
    fig, axs = plt.subplots(2, 1, figsize=(12, 10), sharex=True)

    x = range(len(temperature_results))
    axs[0].plot(x, temperature_results, label="Temperature Standard Deviation", linestyle='--', color='red')
    axs[0].set_title("Temperature Standard Deviation")
    axs[0].set_ylabel("Standard Deviation")
    axs[0].legend()
    axs[0].grid()

    axs[1].bar(x, temp_windows, alpha=0.6, label="Input Temperature Values")
    axs[1].set_title("Temperature Inputs")
    axs[1].set_xlabel("Sample Index")
    axs[1].set_ylabel("Temperature")
    axs[1].legend()
    axs[1].grid()

    plt.tight_layout()
    plt.show()

    fig, axs = plt.subplots(2, 1, figsize=(12, 10), sharex=True)

    x = range(len(humidity_results))
    axs[0].plot(x, humidity_results, label="Humidity Standard Deviation", linestyle='--', color='blue')
    axs[0].set_title("Humidity Standard Deviation")
    axs[0].set_ylabel("Standard Deviation")
    axs[0].legend()
    axs[0].grid()

    axs[1].bar(x, humid_windows, alpha=0.6, label="Input Humidity Values")
    axs[1].set_title("Humidity Inputs")
    axs[1].set_xlabel("Sample Index")
    axs[1].set_ylabel("Humidity")
    axs[1].legend()
    axs[1].grid()

    plt.tight_layout()
    plt.show()


process_file(input_file)
plot_results()
