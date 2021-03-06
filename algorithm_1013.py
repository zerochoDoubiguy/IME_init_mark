"""
created by zero on 21.08.10
对初始位置标记的数据进行分析，并进行展示

2021.10.13
对原有算法做了些调整

之前算法有点复杂，原因是原始数据太差，疲于应付数据上的异常，而在正常的数据内应该不会出现，因此本版算法将简化高效

"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import copy
import scipy.optimize as optimize
import statsmodels.api as sm


def smooth(a, WSZ):
    # a:原始数据，NumPy 1-D array containing the data to be smoothed
    # 必须是1-D的，如果不是，请使用 np.ravel()或者np.squeeze()转化
    # WSZ: smoothing window size needs, which must be odd number,
    # as in the original MATLAB implementation
    out0 = np.convolve(a, np.ones(WSZ, dtype=int), 'valid') / WSZ
    r = np.arange(1, WSZ - 1, 2)
    start = np.cumsum(a[:WSZ - 1])[::2] / r
    stop = (np.cumsum(a[:-WSZ:-1])[::2] / r)[::-1]
    return np.concatenate((start, out0, stop))


def forward_through_zero(data):
    """
    计算后向乘积是否小于0，如果<=0,则为1，表示两者过0，否则不过0 ，值为0
    :param data: list[float]
    :return:
    """
    res = []
    for i,e in enumerate(data):
        if i != len(data) - 1:
            if e * data[i+1]<=0:
                res.append(1)
            else:
                res.append(0)
        else:
            res.append(0)
    return  res

def cal_cross_zero_times(df,col,raster_resolution,axis):
    """
    统计df 在 col列的过0点的数量，排除方差大且波动剧烈的部分
    :param df: df DataFrame
    :param col: 列名
    :param raster_resolution: mm，栅格分辨率 0.008
    :param axis : str ， x or y
    :return: 是否合格
    """
    cycle_nums = int((df[axis].max()- df[axis].min())/ raster_resolution) + 1
    cross_threshold = 2 * cycle_nums
    if cross_threshold==0:
        return False
    l = df[col].values.tolist()
    count = 0
    num = l[0]
    for e in l:
        if e*num<0:
            count += 1
            num = e
            if count > cross_threshold:
                return False
    return True

def zero_clean(axis,df,l,interval,theta=0.8):
    """
    clean the zero points recognized
    :param l: 结果，list
    :param interval: 栅格周期一半
    :param theta: 阈值，设置为0.8
    :param col: 波段
    :param df:  数据，DataFrame
    :return: new_l ,list
    """
    new_l = [] # 记录合并后的位置列表
    new_l_ind = [] # 记录新的独立索引，用于画图展示
    usd_dict = {}
    for i,e in enumerate(l):
        if i in usd_dict:
            continue
        else:
            num = df.loc[e, axis]
            if i!= len(l) - 1 :

                ind = i+1
                num_next = df.loc[l[ind],axis]
                total = num
                while(abs(num_next-num) < interval * theta and ind != len(l)): # 相邻点很接近
                    usd_dict[ind] = 1
                    total += num_next
                    ind += 1
                    if ind != len(l):
                        num_next = df.loc[l[ind],axis]
                new_l.append(total/(ind-i))
            else:
                new_l.append(num)
            new_l_ind.append(e)
    return new_l,new_l_ind

if __name__ == "__main__":
    # columns = ['x','y','z','Tx','Ty','Tz','532-high','633-high','780-high','852-1','532-2','633-2','780-2','852-2','532-3','633-3','780-3','852-3','532-4','633-4','780-4','852-4','unusd']
    # file_name = "movex_negative"
    file_name = "movex_positive"
    columns = ['x', 'y', 'z', 'tx', 'ty', 'tz', '532_high', '633_high', '780_high',\
    '852_high', '532_zero', '633_zero', '780_zero', '852_zero']
    file_path = "E:\\软件架构资料学习\\测试采集数据\\扫描数据20211012\\211011初始位置数据\\1\\"
    # csv_name = "movex_negative.csv"
    csv_name = "movex_positive.csv"
    data = pd.read_csv(file_path+csv_name)
    data.columns = columns
    # data = pd.read_csv('E:\\软件架构资料学习\\coarseScan\\movex_positive.csv')
    data = data.drop(data[data['x'] == 0].index)
    data = data.sort_values(by='x')
    print(data.iloc[:, 0])
    fig0 = plt.figure()
    # plt.plot(data.index,data['x'])
    plt.scatter(data.index,data['x'])
    plt.title(file_name)
    plt.show()

    fig = plt.figure()
    columns = ['532_high', '633_high', '780_high', '852_high']

    for col in columns:
        data[col + '_diff'] = data[col].diff()

    plt.subplot(341)
    plt.plot(data['x'], data['532_high'])
    plt.plot(data['x'], data['532_high_diff'])
    plt.title('532_high')

    plt.subplot(342)
    plt.plot(data['x'], data['633_high'])
    plt.plot(data['x'], data['633_high_diff'])
    plt.title('633_high')

    plt.subplot(343)
    plt.plot(data['x'], data['780_high'])
    plt.plot(data['x'], data['780_high_diff'])
    plt.title('780_high')

    plt.subplot(344)
    plt.plot(data['x'], data['852_high'])
    plt.plot(data['x'], data['852_high_diff'])
    plt.title('852_high')

    # plt.subplot(345)
    # plt.plot(data['x'],data['532_zero'])
    # plt.title('532_zero')
    #
    # plt.subplot(346)
    # plt.plot(data['x'],data['633_zero'])
    # plt.title('633_zero')
    #
    # plt.subplot(347)
    # plt.plot(data['x'],data['780_zero'])
    # plt.title('780_zero')
    #
    # plt.subplot(348)
    # plt.plot(data['x'],data['852_zero'])
    # plt.title('852_zero')
    # 当前处理的是 上到下

    """
    绘制信号图可以发现高级光还能用，但是需要降噪，暂定的降噪方案，滑动平均
    """
    df_filter = copy.deepcopy(data)  #
    df_filter['532_high'] = smooth(np.array(data['532_high']), 101)
    df_filter['633_high'] = smooth(np.array(data['633_high']), 101)
    df_filter['780_high'] = smooth(np.array(data['780_high']), 101)
    df_filter['852_high'] = smooth(np.array(data['852_high']), 101)
    """
    对差分信号进行降噪
    """
    for col in columns:
        df_filter[col + '_diff'] = df_filter[col].diff()

    df_filter = df_filter.dropna(axis = 0)

    df_filter['532_high_diff_filter'] = smooth(np.array(df_filter['532_high_diff']), 101)
    df_filter['633_high_diff_filter'] = smooth(np.array(df_filter['633_high_diff']), 101)
    df_filter['780_high_diff_filter'] = smooth(np.array(df_filter['780_high_diff']), 101)
    df_filter['852_high_diff_filter'] = smooth(np.array(df_filter['852_high_diff']), 101)



    plt.subplot(345)
    plt.plot(df_filter['x'], df_filter['532_high'])
    plt.plot(df_filter['x'], df_filter['532_high_diff'])
    plt.title('633_filter')

    plt.subplot(346)
    plt.plot(df_filter['x'], df_filter['633_high'])
    plt.plot(df_filter['x'], df_filter['633_high_diff'])
    plt.title('633_filter')

    plt.subplot(347)
    plt.plot(df_filter['x'], df_filter['780_high'])
    plt.plot(df_filter['x'], df_filter['780_high_diff'])
    plt.title('780_filter')

    plt.subplot(348)
    plt.plot(df_filter['x'], df_filter['852_high'])
    plt.plot(df_filter['x'], df_filter['852_high_diff'])
    plt.title('852_filter')
    
    ax1 = fig.add_subplot(3, 4, 9)
    ax1.plot(df_filter['x'],df_filter['532_high_diff'])
    ax1.plot(df_filter['x'], df_filter['532_high_diff_filter'])
    plt.title('532')

    ax1 = fig.add_subplot(3, 4, 10)
    ax1.plot(df_filter['x'],df_filter['633_high_diff'])
    ax1.plot(df_filter['x'], df_filter['633_high_diff_filter'])
    plt.title('633')

    ax1 = fig.add_subplot(3, 4,11)
    ax1.plot(df_filter['x'],df_filter['780_high_diff'])
    ax1.plot(df_filter['x'], df_filter['780_high_diff_filter'])
    plt.title('780')

    ax1 = fig.add_subplot(3, 4, 12)
    ax1.plot(df_filter['x'],df_filter['852_high_diff'])
    ax1.plot(df_filter['x'], df_filter['852_high_diff_filter'])
    plt.title('852')

    # plt.show()

    # ax1 = fig.add_subplot(3, 4, 9)
    # fig = sm.graphics.tsa.plot_acf(df_filter['780_high'], lags=len(df_filter) * 0.9,ax=ax1)
    # ax1.xaxis.set_ticks_position('bottom')
    # ax1.set_title("780" + "_ACF")
    # fig = sm.graphics.tsa.plot_acf(df_filter['780_high_diff'], lags=len(df_filter) * 0.9)

    plt.show()
    # plt.close()
    """
    统计当前的周期，并进行切片，以计算标准差，借助标准差识别一阶导为0的峰值。
    设定一个阈值，选择区间方差大于极值百分比的区间
    """

    df_filter = df_filter.reset_index(drop=True)
    raster_resolution = 0.008/2 #8um 栅格中间距离，其实是周期的一半，ppt里左右两侧不一致左侧可能16um，右侧16.2um？
    cycle_nums = int((df_filter["x"].max()-df_filter['x'].min())/raster_resolution)
    interval = int(len(df_filter)/cycle_nums)
    fig2 = plt.figure()
    df_interval = pd.DataFrame(columns = np.arange(0,cycle_nums,1))
    std_threshold = {}
    cross_threshold = 4 # 过0 的次数，判断是否是周期范围内
    std_ratio = 0.5# 最大方差的0.1范围内认为都是周期。
    over_dict = {} # 存放各个波长高于阈值的区间ind
    for ind,col in enumerate(columns):
        temp_max = 0
        for i in range(cycle_nums):
            slice = df_filter.iloc[i*interval:(i+1)*interval,:]

            df_interval.loc['var',i] = slice[col+'_diff_filter'].std()
            # if cal_cross_zero_times(slice,col+'_diff_filter',raster_resolution,'x'): # 统计方差时也要确保处于周期内，排除处于栅格周期但不稳定的 方差大但是局部高频的情况
            temp_max = max(temp_max,slice[col+'_diff_filter'].std())
        # plt.title(col+'_diff')
        std_threshold[col] = temp_max  #
        ax1 = fig2.add_subplot(1, 4, ind + 1)
        df_interval.plot(y=np.arange(0,cycle_nums,1), kind='bar',title = col+'_diff',ax =ax1)

        over_list = []
        for i in range(cycle_nums):
            if df_interval.loc['var',i] > temp_max * std_ratio:
                over_list.append(i)
        over_dict[col] = over_list
    plt.show()
    plt.close()

    columns = columns[1:]
    fig4 = plt.figure()
    for ind,col in enumerate(columns):
        fig4.add_subplot(4,1,ind+1)
        max_i = max(over_dict[col])
        min_i = min(over_dict[col])
        over_slice = df_filter.loc[min_i*interval:(max_i+1)*interval,:]
        plt.plot(df_filter['x'], df_filter[col])
        plt.plot(over_slice['x'], over_slice[col])
    plt.show()
    plt.close()


    # 找到 方差为0的点，并对每个点前后取半个周期判断标准差是否在阈值内，判断该点是否为0.
    res_dict = {}
    for col in columns :
        max_i = max(over_dict[col])
        min_i = min(over_dict[col])
        over_slice = df_filter.loc[min_i * interval:(max_i + 1) * interval, :]
        over_slice.loc[:,'through_zero_'+col] = forward_through_zero(over_slice[col+"_diff_filter"].values.tolist())
        slice_through_zero = over_slice.loc[over_slice.loc[:,'through_zero_'+col] == 1]
        res = []
        """
        对每一个std=0的点，查看前后interval 个，看std是否符合要求
        """
        for index,row in slice_through_zero.iterrows():
            # upper = min(len(df_filter)-1,int(index+0.5*interval))
            # lower = max(0,int(index - 0.5*interval))
            # temp_slice = df_filter.loc[lower:upper,:]
            # temp_std = temp_slice[col+"_diff_filter"].std()
            # if temp_std >= std_threshold[col]*(1-std_ratio) and cal_cross_zero_times(temp_slice,col+"_diff_filter",raster_resolution,'x'): ## 该导数为0点是峰值
            res.append(index)
        res_dict[col] = res
    """
    通过分析发现获得的点有重复和临近的现象，因此需要对结果进行合并
    xpa标记相邻栅格距离为0.008mm，而波谷和波峰的插值为0.004mm左右，可以据此对数据进行清洗
    """
    res_merge_dict = {} # 记录经过清洗后的df中的ind
    point_dict = {} # 记录合并后的位置结果
    for col in columns:
        point_dict,res_merge_dict[col] = zero_clean('x',df_filter,res_dict[col],raster_resolution,0.8)

    """
    对每个波段进行画图
    """
    print('start to plot')
    fig3 = plt.figure(figsize=(30,40))
    for i,col in enumerate(columns):
        ax1 = fig3.add_subplot(4, 2, i*2+1)
        ax1.plot(df_filter['x'], df_filter[col])
        x_l = []
        y_l = []
        for e in res_dict[col]:
            x_l.append(df_filter.loc[e,'x'])
            y_l.append(df_filter.loc[e,col])
        ax1.scatter(x_l,y_l,c='red')
        for inddd in range(len(x_l)):
            plt.annotate(x_l[inddd], xy=(x_l[inddd], y_l[inddd]))
        plt.title(col)

        ax1 = fig3.add_subplot(4, 2, i*2+2)
        ax1.plot(df_filter['x'], df_filter[col])
        x_l = []
        y_l = []
        for e in res_merge_dict[col]:
            x_l.append(df_filter.loc[e,'x'])
            y_l.append(df_filter.loc[e,col])
        ax1.scatter(x_l,y_l,c='red')
        for inddd in range(len(x_l)):
            plt.annotate(x_l[inddd], xy=(x_l[inddd], y_l[inddd]))
        plt.title(col+"_merge")
    # plt.savefig(file_name+'.png')
    plt.show()
    plt.close()

    """
    合并方法没啥问题，接下来就是要把正负方向移动的放在一起
    """








