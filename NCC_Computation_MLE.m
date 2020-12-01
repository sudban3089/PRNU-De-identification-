%%For details about MLE SPN, refer to
% Chen et al., "Determining Image Origin and Integrity Using Sensor Noise,
% T-IFS 2008
%%

function [normcrosscorr_similarity]= NCC_Computation_MLE(currentimage,qmf,L)

% Load all the reference patterns computed for MLE SPN--
cd('Noise Templates MLE\')

F1 = load('MLE template iPhone5_DEVICE1 FRONT.mat');
F2 = load('MLE template iPhone5_DEVICE2 FRONT.mat');
F3 = load('MLE template SamsungGalaxyS4 FRONT.mat');
F4 = load('MLE template ASUS.mat');
F5 = load('MLE template HTC.mat');
F6 = load('MLE template MEIZU.mat');
F7 = load('MLE template Oppo.mat');
F8 = load('MLE template SamsungGalaxyS6.mat');
F9 = load('MLE template Sony.mat');

Reference_patterns = [F1; F2; F3; F4; F5; F6; F7; F8; F9];

%% Correlate the testnoise residual with reference pattern

cd ..

Noisex_fft = NoiseExtractFromImage_MLE(currentimage,qmf,2,L);


Noiseresidual_spatial = WienerInDFT(Noisex_fft,std2(Noisex_fft));
Noiseresidual_testimage = single(Noiseresidual_spatial);


for camf =1:numel(Reference_patterns)
    Camera_Fingerprint = Reference_patterns(camf).RP_spatial;
    
    
    %%    -------------
    %%   |Calculate NCC|
    %%    --------------
    
    Ix = double(currentimage);
    Camera_Fingerprint = double(Camera_Fingerprint);
    [rsize,csize]=size(Ix);
    Cx_resized = imresize(Camera_Fingerprint,[rsize,csize]);
    normcrosscorr_similarity(camf) = normcor(Noiseresidual_testimage,Ix.*Cx_resized);
    
    
end



