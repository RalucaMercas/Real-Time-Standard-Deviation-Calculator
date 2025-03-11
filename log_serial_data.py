import serial
from datetime import datetime, timedelta
import time
import struct

ser = serial.Serial('COM10', 9600)
log_file = "INPUT_VALUES.csv"

current_time = datetime.now()


def float_to_binary_string(float_value):
    packed = struct.pack('>f', float_value)
    binary_string = ''.join(f'{byte:08b}' for byte in packed)
    return binary_string


with open(log_file, "a") as file:
    while True:
        data = ser.readline().decode('utf-8').strip()

        values = data.split(",")
        temperature = float(values[0])
        humidity = float(values[1])

        temp_binary = float_to_binary_string(temperature)
        hum_binary = float_to_binary_string(humidity)

        log_entry_time = current_time.strftime('%d/%m/%Y %H:%M:%S')
        current_time += timedelta(seconds=30)

        log_entry = f"{log_entry_time},{temp_binary},{hum_binary}\n"
        print(f"{log_entry_time},{temperature},{humidity}\n")
        file.write(log_entry)

        time.sleep(30)
