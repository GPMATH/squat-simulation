function run_squat_demo()
% Run from the cloned repo directory. Requires MATLAB + Simulink.
t=(0:0.02:10)';
p.athlete_accel=0.5+2.5*exp(-((t-6)/0.8).^2);
p.motor_downward_N=zeros(size(t)); % UNKNOWN: motor scenario off by default
p.single_x=0.85*sin(2*pi*t/8);
p.single_y=0.85*cos(2*pi*t/8);
p.left_fraction=0.5+0.4*sin(2*pi*t/10);
p.left_x=0.6*sin(2*pi*t/6);
p.left_y=0.5*cos(2*pi*t/7);
p.right_x=-0.5*sin(2*pi*t/6);
p.right_y=-0.5*cos(2*pi*t/7);
keys=fieldnames(p);
for k=1:numel(keys)
 assignin('base',['profile_' keys{k}],[t p.(keys{k})]);
end
model=build_squat_model();
r=sim(model,'ReturnWorkspaceOutputs','on');
single=r.get('result_single'); left=r.get('result_left');
right=r.get('result_right'); total=r.get('result_total');
one=squeeze(single.Data); L=squeeze(left.Data); R=squeeze(right.Data);
% Timeseries dimension order can differ by release.
if size(one,1)~=numel(t),one=one';end
if size(L,1)~=numel(t),L=L';end
if size(R,1)~=numel(t),R=R';end
figure('Name','One plate: four cells');plot(single.Time,one/9.81,'LineWidth',1.5);
hold on;yline(300,'r--','300 kgf sensor limit');grid on;
xlabel('Time [s]');ylabel('Individual cell force [kgf]');
title('One plate: moving center of pressure');
legend('Corner 1','Corner 2','Corner 3','Corner 4','Rated limit');
figure('Name','Two plates: eight cells');
plot(left.Time,L/9.81,'LineWidth',1.3);hold on;
plot(right.Time,R/9.81,'--','LineWidth',1.3);
yline(300,'r--','300 kgf sensor limit');grid on;
xlabel('Time [s]');ylabel('Individual cell force [kgf]');
title('Two plates: asymmetric foot loading');
legend('L1','L2','L3','L4','R1','R2','R3','R4','Rated limit');
figure('Name','Total platform force');
plot(total.Time,squeeze(total.Data)/9.81,'k','LineWidth',2);grid on;
xlabel('Time [s]');ylabel('Total force [kgf]');
title('Acceleration response (motor input = 0 N by default)');
fprintf('Peak one-plate cell: %.1f kgf; two-plate cell: %.1f kgf\n',...
 max(one(:))/9.81,max([L(:);R(:)])/9.81);
end
