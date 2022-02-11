#!/bin/python3

import pydicom, sys, os
from pydicom.errors import InvalidDicomError
if len(sys.argv) < 2:
    exit(1)

rootPath = sys.argv[1]
filesFound = []
dicomFilesFound = []
for root, dirs, files in os.walk(rootPath):
    for file in files:
        if os.path.splitext(file)[1] == ".dcm":
            dicomFilesFound.append(os.path.join(root, file))
        #filesFound.append(os.path.join(root, file))


#print(dicomFilesFound)
firstFilePath = dicomFilesFound[0]
first_file = firstFilePath

#files = [ os.path.join(path, f) for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) ]
#files = [ os.path.join(path, f) for f in os.listdir(path) ]
#isFiles = [ os.path.isfile(f) for f in files ]
#print(files)
#print(isFiles)
#first_file = next(os.path.join(path, f) for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)))
try:
    #print(first_file)
    dataset = pydicom.dcmread(first_file)
except InvalidDicomError as e:
    print("Invalid DICOM")
    exit(1)
except Exception as e:
    print("Exception:")
    print(e)
    exit(1)

print(dataset['StudyInstanceUID'].value)
