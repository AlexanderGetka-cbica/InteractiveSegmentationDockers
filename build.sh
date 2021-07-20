#!/bin/bash

VERSION="0721"

docker build --build-arg VERSION=${VERSION} -t alexandergetka/base:$VERSION base
docker build --build-arg VERSION=${VERSION} -t alexandergetka/x11:$VERSION x11
#docker build --build-arg VERSION=${VERSION} -t alexandergetka/slicer:$VERSION slicer
docker build --build-arg VERSION=${VERSION} -t alexandergetka/intsegwebhook:$VERSION webhook
#docker build --build-arg VERSION=${VERSION} -t alexandergetka/incise:$VERSION incise
docker build --build-arg VERSION=${VERSION} -t alexandergetka/captkdocker:$VERSION captk



#SLICER_MORPH_EXTS="MarkupsToModel Auto3dgm SegmentEditorExtraEffects Sandbox SlicerIGT RawImageGuess SlicerDcm2nii SurfaceWrapSolidify SlicerMorph"

#docker build \
#  --build-arg VERSION=${VERSION} --build-arg SLICER_EXTS="${SLICER_MORPH_EXTS}" \
#  -t alexandergetka/slicer-morph:$VERSION slicer-plus

#SLICER_DMRI_EXTS="ukftractography SlicerDMRI"

#docker build \
#  --build-arg VERSION=${VERSION} --build-arg SLICER_EXTS="${SLICER_DMRI_EXTS}" \
#  -t alexandergetka/slicer-dmri:$VERSION slicer-plus

#docker build --build-arg VERSION=${VERSION} -t alexandergetka/slicer-dev:$VERSION slicer-dev


#docker build -t alexandergetka/slicer3:$VERSION slicer3
#docker build --build-arg VERSION=${VERSION} --no-cache -t alexandergetka/slicer-chronicle:$VERSION slicer-chronicle
