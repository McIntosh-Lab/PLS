%  Usage:  [llcorr, ulcorr, prop, llcorr_adj, ulcorr_adj] = ...
%	rri_distrib(distrib, ll, ul, num_boot, ClimNi, orig_corr)
%
%  Note: change corr to usc for method 1,2
%        change distrib to Tdistrib for method 4,6
%
function  [llcorr, ulcorr, prop, llcorr_adj, ulcorr_adj] = ...
	rri_distrib(distrib, ll, ul, num_boot, ClimNi, orig)
  
   %  loop to calculate upper and lower CI limits
   %
   for r=1:size(distrib,1)	
      for c=1:size(distrib,2)
         ulcorr(r,c)=percentile(distrib(r,c,2:num_boot+1),ul);
         llcorr(r,c)=percentile(distrib(r,c,2:num_boot+1),ll);
         prop(r,c)=length( find(distrib(r,c,2:num_boot+1) ...
                                    <= orig(r,c)) ) / num_boot;

         if prop(r,c)==1 |prop(r,c)==0
            llcorr_adj(r,c)=NaN;
            ulcorr_adj(r,c)=NaN;
         else

            % adjusted confidence intervals - in case the
            % bootstrap samples are extremely skewed

            % norm inverse to start to adjust conf int
            %
            ni=cumulative_gaussian_inv(prop(r,c));

            % 1st part of recalc the lower conf interval,
            % this evaluates to +1.96 for 95%CI
            %
            uli=(2*ni) + cumulative_gaussian_inv(1-ClimNi);

            % 1st part of recalc the upper conf interval
            % e.g -1.96 for 95%CI
            %
            lli=(2*ni) + cumulative_gaussian_inv(ClimNi); 

            ncdf_lli=cumulative_gaussian(lli)*100;	% percentile for lower bounds
            ncdf_uli=cumulative_gaussian(uli)*100;	% percentile for upper bounds

            % new percentile
            %
            llcorr_adj(r,c)=(percentile(distrib(r,c,2:num_boot+1), ncdf_lli));
            ulcorr_adj(r,c)=(percentile(distrib(r,c,2:num_boot+1), ncdf_uli));

         end	% if
      end		% for c
   end			% for r

