#!/bin/python3

import pydicom, sys

try:
    dataset = pydicom.dcmread(sys.argv[1])
except:
    exit(1)

print(dataset['StudyInstanceUID'].value)
