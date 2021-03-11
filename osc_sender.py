import json
from pythonosc import udp_client
from pythonosc import osc_message_builder
import time
import csv


def open_and_read_json(filename):
    """
    Just a json opener. Not in use for this program.
    :param filename: json file
    :return: returns the json file.
    """
    with open(filename) as data_file:
        return json.load(data_file)


def json_osc_sender(data):
    """
    Sends data from the json file over local network (to SC) with OSC.
    :param data: loaded json file.
    :return: None
    """
    for key in data:
        msg = osc_message_builder.OscMessageBuilder(address='/s_new')
        msg.add_arg('rate', arg_type='s')
        print(key, data[key])
        msg.add_arg(((data[key]-188)*500), 'f')
        msg = msg.build()
        client.send(msg)
        time.sleep(0.75)


def csv_reader(file_name, client):
    """
    Takes in a comma delineated csv file and sends its data via OSC over local network.
    :param file_name: csv file path
    :param client: OSC Client
    :return: None
    """
    record_msg = osc_message_builder.OscMessageBuilder(address='/record')
    record_msg.add_arg(1, arg_type='i')
    record_msg = record_msg.build()
    client.send(record_msg)
    with open(file_name) as csv_file:
        the_csv = csv.reader(csv_file, delimiter=',')
        for row in the_csv:
            print(row)
            row = [float(item) for item in row]
            msg = osc_message_builder.OscMessageBuilder(address='/s_new')
            msg.add_arg('avg_speed', arg_type='s')
            msg.add_arg(abs(row[0]), 'f')
            msg.add_arg('h1_pressure', arg_type='s')
            msg.add_arg(row[1], 'f')
            msg.add_arg('h1_speed', arg_type='s')
            msg.add_arg(row[2], 'f')
            msg.add_arg('h2_pressure', arg_type='s')
            msg.add_arg(row[3], 'f')
            msg.add_arg('h2_speed', arg_type='s')
            msg.add_arg(row[4], 'f')
            msg.add_arg('h3_pressure', arg_type='s')
            msg.add_arg(row[5], 'f')
            msg.add_arg('h3_speed', arg_type='s')
            msg.add_arg(row[6], 'f')
            msg = msg.build()
            client.send(msg)
            time.sleep(0.1)
    time.sleep(1)
    record_msg = osc_message_builder.OscMessageBuilder(address='/record')
    record_msg.add_arg(0, arg_type='i')
    record_msg = record_msg.build()
    client.send(record_msg)


if __name__ == '__main__':
    # FILE_NAME = "average_pressure.json"
    # timepoint_and_pressure = open_and_read_json(FILE_NAME)
    # print(min(timepoint_and_pressure.values()))
    # print(max(timepoint_and_pressure.values()))
    client = udp_client.SimpleUDPClient("127.0.0.1", 57120)
    file_name = 'Hurricanes_19days_data.csv'
    # file_name = 'PATH'
    csv_reader(file_name, client=client)
