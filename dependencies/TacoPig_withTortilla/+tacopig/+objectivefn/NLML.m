% The negative log marginal likelihood function
% [nlml, nlmlg] = GP.objectivefn.NLML(parvec)
% Inputs: parvec = a concatinated vector of the mean function, covariance
%         function and noise funtion's parameters/hyperparameters.
% Outputs: nlml = the negative log marginal likelihood
%          nlmlg = the gradient of the log marginal likelihood with respect to each of the parameters in parvec.

function [nlml, nlmlg] = NLML(this, parvec)
            

                
            % Get configuration
            use_svd = strcmpi(this.factorisation, 'svd');
            use_chol = strcmpi(this.factorisation, 'chol');
%           need_grad = strcmpi(optimget(this.opts,'GradObj'),'on');
            
            % Unpack the parameters
            D = size(this.X,1);
            ncovpar = this.CovFn.npar(D);
            nmeanpar = this.MeanFn.npar(D);
            nnoisepar = this.NoiseFn.npar;
            
            meanpar = parvec(1:nmeanpar);
            covpar = parvec(nmeanpar+1:nmeanpar+ncovpar);
            noisepar = parvec(nmeanpar+ncovpar+1:nmeanpar+ncovpar+nnoisepar);

            
            % Update hypers during learning in case we stop early
            this.meanpar = meanpar;
            this.covpar = covpar;
            this.noisepar = noisepar;

            % Get mu, K and (y-mu) and gradients if needed
            %if (need_grad) 
            % will we at some point have Keval providing gradients directly?
            %    [K, kgrad] = this.CovFn.Keval(this.X, covpar);
            %else
                K = this.CovFn.Keval(this.X, this);
                N = size(K,1); % not always equal to the size of X!
                noise = this.NoiseFn.eval(this.X, this);
            %end
            
            K = K + noise;
            mu = this.MeanFn.eval(this.X, this); 
            ym = this.y-mu;
            
            
            % Factorise K
            if (use_svd)
                [U,S,V] = svd(K);
                S0 = diag(S);
                S2 = S0;
                S2(S2>0) = 1./S2(S2>0);
                invK = V*diag(S2)*U';
                alpha = (invK*ym');
                nlml = 0.5*(ym*alpha + sum(log(S0)) + N*log(2*pi));
            elseif (use_chol)
                L = chol(K, 'lower');
                if nargout>1
                    I = eye(size(K));
                    invK  = L'\(L\I);
                    alpha = (invK*ym');
                else
                    alpha = L'\(L\ym');
                end
                nlml = 0.5*(ym*alpha + 2*sum(log(diag(L))) + N*log(2*pi));
            else
                error('tacopig:badConfiguration','Invalid factorisation choice');
            end
            
            %Compute the gradient for covariance hyperparameters
            if nargout>1
                
                disp(['Using Gradients ... by marcos.'])
                W = invK - alpha*alpha';
                mgrad     = this.MeanFn.gradient(this.X, this);
                kgrad     = this.CovFn.gradient(this.X, this);
                noisegrad = this.NoiseFn.gradient(this.X, this);
                nlmlg     = zeros(length(parvec),1);
                
                % Mean Function Gradient
                for i= 1:length(mgrad)
                    nlmlg(i) = -mgrad{i}*alpha;
                end
                
                % Kernel Gradient
                for i = 1:length(kgrad)
                    nlmlg(i+nmeanpar) = 0.5*sum(sum(W.*kgrad{i}));
                end    

                %Noise gradient
                for i = 1:length(noisegrad)
                    nlmlg(ncovpar+nmeanpar+i) = 0.5*sum(sum(W.*noisegrad{i}));
                end
               
            end
          
           
        end
