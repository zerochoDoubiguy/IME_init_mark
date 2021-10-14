 
clear all;
close all;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                     第一部分 提取干涉仪的板卡采集的位置数据IF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SampleData  = 1:32;
N = 100;
Long = 1602;%一帧长度为12816字节  8字节一截取 12816/8=1602

filePath = '.\\第一次\\'
fileName = '2021-09-27 16-15-13';
fileName2 = '2021-09-27 16-15-12'; 
fileID = fopen([filePath,'IF_',fileName2,'.bin']);
% fileID = fopen('IF.bin');
IF_ReadData0= fread(fileID,'uint64');
fclose(fileID);

IF_RLength = size(IF_ReadData0);
IF_ReadData0 = uint64(IF_ReadData0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1.2. 提取数据中64位大小端的转换
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a=uint64(IF_ReadData0);
% a=uint64(0x0102131415161718);
% % aa8=uint64(255);aaa8=uint64(bitand(a,aa8));c8=uint64(bitshift(aaa8,56));
% % aa7=uint64(65280);aaa7=uint64(bitand(a,aa7));c7=uint64(bitshift(aaa7,40));
% % aa6=uint64(16711680);aaa6=uint64(bitand(a,aa6));c6=uint64(bitshift(aaa6,24));
% % aa5=uint64(4278190080);aaa5=uint64(bitand(a,aa5));c5=uint64(bitshift(aaa5,8));
% % aa4=uint64(1095216660480);aaa4=uint64(bitand(a,aa4));c4=uint64(bitshift(aaa4,-8));
% % aa3=uint64(280375465082880);aaa3=uint64(bitand(a,aa3));c3=uint64(bitshift(aaa3,-24));
% % aa2=uint64(71776119061217280);aaa2=uint64(bitand(a,aa2));c2=uint64(bitshift(aaa2,-40));
% % aa1=uint64(-72057594037927936);aaa1=uint64(bitand(a,aa1));c1=uint64(bitshift(aaa1,-56));
% % D=uint64(c8+c7+c6+c5+c4+c3+c2+c1);
% % IF_ReadData = uint64(D);    


aa8=uint64(0x00000000000000FF);aaa8=uint64(bitand(a,aa8));c8=uint64(bitshift(aaa8,56));
aa7=uint64(0x000000000000FF00);aaa7=uint64(bitand(a,aa7));c7=uint64(bitshift(aaa7,40));
aa6=uint64(0x0000000000FF0000);aaa6=uint64(bitand(a,aa6));c6=uint64(bitshift(aaa6,24));
aa5=uint64(0x00000000FF000000);aaa5=uint64(bitand(a,aa5));c5=uint64(bitshift(aaa5,8));
aa4=uint64(0x000000FF00000000);aaa4=uint64(bitand(a,aa4));c4=uint64(bitshift(aaa4,-8));
aa3=uint64(0x0000FF0000000000);aaa3=uint64(bitand(a,aa3));c3=uint64(bitshift(aaa3,-24));
aa2=uint64(0x00FF000000000000);aaa2=uint64(bitand(a,aa2));c2=uint64(bitshift(aaa2,-40));
aa1=uint64(0xFF00000000000000);aaa1=uint64(bitand(a,aa1));c1=uint64(bitshift(aaa1,-56));
D=uint64(c8+c7+c6+c5+c4+c3+c2+c1);
IF_ReadData = uint64(D); 
            
IF_32ChnlData = uint64(zeros(floor(IF_RLength(1)/1602).*50,32));          %采集的数据分通道提取
IF_32ChnlData_OrigValid = uint64(zeros(floor(IF_RLength(1)/1602).*50,16));%原始数据数据中低36bit有效
IF_32ChnlData_SloverData = double(zeros(floor(IF_RLength(1)/1602).*50,6));%解算数据（通过原始数据计算解算数据）

for Nf2=1:IF_RLength(1)/1602
    for i = 1:32 %通道数字
        for j = 1:50%一帧的采样次数
            IF_32ChnlData((Nf2-1)*50+j,i) = IF_ReadData(1602*(Nf2-1)+32*(j-1)+i+2);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1.3提取原始数据数据中的低36bit的有效数据
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a=uint64(0x0123456789ABCDEF);
% aa=uint64(0x0FFFFFFFFF);
% aaa=uint64(bitand(a,aa));

for Nf2=1:IF_RLength(1)/1602
    for i = 1:16 %通道数字
        for j = 1:50%一帧的采样次数
            IF_32ChnlData((Nf2-1)*50+j,i) = IF_ReadData(1602*(Nf2-1)+32*(j-1)+i+2);
             bb=uint64(0x0FFFFFFFFF);          %    提取原始数据数据中的低36bit的有效数据
%             bb=uint64(68719476735);           %    提取原始数据数据中的低36bit的有效数据
            IF_32ChnlData_OrigValid((Nf2-1)*50+j,i)=bitand((IF_32ChnlData((Nf2-1)*50+j,i)),bb); 
        end
    end
end


ymax = max(max(IF_32ChnlData));
ymin = min(min(IF_32ChnlData));



% figure
% subplot(2,5,1); plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,1),'-g'); title('IFOrigDataValid-ch1');%  axis([0 3000 -1 10e10]);
% subplot(2,5,2); plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,2),'-r'); title('IFOrigDataValid-ch2');%  axis([0 3000 -1 10e10]);
% subplot(2,5,3); plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,3),'-m'); title('IFOrigDataValid-ch3');%  axis([0 3000 -1 10e10]);
% subplot(2,5,4); plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,4),'-k'); title('IFOrigDataValid-ch4');%  axis([0 3000 -1 10e10]);
% subplot(2,5,5); plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,5),'-g'); title('IFOrigDataValid-ch5');%  axis([0 3000 -1 10e10]);
% subplot(2,5,6); plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,6),'-r'); title('IFOrigDataValid-ch6');%  axis([0 3000 -1 10e10]);
% subplot(2,5,7); plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,7),'-m'); title('IFOrigDataValid-ch7');%  axis([0 3000 -1 10e10]);
% subplot(2,5,8); plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,8),'-k'); title('IFOrigDataValid-ch8');%  axis([0 3000 -1 10e10]);
% subplot(2,5,9); plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,9),'-k'); title('IF0rigDataValid-ch9');%  axis([0 3000 -1 1e6]);
% subplot(2,5,10);plot((1:floor(IF_RLength(1)/1602).*50),IF_32ChnlData_OrigValid(:,10),'-k'); title('IFOrigDataValid-ch10');%axis([0 3000 -1 1e6]);
          

