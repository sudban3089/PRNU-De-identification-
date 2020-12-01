%% Developed by Sudipta Banerjee: Code for PRNU Anonymization as implemented in BTAS 2019 paper 
clc
close all
clear

addpath('Functions/')
addpath('Filter/')
qmf = MakeONFilter('Daubechies',8);
L = 4;

%% Read the test image

imageDir = 'Example_TestImages';
cd(imageDir)
Exampletestimg = rgb2gray(imread('010_IP5_OU_F_RI_01_2.jpg')); % '066_IP5_IN_F_RI_01_3.jpg', '072_GS4_OU_F_RI_01_3.jpg'

%%

[rsize,csize]=size(Exampletestimg);
minval = min(rsize,csize);

% Hyperparameter alpha needs to be tuned between 0 and 1 using validation images for different datasets
alpha=0.9;% hyperparamter tuned for MICHE-I dataset

%% Perform anonymization (portions were motivated from https://stackoverflow.com/questions/22322427/decomposing-an-image-into-two-frequency-components-using-dct)

tic
dct_img = dct2(Exampletestimg);
cutoff = round(alpha*minval);
High = fliplr(tril(fliplr(dct_img),cutoff));
Low = dct_img-High;
High_perturbed = 0;
Low_perturbed = 0;
perturbeddct = High_perturbed+Low;
perturbedimg = idct2(perturbeddct);
toc

%% Evaluate correlation with MLE, Enhanced and Phase Reference patterns
cd ..

% Before anonymization
NCC_OriginalImage_Phase= NCC_Computation_Phase(Exampletestimg,qmf,L);
NCC_OriginalImage_MLE = NCC_Computation_MLE(Exampletestimg,qmf,L);
NCC_OriginalImage_Enh = NCC_Computation_Enhanced(Exampletestimg,qmf,L);

% After anonymization
NCC_AnonymizedImage_Phase= NCC_Computation_Phase(perturbedimg,qmf,L);
NCC_AnonymizedImage_MLE = NCC_Computation_MLE(perturbedimg,qmf,L);
NCC_AnonymizedImage_Enh = NCC_Computation_Enhanced(perturbedimg,qmf,L);


subplot(1,2,1),imshow(Exampletestimg,[]),title('Original Image');hold  on
subplot(1,2,2),imshow(perturbedimg,[]),title('Anonymized Image');hold off

[~,maxind_NCC_Original_Phase]= max(NCC_OriginalImage_Phase,[],2);
[~,maxind_NCC_Original_MLE]= max(NCC_OriginalImage_MLE,[],2);
[~,maxind_NCC_Original_Enhanced]= max(NCC_OriginalImage_Enh,[],2);

[~,maxind_NCC_Perturbed_Phase]= max(NCC_AnonymizedImage_Phase,[],2);
[~,maxind_NCC_Perturbed_MLE]= max(NCC_AnonymizedImage_MLE,[],2);
[~,maxind_NCC_Perturbed_Enhanced]= max(NCC_AnonymizedImage_Enh,[],2);

disp(['Phase SPN: Original image --> ' DispSensor(maxind_NCC_Original_Phase)    '; Perturbed image --> ' DispSensor(maxind_NCC_Perturbed_Phase)])
disp(['MLE SPN: Original image --> ' DispSensor(maxind_NCC_Original_MLE)    '; Perturbed image --> ' DispSensor(maxind_NCC_Perturbed_MLE)])
disp(['Enhanced SPN: Original image --> ' DispSensor(maxind_NCC_Original_Enhanced)    '; Perturbed image --> ' DispSensor(maxind_NCC_Perturbed_Enhanced)])

%% Periocular matching (uses ResNet 101 for obtaining features and use the cosine similarity as match score. Repeat it for several images to compute Receiver Operating Characteristics Curves)
% Refer to the paper for more details: Diaz et al., "Periocular recognition using CNN features off-the-shelf," BIOSIG 2018
% Uncomment following lines if DL toolbox is available, otherwise leave them commented
% and use some other periocular matcher but results may vary from the original paper

% net=resnet101; %% NEED DEEP LEARNING TOOLBOX FOr MATLAB R2018a
% inputSize = net.Layers(1).InputSize;
% layer = net.Layers(170,1).Name;
% 
% % ResNet Features for Original Image
% input_Original = imresize(Exampletestimg,[inputSize(1),inputSize(2)]);
% CLAHE_Original = adapthisteq(uint8(input_Original));
% netimage_Original = cat(3,CLAHE_Original,CLAHE_Original,CLAHE_Original);
% 
% Features_Original = activations(net,netimage_Original,layer,'OutputAs','rows');
% 
% % ResNet Features for Anonymized Image
% input_Anonymized = imresize(perturbedimg,[inputSize(1),inputSize(2)]);
% CLAHE_Anonymized = adapthisteq(uint8(input_Anonymized));
% netimage_Anonymized = cat(3,CLAHE_Anonymized,CLAHE_Anonymized,CLAHE_Anonymized);
% 
% Features_Anonymized = activations(net,netimage_Anonymized,layer,'OutputAs','rows');
% 
% Features_Cosinedistance = pdist2(Features_Original,Features_Anonymized,'cosine');
% Features_Cosinesimilarity = 1- Features_Cosinedistance;
% 
