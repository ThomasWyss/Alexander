%-------------------------------------------------------------------------
%   Outlier auf "SPVH Exponential Fit" wählen, mit "Brush/Select Data":
%       - entweder Rechts oder Links wählen (Rot oder Blau)
%       - Menu: Tools->Brushing->Create new variable
%       - Variable Name:    Outlier1
%-------------------------------------------------------------------------

szFileNameOutlier=['..\Data\Outliers\',Plot.Text.szPatient,'_Outlier_RH.mat'];
OutlierH.SPV=outlier1(:,2);
OutlierH.dTime=outlier1(:,1);
save(szFileNameOutlier,'OutlierH');
load('outlier1.mat');

clear Outlier;

countDS=1;
[iiend, ~]=size(OutlierH.dTime)
for ii= 1:iiend
    tt=find(Plot.RightH.dTime==OutlierH.dTime(ii));
    [~,siz]=size(tt);
    for jj= 1:siz
        OutlierRH(countDS,1)=tt(jj);    %Idx
        OutlierRH(countDS,2)=Plot.RightH.dTime(OutlierRH(countDS,1)); %dTime
        OutlierRH(countDS,3)=Plot.RightH.SPV(OutlierRH(countDS,1)); %SPV
        OutlierRH(countDS,4)=Plot.RightH.Pos(OutlierRH(countDS,1)); %Pos
        OutlierRH(countDS,5)=Plot.RightH.idx(OutlierRH(countDS,1)); %idx
        countDS=countDS+1;
    end
end

uOutlierRH=unique(OutlierRH,'row');

aaa=1;