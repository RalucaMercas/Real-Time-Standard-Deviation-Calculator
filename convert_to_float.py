import struct


def binary_string_to_float(string):
    binary_bytes = int(string, 2).to_bytes(4, byteorder='big')
    float_value = struct.unpack('>f', binary_bytes)[0]
    return float_value


def process_file(input_file, output_file):
    with open(input_file, "r") as file:
        with open(output_file, "w") as f:
            for line in file:
                values = line.strip().split(",")
                timestamp = values[0]
                temperature = binary_string_to_float(values[1])
                humidity = binary_string_to_float(values[2])
                f.write(f"{timestamp},{temperature:.2f},{humidity:.2f}\n")
                print(f"{timestamp},{temperature:.2f},{humidity:.2f}\n")


process_file("EXPECTED_VALUES.csv", "FLOAT_EXPECTED_VALUES.csv")
