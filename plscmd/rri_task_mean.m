function [meanmat,stdmat]=rri_task_mean(inmat,n)
% Syntax [meanmat,stdmat]=rri_task_mean(inmat,n)
% Returns a matrix of task means and standard deviations for an array
% with data for each task stacked on top of one another

[m1 m]=size(inmat);
k=m1/n;

if strcmpi(class(inmat),'single')
   meanmat=single(zeros(k,m));
else
   meanmat=zeros(k,m);
end

if(nargout>1)
	stdmat=zeros(k,m);
end

temp=zeros(n,m);

for i=1:k
	temp=inmat(1+(n*(i-1)):n*i,:);
	meanmat(i,:)=mean(temp,1);

	if(nargout>1)
		stdmat(i,:)=std(temp,0,1);
	end
end