% figure
% subplot(2,5,1); plot((1:floor(IF_RLength(1)/1602).*50)*2E-6,IF_32ChnlData_OrigValid(:,1),'-g'); title('IFOrigDataValid-ch1'); % axis([0.2 2e-6 -1 10e10]);
% subplot(2,5,2); plot((1:floor(IF_RLength(1)/1602).*50)*2E-6,IF_32ChnlData_OrigValid(:,2),'-r'); title('IFOrigDataValid-ch2'); % axis([0.2 2e-6 -1 10e10]);
% subplot(2,5,3); plot((1:floor(IF_RLength(1)/1602).*50)*2E-6,IF_32ChnlData_OrigValid(:,3),'-m'); title('IFOrigDataValid-ch3');  %axis([0.2 2e-6 -1 10e10]);
% subplot(2,5,4); plot((1:floor(IF_RLength(1)/1602).*50)*2E-6,IF_32ChnlData_OrigValid(:,4),'-k'); title('IFOrigDataValid-ch4');% axis([0.2 2e-6 -1 10e10]);
% subplot(2,5,5); plot((1:floor(IF_RLength(1)/1602).*50)*2E-6,IF_32ChnlData_OrigValid(:,5),'-g'); title('IFOrigDataValid-ch5');%  axis([0.2 2e-6 -1 10e10]);
% subplot(2,5,6); plot((1:floor(IF_RLength(1)/1602).*50)*2E-6,IF_32ChnlData_OrigValid(:,6),'-r'); title('IFOrigDataValid-ch6');%  axis([0.2 2e-6 -1 10e10]);
% subplot(2,5,7); plot((1:floor(IF_RLength(1)/1602).*50)*2E-10,IF_32ChnlData_OrigValid(:,7),'-m'); title('IFOrigDataValid-ch7');%  axis([0.2 2e-6 -1 10e10]);
% subplot(2,5,8); plot((1:floor(IF_RLength(1)/1602).*50)*2E-6,IF_32ChnlData_OrigValid(:,8),'-k'); title('IFOrigDataValid-ch8');%  axis([0.2 2e-6 -1 10e10]);
% subplot(2,5,9); plot((1:floor(IF_RLength(1)/1602).*50)*2E-6,IF_32ChnlData_OrigValid(:,9),'-k'); title('IF0rigDataValid-ch9'); % axis([0.2 2e-6 -1 10e10]);
% subplot(2,5,10);plot((1:floor(IF_RLength(1)/1602).*50)*2E-6,IF_32ChnlData_OrigValid(:,10),'-k'); title('IFOrigDataValid-ch10');%  axis([0.2 2e-6 -1 10e10]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %提取解算数据第16-21列
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% chX_SloverData=double(IF_32ChnlData(:,16));
% chY_SloverData=double(IF_32ChnlData(:,17));
% chZ_SloverData=double(IF_32ChnlData(:,18));
% chQX_SloverData= double(IF_32ChnlData(:,19));
% chQY_SloverData=double(IF_32ChnlData(:,20));
% chQZ_SloverData=double(IF_32ChnlData(:,21));
% IF_32ChnlData_SloverData=[chX_SloverData,chZ_SloverData,chQX_SloverData,chQY_SloverData,chQY_SloverData];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %在matlab中 干涉仪板卡的原始数据计算解算数据
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #define LASER_UNIT_NM              0.154538818359375//nm
% #define TY_DIS	18000000.0
% #define TX_DIS	18000000.0
% #define TZ_DIS 	39000000.0
%       laserLen[0]=axis1 * LASER_UNIT_NM;
% 		laserLen[1]=axis2 * LASER_UNIT_NM;
% 		laserLen[2]=axis3 * LASER_UNIT_NM;
% 		laserLen[3]=axis4* LASER_UNIT_NM;
% 		laserLen[4]=axis5* LASER_UNIT_NM;
% 		laserLen[5]=-axis6* LASER_UNIT_NM;
% 		laserLen[6]=-axis7* LASER_UNIT_NM;
% 		laserLen[7]=-axis8* LASER_UNIT_NM;
% 		laserLen[8]=-axis9* LASER_UNIT_NM;
% 		laserLen[9]=axis10 * LASER_UNIT_NM;

%   x= (laserLen[1]+laserLen[2]+laserLen[3]+laserLen[4])/4.0;			//X
% 	y = (laserLen[5]+laserLen[6]+laserLen[7]+laserLen[8])/4.0;			//Y
% 	tz = (laserLen[1]+laserLen[2])/2.0-(laserLen[3]+laserLen[4])/2.0;
% 	tz = tz/TZ_DIS*1E9;											//TZ
% 	z = -(laserLen[0]+laserLen[9])/2.0;								//Z
% 	tx = (laserLen[3]+laserLen[1])/2.0-(laserLen[4]+laserLen[2])/2.0;
% 	tx = tx/TX_DIS*1E9;											//TX
% 	ty = (laserLen[7]+laserLen[5])/2.0-(laserLen[8]+laserLen[6])/2.0;
% 	ty = -ty/TY_DIS*1e9;
%  laserLen=[laserLen0;laserLen1,laserLen2,laserLen3,laserLen4;laserLen5,laserLen6;laserLen7,laserLen8,laserLen9];
 


%  axis1=   typecast(uint64(IF_32ChnlData_OrigValid(:,1)), 'int64');   laserLen0=double(axis1.*LASER_UNIT_NM);
%  axis2=   typecast(uint64(IF_32ChnlData_OrigValid(:,2)), 'int64');  laserLen1=double(axis2.*LASER_UNIT_NM);
%  axis3=   typecast(uint64(IF_32ChnlData_OrigValid(:,3)), 'int64');  laserLen2=double(axis3.*LASER_UNIT_NM);
%  axis4=   typecast(uint64(IF_32ChnlData_OrigValid(:,5)), 'int64');  laserLen3=double(axis4.*LASER_UNIT_NM);
%  axis5=   typecast(uint64(IF_32ChnlData_OrigValid(:,6)), 'int64');   laserLen4=double(axis5.*LASER_UNIT_NM);
%  axis6=   typecast(uint64(IF_32ChnlData_OrigValid(:,7)), 'int64');  laserLen5=-double((axis6.*LASER_UNIT_NM));
%  axis7=   typecast(uint64(IF_32ChnlData_OrigValid(:,8)), 'int64');   laserLen6=-double(axis7.*LASER_UNIT_NM);
%  axis8=   typecast(uint64(IF_32ChnlData_OrigValid(:,9)), 'int64');  laserLen7=-double(axis8.*LASER_UNIT_NM);
%  axis9=   typecast(uint64(IF_32ChnlData_OrigValid(:,10)), 'int64'); laserLen8=-double(axis9.*LASER_UNIT_NM);
% %  axis10=  typecast(uint64(IF_32ChnlData_OrigValid(:,11)), 'int64');laserLen9=double(axis10.*LASER_UNIT_NM);


%   axis1_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,1)), 'int64');  axis1_cmp=axis1_0-2^36;  axis1=axis1_cmp;  laserLen0=double(axis1.*LASER_UNIT_NM);
%   axis2_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,2)), 'int64');  axis2_cmp=axis2_0-2^36;  axis2=axis2_cmp;  laserLen1=double(axis2.*LASER_UNIT_NM);
%   axis3_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,3)), 'int64');  axis3_cmp=axis3_0-2^36;  axis3=axis3_cmp;  laserLen2=double(axis3.*LASER_UNIT_NM);
%   axis4_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,5)), 'int64');  axis4_cmp=axis4_0-2^36;  axis4=axis4_cmp;  laserLen3=double(axis4.*LASER_UNIT_NM);
%   axis5_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,6)), 'int64');  axis5_cmp=axis5_0-2^36;  axis5=axis5_cmp;  laserLen4=double(axis5.*LASER_UNIT_NM);
%   axis6_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,7)), 'int64');  axis6_cmp=axis6_0-2^36;  axis6=axis6_cmp;  laserLen5=double(axis6.*LASER_UNIT_NM);
%   axis7_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,8)), 'int64');  axis7_cmp=axis7_0-2^36;  axis7=axis7_cmp;  laserLen6=double(axis7.*LASER_UNIT_NM);
%   axis8_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,9)), 'int64');  axis8_cmp=axis8_0-2^36;  axis8=axis8_cmp;  laserLen7=double(axis8.*LASER_UNIT_NM);
%   axis9_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,10)), 'int64');  axis9_cmp=axis9_0-2^36;  axis9=axis0_cmp;  laserLen8=double(axis9.*LASER_UNIT_NM);
%  axis10_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,11)), 'int64');  axis10_cmp=axis10_0-2^36;  axis10=axis10_cmp;  laserLen9=double(axis10.*LASER_UNIT_NM);
 

 LASER_UNIT_NM =0.154538818359375;%//nm
 TY_DIS	=18000000.0;
 TX_DIS	=18000000.0;
 TZ_DIS =39000000.0;
 axis1=   typecast(uint64(IF_32ChnlData_OrigValid(:,1)), 'int64');   laserLen0=double(axis1.*LASER_UNIT_NM);
 axis2=   typecast(uint64(IF_32ChnlData_OrigValid(:,2)), 'int64');  laserLen1=double(axis2.*LASER_UNIT_NM);
 axis3=   typecast(uint64(IF_32ChnlData_OrigValid(:,3)), 'int64');  laserLen2=double(axis3.*LASER_UNIT_NM);
 axis4=   typecast(uint64(IF_32ChnlData_OrigValid(:,5)), 'int64');  laserLen3=double(axis4.*LASER_UNIT_NM);
 axis5=   typecast(uint64(IF_32ChnlData_OrigValid(:,6)), 'int64');   laserLen4=double(axis5.*LASER_UNIT_NM);
 axis6=   typecast(uint64(IF_32ChnlData_OrigValid(:,7)), 'int64');  laserLen5=-double((axis6.*LASER_UNIT_NM));
 axis7=   typecast(uint64(IF_32ChnlData_OrigValid(:,8)), 'int64');   laserLen6=-double(axis7.*LASER_UNIT_NM);
 axis8=   typecast(uint64(IF_32ChnlData_OrigValid(:,9)), 'int64');  laserLen7=-double(axis8.*LASER_UNIT_NM);
 axis9=   typecast(uint64(IF_32ChnlData_OrigValid(:,10)), 'int64'); laserLen8=-double(axis9.*LASER_UNIT_NM);
