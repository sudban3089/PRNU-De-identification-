%%For details about Phase SPN, refer to
% Kang et al., "Enhancing Source Camera Identification Performance With a
% Camera Reference Phase Sensor Pattern Noise", T-IFS 2012
%%
function Noise = NoiseExtractFromImage_Phase(image,qmf,sigma,L,noZM,color)

if nargin<5, noZM=0;  end
 if nargin<6, color=0; end

if ischar(image), X = imread(image); else X = image; clear image, end

[M0,N0,three]=size(X);
    datatype = class(X);
    switch datatype,                    % convert to [0,255]
        case 'uint8',  X = double(X);
        case 'uint16', X = double(X)/65535*255;
    end


if three~=3,
    Noise = NoiseExtract_Basic(X,qmf,sigma,L); % for test use NoiseExtract_Basic.m for generating Phase Reference Pattern use NoiseExtract_Phase.m 
    if ~color
        Noise = rgb2gray1(Noise);
    end
 end
if noZM
    'not removing the linear pattern';
  
end
 Noise = single(Noise);
 



