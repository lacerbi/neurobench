function mat = grammSchmidt(v)
%grammSchindt Orthonormalization process.
% usage: (i)  mat = grammSchmidt(v) where v is a nxn matrix set arranged in row vectors.
%             out mat is the orthonormal set.
% usage: (ii) mat = grammSchmidt(v) where v is a nx1 vector.
%             out mat is the orthonormal set, where one of the vectors is
%             the normalized input vector.
%        in each case the orthonormal set in mat is given in rows (i.e. 
%        { mat(1,:), mat(2,:)....mat(n,:) }
% Created by <a href="mailto:ohad_m@yahoo.com">Ohad Menashe</a> 2010 



%input check
if(size(v,2)~=1 && size(v,2)~=size(v,1))
    error('Either square matrix or clomn vector!');
end
%case vector: build square matrix from vector
if(size(v,2)==1)
    v=v';
    mat = eye(size(v',1));
	%put the input vector in the matrix, occording top the maximum element
    [a b ] =max(v);
    mat(1,:)=v;
    if(b~=1)
    mat(b,:) = [1 zeros(1,size(mat,1)-1)];
    end
else
    mat = v;
end
% fprintf('[%5.1f%%]',0);
for i=2:length(v)
	%normalize i-1
    mat(i-1,:)=mat(i-1,:)/sqrt(mat(i-1,:)*mat(i-1,:)');
	%build projection matrix of all the previous vectors
    b = mat(1:i-1,:)';
    P = eye(size(b,1))-b*(b'*b)^-1*b';
    mat(i,:) = mat(i,:)*P;
    % fprintf('\b\b\b\b\b\b\b\b[%5.1f%%]',i/length(v)*100);
end
%normalize last row
mat(end,:)=mat(end,:)/sqrt(mat(end,:)*mat(end,:)');
assert(max(max(abs(mat*mat'-eye(size(mat)))))<1e-6,'bad grammSchimdt! not orthogonal set in output???');
end