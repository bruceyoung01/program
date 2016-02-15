#  $ID: read_text_data.py V01 02/08/2016 12:12 ZHIFENG YANG EXP$
#
#******************************************************************************
#  PROGRAM read_text_data.py READS THE TEXT DATA FILE FROM A SINGLE TEXT FILE.
#
#  FLOW CHART:
#  ============================================================================
#  (1 ) SPECIFY THE INFO FOR THE DATA, INCLUDING THE DATA DIRECTORY, FILE NAME
#
#  NOTES:
#  ============================================================================
#  (1 ) ORIGINALLY WRITTEN BY ZHIFENG YANG. (02/08/2016)
#******************************************************************************
#
#  LOAD FUNCTIONS AND PROCEDURES
import numpy as np
import matplotlib.pyplot as plt
import sys
sys.path.insert(0, '/umbc/xfs1/zzbatmos/users/vy57456/program/python/python_lib/function/')
import running_average

#   DATA INFO
dir      = "/home/vy57456/zzbatmos_user/data/homework/cp/"
filename = "testfile.txt"

#   READ DATA
a        = open(dir + filename, "r")
data     = []

#   CONVERT STRING IN DATA LIST TO FLOAT
with a as file:
    for line in file:
        for element in line.split():
            data.append(float(element))
print data

#   CALL FUNTION running_average TO CALCULATE RUNNING AVERAGE OF data
data_avg = []
n        = 3
data_avg = running_average.running_average(data, n)
print data_avg

#   PLOT THE DATA
plt.plot(data)
plt.xlabel('# of data')
plt.ylabel('data')
plt.show()

#   PLOT THE DATA
plt.plot(data_avg)
plt.xlabel('# of data')
plt.ylabel('data running average')
plt.show()
