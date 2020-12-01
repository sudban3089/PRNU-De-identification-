%% Use this function for computing Sensor Reference Patterns
% Portion of codes adopted from http://dde.binghamton.edu/download/camera_fingerprint/
% Please refer to the above website for more details about computing sensor reference patterns
%%
function [RP,LP,ImagesinRP] = getFingerprint_monochrome(Images,qmf,L,sigma) 

database_size = length(Images);             % Number of the images
if database_size==0, error('No images of specified type in the directory.'); end
                
if nargin<4, sigma = 3; end                 % local std of extracted noise
       
t=0; 
for i=1:database_size
    SeeProgress(i),
    if isstruct(Images) %% Remember to uncomment this for
% Example code only
        im = Images(i).name;
% %     else
%         im = Images{i};
    end
%       X = imread(im);
     X = im;
     X = double255(X);
    if t==0
        [M,N]=size(X);
   %  Initialize sums 
        RPsum=zeros(M,N,'single');             
    end
    % The image will be the t-th image used for the reference pattern RP
    t=t+1;                                      % counter of used images
    ImagesinRP(t).name = im;
    
    %% Use the following lines for computing Reference Patterns for Enhanced SPN and Phase SPN 
%     ImNoise = single(NoiseExtract_Basic(X(:,:),qmf,sigma,L)); %NoiseExtract_Phase
%     RPsum = RPsum + ImNoise;
   
   
    %% The following section is to be used for MLE SPN otherwise comment it
  % begin MLE SPN  
    NN=zeros(M,N,'single');
    ImNoise = single(NoiseExtract_MLE(X(:,:),qmf,sigma,L)); 
        Inten = single(IntenScale(X(:,:))).*Saturation(X(:,:));    % zeros for saturated pixels
        RPsum = RPsum+ImNoise.*Inten;   	% weighted average of ImNoise (weighted by Inten)
        NN = NN + Inten.^2;
  
   RP = RPsum./(NN+1);
  %  Remove linear pattern and keep its parameters
   [RP,LP] = ZeroMeanTotal(RP);
% end MLE SPN 
%%
end

clear ImNoise X
if t==0, error('None of the images was color image in landscape orientation.'), end

RP = single(RPsum); % reduce double to single precision for Enhanced SPN and Phase SPN    
RP = single(RP); % Use this for MLE SPN otherwise comment it
    
%%% FUNCTIONS %%
function X=double255(X)
% convert to double ranging from 0 to 255
datatype = class(X);
    switch datatype,                % convert to [0,255]
        case 'uint8',  X = double(X);
        case 'uint16', X = double(X)/65535*255;  
    end
