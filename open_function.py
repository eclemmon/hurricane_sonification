import netCDF4
from datetime import datetime, timedelta
import numpy
import io
import json
import csv

"""
These are the variables provided
units -- kg/m2
long_name -- Total (vertically integrated) precipitable water
_FillValue -- -900.0
long_name -- latitude
units -- degrees_north
_FillValue -- -900.0
long_name -- longitude
units -- degrees_east
long_name -- time
units -- days since 0001-01-01 00:00:00
calendar -- noleap
bounds -- time_bnds
long_name -- time interval endpoints
"""

# src = netCDF4.Dataset("/Users/ericlemmon/Downloads/Hurricanes_19days.nc", mode='r')
# print(src.variables)
# for name, variable in src.variables.items():
#     for attrname in variable.ncattrs():
#         print("{} -- {}".format(attrname, getattr(variable, attrname)))
print("*"*20)

# test = pressure[0][0]

def time_data_builder(source):
    pressure = src.variables['TMQ'][:]
    result = {}
    time_string = 0
    for time in pressure:
        stringformat = "time_{}".format(time_string)
        result[stringformat] = sum([sum(subset) / len(subset) for subset in time])/len(pressure)
        time_string += 1
    return result

# dat = time_data_builder(src)
# print(dat)

# with io.open("average_pressure.json", 'w', encoding='utf8') as outfile:
#     string = json.dumps(dat,
#                         indent=4, sort_keys=True,
#                         separators=(',', ': '), ensure_ascii=False)
#     outfile.write(string)

# print(test)
# print(len(test))
# time_point_pressure = []
#
# print(len(pressure))
# for timepoint in pressure:
#     time_point_pressure.append(sum(timepoint)/len(timepoint))
#
# for time in times:
#     print("Time: {}. Pressure: {}".format(time, time_point_pressure))

file_name = '/Users/ericlemmon/Downloads/Hurricanes_19days_data.csv'

def csv_reader(file_name):
    with open(file_name) as csv_file:
        the_csv = csv.reader(csv_file, delimiter=',')
        for row in the_csv:
            print(row)

csv_reader(file_name)