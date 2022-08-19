%Function rri_remap
%syntax [outmat,coords]=rri_remap(datamat,mb)
% Selects only voxels that are identified as brain and writes them
% to a new matrix.  Returns also the coordinates for each row so the
% voxels can be remapped to brain images

function[outmat,coords]=rri_remap(datamat,mb)
%Find brain pixels
coords=find(mb~=0);

[r c]=size(datamat);

%remaps datamat to have only brain voxels, will cut the problem in half
%voxels will be remapped later

for i=1:r
	outmat(i,:)=datamat(i,coords);
end

