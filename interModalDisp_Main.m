clear;
tic
load('besDerZerMat.mat');
load('besZerMat.mat');
c=3*10^8;
% radius=0.305/2;
radius=0.127/2;
% freq = 2.40E9:0.3125E6:2.5E9;
% freq = 58.2E9:2E6:60.2E9;
% freq = 58.2E9:2E6:62.2E9;
freq = 59.4E9:1E6:60.4E9;

Zo=50;
eta = 377;
% l = 0.035;
l = 0.001;

sigma = 10^6;
mu = 4*pi*10^-7;
R = ((2*pi*freq*mu)./(2*sigma)).^0.5;
k = 2*pi*freq./c;
WGlenS = [1 2 4 8];
% WGlenS = 6.1;
channel = [];
pn_dB = [];
att = [];
n_TE=[];
m_TE=[];
fc_TE=[];
coWnTE=[];
n_TM=[];
m_TM=[];
fc_TM=[];
coWnTM=[];
% 
% for fi=1:length(freq)
%     n_TE=[];
%     m_TE=[];
%     fc_TE=[];
%     coWnTE=[];
%     for m=1:1001
%         for n=1:1000
%             fc_TE_temp=(c/(2*pi*radius))*besDerZerMat(m,n);
%             if fc_TE_temp <= freq(fi)
%                 n_TE = [n_TE n];
%                 m_TE = [m_TE m-1];
%                 fc_TE = [fc_TE fc_TE_temp];
%                 coWnTE = [coWnTE besDerZerMat(m,n)/radius];
%             end
%         end
%     end
% %     if length(n_TE1) < 796
% %         n_TE1 = [n_TE1 zeros(1, 796-length(n_TE1))];
% %     end
% %     n_TE = [n_TE; n_TE1];
% %     m_TE = [m_TE; m_TE1];
% %     fc_TE = [fc_TE; fc_TE1]; 
% %     coWnTE = [coWnTE; coWnTE1]; 
% end
% 
% for fi=1:length(freq)
%     n_TM=[];
%     m_TM=[];
%     fc_TM=[];
%     coWnTM=[];
%     for m=1:1001
%         for n=1:1000
%             fc_TM_temp=(c/(2*pi*radius))*besZerMat(m,n);
%             if fc_TM_temp <= freq(fi)
%                 n_TM = [n_TM n];
%                 m_TM = [m_TM m-1];
%                 fc_TM = [fc_TM fc_TM_temp];
%                 coWnTM = [coWnTM (besZerMat(m,n))/radius];
%             end
%         end
%     end
% %     n_TM = [n_TM (n_TM1)'];
% %     m_TM = [m_TM (m_TM1)'];
% %     fc_TM = [fc_TM (fc_TM1)'];
% %     coWnTM = [coWnTM (coWnTM1)'];
% end

% fc_TE = fc_TE';
% fc_TM = fc_TM';
% 
% m_TE = m_TE';
% n_TE = n_TE';
% 
% m_TM = m_TM';
% n_TM = n_TM';
% 
% coWnTE = coWnTE';
% coWnTM = coWnTM';

nTE = load('nTE.mat');
n_TE = nTE.n_TE;
nTM = load('nTM.mat');
n_TM = nTM.n_TM;
gammaTE = load('gammaTE.mat');
gammaTE = gammaTE.gammaTE;
gammaTM = load('gammaTM.mat');
gammaTM = gammaTM.gammaTM;
radresTE = load('radresTE.mat');
radresTE = radresTE.radresTE;
radresTM = load('radresTM.mat');
radresTM = radresTM.radresTM;

% [radresTE, radresTM, gammaTE, gammaTM] = radResCyl_multitone(m_TE,n_TE,m_TM,n_TM,radius,freq,fc_TE,fc_TM,c,k,R,eta,l,coWnTE,coWnTM);

radreacTE = imag(hilbert(radresTE));
radreacTM = imag(hilbert(radresTM));

for fi=1:length(freq)
    antresTE(fi) = sum(radresTE(fi,:));
    antresTM(fi) = sum(radresTM(fi,:));
    antreacTE(fi) = sum(radreacTE(fi,:));
    antreacTM(fi) = sum(radreacTM(fi,:));
    antimpTE(fi) = antresTE(fi) +1i*antreacTE(fi);
    antimpTM(fi) = antresTM(fi) +1i*antreacTM(fi);
    for n = 1:length(n_TE)
        TEmodeimp(fi,n)=radresTE(fi,n)+1i*radreacTE(fi,n);
    end
    for n = 1:length(n_TM)
        TMmodeimp(fi,n)=radresTM(fi,n)+1i*radreacTM(fi,n);
    end    
end

for i = 1:length(WGlenS)
    [channelT, attT, totPowerS, theta,meanDelayT, rmsDelayT, pn_dBT] = interModalDisp2(antimpTE,antimpTM,gammaTE,gammaTM,TEmodeimp,TMmodeimp,freq,WGlenS(i),Zo);
    channel = [channel; channelT];
    att = [att; attT];
    pn_dB = [pn_dB; pn_dBT];
    attB = attT(attT ~= 0);
end
figure
subplot(4,1,1)
plot(freq,-14+att(1,:),'b',freq,-36*ones(1,1001),'k');
legend("Length = 1 m");
subplot(4,1,2)
plot(freq,-14+att(2,:),'r',freq,-39*ones(1,1001),'k');
legend("Length = 2 m");
subplot(4,1,3)
plot(freq,-14+att(3,:),'g',freq,-45*ones(1,1001),'k');
legend("Length = 4 m");
subplot(4,1,4)
plot(freq,-14+att(4,:),'y-*',freq,-50*ones(1,1001),'k');
legend("Length = 8 m");
% plot(freq,att);
toc