axis10_0=  typecast(uint64(IF_32ChnlData_OrigValid(:,11)), 'int64');  axis10_cmp=axis10_0-2^36;  axis10=axis10_cmp;  laserLen9=double(axis10.*LASER_UNIT_NM);
  


 axis=[axis1,axis2,axis3,axis4,axis5,axis6,axis7,axis8,axis9,axis10];
 laserLen=[laserLen0,laserLen1,laserLen2,laserLen3,laserLen4,laserLen5,laserLen6,laserLen7,laserLen8,laserLen9];
 

 x  = (laserLen1+laserLen2+laserLen3+laserLen4)/4.0;			%//X   nm
 y  = (laserLen5+laserLen6+laserLen7+laserLen8)/4.0;			%//Y   nm
 tz = (laserLen1+laserLen2)/2.0-(laserLen3+laserLen4)/2.0;
 tz = tz/TZ_DIS*1E9;											%//TZ
 z  = -(laserLen0+laserLen9)/2.0;								%//Z   nm
 tx = (laserLen3+laserLen1)/2.0-(laserLen4+laserLen2)/2.0;
 tx = tx/TX_DIS*1E9;											%&//TX
 ty = (laserLen7+laserLen5)/2.0-(laserLen8+laserLen6)/2.0;
 ty = -ty/TY_DIS*1e9;
 LocationSloverData=[x*1E-6,y*1E-6,z*1E-3,tx,ty,tz];
 
