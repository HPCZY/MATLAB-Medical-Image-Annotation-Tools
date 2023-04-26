function varargout = DicomLabeler(varargin)
% DICOMLABELER MATLAB code for DicomLabeler.fig
%      DICOMLABELER, by itself, creates a new DICOMLABELER or raises the existing
%      singleton*.
%
%      H = DICOMLABELER returns the handle to a new DICOMLABELER or the handle to
%      the existing singleton*.
%
%      DICOMLABELER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DICOMLABELER.M with the given input arguments.
%
%      DICOMLABELER('Property','Value',...) creates a new DICOMLABELER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DicomLabeler_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DicomLabeler_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DicomLabeler

% Last Modified by GUIDE v2.5 16-Jul-2020 10:14:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DicomLabeler_OpeningFcn, ...
                   'gui_OutputFcn',  @DicomLabeler_OutputFcn, ...
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


% --- Executes just before DicomLabeler is made visible.
function DicomLabeler_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DicomLabeler (see VARARGIN)

% Choose default command line output for DicomLabeler
handles.output = hObject;

%% init
clc
warning('off')
set(handles.axes1,'Visible','off')
set(handles.axes2,'Visible','off')
set(handles.listbox1,'Visible','off')

handles.files = {};

handles.folder = '';
handles.FILEREAD = 0;
handles.fileNames = {};
handles.Better = 0;
handles.fileNum = 0;
handles.fileIdx = 0;
handles.save = 0;
handles.img = {};
handles.mask = {};
handles.obj = {};
handles.dir = 1;
handles.range = 96;
handles.cx = 0;
handles.cy = 0;


set(handles.text1,'String','请点击“打开文件”选择你的图片')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DicomLabeler wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DicomLabeler_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Better = get(handles.radiobutton1,'value');
% Hint: get(hObject,'Value') returns toggle state of radiobutton1
guidata(hObject, handles);

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.save = get(handles.radiobutton2,'value');
% Hint: get(hObject,'Value') returns toggle state of radiobutton2
guidata(hObject, handles);

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.FILEREAD
    idx = get(handles.listbox1,'value');
    handles.fileIdx = idx;
    set(handles.text1,'String',['正在处理第',num2str(idx),'号图'])
    im = handles.files{handles.fileIdx};
    axes(handles.axes1);
    imshow(im)
end
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% openfile
% 获取图像集
[~,fileFolder,filterindex] = uigetfile('*.dcm','选择定标图像');
handles.folder = fileFolder;
dirOutput = dir(fullfile(fileFolder,'*.dcm'));
fileNames = {dirOutput.name};
handles.fileNames = fileNames;
if ~isempty(fileNames)
    handles.dir = 1;
    handles.FILEREAD = 1;
    handles.fileNum = length(fileNames);
    handles.fileIdx = 1;
    
    set(handles.text1,'String','成功读取路径下的数据')
else
   set(handles.text1,'String','读取失败') 
end

if handles.FILEREAD
    
    set(handles.listbox1,'Visible','on')
    set(handles.listbox1,'String',fileNames)

    handles.files = cell(handles.fileNum,1);
    handles.mask = cell(handles.fileNum,1);
    handles.obj = cell(handles.fileNum,1);
    handles.img = cell(handles.fileNum,1);

    for k = 1:handles.fileNum
        dcm = dicomread([fileFolder,fileNames{k}]);
        info = dicominfo([fileFolder,fileNames{k}]);      
        im = dicom2im(dcm,info);       
        handles.files{k} = im;
    end
    
     im = handles.files{handles.fileIdx};
     axes(handles.axes1);
    imshow(im)
end

guidata(hObject, handles);



% --- Executes on button press in begin.
function begin_Callback(hObject, eventdata, handles)
% hObject    handle to begin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Better = get(handles.radiobutton1,'value');
handles.save = get(handles.radiobutton2,'value');

if handles.FILEREAD
    set(handles.text1,'String','请点击目标的大致区域（中心）') 
imsrc = handles.files{handles.fileIdx};
[im,cx,cy] = zoom(imsrc,handles.range);
handles.cx = cx;
handles.cy = cy;

axes(handles.axes2);
imshow(im)
set(handles.text1,'String','请绘制（点击）目标轮廓节点') 
[out,mask] = manseg(im);
    
if handles.Better
    set(handles.text1,'String','正在优化轮廓') 
    T = 0.3;
    [out,mask] = better(out,mask,T);
    
end
imedge = mask-imerode(mask,strel('disk',1));
[x,y] = find(imedge);

axes(handles.axes1);
imshow(imsrc),hold on
plot(y+handles.cy-handles.range,x+handles.cx-handles.range,'r.')

axes(handles.axes2);
imshow(out)

mask = zeros(512,512);
mask((x+handles.cx-handles.range-1)+512*(y+handles.cy-handles.range-1)) = 1;

maske = imdilate(mask,strel('disk',1));
img = cat(3,imsrc+maske,imsrc-maske,imsrc-maske);

