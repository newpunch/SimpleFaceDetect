function varargout = BP(varargin)
% BP M-file for BP.fig
%      BP, by itself, creates a new BP or raises the existing
%      singleton*.
%
%      H = BP returns the handle to a new BP or the handle to
%      the existing singleton*.
%
%      BP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BP.M with the given input arguments.
%
%      BP('Property','Value',...) creates a new BP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BP

% Last Modified by GUIDE v2.5 13-Jun-2014 20:40:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BP_OpeningFcn, ...
                   'gui_OutputFcn',  @BP_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BP is made visible.
function BP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BP (see VARARGIN)

% Choose default command line output for BP
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BP wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BP_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in input.
function input_Callback(hObject, eventdata, handles)
% hObject    handle to input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TestDatabasePath
TestDatabasePath=uigetdir('E:\T\', 'Select test database path');
axes(handles.axes1);
a=imread(strcat(TestDatabasePath,'\test.jpg'));
imshow(a)
set(handles.text1,'string','待识别的人脸图像')
 % --- Executes on button press in recognise.
function recognise_Callback(hObject, eventdata, handles)
% hObject    handle to recognise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TrainDatabasePath=uigetdir('E:\T\', 'Select training database path');
global TestDatabasePath
value = bpnet(TestDatabasePath,TrainDatabasePath)
set(handles.text2,'string',value)
%特征提取程序：
function [icaproject,wica]=bpFeatureExtract(imagepath)
% 用于训练的图片数量
Count=20;
%图像格式为.jpg;
S=[]; %用于存储20幅图像的矩阵
for i=1:Count
str=strcat(imagepath,int2str(i),'.jpg'); %把两个字符串连接起来组成图像名
eval('img=imread(str);');
img(:,:,1)=img(:,:,1);
img(:,:,2)=img(:,:,1);
img(:,:,3)=img(:,:,1);
[row col]=size(img); % 获得一幅图像的行数N1和列数N2
temp=reshape(img,row*col,1); %产生一个(N1*N2)x1 matrix
S=[S temp]; %S is a N1*N2xM matrix
end
sig=double(S');%sig是MxN1*N2 matrix
%对sig矩阵去均值处理
sigmean=mean(sig);%对每一列取均值,imgsig是20x10304
for i=1:size(sig)
imgsig(i,:)=sig(i,:)-sigmean;
end
%对去均值的数据进行白化处理
covariancematrix=cov(imgsig',1);%covariancematrix是20x20矩阵
[E,D]=eig(covariancematrix);%E和D是20x20矩阵
% 去掉值为0的特征值
v=[];
d=[];
for i=1:size(E,2)
if(D(i,i)>0)
v=[v E(:,i)];
d=[d D(i,i)];
end
end
%将特征值由大到小排序，特征值对应的特征向量也作相应的排序
Dccol=d;
Vc=v;
%从小到大排序
[Dcsort Dcindex]=sort(Dccol);
%Vc的列数
DcCols=size(Vc,2);
%反序
for i=1:DcCols
 Vcsort(:,i)=Vc(:,Dcindex(DcCols-i+1));
 Dcsort(i)=Dccol(Dcindex(DcCols-i+1));
end
%取前k个最大特征值对应的特征向量，保留95％的能量，此时k=8
Dcsum=sum(Dcsort);
Dcsum_extract=0;
k=0;
while(Dcsum_extract/Dcsum<0.95)
 k=k+1;
 Dcsum_extract=sum(Dcsort(1:k));
end
%temp是由前k个最大的非0特征值对应的特征向量组成的
i=1;
temp=[];
while(i<=k)
 temp(:,i)=Dcsort(i)^(-1/2)*Vcsort(:,i);
 i=i+1;
end
whiteningmatrix=temp';%用于白化数据的白化矩阵，whiteningmatrix是8x20
%用快速ICA算法求分离矩阵w（迭代50次）
whitesig=whiteningmatrix*imgsig;
X=whitesig;%X是8x10304
[vectorsize,numsamples]=size(X);
B=zeros(vectorsize);%B是8x8
numofic=vectorsize;%numofic是8
for r=1:numofic
 i=1;
 maxnumiterations=50;%设置最大的迭代次数
w=rand(vectorsize,1)-.5;%随机设置初始值
w=w/norm(w);%初始化w（0），令其模为1
while i<=maxnumiterations+1
w=w-B*B'*w;
w=w/norm(w);
w=(X*((X'*w).^3))/numsamples-3*w;
w=w/norm(w);
i=i+1;
end

W(r,:)=w'*whiteningmatrix;%W(r,:)是1x20
B(:,r)=w;
end
%求原信号
icaproject=W*sig*sig';%独立成分，W是8x40，icaproject是8x40，icaproject的每一列表示一幅图像的特征值
wica=W*sig;%投影空间
%BP神经网络程序：
function res=bpnet(TestDatabasePath,TrainDatabasePath)
%先设置人脸图片库所在的路径，调用特征提取函数bpFeatureExtract，将所有人脸在特征脸上的投影p提取出来
imagepath=strcat(TrainDatabasePath,'\');
[p,wica]=bpFeatureExtract(imagepath);
%把p归一化到[-1 +1]，然后作为神经网络的输入
p=premnmx(p')';
t=[1 0 0 0;1 0 0 0;1 0 0 0;1 0 0 0;1 0 0 0;0 1 0 0;0 1 0 0;0 1 0 0;0 1 0 0;0 1 0 0;
    0 0 1 0;0 0 1 0;0 0 1 0;0 0 1 0;0 0 1 0;0 0 0 1;0 0 0 1;0 0 0 1;0 0 0 1;0 0 0 1]';%神经网络的理论输出值

%设计神经网路
[prow pcol]=size(p);
num=prow*pcol;%提取p中元素个数作为神经网络的输入层神经元个数
net=newff(minmax(p),[num,10,4],{'tansig','tansig','purelin'},'traingda');%隐层神经元个数为10，输出层神经元个数为4，4表示识别出两个人
net.trainParam.show=200;%显示速率为200
net.trainParam.lr=0.01;%学习率为0.01
net.trainParam.epochs=5000;%迭代次数不超过5000
net.trainParam.goal=0.001;%训练误差为0.001
[net,tr]=train(net,p,t);
%用神经网络识别
imgtest=imread(strcat(TestDatabasePath,'\test.jpg'));
imgtest(:,:,1)=imgtest(:,:,1);
imgtest(:,:,2)=imgtest(:,:,1);
imgtest(:,:,3)=imgtest(:,:,1);
[row col]=size(imgtest); % 获得行数和列数
imgtest=reshape(imgtest,1,row*col);
sig=double(imgtest);
imgtest=sig;
%把待测试图像imgtest在子空间上投影
projectcoeftest=wica*(imgtest)';%projectcoeftest是8x1
ptest=premnmx(projectcoeftest);%把投影值projectcoeftest归一化到[-1 +1]，然后作为神经网络的输入
%仿真
result=sim(net,ptest)
%显示识别出的人名信息
if result(1,1)>0.9
    res='识别结果：此人是测试第一组的';
  elseif result(2,1)>0.9
    res='识别结果：此人是测试第二组的';
elseif result(3,1)>0.9
    res='识别结果：此人是测试第三组的';
elseif result(4,1)>0.9
    res='识别结果：此人是测试第四组的';
else res='识别结果：这不知道哪里冒出来的陌生人';
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'axes1') returns contents of edit2 as text
%        str2double(get(hObject,'axes1')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function recognise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recognise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
