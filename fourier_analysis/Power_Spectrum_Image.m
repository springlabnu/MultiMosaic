[file ,path] = uigetfile('*.tif','Select Image for Power Spectral Analysis');
% Read image
im=double(imread([path file]));

L = (min(size(im))); % Length of the short side of image

% fft2 = 2D fourier transform. fftshift = shift 0-frequency component to middle
imf=fftshift(fft2(im, L, L)); 

impf=abs(imf).^2; % Power spectra = |F(im)|^2
Pf = rotavg(impf); % Rotational average of the 2D power spectra

%% Scramble image for control
imvector = reshape(im, 1, []); 
imrand = imvector(randperm(length(imvector)));
imrand = reshape(imrand, size(im));

imfrand=fftshift(fft2(imrand, L, L));
impfrand=abs(imfrand).^2;
Pfrand=rotavg(impfrand);

%% Put back into spatial units
lengths = 1.1 * (L) ./ (1:(L/2))'; % HyperCFME: 1.1 um/pixel, so lenghts are um

Pf = Pf(2:end);
Pfrand = Pfrand(2:end);

%% Graph results
% Grab window of 15 um - max um, and normalize to sum total heterogeneity
Pf = Pf(lengths>10);
Pfrand = Pfrand(lengths>10);
lengths = lengths(lengths>10);

Pf = Pf / sum(Pf, 'all');
Pfrand = Pfrand / sum(Pfrand, 'all');

figure
loglog(lengths,Pf,lengths, Pfrand);
