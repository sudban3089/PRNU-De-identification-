function Noise = NoiseExtractFromImage_MLE(image,qmf,sigma,L,noZM,color)

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
    Noise = NoiseExtract_MLE(X,qmf,sigma,L);
    if ~color
        Noise = rgb2gray1(Noise);
    end
end
if noZM
    'not removing the linear pattern';
    
else
    Noise = ZeroMeanTotal(Noise);
end
Noise = single(Noise);




