% make gridmask.nc
% Date: 2022-05-26
% Edited by Evan
% ==================================
clc
clear
close all

% ==================================
% Read Gridfile
% ==================================
GridFile = 'GRIDCRO2D_2021076.nc';
close

lat = ncread(GridFile,'LAT');
lon = ncread(GridFile,'LON');  

% ==================================
% Set Region
% ==================================

% read shp file of cities 
ffbsg={'F:/Data/City_Boundary/Guangd'};
fileFolder=fullfile(ffbsg{1});
dirOutput=dir(fullfile(fileFolder,'*.txt'));
tfile={dirOutput.name};

% set region names: the serial number comes from the sequence of local file
num_DG=2; % DG = Dongguan
num_FS=3; % FS = Foshan
num_GZ=4; % GZ = Guangzhou
num_QY=11; % QY = Qingyuan
num_SG=14; % SG = Shaoguan
num_SZ=15; % SZ = Shenzhen
num_ZS=20; % ZS = Zhongshan
num_ZH=21; % ZH = Zhuhai
num=[2,3,4,11,14,15,20,21];
DG(98,74)=0;
FS(98,74)=0;
GZ(98,74)=0;
QY(98,74)=0;
SG(98,74)=0;
SZ(98,74)=0;
ZS(98,74)=0;
ZH(98,74)=0;
mat={DG,FS,GZ,QY,SG,SZ,ZS,ZH};

for i=1:8
    [xx,yy]=textread(fullfile(fileFolder,tfile{num(i)}),'%f%f','delimiter', [',',';']);
    in=inpolygon(lon,lat,xx,yy); % logical
    inn=in*1; % convert to double
    mat{i}=inn;
end
DG=mat{1};
FS=mat{2};
GZ=mat{3};
QY=mat{4};
SG=mat{5};
SZ=mat{6};
ZS=mat{7};
ZH=mat{8};

% =====================================
%% revise netcdf file from GRIDCRO2D
% =====================================

ncid = netcdf.open('GRIDMASK_SG.nc','NC_WRITE');
netcdf.reDef(ncid);

% rename variable
netcdf.renameVar(ncid,1,'DG');
netcdf.renameVar(ncid,2,'FS');
netcdf.renameVar(ncid,3,'GZ');
netcdf.renameVar(ncid,4,'QY');
netcdf.renameVar(ncid,5,'SG');
% netcdf.renameVar(ncid,8,'SZ');
% netcdf.renameVar(ncid,9,'ZS');
netcdf.renameVar(ncid,6,'ZH');

% define attribute
% NOTE:the name of each variable with Spaces is 16 characters 
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'VAR-LIST',...
'DG              FS              GZ              QY              SG              ZH              PURB            ');

% end definition
netcdf.endDef(ncid);

% clear var data
finfo = ncinfo('GRIDMASK_SG.nc');
[~,variablesNum]=size(finfo.Variables);
for i=1:variablesNum
    vardata=zeros(finfo.Variables(1,i).Size);
    ncwrite('GRIDMASK_SG.nc',finfo.Variables(1,i).Name,vardata);
end
% write data
netcdf.putVar(ncid, 1, DG);
netcdf.putVar(ncid, 2, FS);
netcdf.putVar(ncid, 3, GZ);
netcdf.putVar(ncid, 4, QY);
netcdf.putVar(ncid, 5, SG);
% netcdf.putVar(ncid, SZid, SZ);
% netcdf.putVar(ncid, ZSid, ZS);
netcdf.putVar(ncid, 6, ZH);

        
netcdf.close(ncid);
ncdisp('GRIDMASK_SG.nc')

%}