% rotavg.m - function to compute rotational average of (square) array
% by Bruno Olshausen
% 
% function f = rotavg(array)
%
% array can be of dimensions N x N x M, in which case f is of 
% dimension NxM.  N should be even.
%

function f = rotavg(array)

% TODO: Cut off edges of large side of array
if size(array,1) ~= size(array,2)
    [len, wid] = size(array, [1 2]);
    
    if len > wid
        array = array(floor(len/2-wid/2):floor(len/2+wid/2),:,:); 
        
    else
        array = array(:,ceil(wid/2-len/2):floor(wid/2+len/2),:); 
    end
end

if mod(size(array,1),2) % N is odd
    array = array(1:end-1, 1:end-1, :);
end

if ~isreal(array) % Array is a complex number
    x = real(array);
    y = imag(array);
    clear array
    array(:,:,1) = x;
    array(:,:,2) = y;
    
    iscomplex = 1;
else
    iscomplex = 0;
end

[~, N, M]=size(array);



[X, Y]=meshgrid(-N/2:N/2-1,-N/2:N/2-1);

[~, rho]=cart2pol(X,Y);

rho=round(rho);
i=cell(N/2+1,1);
for r=0:N/2
  i{r+1}=find(rho==r);
end

f=zeros(N/2+1,M);

for m=1:M

  a=array(:,:,m);
  for r=0:N/2
    f(r+1,m)=mean(a(i{r+1}));
  end
  
end

if iscomplex
    x = f(:,1);
    y = f(:,2);
    f = complex(x,y);
end


