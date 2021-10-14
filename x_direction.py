"""
created by zero on 21.08.10
对初始位置标记的数据进行分析，并进行展示

"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import copy
import scipy.optimize as optimize
import statsmodels.api as sm


def smooth(a,WSZ):
    # a:原始数据，NumPy 1-D array containing the data to be smoothed
    # 必须是1-D的，如果不是，请使用 np.ravel()或者np.squeeze()转化
    # WSZ: smoothing window size needs, which must be odd number,
    # as in the original MATLAB implementation
    out0 = np.convolve(a,np.ones(WSZ,dtype=int),'valid')/WSZ
    r = np.arange(1,WSZ-1,2)
    start = np.cumsum(a[:WSZ-1])[::2]/r
    stop = (np.cumsum(a[:-WSZ:-1])[::2]/r)[::-1]
    return np.concatenate((  start , out0, stop  ))

def kalmamFilter(z):
    n_iter = len(z)
    sz = (n_iter,)  # size of array
    xhat = np.zeros(sz)  # a posteri estimate of x
    P = np.zeros(sz)  # a posteri error estimate
    xhatminus = np.zeros(sz)  # a priori estimate of x
    Pminus = np.zeros(sz)  # a priori error estimate
    K = np.zeros(sz)  # gain or blending factor
    R = 0.1 ** 2  # estimate of measurement variance, change to see effect  ###这是需要修改的
    # intial guesses
    xhat[0] = 0.0
    P[0] = 1.0
    Q = 1e-5  # process variance
    for k in range(1, n_iter):
        # time update
        xhatminus[k] = xhat[k - 1]  # X(k|k-1) = AX(k-1|k-1) + BU(k) + W(k),A=1,BU(k) = 0
        Pminus[k] = P[k - 1] + Q  # P(k|k-1) = AP(k-1|k-1)A' + Q(k) ,A=1

        # measurement update
        K[k] = Pminus[k] / (Pminus[k] + R)  # Kg(k)=P(k|k-1)H'/[HP(k|k-1)H' + R],H=1
        xhat[k] = xhatminus[k] + K[k] * (z[k] - xhatminus[k])  # X(k|k) = X(k|k-1) + Kg(k)[Z(k) - HX(k|k-1)], H=1
        P[k] = (1 - K[k]) * Pminus[k]  # P(k|k) = (1 - Kg(k)H)P(k|k-1), H=1
    #    pylab.figure()
    #    pylab.plot(z,'k+',label='noisy measurements')     #测量值
    #    pylab.plot(xhat,'b-',label='a posteri estimate')  #过滤后的值
    #    pylab.axhline(x,color='g',label='truth value')    #系统值
    #    pylab.legend()
    return xhat.tolist()


def func(x, p):
    """
      一元二次拟合 ：ax**2+bx+c
    """
    a,b,c = p
    return a*(x-b)*(x-b) + c


def func2(x, C, p_ans):
    """
      多项式拟合 ：(a*x**2+b*x+c)-(d*x**2+e*x+f)*cos(2*pi*k*x+fi)
    """
    a, b, c, d, e, f = C
    return (a * x * x + b * x + c) - (d * x * x + e * x + f) * np.cos(2 * np.pi * p_ans[2] * x + p_ans[3])


# def redis(p, y, x):
#     return y - func(x, p)
#
# def func_envi(x,p):
#     """
#     结合得到的fi，k计算a,b,c,d,e,f
#     """
#




