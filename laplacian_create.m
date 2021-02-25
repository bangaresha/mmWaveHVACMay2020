%%% laplacian create

% Nx,Ny = grid size, including boundary points
% alf = dx/dy
% bc = 1 (clamped), 2 (simple), 3 (free)
% creates laplacian without scaling by 1/dx^2;

function [D] = laplacian_create(Nx,Ny,alf,bc,nu)

    if((bc==1)|(bc==2))
        D = sparse(zeros((Nx-1)*(Ny-1),(Nx-1)*(Ny-1)));

        D0vec = zeros(Nx-1,1); D0vec(1,1) = -2-2*alf^2; D0vec(2,1) = 1; 
        D0 = sparse(toeplitz(D0vec));

        D1 = sparse(diag(ones(Nx-1,1)*alf^2));

        for n=1:Ny-1
            D((n-1)*(Nx-1)+1:n*(Nx-1),(n-1)*(Nx-1)+1:n*(Nx-1)) = D0;
        end
        for n=1:Ny-2
            D((n-1)*(Nx-1)+1:n*(Nx-1),n*(Nx-1)+1:(n+1)*(Nx-1)) = D1;
            D(n*(Nx-1)+1:(n+1)*(Nx-1),(n-1)*(Nx-1)+1:n*(Nx-1)) = D1;
        end
        
    end
    if(bc==3)
        D = sparse(zeros((Nx+1)*(Ny+1),(Nx+1)*(Ny+1)));

        D0vec = zeros(Nx+1,1); D0vec(1,1) = -2-2*alf^2; D0vec(2,1) = 1; 
        D0 = sparse(toeplitz(D0vec));
        D0(1,1) = -2*(1-nu)*alf^2;D0(1,2) = 0;
        D0(Nx+1,Nx+1) = -2*(1-nu)*alf^2;D0(Nx+1,Nx) = 0;
        
        D00vec = zeros(Nx+1,1); D00vec(1,1) = -2*(1-nu); D00vec(2,1) = 1-nu; 
        D00 = sparse(toeplitz(D00vec)); D00(1,1) = 0; D00(1,2) = 0; D00(Nx+1,Nx+1) = 0; D00(Nx+1,Nx) = 0;
        D1 = sparse(diag(ones(Nx+1,1)*alf^2));D1(1,1) = (1-nu)*alf^2; D1(Nx+1,Nx+1) = (1-nu)*alf^2;

        for n=2:Ny
            D((n-1)*(Nx+1)+1:n*(Nx+1),(n-1)*(Nx+1)+1:n*(Nx+1)) = D0;
        end
        for n=2:Ny
            D((n-1)*(Nx+1)+1:n*(Nx+1),n*(Nx+1)+1:(n+1)*(Nx+1)) = D1;
            D((n-1)*(Nx+1)+1:(n)*(Nx+1),(n-2)*(Nx+1)+1:(n-1)*(Nx+1)) = D1;
        end
        D(1:Nx+1,1:Nx+1) = D00;
        D(Ny*(Nx+1)+1:(Nx+1)*(Ny+1),Ny*(Nx+1)+1:(Nx+1)*(Ny+1)) = D00; 
    end