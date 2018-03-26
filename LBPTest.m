fingerprint = imread('s8.png');
greyFingerprint = rgb2gray(fingerprint);
test = size(greyFingerprint);
test2 = prod(floor(size(greyFingerprint)./[3 3]));

figure
imshow(greyFingerprint)
title('Original Fingerprint')

imageSize = size(greyFingerprint);
numRows = imageSize(1);
numCols = imageSize(2);

wavelengthMin = 4/sqrt(2);
wavelengthMax = hypot(numRows,numCols);
n = floor(log2(wavelengthMax/wavelengthMin));
wavelength = 2.^(0:(n-2)) * wavelengthMin;

deltaTheta = 45;
orientation = 0:deltaTheta:(180-deltaTheta);

g = gabor(wavelength,orientation);

gabormag = imgaborfilt(greyFingerprint,g);

for i = 1:length(g)
    sigma = 0.5*g(i).Wavelength;
    K = 3;
    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),K*sigma); 
end


X = 1:numCols;
Y = 1:numRows;
[X,Y] = meshgrid(X,Y);
featureSet = cat(3,gabormag,X);
featureSet = cat(3,featureSet,Y);

numPoints = numRows*numCols;
X = reshape(featureSet,numRows*numCols,[]);

X = bsxfun(@minus, X, mean(X));
X = bsxfun(@rdivide,X,std(X));

coeff = pca(X);
feature2DImage = reshape(X*coeff(:,1),numRows,numCols);
figure
imshow(feature2DImage,[])

L = kmeans(X,2,'Replicates',5);

L = reshape(L,[numRows numCols]);
figure
imshow(label2rgb(L))

Aseg1 = zeros(size(greyFingerprint),'like',greyFingerprint);
Aseg2 = zeros(size(greyFingerprint),'like',greyFingerprint);
BW = L == 2;
BW = repmat(BW,[1 1]);
Aseg1(BW) = greyFingerprint(BW);
Aseg2(~BW) = greyFingerprint(~BW);
figure
imshow(Aseg1);


lbpFeatures = extractLBPFeatures(bw,'Normalization','None');
all = sum(lbpFeatures);
diagram = lbpFeatures/all;

figure
bar(diagram);
title ('Histogram of s1');