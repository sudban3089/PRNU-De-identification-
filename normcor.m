function ncvalue=normcor(input1,input2)


% Set up temporary array for holding mean subtracted difference

alloc_input1 = size(input1);
alloc_input2 = size(input2);
numDim=1; % numDimensions =1 for grayscale image

meanSubtracted_input1 = repmat(0, alloc_input1);
meanSubtracted_input2 = repmat(0, alloc_input2);

% Calculate mean subtracted difference images

for i=1:numDim
    mean_input1(i) = mean(mean(input1(:,:,i)));
    meanSubtracted_input1(:,:,i) = input1(:,:,i) - mean_input1(i);
    
    mean_input2(i) = mean(mean(input2(:,:,i)));
    meanSubtracted_input2(:,:,i) = input2(:,:,i) - mean_input2(i);
end

for i=1:numDim
    num(i) = sum(sum(meanSubtracted_input1(:,:,i).*meanSubtracted_input2(:,:,i)));
    den(i) = sqrt(sum(sum(meanSubtracted_input1(:,:,i).^2))).*...
        sqrt(sum(sum(meanSubtracted_input2(:,:,i).^2)));
end

ncvalue = num./den;
