function squat_interactive()
% AS-23 interactive load distribution teaching model (not structural FEA).
% Configuration 1: one four-cell plate. Configuration 2: two four-cell plates.
% Ratings: 300 kg equivalent force per cell. Requires MATLAB uifigure/uiaxes.
rated=300;
fig=uifigure('Name','AS-23 | Force Plate Explorer','Position',[90 70 1280 850], ...
    'Color',[0.97 0.98 0.99]);
uilabel(fig,'Position',[40 801 1120 32], 'Text', ...
    'ALEX SQUAT  |  Force plate load explorer', ...
    'FontSize',21,'FontWeight','bold');
uilabel(fig,'Position',[40 771 1160 23],'Text', ...
    'Move the sliders to shift the load. Numbers show kgf on EACH cell; red indicates above its 300 kg nominal rating.', ...
    'FontSize',12,'FontColor',[0.35 0.4 0.45]);
ax1=uiaxes(fig,'Position',[50 409 555 340]);
ax2=uiaxes(fig,'Position',[665 409 555 340]);
ax1.Color=[1 1 1];ax2.Color=[1 1 1];
controls={'Total vertical load','Single-plate X position','Single-plate Y position', ...
    'Left-foot load share','Left-foot X position','Left-foot Y position', ...
    'Right-foot X position','Right-foot Y position'};
mins=[0 -1 -1 0 -1 -1 -1 -1];
maxs=[750 1 1 1 1 1 1 1];
vals=[280 0 0 .5 0 0 0 0];
sliders=gobjects(1,8);
readouts=gobjects(1,8);
order=[1 2 3 4 5 6 7 8];
for j=1:8
    k=order(j);
    col=floor((j-1)/4); row=mod(j-1,4);
    left=55+620*col;
    labelY=350-77*row;
    uilabel(fig,'Position',[left labelY 355 23], 'Text',controls{k}, ...
        'FontSize',13,'FontWeight','bold');
    readouts(k)=uilabel(fig,'Position',[left+367 labelY 125 23], ...
        'Text','','FontSize',13,'HorizontalAlignment','right');
    sliders(k)=uislider(fig,'Position',[left+5 labelY-27 475 3],...
        'Limits',[mins(k) maxs(k)],'Value',vals(k),'MajorTicks',[],...
        'MinorTicks',[]);
    sliders(k).ValueChangingFcn=@(~,e)change(k,e.Value);
    sliders(k).ValueChangedFcn=@(~,e)change(k,e.Value);
end
status=uilabel(fig,'Position',[40 15 1200 35],'Text','', ...
    'FontSize',15,'FontWeight','bold');
refresh();

    function change(k,value)
        vals(k)=value;
        refresh();
    end

    function f=calcCorners(total,x,y)
        % Corner-weighting visualization. Not a rigid-plate stiffness solver.
        f=total/4 * [(1-x)*(1-y), (1+x)*(1-y), ...
                     (1-x)*(1+y), (1+x)*(1+y)];
    end

    function renderPlate(ax,configuration,loads,x,y)
        cla(ax);hold(ax,'on');
        if configuration==1
            centers=0;
            rectangle(ax,'Position',[-1 -1 2 2], ...
                'EdgeColor',[0.38 0.47 0.61],'LineWidth',2, ...
                'FaceColor',[0.94 0.96 0.99]);
            pts=[-1 -1;1 -1;-1 1;1 1];
            scatter(ax,x,y,180,[0.92 0.38 0.16],'x','LineWidth',2.6);
            xlim(ax,[-1.8 1.8]);
            label='ONE PLATE  /  FOUR CELLS';
        else
            centers=[-1.4 1.4];
            for m=1:2
                rectangle(ax,'Position',[centers(m)-1 -1 2 2], ...
                    'EdgeColor',[0.38 0.47 0.61],'LineWidth',2, ...
                    'FaceColor',[0.94 0.96 0.99]);
            end
            pts=[centers(1)-1 -1;centers(1)+1 -1; ...
                 centers(1)-1 1;centers(1)+1 1; ...
                 centers(2)-1 -1;centers(2)+1 -1; ...
                 centers(2)-1 1;centers(2)+1 1];
            scatter(ax,[centers(1)+x(1),centers(2)+x(2)],y, ...
                180,[0.92 0.38 0.16],'x','LineWidth',2.6);
            xlim(ax,[-2.9 2.9]);
            label='TWO FOOT PLATES  /  EIGHT CELLS';
        end
        for n=1:numel(loads)
            if loads(n)>rated
                c=[0.82 0.15 0.16];
            elseif loads(n)>0.8*rated
                c=[0.94 0.55 0.12];
            else
                c=[0.11 0.55 0.66];
            end
            scatter(ax,pts(n,1),pts(n,2),220,c,'filled',...
                'MarkerEdgeColor',[1 1 1],'LineWidth',1.2);
            if pts(n,2)>0
                textY=pts(n,2)-0.26;
            else
                textY=pts(n,2)+0.26;
            end
            text(ax,pts(n,1),textY,sprintf('%.1f kgf',loads(n)),...
                'HorizontalAlignment','center','FontSize',10,...
                'FontWeight','bold','Color',[0.13 0.18 0.26]);
        end
        ylim(ax,[-1.42 1.42]);axis(ax,'equal');axis(ax,'manual');
        ax.XTick=[];ax.YTick=[];box(ax,'off');grid(ax,'off');
        title(ax,sprintf('%s  |  Peak %.1f kgf',label,max(loads)),...
            'FontWeight','bold','FontSize',13);
        hold(ax,'off');
    end

    function refresh()
        F=vals(1);
        one=calcCorners(F,vals(2),vals(3));
        left=calcCorners(F*vals(4),vals(5),vals(6));
        right=calcCorners(F*(1-vals(4)),vals(7),vals(8));
        renderPlate(ax1,1,one,vals(2),vals(3));
        renderPlate(ax2,2,[left right],[vals(5),vals(7)],...
            [vals(6),vals(8)]);
        readouts(1).Text=sprintf('%.0f kgf',F);
        readouts(2).Text=sprintf('%+.2f',vals(2));
        readouts(3).Text=sprintf('%+.2f',vals(3));
        readouts(4).Text=sprintf('%.0f %%',vals(4)*100);
        for k=5:8
            readouts(k).Text=sprintf('%+.2f',vals(k));
        end
        peak=max([one left right]);
        if peak>rated
            status.Text=sprintf('WARNING  |  Maximum cell %.1f kgf exceeds 300 kg rating',peak);
            status.FontColor=[0.80 0.15 0.17];
        else
            status.Text=sprintf('Total load: %.1f kgf     |     Maximum cell: %.1f kgf (%.0f%% of 300 kg rating)     |     Illustrative model only', ...
                F,peak,100*peak/rated);
            status.FontColor=[0.16 0.35 0.38];
        end
    end
end
