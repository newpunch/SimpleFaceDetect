# SimpleFaceDetect
简单人脸识别GUI

这是一个简单人脸识别GUI程序，是我去年做的一个小东西。 采用MATLAB编程，并运用了其中的GUI编程实现人机交互，采用主成分分析和BP神经网络相结合的方法
主要采用主成分分析法是来提取人脸特征向量，主成分分析法介绍可浏览[这里9](http://blog.csdn.net/on2way/article/details/42175439)

利用此法将所有人脸在特征脸上的投影p提取出来把p归一化到[-1 +1]，然后作为神经网络的输入和神经网络的理论输出值。

利用BP神经网络训练，神经网络主要设置如下：
提取p中元素个数作为神经网络的输入层神经元个数
设置隐层神经元个数为10
输出层神经元个数为4，4表示识别出四个人
显示速率为200，学习率为0.01，迭代次数不超过5000，训练误差为0.001。

人脸库采用ORL人脸数据库，采用Matlab GUIDE运行程序将人脸库T文件夹放到E盘，训练人脸图像为1～20.jpg，测试图像为test.jpg。

![界面](https://github.com/newpunch/SimpleFaceDetect/blob/master/GUI.png)

![训练图](https://github.com/newpunch/SimpleFaceDetect/blob/master/NeuralNetworkTraining.png)
