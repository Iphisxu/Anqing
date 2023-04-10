# some functions to calculate results of model outputs
# Evan, 2023-03-31

import numpy as np
import xarray as xr
import pandas as pd
import geopandas as gpd
import shapely.geometry as sgeom
from shapely.prepared import prep
import matplotlib.pyplot as plt
from matplotlib import rcParams

# silence the warning note
import warnings
warnings.filterwarnings("ignore")

def cal_IOA(obsList, simList):
    '''
    calculate Willmott's Index of Agreement, so-called WIA or IOA
    '''
    if len(obsList) != len(simList):
        raise Exception("length of sim is not consistent with that of obs")
    # calculate the numerator and denominator for IOA
    numerator = np.sum((simList - obsList) ** 2)
    mean_obsList = np.mean(obsList)
    denominator = np.sum((np.abs(simList - mean_obsList) + np.abs(obsList - mean_obsList)) ** 2)
    ioa = 1 - (numerator / denominator)

    return ioa

def cal_RMSE(obsList, simList):
    """
    calculat Root Mean Square Error, so-called RMSE
    """
    if len(obsList) != len(simList):
        raise Exception("length of sim is not consistent with that of obs")
    rmse = np.sqrt(np.mean((simList - obsList) ** 2))
    
    return rmse

def evaluation_frame(obs, sim, df):
    '''
    print evaluation results
    
    '''
    dfout = pd.DataFrame([['obs mean', np.nanmean(obs)],
                          ['sim mean', np.nanmean(sim)],
                          ['R', df.corr().iloc[0,1]],
                          ['MB', np.nanmean(sim)-np.nanmean(obs)],
                          ['RMSE', cal_RMSE(obs.data,sim.data)],
                          ['IOA', cal_IOA(obs.data,sim.data)]],
                         columns=['param','value'])
    
    return dfout

