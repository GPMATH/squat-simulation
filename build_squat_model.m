function model=build_squat_model()
% AS-23: build reproducible one-plate/two-plate Simulink visualization.
% A simplified sensitivity model, not validated mechanics/FEA.
model='alex_squat_force_plates';
if bdIsLoaded(model),close_system(model,0);end
new_system(model);open_system(model);
set_param(model,'StopTime','10','Solver','FixedStepDiscrete','FixedStep','0.02');
inputs={'athlete_accel','motor_downward_N','single_x','single_y','left_fraction','left_x','left_y','right_x','right_y'};
for k=1:numel(inputs)
 y=45+70*(k-1);
 add_block('simulink/Sources/From Workspace',[model '/' inputs{k}],...
 'VariableName',['profile_' inputs{k}],'Interpolate','on','Position',[35 y 195 y+32]);
end
add_block('simulink/User-Defined Functions/MATLAB Function',[model '/Load distribution'],...
'Position',[305 140 555 490]);
chart=sfroot.find('-isa','Stateflow.EMChart','Path',[model '/Load distribution']);
assert(~isempty(chart),'Cannot access MATLAB Function block');
lines={
'function [single,left,right,total] = distribute(a,motorN,sx,sy,share,lx,ly,rx,ry)'
'%#codegen'
'g=9.81; athlete=150; plate=15;'
'total=(athlete+plate)*g+athlete*a+motorN;'
'share=min(max(share,0),1);'
'single=cornerLoads(total,sx,sy);'
'left=cornerLoads((total-plate*g)*share+plate*g/2,lx,ly);'
'right=cornerLoads((total-plate*g)*(1-share)+plate*g/2,rx,ry);'
'end'
'function f=cornerLoads(F,x,y)'
'x=min(max(x,-1),1); y=min(max(y,-1),1);'
'f=F/4*[(1-x)*(1-y);(1+x)*(1-y);(1-x)*(1+y);(1+x)*(1+y)];'
'end'};
chart.Script=strjoin(lines,newline);
for k=1:numel(inputs)
 add_line(model,[inputs{k} '/1'],['Load distribution/' num2str(k)],'autorouting','on');
end
outputs={'single','left','right','total'};
for k=1:4
 y=130+120*(k-1);
 add_block('simulink/Sinks/To Workspace',[model '/' outputs{k}],...
 'VariableName',['result_' outputs{k}],'SaveFormat','Timeseries',...
 'Position',[675 y 825 y+35]);
 add_line(model,['Load distribution/' num2str(k)],[outputs{k} '/1'],'autorouting','on');
end
add_block('simulink/Sinks/Scope',[model '/Sensor scope'],...
'NumInputPorts','3','Position',[875 190 935 280]);
for k=1:3
 add_line(model,['Load distribution/' num2str(k)],['Sensor scope/' num2str(k)],'autorouting','on');
end
save_system(model);
fprintf('Created %s.slx\n',model);
end