figure
subplot(2,3,1); plot((1:floor(IF_RLength(1)/1602).*50),x*1E-6,'-g'); title('x轴解算位置数据'); xlabel('point') ; ylabel('x轴解算位置数据（mm）');%  axis([0 3000 -1 10e10]);
subplot(2,3,2); plot((1:floor(IF_RLength(1)/1602).*50),y*1E-6,'-g'); title('y轴解算位置数据');xlabel('point') ; ylabel('y轴解算位置数据（mm）');%  axis([0 3000 -1 10e10]); 
subplot(2,3,3); plot((1:floor(IF_RLength(1)/1602).*50),z*1E-3,'-g'); title('z轴解算位置数据');xlabel('point') ; ylabel('z轴解算位置数据（um）');%  axis([0 3000 -1 10e10]);

subplot(2,3,4); plot((1:floor(IF_RLength(1)/1602).*50),tx,'-g'); title('tx轴解算位置数据'); xlabel('point') ; ylabel('tx轴解算位置数据（nm）');%  axis([0 3000 -1 10e10]);
subplot(2,3,5); plot((1:floor(IF_RLength(1)/1602).*50),ty,'-g'); title('ty轴解算位置数据');xlabel('point') ; ylabel('ty轴解算位置数据（nm）');%  axis([0 3000 -1 10e10]); 
subplot(2,3,6); plot((1:floor(IF_RLength(1)/1602).*50),tz,'-g'); title('tz轴解算位置数据');xlabel('point') ; ylabel('tz轴解算位置数据（nm）');%  axis([0 3000 -1 10e10]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %                    第二部分   提取 ADC板卡采集的光强数据
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileID = fopen([filePath,'ADC1_',fileName,'.bin']);
AdcReadData = fread(fileID,'uint16');
fclose(fileID);

AdcRLength = size(AdcReadData);
AdcReadData = uint16(AdcReadData);

Adc8ChnlData = uint16(zeros(AdcRLength(1)/408.*50,8));

for Nf2=1:AdcRLength(1)/408
    for i = 1:8
        for j = 1:50
            Adc8ChnlData((Nf2-1)*50+j,i) = AdcReadData(408*(Nf2-1)+8*j+i);
        end
    end
end

ymax = max(max(Adc8ChnlData));
ymin = min(min(Adc8ChnlData));
figure
 subplot(2,4,1); plot((1:AdcRLength(1)/408.*50)*2E-6,Adc8ChnlData(:,1),'-g');  title('532nm-ch1'); %  axis([0.2 0.4 1.1e4 1.9e4]);
 subplot(2,4,2); plot((1:AdcRLength(1)/408.*50)*2E-6,Adc8ChnlData(:,2),'-r');  title('633nm-ch2'); %  axis([0.2 0.4 1.6e4 2.6e4]);
 subplot(2,4,3); plot((1:AdcRLength(1)/408.*50)*2E-6,Adc8ChnlData(:,3),'-m');  title('780nm-ch3'); %  axis([0.2 0.4 0.5e4 3.5e4]); 
 subplot(2,4,4);  plot((1:AdcRLength(1)/408.*50)*2E-6,Adc8ChnlData(:,4),'-k'); title('852nm-ch4'); %  axis([0.2 0.4 1.9e4 2.6e4]);
 subplot(2,4,5); plot((1:AdcRLength(1)/408.*50)*2E-6,Adc8ChnlData(:,5),'-g');  title('532nm-ch5'); %  axis([0.2 0.4 1.4e4 3.2e4]);
 subplot(2,4,6); plot((1:AdcRLength(1)/408.*50)*2E-6,Adc8ChnlData(:,6),'-r');  title('633nm-ch6'); %  axis([0.2 0.4 2.2e4 3.6e4]);
 subplot(2,4,7); plot((1:AdcRLength(1)/408.*50)*2E-6,Adc8ChnlData(:,7),'-m');  title('780nm-ch7'); %  axis([0.2 0.4 0.5e4 3e4]);
 subplot(2,4,8); plot((1:AdcRLength(1)/408.*50)*2E-6,Adc8ChnlData(:,8),'-k');  title('852nm-ch8'); %  axis([0.2 0.4 2.2e4 3.4e4]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %                 第三部分   在matlab中 干涉仪板卡的位置数据IF与AD板卡的光强数据一一对应
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  x =[ 1  6  2  8  6  3 ];
%  y=[ 2  3   4  5  6   4 ];
%  figure
%  plot (x,y) 

SizeLocation=size(LocationSloverData(:,1));
SizeAdc=size(Adc8ChnlData(:,1));
size=min(SizeLocation,SizeAdc);
% 
% figure%  532nm-ch1高级光 光强分别对应的X轴 Y轴 Z轴 tx ty tz的数据
% subplot(3,1,1); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,1),'-g');title('ch1-- 532nm 高级光');  xlabel('X轴位置(mm)'); ylabel('光强');%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,2); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,1),'-g');                     xlabel('Y轴位置'); ylabel('光强') %  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,3); plot(LocationSloverData(1:size,3),Adc8ChnlData(1:size,1),'-g');                     xlabel('Z轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);

% 
% figure% 633nm-ch2高级光 光强分别对应的X轴 Y轴 Z轴 tx ty tz的数据
% subplot(3,1,1); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,2),'-g'); title('ch2-- 633nm 高级光'); xlabel('X轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,2); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,2),'-g');                     xlabel('Y轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,3); plot(LocationSloverData(1:size,3),Adc8ChnlData(1:size,2),'-g');                      xlabel('Z轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% 
% figure% 780nm-ch3高级光 光强分别对应的X轴 Y轴 Z轴 tx ty tz的数据
% subplot(3,1,1); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,3),'-g'); title('ch3-- 780nm 高级光'); xlabel('X轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,2); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,3),'-g');                     xlabel('Y轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,3); plot(LocationSloverData(1:size,3),Adc8ChnlData(1:size,3),'-g');                     xlabel('Z轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% 
% figure% 852nm-ch4高级光 光强分别对应的X轴 Y轴 Z轴 tx ty tz的数据
% subplot(3,1,1); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,4),'-g'); title('ch4-- 852nm 高级光'); xlabel('X轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,2); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,4),'-g');                     xlabel('Y轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,3); plot(LocationSloverData(1:size,3),Adc8ChnlData(1:size,4),'-g');                     xlabel('Z轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% 
% figure%  532nm-ch5零级光 光强分别对应的X轴 Y轴 Z轴 tx ty tz的数据
% subplot(3,1,1); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,5),'-g');title('ch5-- 532nm 零级光');  xlabel('X轴位置'); ylabel('光强');%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,2); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,5),'-g');                     xlabel('Y轴位置'); ylabel('光强') %  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,3); plot(LocationSloverData(1:size,3),Adc8ChnlData(1:size,5),'-g');                     xlabel('Z轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% 
% 
% figure% 633nm-ch6零级光 光强分别对应的X轴 Y轴 Z轴 tx ty tz的数据
% subplot(3,1,1); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,6),'-g'); title('ch6-- 633nm 零级光'); xlabel('X轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,2); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,6),'-g');                     xlabel('Y轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,3); plot(LocationSloverData(1:size,3),Adc8ChnlData(1:size,6),'-g');                      xlabel('Z轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% 
% figure% 780nm-ch7零级光 光强分别对应的X轴 Y轴 Z轴 tx ty tz的数据
% subplot(3,1,1); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,7),'-g'); title('ch7-- 780nm 零级光'); xlabel('X轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,2); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,7),'-g');                     xlabel('Y轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,3); plot(LocationSloverData(1:size,3),Adc8ChnlData(1:size,7),'-g');                     xlabel('Z轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% 
% figure% 852nm-ch8零级光光强分别对应的X轴 Y轴 Z轴 tx ty tz的数据
% subplot(3,1,1); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,8),'-g'); title('ch8-- 852nm 零级光'); xlabel('X轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,2); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,8),'-g');                     xlabel('Y轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(3,1,3); plot(LocationSloverData(1:size,3),Adc8ChnlData(1:size,8),'-g');                     xlabel('Z轴位置'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);




% 
figure%   x轴方向位置移动，对应的8路测量光的光强信号
subplot(2,4,1); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,1),'-g');title('ch1-- 532nm 高级光');  xlabel('X轴位置(mm)'); ylabel('光强');%  axis([0.2 0.4 1.1e4 1.9e4]);
subplot(2,4,2); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,2),'-g'); title('ch2-- 633nm 高级光'); xlabel('X轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
subplot(2,4,3); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,3),'-g'); title('ch3-- 780nm 高级光'); xlabel('X轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
subplot(2,4,4); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,4),'-g'); title('ch4-- 852nm 高级光'); xlabel('X轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
subplot(2,4,5); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,5),'-g');title('ch5-- 532nm 零级光');  xlabel('X轴位置(mm)'); ylabel('光强');%  axis([0.2 0.4 1.1e4 1.9e4]);
subplot(2,4,6); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,6),'-g'); title('ch6-- 633nm 零级光'); xlabel('X轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
subplot(2,4,7); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,7),'-g'); title('ch7-- 780nm 零级光'); xlabel('X轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
subplot(2,4,8); plot(LocationSloverData(1:size,1),Adc8ChnlData(1:size,8),'-g'); title('ch8-- 852nm 零级光'); xlabel('X轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);


% figure%  y轴方向位置移动，对应的8路测量光的光强信号
% subplot(2,4,1); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,1),'-g');title('ch1-- 532nm 高级光');  xlabel('y轴位置(mm)'); ylabel('光强');%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(2,4,2); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,2),'-g'); title('ch2-- 633nm 高级光'); xlabel('y轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(2,4,3); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,3),'-g'); title('ch3-- 780nm 高级光'); xlabel('y轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(2,4,4); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,4),'-g'); title('ch4-- 852nm 高级光'); xlabel('y轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(2,4,5); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,5),'-g');title('ch5-- 532nm 零级光');  xlabel('y轴位置(mm)'); ylabel('光强');%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(2,4,6); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,6),'-g'); title('ch6-- 633nm 零级光'); xlabel('y轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(2,4,7); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,7),'-g'); title('ch7-- 780nm 零级光'); xlabel('y轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
% subplot(2,4,8); plot(LocationSloverData(1:size,2),Adc8ChnlData(1:size,8),'-g'); title('ch8-- 852nm 零级光'); xlabel('y轴位置(mm)'); ylabel('光强')%  axis([0.2 0.4 1.1e4 1.9e4]);
