import serial
import csv

uart = serial.Serial(port='COM8', baudrate=9600, timeout=1)

input_csv = "INPUT_VALUES.csv"
output_csv = "OUTPUT_VALUES_BASYS.csv"


def send_data_to_fpga(temp, humidity):
    for i in range(4):
        byte = (temp >> (i * 8)) & 0xFF
        uart.write(bytes([byte]))

    for i in range(4):
        byte = (humidity >> (i * 8)) & 0xFF
        uart.write(bytes([byte]))


def receive_data_from_fpga():
    temperature_std_dev = 0
    humidity_std_dev = 0

    for i in range(4):
        byte = uart.read(1)
        if byte:
            temperature_std_dev |= int.from_bytes(byte, byteorder='little') << (i * 8)

    for i in range(4):
        byte = uart.read(1)
        if byte:
            humidity_std_dev |= int.from_bytes(byte, byteorder='little') << (i * 8)

    return temperature_std_dev, humidity_std_dev


def main():
    with open(input_csv, 'r') as infile, open(output_csv, 'w', newline='') as outfile:
        csv_reader = csv.reader(infile)
        csv_writer = csv.writer(outfile)

        for index, row in enumerate(csv_reader):
            timestamp, temp_binary, humidity_binary = row
            temperature = int(temp_binary, 2)
            humidity = int(humidity_binary, 2)

            send_data_to_fpga(temperature, humidity)

            temp_std_dev, humidity_std_dev = receive_data_from_fpga()

            csv_writer.writerow([
                index,
                f"{temp_std_dev:032b}",
                f"{humidity_std_dev:032b}"
            ])
            print(f"Processed row {index}: Temp Std Dev={temp_std_dev:032b}, Humidity Std Dev={humidity_std_dev:032b}")


if __name__ == "__main__":
    main()
