function q = vc_bh_fdr(p)
% VC_BH_FDR Benjamini-Hochberg FDR-adjusted p-values.
% Aug 2026
% Authors: Maria Guadalupe Yanez Ramos (MGYR) and Dora Hermes (DH). 

originalSize = size(p);
p = p(:);

valid = isfinite(p);
pv = p(valid);

[ps, order] = sort(pv);
m = numel(ps);

q_sorted = ps .* m ./ (1:m)';
q_sorted = flipud(cummin(flipud(q_sorted)));
q_sorted = min(q_sorted, 1);

q_valid = nan(m,1);
q_valid(order) = q_sorted;

q = nan(size(p));
q(valid) = q_valid;

q = reshape(q, originalSize);

end