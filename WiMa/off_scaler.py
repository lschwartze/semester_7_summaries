# -*- coding: utf-8 -*-
"""
Created on Mon Jan 22 18:59:37 2024

@author: laurin
this program takes .off files (i think they have to be converted to .txt but i haven't checked)
and the moves them and rescales them such that the fit nicely into the scene
"""

import numpy as np
import os

center = np.array([0.9950,1,1])
radius = 3

for filename in os.listdir("off_copies/"):
    file_to_open = rf"off_copies/{filename}"
    print(f"working on {file_to_open}")
    with open(file_to_open,"r+") as f:
        lines = [line.rstrip() for line in f]
        # make coordinate string to list
        size_array = lines[1].split()
        num_vertices = int(size_array[0])
        
        # each coordinate list is mapped to float datatype
        coord = [lines[2+i] for i in range(num_vertices)]
        coord = [s.split() for s in coord]
        coord = [list(map(float, l)) for l in coord]
        # convert to numpy for better speed
        coord = np.array(coord)
        m = np.mean(coord,0)
        # this centers the object at 0
        coord = coord-m
        dist = np.linalg.norm(coord,axis=1)
        largest = np.max(dist)
        # this rescales the model
        coord = coord/largest*radius
        # this moves it to the desired center
        coord = coord + center
        coord = [list(map(str, l)) for l in coord]
        coord = [" ".join(l) for l in coord]
        
        for i in range(num_vertices):
            lines[2+i] = coord[i]
        for i in range(len(lines)):
            lines[i] = lines[i]+"\n"
            
    with open(file_to_open, "w") as f:
        f.writelines(lines)
        
        