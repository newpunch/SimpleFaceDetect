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
set(handles.text1,'string','��ʶ�������ͼ��')
 % --- Executes on button press in recognise.
function recognise_Callback(hObject, eventdata, handles)
% hObject    handle to recognise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TrainDatabasePath=uigetdir('E:\T\', 'Select training database path');
global TestDatabasePath
value = bpnet(TestDatabasePath,TrainDatabasePath)
set(handles.text2,'string',value)
%������ȡ����
function [icaproject,wica]=bpFeatureExtract(imagepath)
% ����ѵ����ͼƬ����
Count=20;
%ͼ���ʽΪ.jpg;
S=[]; %���ڴ洢20��ͼ��ľ���
for i=1:Count
str=strcat(imagepath,int2str(i),'.jpg'); %�������ַ��������������ͼ����
eval('img=imread(str);');
img(:,:,1)=img(:,:,1);
img(:,:,2)=img(:,:,1);
img(:,:,3)=img(:,:,1);
[row col]=size(img); % ���һ��ͼ�������N1������N2
temp=reshape(img,row*col,1); %����һ��(N1*N2)x1 matrix
S=[S temp]; %S is a N1*N2xM matrix
end
sig=double(S');%sig��MxN1*N2 matrix
%��sig����ȥ��ֵ����
sigmean=mean(sig);%��ÿһ��ȡ��ֵ,imgsig��20x10304
for i=1:size(sig)
imgsig(i,:)=sig(i,:)-sigmean;
end
%��ȥ��ֵ�����ݽ��а׻�����
covariancematrix=cov(imgsig',1);%covariancematrix��20x20����
[E,D]=eig(covariancematrix);%E��D��20x20����
% ȥ��ֵΪ0������ֵ
v=[];
d=[];
for i=1:size(E,2)
if(D(i,i)>0)
v=[v E(:,i)];
d=[d D(i,i)];
end
end
%������ֵ�ɴ�С��������ֵ��Ӧ����������Ҳ����Ӧ������
Dccol=d;
Vc=v;
%��С��������
[Dcsort Dcindex]=sort(Dccol);
%Vc������
DcCols=size(Vc,2);
%����
for i=1:DcCols
 Vcsort(:,i)=Vc(:,Dcindex(DcCols-i+1));
 Dcsort(i)=Dccol(Dcindex(DcCols-i+1));
end
%ȡǰk���������ֵ��Ӧ����������������95������������ʱk=8
Dcsum=sum(Dcsort);
Dcsum_extract=0;
k=0;
while(Dcsum_extract/Dcsum<0.95)
 k=k+1;
 Dcsum_extract=sum(Dcsort(1:k));
end
%temp����ǰk�����ķ�0����ֵ��Ӧ������������ɵ�
i=1;
temp=[];
while(i<=k)
 temp(:,i)=Dcsort(i)^(-1/2)*Vcsort(:,i);
 i=i+1;
end
whiteningmatrix=temp';%���ڰ׻����ݵİ׻�����whiteningmatrix��8x20
%�ÿ���ICA�㷨��������w������50�Σ�
whitesig=whiteningmatrix*imgsig;
X=whitesig;%X��8x10304
[vectorsize,numsamples]=size(X);
B=zeros(vectorsize);%B��8x8
numofic=vectorsize;%numofic��8
for r=1:numofic
 i=1;
 maxnumiterations=50;%�������ĵ�������
w=rand(vectorsize,1)-.5;%������ó�ʼֵ
w=w/norm(w);%��ʼ��w��0��������ģΪ1
while i<=maxnumiterations+1
w=w-B*B'*w;
w=w/norm(w);
w=(X*((X'*w).^3))/numsamples-3*w;
w=w/norm(w);
i=i+1;
end

W(r,:)=w'*whiteningmatrix;%W(r,:)��1x20
B(:,r)=w;
end
%��ԭ�ź�
icaproject=W*sig*sig';%�����ɷ֣�W��8x40��icaproject��8x40��icaproject��ÿһ�б�ʾһ��ͼ�������ֵ
wica=W*sig;%ͶӰ�ռ�
%BP���������
function res=bpnet(TestDatabasePath,TrainDatabasePath)
%����������ͼƬ�����ڵ�·��������������ȡ����bpFeatureExtract���������������������ϵ�ͶӰp��ȡ����
imagepath=strcat(TrainDatabasePath,'\');
[p,wica]=bpFeatureExtract(imagepath);
%��p��һ����[-1 +1]��Ȼ����Ϊ�����������
p=premnmx(p')';
t=[1 0 0 0;1 0 0 0;1 0 0 0;1 0 0 0;1 0 0 0;0 1 0 0;0 1 0 0;0 1 0 0;0 1 0 0;0 1 0 0;
    0 0 1 0;0 0 1 0;0 0 1 0;0 0 1 0;0 0 1 0;0 0 0 1;0 0 0 1;0 0 0 1;0 0 0 1;0 0 0 1]';%��������������ֵ

%�������·
[prow pcol]=size(p);
num=prow*pcol;%��ȡp��Ԫ�ظ�����Ϊ��������������Ԫ����
net=newff(minmax(p),[num,10,4],{'tansig','tansig','purelin'},'traingda');%������Ԫ����Ϊ10���������Ԫ����Ϊ4��4��ʾʶ���������
net.trainParam.show=200;%��ʾ����Ϊ200
net.trainParam.lr=0.01;%ѧϰ��Ϊ0.01
net.trainParam.epochs=5000;%��������������5000
net.trainParam.goal=0.001;%ѵ�����Ϊ0.001
[net,tr]=train(net,p,t);
%��������ʶ��
imgtest=imread(strcat(TestDatabasePath,'\test.jpg'));
imgtest(:,:,1)=imgtest(:,:,1);
imgtest(:,:,2)=imgtest(:,:,1);
imgtest(:,:,3)=imgtest(:,:,1);
[row col]=size(imgtest); % �������������
imgtest=reshape(imgtest,1,row*col);
sig=double(imgtest);
imgtest=sig;
%�Ѵ�����ͼ��imgtest���ӿռ���ͶӰ
projectcoeftest=wica*(imgtest)';%projectcoeftest��8x1
ptest=premnmx(projectcoeftest);%��ͶӰֵprojectcoeftest��һ����[-1 +1]��Ȼ����Ϊ�����������
%����
result=sim(net,ptest)
%��ʾʶ�����������Ϣ
if result(1,1)>0.9
    res='ʶ�����������ǲ��Ե�һ���';
  elseif result(2,1)>0.9
    res='ʶ�����������ǲ��Եڶ����';
elseif result(3,1)>0.9
    res='ʶ�����������ǲ��Ե������';
elseif result(4,1)>0.9
    res='ʶ�����������ǲ��Ե������';
else res='ʶ�������ⲻ֪������ð������İ����';
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