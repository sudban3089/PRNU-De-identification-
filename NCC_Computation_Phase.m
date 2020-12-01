%%For details about Phase SPN, refer to
% Kang et al., "Enhancing Source Camera Identification Performance With a
% Camera Reference Phase Sensor Pattern Noise", T-IFS 2012
%%

function [normcrosscorr_similarity]= NCC_Computation_Phase(currentimage,qmf,L)

% Load all the reference patterns computed for Phase SPN--
cd('Noise Templates Phase\')

F1 = load('Phase template IP5 DEVICE1 FRONT.mat');
F2 = load('Phase template IP5 DEVICE2 FRONT.mat');
F3 = load('Phase template SamsungGalaxyS4 FRONT.mat');
F4 = load('Phase template ASUS.mat');
F5 = load('Phase template HTC.mat');
F6 = load('Phase template MEIZU.mat');
F7 = load('Phase template Oppo.mat');
F8 = load('Phase template SamsungGalaxyS6.mat');
F9 = load('Phase template Sony.mat');

Reference_patterns = [F1; F2; F3; F4; F5; F6; F7; F8; F9];

%% Correlate the testnoise residual with reference pattern

cd ..
Noisex_fft = NoiseExtractFromImage_Phase(currentimage,qmf,2,L);
Noiseresidual_spatial = single(Noisex_fft);
Noiseresidual_testimage = double(Noiseresidual_spatial);


for camf =1:numel(Reference_patterns)
    Camera_Fingerprint = Reference_patterns(camf).RP_spatial;
    [r c] = size(Camera_Fingerprint);
    
    
    %%    -------------
    %%   |Calculate NCC|
    %%    --------------
    
    Ix = double(currentimage);
    Camera_Fingerprint = double(Camera_Fingerprint);
    [rsize,csize]=size(Camera_Fingerprint);
    
    Noiseresidual_testimage =  imresize(Noiseresidual_testimage,[rsize,csize]);
    
    normcrosscorr_similarity(camf) = normcor(Noiseresidual_testimage,Camera_Fingerprint);
  
end


  
  