function [ L_opt, K_opt] = UPOLS_parameters(N, B)
% N: IR length
% B: buffer length
    c_opt = inf;
    for k =1:log2(N)
        rang(k) = 2^k;
    end
    for k = 1:length(rang)
        L = rang(k);
        d_max = B - gcd(L,B);
        K_min = B + L + d_max - 1;
%         K_max = 2^ceil(log2(K_min));
%         k_sort = np.sort([K_min, K_max])
%         if k_sort[0] == k_sort[1]:
%             k_sort[1] = k_sort[1]+1
%         end
        for K = K_min%:K_max
            c = cost(B,N,L,K);
            if c < c_opt
                c_opt = c;
                L_opt = L;
                K_opt = K;
            end
        end
    end
end
        

function c = cost(B,N,L,K)
    % theoretical time estimates for each operation, pag. 211'''
      c = 1/B*( 1.68*K*log2(K) + 3.49*K*log2(K) + ...
          6*((K+1)/2) + ((N/L)-1)*8*((K+1)/2));
end
        