function vc_ieeg_elAdd_sizable_colors(els,r2,colorMode,varargin)

% VC_IEEEG_ELADD_SIZABLE Plot electrodes with value-dependent marker size.
%
%   vc_ieeg_elAdd_sizable_colors(els,r2,colorMode)
%   vc_ieeg_elAdd_sizable_colors(els,r2,colorMode,maxr2,max_elsize)
%
% INPUTS
%   els        - electrode coordinates; rows = electrodes, columns = xyz
%   r2         - values used to determine electrode size and color
%   colorMode  - visualization mode:
%                  'green'
%                  'pink'
%
% OPTIONAL INPUTS
%   maxr2      - maximum value used for scaling
%   max_elsize - maximum electrode marker size (default = 45)
%
% This function is adapted from:
%
%   ieeg_elAdd_sizable.m
%   K.J. Miller and D. Hermes
%
% Original source in github:
%   MultimodalNeuroimagingLab/mnl_ieegBasics/
%   functions/ieeg_elAdd_sizable.m
%
% Original copyright:
%   Copyright (C) 2006 K.J. Miller & D. Hermes,
%   Dept of Neurology and Neurosurgery,
%   University Medical Center Utrecht
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% Modified by Maria Guadalupe Yanez-Ramos (MGYR)
% and Dora Hermes (DH), 2026.
%
% Modifications include configurable color maps and visualization
% behavior used for the visual connectivity analyses.


hold on

%% Defaults

max_elsize = 45;
maxr2 = round(max(r2));

if abs(round(min(r2))) > maxr2
    maxr2 = abs(round(min(r2)));
end

% Optional scaling value.
if ~isempty(varargin) && ~isempty(varargin{1})
    maxr2 = varargin{1};
end

% Optional maximum electrode size.
if numel(varargin) >= 2 && ~isempty(varargin{2})
    max_elsize = varargin{2};
end

r2 = r2 / maxr2;

elsize = 15:(max_elsize-15)/(100-1):max_elsize;


%% Color map

switch lower(colorMode)

    case 'green'

        colors = [
            0.8  1.00  0.10
            0.00 0.40  0.00
            0.00 0.70  0.00
            0.50 1.00  0.05
        ];

        nColors = 100;
        x = [1 33 66 100];

        cm1 = interp1(x,colors,linspace(1,100,nColors));


    case 'pink'

        colors = [
            0.00 0.00 0.75
            0.70 0.429 0.748
            1.00 0.00 1.00
            1.00 0.78 0.89
        ];

        nColors = 100;
        x = [1 33 66 100];

        cm1 = interp1(x,colors,linspace(1,100,nColors));

        % Preserve behavior of the previous pink implementation.
        cm2 = colormap('parula');


    otherwise

        error('Unknown colorMode "%s". Use "green" or "pink".', ...
            colorMode);

end


%% Plot electrodes

for k = 1:size(els,1)

    if isnan(r2(k))
        continue
    end

    switch lower(colorMode)

        case 'green'

            if r2(k) > 0

                ind_color = abs(round(100*r2(k)));

                if ind_color > 100
                    ind_color = 100;
                end

                elsize_r2 = elsize(ind_color);
                elcol_r2 = cm1(ind_color,:);

                plot3(els(k,1),els(k,2),els(k,3),'.', ...
                    'Color','k', ...
                    'MarkerSize',elsize_r2+2)

                plot3(els(k,1),els(k,2),els(k,3),'.', ...
                    'Color',elcol_r2, ...
                    'MarkerSize',elsize_r2-5)

            else

                plot3(els(k,1),els(k,2),els(k,3),'.', ...
                    'Color',[.99 .99 .99], ...
                    'MarkerSize',12)

                plot3(els(k,1),els(k,2),els(k,3),'.', ...
                    'Color','k', ...
                    'MarkerSize',12)

            end


        case 'pink'

            if abs(r2(k)) > 0.01

                ind_color = abs(round(100*r2(k)));

                if ind_color > 100
                    ind_color = 100;
                end

                elsize_r2 = elsize(ind_color);

                if r2(k) > 0.01

                    elcol_r2 = cm1(ind_color,:);

                    plot3(els(k,1),els(k,2),els(k,3),'.', ...
                        'Color','k', ...
                        'MarkerSize',elsize_r2)

                    plot3(els(k,1),els(k,2),els(k,3),'.', ...
                        'Color',elcol_r2, ...
                        'MarkerSize',elsize_r2-5)

                elseif r2(k) < 0.01

                    elcol_r2 = cm2(ind_color,:);

                    plot3(els(k,1),els(k,2),els(k,3),'.', ...
                        'Color','k', ...
                        'MarkerSize',elsize_r2)

                    plot3(els(k,1),els(k,2),els(k,3),'.', ...
                        'Color',elcol_r2, ...
                        'MarkerSize',elsize_r2-5)

                end

            else

                plot3(els(k,1),els(k,2),els(k,3),'.', ...
                    'Color','k', ...
                    'MarkerSize',12)

            end

    end

end

end