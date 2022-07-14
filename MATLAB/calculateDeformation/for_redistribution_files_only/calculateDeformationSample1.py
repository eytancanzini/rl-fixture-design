#!/usr/bin/env python
"""
Sample script that uses the calculateDeformation module created using
MATLAB Compiler SDK.

Refer to the MATLAB Compiler SDK documentation for more information.
"""

from __future__ import print_function
import calculateDeformation
import matlab

my_calculateDeformation = calculateDeformation.initialize()

fixturePosIn = matlab.double([400.0, 800.0, 10.0], size=(1, 3))
drillPosIn = matlab.double([505.283, 487.164, 10.0], size=(1, 3))
zOut, xOut = my_calculateDeformation.calculateDeformation(fixturePosIn, drillPosIn, nargout=2)
print(zOut, xOut, sep='\n')

my_calculateDeformation.terminate()
