load('expTest_001.mat');
% figure('Name',[Plot.Text.szFileName(1:end-4),' SPVH_Position'],'Position',[1, 1, 1920,1080]); % Fig 4

subplot(2,1,1);
plot(Data14R(1:27,1),Data14R(1:27,3),'go');
xlabel('Time [s]');
ylabel('SPV [\circ/s]');

subplot(2,1,2);
plot(Data14R(:,2),Data14R(:,3),'go');
xlabel('Position [\circ]');
ylabel('SPV [\circ/s]');

    f = fittype('a*exp(t/x)'); 
[fit1,gof,fitinfo] = fit(Data14R(:,1),Data14R(:,3),f);   %,'StartPoint',[1 1]);                

aaa=0;