%-------------------------------------------------------------------------
%   Outlier auf "SPVH Exponential Fit" wählen, mit "Brush/Select Data":
%       - entweder Rechts oder Links wählen (Rot oder Blau)
%       - Menu: Tools->Brushing->Create new variable
%       - Variable Name:    Outlier1
%       - nochmals Programm von vorne starten, outliers sollten 
%         weg sein
%-------------------------------------------------------------------------

clear OutlierRH;
szFileNameOutlier=['..\Data\Outliers\',Plot.Text.szPatient,'_Outlier_RH.mat'];
OutlierRH.SPV=outlier1(:,2);
OutlierRH.dTime=outlier1(:,1);
load(szFileNameOutlier);

countDS=1;
[iiend, ~]=size(OutlierRH.dTime)
for ii= 1:iiend
    tt=find(Plot.RightH.dTime==OutlierRH.dTime(ii));
    [~,siz]=size(tt);
    for jj= 1:siz
        aOutlierRH(countDS,1)=tt(jj);    %Idx
        aOutlierRH(countDS,2)=Plot.RightH.dTime(aOutlierRH(countDS,1)); %dTime
        aOutlierRH(countDS,3)=Plot.RightH.SPV(aOutlierRH(countDS,1)); %SPV
        aOutlierRH(countDS,4)=Plot.RightH.Pos(aOutlierRH(countDS,1)); %Pos
        aOutlierRH(countDS,5)=Plot.RightH.idx(aOutlierRH(countDS,1)); %idx
        countDS=countDS+1;
    end
end

uOutlierRH=unique(aOutlierRH,'row');

save(szFileNameOutlier,'uOutlierRH');

aaa=1;