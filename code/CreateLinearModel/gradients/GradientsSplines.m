function [ dE, E ] = GradientsSplines(MomFull, Timepoints, GradientName, varargin)
% Prepares gradients with finite difference scheme
    for i = 1:size(MomFull, 1)
        switch GradientName
            case 'splines'
                [dE(i, :), ~, ~, E(i, :)] = SplineGradient(VertVect(MomFull(i, :)), VertVect(Timepoints));
            case 'splines2'
                [dE(i, :), ~, ~, E(i, :)] = SplineGradient2(VertVect(MomFull(i, :)), VertVect(Timepoints));
            case 'splinessm'
                [dE(i, :), ~, ~, E(i, :)] = SplineGradientSM(VertVect(MomFull(i, :)), VertVect(Timepoints));
            case 'smooth'
                [dE(i, :), ~, ~, E(i, :)] = SmoothSplineGradient(VertVect(MomFull(i, :)), VertVect(Timepoints));
            case {'bsplines4', 'ramsayOLS', 'ramsayFG'}
                dk = 4;
                x = VertVect(Timepoints);
                y = VertVect(MomFull(i, :));
                [ cBsplines, breaks ] = BSplineFit( x, y, dk );
                [ E(i, :), dy ] = BSplineEst( dk, breaks, cBsplines, x);
                dE(i, :) = dy(2:end);
            case 'adaptive'
                b_hat = varargin{1};
                MomFullWeights = varargin{2};
                dk = 4;
                lamda_list = exp([-7:7]);

                x = VertVect(Timepoints);
                y = VertVect(MomFull(i, :));
                w = VertVect(MomFullWeights(i, :));
                
                [ cBsplines, breaks ] = BSplineFit( x, y, dk );
                [ E(i, :), dy ] = BSplineEst( dk, breaks, cBsplines, x);
                dE(i, :) = dy(2:end);
                
                MseFit = [];
                dMseFit = [];
                for lambda = lamda_list
                    [ cBsplines, breaks ] = BSplineFitSmooth( lambda, x, y, b_hat(i, :), w, dk);
                    [ y_hat, dy_hat ] = BSplineEst( dk, breaks, cBsplines, x(2:end));
                    MseFit(end+1) = std((y_hat - y(2:end)) ./ w(2:end));
                    dMseFit(end+1) = std((dy_hat - b_hat(i, :)')/mean(b_hat(i, :)));
                end
                g = MseFit + dMseFit;
                [~, ii] = min(g);

                lambda = lamda_list(ii);
                [ cBsplines, breaks ] = BSplineFitSmooth( lambda, x, y, b_hat(i, :), w, dk);
                [ E(i, :), dy ] = BSplineEst( dk, breaks, cBsplines, x);
                dE(i, :) = dy(2:end);
        end
    end
end