mask = imfill(mask>0,'holes');

handles.mask{handles.fileIdx} = uint8(mask*255);
handles.obj{handles.fileIdx} = uint8(imsrc.*mask*255);
handles.img{handles.fileIdx} = uint8(img*255);



if handles.save
    filemask = [handles.folder,'mask\'];
    fileobj = [handles.folder,'obj\'];
    fileimg = [handles.folder,'img\'];
    if handles.dir
    mkdir(filemask) 
    mkdir(fileobj)
    mkdir(fileimg)
    handles.dir = 0;
    end
   imwrite(handles.mask{handles.fileIdx},...
       [filemask,'mask',handles.fileNames{handles.fileIdx}(1:end-4),'.jpg']); 
   imwrite(handles.obj{handles.fileIdx},...
       [fileobj,'obj',handles.fileNames{handles.fileIdx}(1:end-4),'.jpg']); 
      imwrite(handles.img{handles.fileIdx},...
       [fileimg,'obj',handles.fileNames{handles.fileIdx}(1:end-4),'.jpg']); 
   
   dicomwrite(handles.mask{handles.fileIdx},...
       [filemask,'mask',handles.fileNames{handles.fileIdx}(1:end-4),'.dcm'])
   dicomwrite(handles.obj{handles.fileIdx},...
       [fileobj,'obj',handles.fileNames{handles.fileIdx}(1:end-4),'.dcm'])
   
   set(handles.text1,'String',['已将结果分别保存在',handles.folder,'(mask/obj)']) 
end

end


guidata(hObject, handles);


% --------------------------------------------------------------------
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.FILEREAD
    filemask = [handles.folder,'mask\'];
    fileobj = [handles.folder,'obj\'];
    fileimg = [handles.folder,'img\'];
    if handles.dir
    mkdir(filemask) 
    mkdir(fileobj)
    mkdir(fileimg)
    handles.dir = 0;
    end
   imwrite(handles.mask{handles.fileIdx},...
       [filemask,'mask',handles.fileNames{handles.fileIdx}(1:end-4),'.jpg']); 
   imwrite(handles.obj{handles.fileIdx},...
       [fileobj,'obj',handles.fileNames{handles.fileIdx}(1:end-4),'.jpg']); 
      imwrite(handles.img{handles.fileIdx},...
       [fileimg,'obj',handles.fileNames{handles.fileIdx}(1:end-4),'.jpg']); 
      
   dicomwrite(handles.mask{handles.fileIdx},...
       [filemask,'mask',handles.fileNames{handles.fileIdx}(1:end-4),'.dcm'])
   dicomwrite(handles.obj{handles.fileIdx},...
       [fileobj,'obj',handles.fileNames{handles.fileIdx}(1:end-4),'.dcm'])
   set(handles.text1,'String',['已将结果分别保存在',handles.folder,'(mask/obj)']) 
end

guidata(hObject, handles);



function im = dicom2im(dcm,info)
%% 灰度转CT值
dcm = double(dcm);
dcmCT = dcm * info.RescaleSlope + info.RescaleIntercept;

%% 调窗+归一化
k = 1;   
lv = info.WindowCenter - info.WindowWidth(k)/2;
uv = info.WindowCenter + info.WindowWidth(k)/2;
im = (dcmCT-lv)/info.WindowWidth(k);
im(im<0) = 0;
im(im>1) = 1;


%% 放大
function [out,x,y] = zoom(im,range)
% 准备工作
[M,N] = size(im);

% 手动选点
hold on
[y,x,~] = ginput(1);

x = round(x);
y = round(y);
tmp = zeros(512+range*2);
tmp(range+1:range+M,range+1:range+N) = im;

out = tmp(x:x+range*2,y:y+range*2);


function [out,mask,p] = manseg(im)
% 准备工作
[M,N] = size(im);
pnum = 0;
p = [];

% 手动选点
hold on
while 1
    [x,y,flag] = ginput(1);
    if flag==1
        pnum = pnum+1;
        plot(x,y,'b.','MarkerSize',20)
        p(pnum,1:2) = [y,x];
        if pnum>1
           line([p(pnum-1,2),p(pnum,2)],[p(pnum-1,1),p(pnum,1)],'LineWidth',2) 
        end
    else
        line([p(1,2),p(pnum,2)],[p(1,1),p(pnum,1)],'LineWidth',2) 
        break
    end
end
hold off

% 生成蒙板
if pnum<3
   error('至少三个点') 
end

p = [p;p(1:2,:)];

[x,y] = myspline(p); 

mask = zeros(M,N,'logical');
for k = 1:length(x)    
    xt = round(x(k));
    yt = round(y(k));
    
    if xt<1
        xt = 1;
    end
    if yt<1
        yt = 1;
    end
    if xt>M
        xt = M;
    end
    if yt>N
        yt = N;
    end
    mask(xt,yt) = 1;
end
mask = imfill(mask,'hole');

out = mask.*im; 
