

load('DataJorgos.mat','DataJorgos');

figure('Name',' Zeitkonstante','Position',[1, 1, 1920,1080]); % Fig 4
xy=find(DataJorgos(:,5));

subplot(2,1,1);
for ii=1:xy(end)
    
end
plot(DataJorgos(xy,2),log(DataJorgos(xy,5)));
plot(DataJorgos(xy,2),-log(DataJorgos(xy,5)),'ro');

subplot(2,1,2);
semilogy(DataJorgos(xy,2),DataJorgos(xy,5));
semilogy(DataJorgos(xy,2),DataJorgos(xy,5),'ro');
xlim([0 130]);

aaa=0;
close all; clear all;