if __name__ == "__main__":
    # columns = ['x','y','z','Tx','Ty','Tz','532-high','633-high','780-high','852-1','532-2','633-2','780-2','852-2','532-3','633-3','780-3','852-3','532-4','633-4','780-4','852-4','unusd']
    columns = ['x', 'y', 'z', 'tx', 'ty', 'tz', '532_high', '633_high', '780_high',\
    '852_high', '532_zero', '633_zero', '780_zero', '852_zero']
    file_path = "E:\\软件架构资料学习\\测试采集数据\\扫描数据20211012\\211011初始位置数据\\1\\"
    csv_name = "movex_negative.csv"
    data = pd.read_csv(file_path+csv_name)
    data.columns = columns
    # data = pd.read_csv('E:\\软件架构资料学习\\coarseScan\\movex_positive.csv')
    data = data.drop(data[data['x'] == 0].index)
    data = data.sort_values(by='x')
    print(data.iloc[:,0])
    fig = plt.figure()
    columns = ['532_high','633_high','780_high','852_high']

    for col in columns:
        data[col+'_diff'] = data[col].diff()

    plt.subplot(241)
    plt.plot(data['x'],data['532_high'])
    plt.plot(data['x'],data['532_high_diff'])
    plt.title('532_high')

    plt.subplot(242)
    plt.plot(data['x'],data['633_high'])
    plt.plot(data['x'], data['633_high_diff'])
    plt.title('633_high')

    plt.subplot(243)
    plt.plot(data['x'],data['780_high'])
    plt.plot(data['x'], data['780_high_diff'])
    plt.title('780_high')

    plt.subplot(244)
    plt.plot(data['x'],data['852_high'])
    plt.plot(data['x'], data['852_high_diff'])
    plt.title('852_high')

    # plt.subplot(245)
    # plt.plot(data['x'],data['532_zero'])
    # plt.title('532_zero')
    #
    # plt.subplot(246)
    # plt.plot(data['x'],data['633_zero'])
    # plt.title('633_zero')
    #
    # plt.subplot(247)
    # plt.plot(data['x'],data['780_zero'])
    # plt.title('780_zero')
    #
    # plt.subplot(248)
    # plt.plot(data['x'],data['852_zero'])
    # plt.title('852_zero')
    # 当前处理的是 上到下

    """
    绘制信号图可以发现高级光还能用，但是需要降噪，暂定的降噪方案，滑动平均和傅里叶降噪
    """
    df_filter = copy.deepcopy(data) #
    df_filter['532_high'] = smooth(np.array(data['532_high']), 101)
    df_filter['633_high'] = smooth(np.array(data['633_high']), 101)
    df_filter['780_high'] = smooth(np.array(data['780_high']), 101)
    df_filter['852_high'] = smooth(np.array(data['852_high']), 101)

    for col in columns:
        df_filter[col+'_diff'] = df_filter[col].diff()

    plt.subplot(245)
    plt.plot(data['x'],df_filter['532_high'])
    plt.plot(df_filter['x'], df_filter['532_high_diff'])
    plt.title('633_filter')

    plt.subplot(246)
    plt.plot(data['x'],df_filter['633_high'])
    plt.plot(df_filter['x'], df_filter['633_high_diff'])
    plt.title('633_filter')

    plt.subplot(247)
    plt.plot(data['x'],df_filter['780_high'])
    plt.plot(df_filter['x'], df_filter['780_high_diff'])
    plt.title('780_filter')

    plt.subplot(248)
    plt.plot(data['x'],df_filter['852_high'])
    plt.plot(df_filter['x'], df_filter['852_high_diff'])
    plt.title('852_filter')

    # plt.show()

    # ax1 = fig.add_subplot(3, 4, 9)
    # fig = sm.graphics.tsa.plot_acf(df_filter['780_high'], lags=len(df_filter) * 0.9,ax=ax1)
    # ax1.xaxis.set_ticks_position('bottom')
    # ax1.set_title("780" + "_ACF")
    # fig = sm.graphics.tsa.plot_acf(df_filter['780_high_diff'], lags=len(df_filter) * 0.9)
    
    plt.show()
    # plt.close()
    interval_num = 10
    interval = int(len(df_filter)/10)
    figure = plt.figure()
    df_interval = pd.DataFrame(columns = np.arange(0,interval_num,1))
    for i in range(interval_num):
        slice = df_filter.iloc[i*interval:(i+1)*interval,:]
        df_interval.loc['var',i] = slice['780_high'].std()
        ax1 = figure.add_subplot(10, 1, i+1)
        fig = sm.graphics.tsa.plot_acf(slice['780_high'], lags=len(slice) * 0.9, ax=ax1)
        ax1.xaxis.set_ticks_position('bottom')
        ax1.set_title("780_" +str(i)+ "_ACF" )
    figure.show()
    # plt.close()
    df_interval.plot(y=np.arange(0,interval_num,1), kind='bar')



    plt.show()