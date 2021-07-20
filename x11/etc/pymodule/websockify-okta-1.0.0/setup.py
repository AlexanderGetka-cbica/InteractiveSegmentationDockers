import os
from setuptools import setup

# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
    name = "websockify_okta",
    version = "0.1.0",
    author = "Alexander Getka",
    author_email = "alexgetka@gmail.com",
    description = ("Small amount of glue for token-verification using OKTA for unique user IDs."),
    license = "MIT",
    keywords = "ignore glue okta websockify token",
    packages=['websockify_okta'],
    long_description=read('README'),
    install_requires=['websockify'],
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Topic :: Utilities",
        "License :: MIT License",
    ],
)
