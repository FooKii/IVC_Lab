# IVC_Lab
*IVC_Lab, Summer 2019*

## The disadvantage of the DCT/Fourier Transform
- However, the big disadvantage of a Fourier expansion is that it has only frequency resolution and no time resolution. This means that although we might be able to determine all the frequencies present in a signal, we do not know at what time they are present. [PPT-Example](http://www.polyvalens.com/blog/wavelets/theory/)     

- 从傅里叶变换公式可以看出，它是以正弦波及其高次谐波为标准基的，因此它是对信号的一种总体上的分析，具有单一的局部定位能力，也就是在时域的良好定位是以频域的全部信号分析为代价的，对频域的良好定位是以时域的全部信号分析为代价的，时域和频域分析具有分析上的矛盾，傅立叶变换的频率谱中要么频率是准确的而时间是模糊的，要么时间是准确的而频率是模糊的，它不可能同时在时域和频域都具有良好的定位的能力。傅立叶变换是建立在平稳信号的基础上的，在非平稳时变信号的分析上，它却无能为力。[Link](https://blog.csdn.net/Augusdi/article/details/4166383)   

- [知乎](https://www.zhihu.com/question/22864189) 具体解释了傅立叶在什么情况下不行， 有信号图。时域相差很大的两个信号，可能频谱图一样. <吉布斯效应>， 不好拟合突变函数。 

- [Wavelet-tutorial](http://users.rowan.edu/~polikar/WTtutorial.html) 上面的图片可以放到ppt中 （注明reference） 

- [知乎](https://zhuanlan.zhihu.com/p/66189212) 从傅立叶到dwt  

## DWT - Preparation
- waveltets must have band-pass like spectrum  
> 需要说明，不同于FT的基函数 sin,cos ，小波母函数不具有特定的某一频率，而是具有一个范围内的频率，因此筛选的是一定范围的频率，类似于一个带通滤波器



