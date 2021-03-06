classdef GP_Mat3Cov_DepthFun < GP_CovFunc
   
    properties
%        u_x
%        u_y
%        u_z
       Beta
       r0
    end
    
    methods
        function this = GP_Mat3Cov_DepthFun(Beta,r0)
%             this.u_x = u_x;
%             this.u_y = u_y;
%             this.u_z = u_z;
%             if nargin>3
                this.Beta = Beta;
%             end
%             if nargin>4
                this.r0 = r0;
%             end
        end
        
         function [K z] = eval(this, X1, X2, par)
            [D,N1] = size(X1); %number of points in X1
            N2 = size(X2,2); %number of points in X2
            if D~=size(X2,1)
                error('Dimensionality of X1 and X2 must be the same');
            end
            if (length(par)~=D+1)
                error('Wrong number of hyperparameters for Mat3');
            end
            %Compute weighted squared distances:
            w = par(1:D)'.^(-2);
            XX1 = sum(w(:,ones(1,N1)).*X1.*X1,1);
            XX2 = sum(w(:,ones(1,N2)).*X2.*X2,1);
            X1X2 = (w(:,ones(1,N1)).*X1)'*X2;
            XX1T = XX1';
            % numerical effects can drive z slightly negative 
            z = max(0,XX1T(:,ones(1,N2)) + XX2(ones(1,N1),:) - 2*X1X2);
            K = par(D+1)^2 *(1+sqrt(3*z)).* exp(-sqrt(3*z));
            Depth1 = X1(3,:);
            Depth2= X2(3,:);
            W1 = sqrt((Depth1+this.r0).^this.Beta);
            W2 = sqrt((Depth2+this.r0).^this.Beta);
            K = diag(W1)*K*diag(W2);
%             W = compute_distance_weighting(xobs, u_x, u_y, u_z)
        end
    end
    
    
    % Most covariance functions will be static
    methods(Static) 
        
        function n_theta = npar(D)
            n_theta = D+1; % each dimension + signal variance
        end
        
       
        
%         function [g] = gradient(X, par)
%             
%           %Gradient currently not working correctly.
%             % Same as K?
%             [Kg z] = GP_Mat3Cov.eval(X, X, par);
% 
%             [d,n] = size(X);
%             g = cell(1,d+1);
%             for i=1:d
%  
%                 %Compute weighted squared distance
%                 row = X(i,:);
%                 XXi = row.*row;
%                 XTXi = row'*row;
%                 XXi = XXi(ones(1,n),:);
%                 zi = max(0,XXi+XXi'-2*XTXi);
%                 wi = par(i)^(-3);
%                 g{i} = par(d+1)^2*3*zi* wi.*exp(-sqrt(3*z));
%             end
%             g{d+1} = Kg*(2/par(d+1));
%         end
%         
        
        % Also overload the point covariance kx*x* - its trivial
%         function v = pointval(x_star, par)
%             v = par(end).^2 * ones(1,size(x_star,2));
%         end
        
    end
end
