%% Use this function for computing Enhanced test noise residuals - Model III Enhancement. Refer to paper by
% C.T. Li,"Source Camera Identification Using Enhanced Sensor Pattern
% Noise", T-IFS 2010 for more details
%%
function image_noise_enhanced = NoiseExtract_Enhanced(Im,qmf,sigma,L)

datatype = class(Im);
switch datatype,                % convert to [0,1]
    case 'double',  'do nothing';
    otherwise Im = double(Im);
end

[M,N] = size(Im);

Im_original = Im;

m = 2^L;
% use padding with mirrored image content
minpad=2;    % minimum number of padded rows and columns as well
nr = ceil((M+minpad)/m)*m;  nc = ceil((N+minpad)/m)*m;  % dimensions of the padded image (always pad 8 pixels or more)
pr = ceil((nr-M)/2);      % number of padded rows on the top
prd= floor((nr-M)/2);     % number of padded rows at the bottom
pc = ceil((nc-N)/2);      % number of padded columns on the left
pcr= floor((nc-N)/2);     % number of padded columns on the right
Im = [Im(pr:-1:1,pc:-1:1),     Im(pr:-1:1,:),     Im(pr:-1:1,N:-1:N-pcr+1);
    Im(:,pc:-1:1),           Im,                Im(:,N:-1:N-pcr+1);
    Im(M:-1:M-prd+1,pc:-1:1),Im(M:-1:M-prd+1,:),Im(M:-1:M-prd+1,N:-1:N-pcr+1)];
% check this: Im = padarray(Im,[nr-M,nc-N],'symmetric');

% Precompute noise variance and initialize the output
NoiseVar = sigma^2;

wave_trans = zeros(nr,nc); % malloc the memory
% Wavelet decomposition, without redudance
wave_trans = mdwt(Im,qmf,L);

% Extract the noise from the wavelet coefficients

for i=1:L
    % indicies of the block of coefficients
    Hhigh = (nc/2+1):nc; Hlow = 1:(nc/2);
    Vhigh = (nr/2+1):nr; Vlow = 1:(nr/2);
    
    % Horizontal noise extraction
    wave_trans(Vlow,Hhigh) = WaveNoise(wave_trans(Vlow,Hhigh),NoiseVar);
    
    % Vertical noise extraction
    wave_trans(Vhigh,Hlow) =  WaveNoise(wave_trans(Vhigh,Hlow),NoiseVar);
    
    % Diagonal noise extraction
    wave_trans(Vhigh,Hhigh) = WaveNoise(wave_trans(Vhigh,Hhigh),NoiseVar);
    
    nc = nc/2; nr = nr/2;
end

% Last, coarest level noise extraction
wave_trans(1:nr,1:nc) = 0;


%% Model 3 Enhancement

wave_trans = bsxfun(@times, wave_trans, 1./sqrt(sum(wave_trans.^2, 2))); %% L2 normalization

[row, col]=size(wave_trans);
alpha=6; %% THIS ALPHA IS PART OF ENHANCEMENT NOT FOR ANONYMIZATION OR SPOOFING

Noise_enhanced =zeros(row,col);

for p=1:row
    for q=1:col
        if ( wave_trans(p,q)>=0 &&  wave_trans(p,q)<=alpha)
            Noise_enhanced(p,q)=1-exp(- wave_trans(p,q));
        elseif ( wave_trans(p,q)>=-alpha &&  wave_trans(p,q)<0)
            Noise_enhanced(p,q)=-1+exp( wave_trans(p,q));
        elseif  wave_trans(p,q)>alpha
            Noise_enhanced(p,q)=(1-exp(-alpha)).*exp(alpha- wave_trans(p,q));
        elseif  wave_trans(p,q)<-alpha
            Noise_enhanced(p,q)=(-1+exp(-alpha)).*exp(alpha+ wave_trans(p,q));
        end
    end
end

%% Inverse wavelet transform

image_noise = midwt(Noise_enhanced,qmf,L);

%% Crop to the original size
image_noise_enhanced = image_noise(pr+1:pr+M,pc+1:pc+N);
