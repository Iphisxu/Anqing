import pandas as pd
import numpy as np

def calculate_statistics(sim, obs):
    """
    计算两个时间序列数据的相关性R、平均偏差ME、均方根误差RMSE、一致性指数IOA、标准化平均偏差NMB和标准化平均误差NME，并将结果导出为一个dataframe
    
    参数:
    sim -- 模拟数据的时间序列，格式为pandas Series
    obs -- 观测数据的时间序列，格式为pandas Series
    
    返回值:
    df -- 一个包含计算结果的pandas DataFrame
    """

    # 删除缺失值
    # sim = sim.dropna()
    # obs = obs.dropna()

    # 计算R
    r = np.corrcoef(sim, obs)[0, 1]

    # 计算ME
    me = np.mean(sim - obs)

    # 计算RMSE
    rmse = np.sqrt(np.mean((sim - obs) ** 2))

    # 计算IOA
    ioa = 1 - np.sum((sim - obs) ** 2) / np.sum((np.abs(sim - np.mean(obs)) + np.abs(obs - np.mean(obs))) ** 2)

    # 计算NMB
    nmb = 100 * np.sum(sim - obs) / np.sum(obs)

    # 计算NME
    nme = 100 * rmse / np.mean(obs)

    # 将计算结果存储为一个DataFrame
    df = pd.DataFrame({
        'R': [r],
        'ME': [me],
        'RMSE': [rmse],
        'IOA': [ioa],
        'NMB': [nmb],
        'NME': [nme]
    })

    # 对结果保留两位小数
    df = df.round(2)

    return df
