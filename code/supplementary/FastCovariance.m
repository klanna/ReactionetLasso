function [ cv, mAB ] = FastCovariance( A, B )
% fast covariance estimation between two matrices along second dim
    [~, N] = size(A);
%     w = N / (N-1);
    w = 1;
    mA = mean(A, 2);
    mB = mean(B, 2);
    mAB = mean(A.*B, 2);
    cv = w*(mAB - mA.*mB);
%     ErrCv = w^2 * var(A.*B, 0, 2) / N;
end

