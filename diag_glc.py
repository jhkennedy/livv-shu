#!/usr/bin/env python3

"""
Recreation of Shu's MATLAB plot scripts.
"""

import numpy as np
import scipy as sp
from matplotlib import pyplot as plt
from netCDF4 import Dataset

# --------------------------------------------------------------
input_file1 = 'IG1850_f09_g16.cism.h.0002-01-01-00000.nc_yellow'
input_file2 = 'IG1850_f09_g16.cism.h.0011-01-01-00000.nc'
# --------------------------------------------------------------
VAR = 'temp'
# --------------------------------------------------------------
# varibles:
#     temp(time, level, y1, x1) -- ice temperature
#     usurf(time, y1, x1)       -- ice upper surface elevation
#     thk(time, y1, x1)         -- ice thickness
#     artm(time, y1, x1)        -- annual mean air temperature
#     acab(time, y1, x1)        -- accumulation, ablation rate
#     bmlt(time, y1, x1)        -- basal melt rate
#     bwat(time, y1, x1)        -- basal water depth
#     topg(time, y1, x1)        -- bedrock topography
#     uvel(time, level, y0, x0) -- ice velocity in x direction
#     uflx(time, y0, x0)        -- flux in x direction
#     vvel(time, level, y0, x0) -- ice velocity in y direction
#     vflx(time, y0, x0)        -- flux in y direction
# coordinates
#     level(level)              -- sigma layers,positive = "down"
#     x0(x0)                    -- Cartesian x-coordinate, velocity grid
#     y0(y0)                    -- Cartesian x-coordinate, velocity grid
#     x1(x1)                    -- Cartesian y-coordinate
#     y1(y1)                    -- Cartesian y-coordinate
xy0_vars = ['uvel','uflx','vvel','vflx']
lev_vars = ['temp','uvel','vvel']

# read in coordinates
ncid = Dataset(input_file1, 'r')
x1 = ncid.variables['x1'] 
y1 = ncid.variables['y1'] 
x0 = ncid.variables['x0'] 
y0 = ncid.variables['y0'] 
level = ncid.variables['level'] 
TIME = ncid.variables['time'] 

y1_grid, x1_grid = sp.meshgrid(y1[:], x1[:], indexing='ij')
y0_grid, x0_grid = sp.meshgrid(y0[:], x0[:], indexing='ij')

# --------------------------------------------------------------
# convert x,y to lon,lat
# later...
# temperorily use this
RATIO = abs(y0[0]-y0[-1])/abs(x0[0]-x0[-1])
# --------------------------------------------------------------

if VAR in lev_vars:
    nz = 11;
else:
    nz = 1;

if VAR in xy0_vars:
    X = x0[:]
    Y = y0[:]
    XX = x0_grid
    YY = y0_grid
else:
    X = x1[:]
    Y = y1[:]
    XX = x1_grid
    YY = y1_grid


# read in variables and close files
TEMP = ncid.variables[VAR]

ncid2 = Dataset(input_file2, 'r')
TEMP2 = ncid2.variables[VAR] 
TIME2 = ncid2.variables['time'] 

#TODO:TEMP(abs(TEMP(:))<1e-6) = NaN
#TODO:TEMP2(abs(TEMP2(:))<1e-6) = NaN
#TODO:addpath('m_map')
# --------------------------------------------------------------
# draw figures
for lvl in range(nz):
    plt.figure(figsize=(15,9))

    ax1 = plt.subplot(1,3,1)
    plt.title('input_file1; TIME='+str(TIME[-1]))
    if VAR in lev_vars:
        plt.contourf(XX,YY,TEMP[-1,lvl,:,:], 10, cmap='viridis')
    else:
        plt.contourf(XX,YY,TEMP[-1,:,:], 10, cmap='viridis')
    plt.colorbar(orientation='horizontal')
    ax1.set_xticks([])
    ax1.set_yticks([])
    
    ax2 = plt.subplot(1,3,2)
    plt.title('input_file2; TIME='+str(TIME2[-1]))
    if VAR in lev_vars:
        plt.contourf(XX,YY,TEMP2[-1,lvl,:,:], 10, cmap='viridis')
    else:
        plt.contourf(XX,YY,TEMP2[-1,:,:], 10, cmap='viridis')
    plt.colorbar(orientation='horizontal')
    ax2.set_xticks([])
    ax2.set_yticks([])
    
    ax3 = plt.subplot(1,3,3)
    plt.title('input_file2 - input_file1')
    if VAR in lev_vars:
        plt.contourf(XX,YY,TEMP2[-1,lvl,:,:] - TEMP[-1,lvl,:,:], 10, cmap='viridis')
    else:
        plt.contourf(XX,YY,TEMP2[-1,:,:] - TEMP[-1,:,:], 10, cmap='viridis')
    plt.colorbar(orientation='horizontal')
    ax3.set_xticks([])
    ax3.set_yticks([])
    
        
    plt.suptitle(VAR+' for LEVEL='+str(level[lvl]))

    plt.show()

# clean up
ncid.close()
ncid2.close()
