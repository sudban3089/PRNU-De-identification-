%% Developed by Sudipta Banerjee: Code for PRNU Spoofing as implemented in BTAS 2019 paper 
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
Exampletestimg = rgb2gray(imread('010_IP5_OU_F_RI_01_2.jpg'));

%%
[rsize,csize]=size(Exampletestimg);
minval = min(rsize,csize);
% Hyperparameter alpha needs to be tuned between 0 and 1 using validation images for different datasets
alpha=0.9;% hyperparamter tuned for MICHE-I dataset

%% ***** PLEASE NOTE THE FOLLOWING LINES ******
% alpha = 0.9 if and only if using one image (done here for demo) for spoofing else,
% alpha = 0.7 if multiple candidate images are used, in that case
% perturbedimg_L_cand for all candidate images should be averaged before
% resizing and adding it to perturbedimg in Line 62 (as done in the BTAS 2019 paper)
%%
cutoff = round(alpha*minval);
%% Read the candidate image (whose sensor has to be spoofed)

Candidateimg = rgb2gray(imread('072_GS4_OU_F_RI_01_3.jpg'));

%% Perform spoofing (portions were motivated from https://stackoverflow.com/questions/22322427/decomposing-an-image-into-two-frequency-components-using-dct)

tic

% Candidate image (whose sensor has to be spoofed)
numCandidateimages = 1; % use other value if multiple candidate images are used
PERTURBED_L_CAND = 0;
dct_candidimg = dct2(Candidateimg);
High_Cand = fliplr(tril(fliplr(dct_candidimg),cutoff));
Low_perturbed = 0;

perturbeddct_L_cand = High_Cand+Low_perturbed;
perturbedimg_L_cand = idct2(perturbeddct_L_cand);

PERTURBED_L_CAND = PERTURBED_L_CAND + perturbedimg_L_cand; % iterate this step if multiple candidate images are used

% Averaging and resizing

PERTURBED_L_CAND = PERTURBED_L_CAND./numCandidateimages;
PERTURBED_L_CAND_Resized = imresize(PERTURBED_L_CAND,[rsize,csize]); 


% Test image
dct_img = dct2(Exampletestimg);
cutoff = round(alpha*minval);
High = fliplr(tril(fliplr(dct_img),cutoff));
Low = dct_img-High;
High_perturbed = 0;

perturbeddct = High_perturbed+Low;
perturbedimg = idct2(perturbeddct);

perturbedimg_FINAL = perturbedimg + PERTURBED_L_CAND_Resized;
toc

%% Evaluate correlation with MLE, Enhanced and Phase Reference patterns
cd ..

subplot(1,2,1),imshow(Exampletestimg,[]),title('Original Image');hold  on
subplot(1,2,2),imshow(perturbedimg,[]),title('Spoofed Image');hold off

% Before anonymization
NCC_OriginalImage_Phase= NCC_Computation_Phase(Exampletestimg,qmf,L);
NCC_OriginalImage_MLE = NCC_Computation_MLE(Exampletestimg,qmf,L);
NCC_OriginalImage_Enh = NCC_Computation_Enhanced(Exampletestimg,qmf,L);

% After anonymization
NCC_SpoofedImage_Phase= NCC_Computation_Phase(perturbedimg_FINAL,qmf,L);
NCC_SpoofedImage_MLE = NCC_Computation_MLE(perturbedimg_FINAL,qmf,L);
NCC_SpoofedImage_Enh = NCC_Computation_Enhanced(perturbedimg_FINAL,qmf,L);


[~,maxind_NCC_Original_Phase]= max(NCC_OriginalImage_Phase,[],2);
[~,maxind_NCC_Original_MLE]= max(NCC_OriginalImage_MLE,[],2);
[~,maxind_NCC_Original_Enhanced]= max(NCC_OriginalImage_Enh,[],2);

[~,maxind_NCC_Perturbed_Phase]= max(NCC_SpoofedImage_Phase,[],2);
[~,maxind_NCC_Perturbed_MLE]= max(NCC_SpoofedImage_MLE,[],2);
[~,maxind_NCC_Perturbed_Enhanced]= max(NCC_SpoofedImage_Enh,[],2);

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
% % ResNet Features for Spoofed Image
% input_Spoofed = imresize(perturbedimg_FINAL,[inputSize(1),inputSize(2)]);
% CLAHE_Spoofed = adapthisteq(uint8(input_Spoofed));
% netimage_Spoofed = cat(3,CLAHE_Spoofed,CLAHE_Spoofed,CLAHE_Spoofed);
% 
% Features_Spoofed = activations(net,netimage_Spoofed,layer,'OutputAs','rows');
% 
% Features_Cosinedistance = pdist2(Features_Original,Features_Spoofed,'cosine');
% Features_Cosinesimilarity = 1- Features_Cosinedistance;


