function squat_interactive()
% Interactive AS-23 position sensitivity viewer. Requires MATLAB graphics.
% Uses illustrative corner weighting, NOT stiffness/FEA structural analysis.
fig=uifigure('Name','AS-23 Force Plate Explorer','Position',[100 100 1050 670]);
uilabel(fig,'Position',[25 625 960 30],'Text',...
 '300 kg rated per load cell | Static position study (approximate)','FontSize',17,'FontWeight','bold');
ax1=uiaxes(fig,'Position',[25 250 470 340]);title(ax1,'Configuration 1: four cells');
ax2=uiaxes(fig,'Position',[545 250 470 340]);title(ax2,'Configuration 2: eight cells');
controls={'Total equivalent load [kgf]','Single plate X','Single plate Y',...
'Left foot force fraction','Left foot X','Left foot Y','Right foot X','Right foot Y'};
mins=[0,-1,-1,0,-1,-1,-1,-1];maxs=[750,1,1,1,1,1,1,1];
vals=[280,0,0,0.5,0,0,0,0]; sliders=gobjects(1,8);
for k=1:8
 row=mod(k-1,4);col=floor((k-1)/4);
 xx=35+525*col; yy=202-53*row;
 uilabel(fig,'Position',[xx yy+18 245 20],'Text',controls{k});
 sliders(k)=uislider(fig,'Position',[xx yy 405 3],...
 'Limits',[mins(k) maxs(k)],'Value',vals(k));
 sliders(k).ValueChangingFcn=@(~,event) preview(k,event.Value);
 sliders(k).ValueChangedFcn=@(~,event) preview(k,event.Value);
end
status=uilabel(fig,'Position',[20 7 1000 24],'Text','',...
 'FontSize',13,'FontWeight','bold');
refresh();
    function preview(idx,val)
        vals(idx)=val; refresh();
    end
    function loads=corner(F,x,y)
        loads=F/4*[(1-x)*(1-y),(1+x)*(1-y),(1-x)*(1+y),(1+x)*(1+y)];
    end
    function drawPlate(ax,which,forces,xs,ys)
        cla(ax);hold(ax,'on');
        if which==1
            rectangle(ax,'Position',[-1 -1 2 2],'EdgeColor',[.35 .4 .5],'LineWidth',2);
            positions=[-1 -1;1 -1;-1 1;1 1];
            scatter(ax,positions(:,1),positions(:,2),180,forces,'filled');
            scatter(ax,xs,ys,160,[.9 .35 .1],'filled','Marker','x','LineWidth',3);
        else
            rectangle(ax,'Position',[-2.2 -1 2 2],'EdgeColor',[.35 .4 .5],'LineWidth',2);
            rectangle(ax,'Position',[.2 -1 2 2],'EdgeColor',[.35 .4 .5],'LineWidth',2);
            positions=[-2.2 -1;-.2 -1;-2.2 1;-.2 1;.2 -1;2.2 -1;.2 1;2.2 1];
            scatter(ax,positions(:,1),positions(:,2),180,forces,'filled');
            scatter(ax,[-1.2+xs(1),1.2+xs(2)],[ys(1),ys(2)],...
                160,[.9 .35 .1],'x','LineWidth',3);
        end
        for n=1:numel(forces)
            text(ax,positions(n,1),positions(n,2)+.25,...
                sprintf('%.1f kgf',forces(n)),'HorizontalAlignment','center',...
                'FontSize',10,'FontWeight','bold');
        end
        axis(ax,'equal');xlim(ax,[-2.6 2.6]);ylim(ax,[-1.5 1.5]);grid(ax,'on');
        xlabel(ax,'Relative plate X');ylabel(ax,'Relative plate Y');
        maxval=max(forces);
        title(ax,sprintf('Highest cell: %.1f kgf (%.0f%% rated)',maxval,100*maxval/300));
    end
    function refresh()
        F=vals(1);
        a=corner(F,vals(2),vals(3));
        % Split plate total force according to foot fraction, for demonstration.
        fl=corner(F*vals(4),vals(5),vals(6));
        fr=corner(F*(1-vals(4)),vals(7),vals(8));
        drawPlate(ax1,1,a,vals(2),vals(3));
        drawPlate(ax2,2,[fl fr],[vals(5) vals(7)],[vals(6) vals(8)]);
        worst=max([a fl fr]);
        if worst>300,tag='ABOVE SENSOR RATED RANGE';
        else,tag='Within nominal cell rated range (NOT safety certification)';end
        status.Text=sprintf('Total %.1f kgf | max cell %.1f kgf | %s',F,worst,tag);
    end
end
