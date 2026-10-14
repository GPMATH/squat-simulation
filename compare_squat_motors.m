function results = compare_squat_motors()
% Alex Squat: initial motor screening; MATLAB only, no toolboxes required.
% Run: results = compare_squat_motors;
% Catalog numbers are leads, NOT validated continuous curves.
g=9.80665;
p.athlete_kg=150; p.virtual_mass_kg=200; p.accel_mps2=3;
p.speed_mps=1.5; p.drum_radius_m=0.025; p.gear_efficiency=0.85;
p.motor_efficiency=0.90; p.inverter_efficiency=0.95;
p.bus_voltage_V=48; p.gear_ratios=[3 5 7 10];
% Upward motion: virtual weight includes inertia. Downward example uses
% commanded 200 kgf tension (independent force mode).
p.up_force_N=p.virtual_mass_kg*(g+p.accel_mps2);
p.down_force_N=p.virtual_mass_kg*g;
p.drum_rpm=p.speed_mps/(2*pi*p.drum_radius_m)*60;
p.rope_kW_up=p.up_force_N*p.speed_mps/1000;
p.rope_kW_down=p.down_force_N*p.speed_mps/1000;
% Torque during generation is LOWER at the motor due to reverse gearbox
% loss. Motoring torque is HIGHER due to forward gearbox loss.
names={'JK130BLS115';'JK130BLS120';'JK130BLS140';'JK130BLS165'; ...
       'JK130BLS190';'Freerchobby 83mm hub';'Freerchobby 8055'; ...
       'Freerchobby MP80100';'Freerchobby MP8318';'JK110BLS50'; ...
       'Golden Motor HPM10KW'};
% Mechanical nominal power in W only when meaningfully specified;
% NaN means missing or not established. Published marketing claims for
% outrunners do NOT certify sustained output at our operating speed.
nominal_W=[750;1000;1500;2200;2500;NaN;NaN;NaN;NaN;750;NaN];
rated_Nm=[2.39;3.18;4.77;7.00;11.94;NaN;NaN;NaN;NaN;2.38;NaN];
peak_Nm=[7.1;9.5;14;21;35;8;9.3;NaN;NaN;NaN;NaN];
rated_rpm=[3000;3000;3000;3000;2000;NaN;NaN;NaN;NaN;3000;NaN];
kv_rpm_V=[NaN;NaN;NaN;NaN;NaN;NaN;NaN;130;NaN;NaN;NaN];
notes={...
    '310V winding data; 48V curve needed';...
    '310V winding data; 48V curve needed';...
    '310V winding data; 48V curve needed';...
    '310V winding data; 48V curve needed';...
    '310V winding data; 48V curve needed';...
    'Advertised 8Nm; verify continuous torque and mounting';...
    'Advertised max 9.3Nm; claimed 5kW not confirmed continuous';...
    '130Kv screening variant; seller claims 4kW rated/7kW max; independently verify';...
    'Advertised 2870W; continuous torque curve unknown';...
    '750W rated; high-voltage winding';...
    '10kW model family; cooling and exact winding curve required'};
n=numel(names); ng=numel(p.gear_ratios);
% Each ratio column yields a separate motor shaft demand in either direction.
rows=cell(n*ng,14); ii=0;
for k=1:n
  for j=1:ng
    G=p.gear_ratios(j); ii=ii+1;
    rpm=G*p.drum_rpm;
    gen_Nm=p.up_force_N*p.drum_radius_m*p.gear_efficiency/G;
    drive_Nm=p.down_force_N*p.drum_radius_m/(p.gear_efficiency*G);
    gen_kW=p.rope_kW_up*p.gear_efficiency;
    drive_kW=p.rope_kW_down/p.gear_efficiency;
    gen_bus_kW=gen_kW*p.motor_efficiency*p.inverter_efficiency;
    drive_bus_kW=drive_kW/(p.motor_efficiency*p.inverter_efficiency);
    % Simplified Kt=60/(2*pi*Kv) only if Kv/Kt conventions match.
    if isfinite(kv_rpm_V(k))
      kt=60/(2*pi*kv_rpm_V(k));
      iq_gen=gen_Nm/kt; iq_drive=drive_Nm/kt;
      ideal_noload_rpm=p.bus_voltage_V*kv_rpm_V(k);
      speed_comment=ternary(rpm<=ideal_noload_rpm, ...
         'Below ideal Kv*V speed; torque-at-speed still unknown', ...
         'ABOVE ideal Kv*V speed; not suitable without higher voltage/Kv');
    else
      iq_gen=NaN; iq_drive=NaN; speed_comment='KV/winding not confirmed';
    end
    % These pass/fail flags apply ONLY to confirmed nominal JK data.
    isverified=isfinite(nominal_W(k)) && isfinite(rated_rpm(k)) && ...
       isfinite(rated_Nm(k));
    if isverified
      rated_rpm_ok=rpm<=rated_rpm(k);
      rated_torque_ok=drive_Nm<=rated_Nm(k);
    else
      rated_rpm_ok=false; rated_torque_ok=false;
    end
    rows(ii,:)={names{k},G,rpm,gen_Nm,drive_Nm,gen_kW,drive_kW, ...
      gen_bus_kW,drive_bus_kW,iq_gen,iq_drive,rated_rpm_ok, ...
      rated_torque_ok,[notes{k} '; ' speed_comment]};
  end
end
results=cell2table(rows,'VariableNames',{'Motor','Reduction','MotorRPM', ...
 'GeneratingTorqueNm','MotoringTorqueNm','GeneratingShaftKW', ...
 'MotoringShaftKW','RegenBusKW','MotoringBusKW','ApproxGeneratingIqA', ...
 'ApproxMotoringIqA','WithinListedRatedRPM','WithinListedRatedTorque', ...
 'Caveats'});
% MotorRatedPower must NOT be used as an actual generator-mode rating.
fprintf('\nALEX SQUAT MOTOR SCREEN — NOT AN ENGINEERING APPROVAL\n');
fprintf('150 kg athlete; 200 kg virtual mass; up acceleration %.1f m/s^2\n',p.accel_mps2);
fprintf('Upward rope peak: %.0f N = %.1f kgf; %.2f kW at %.2f m/s\n', ...
 p.up_force_N,p.up_force_N/g,p.rope_kW_up,p.speed_mps);
fprintf('Downward example: %.0f N = 200 kgf; %.2f kW rope\n', ...
 p.down_force_N,p.rope_kW_down);
fprintf('5:1: up generator %.1f Nm, down motor %.1f Nm, motor %.0f rpm\n', ...
 p.up_force_N*p.drum_radius_m*p.gear_efficiency/5, ...
 p.down_force_N*p.drum_radius_m/(p.gear_efficiency*5),5*p.drum_rpm);
fprintf('Up DC regenerated %.2f kW; down DC draw %.2f kW (assumed efficiencies)\n', ...
 p.rope_kW_up*p.gear_efficiency*p.motor_efficiency*p.inverter_efficiency,...
 p.rope_kW_down/(p.gear_efficiency*p.motor_efficiency*p.inverter_efficiency));
fprintf('IMPORTANT: Rated power/torque NOT verified for Freerchobby/Golden entries.\n\n');
view5=results(results.Reduction==5,:);
disp(view5(:,{'Motor','MotorRPM','GeneratingTorqueNm','MotoringTorqueNm', ...
 'ApproxGeneratingIqA','ApproxMotoringIqA'}));
figure('Name','Alex Squat motor comparison: 5-to-1 gearing');
subplot(2,1,1);
bar([view5.GeneratingTorqueNm view5.MotoringTorqueNm]);
set(gca,'XTick',1:n,'XTickLabel',names); xtickangle(35);
ylabel('Required motor torque [Nm]'); grid on;
legend('Up: generating','Down: motoring','Location','best');
title('Required shaft torque at 5:1 — equal for every motor');
subplot(2,1,2);
bar([view5.MotoringBusKW view5.RegenBusKW]);
set(gca,'XTick',1:n,'XTickLabel',names); xtickangle(35);
ylabel('Bus power magnitude [kW]'); grid on;
legend('Down: DC input','Up: DC regeneration','Location','best');
title('Energy management duty — 5:1 gear, illustrative efficiencies');
figure('Name','Alex Squat: gearbox ratio trade-off');
G=p.gear_ratios;
plot(G,p.up_force_N*p.drum_radius_m*p.gear_efficiency./G,'-o','LineWidth',1.5);
hold on;
plot(G,p.down_force_N*p.drum_radius_m./(p.gear_efficiency*G),'-s','LineWidth',1.5);
grid on; xlabel('Gear reduction ratio'); ylabel('Motor torque magnitude [Nm]');
legend('Up generating','Down motoring','Location','best');
title('Torque needed versus gearbox ratio');
writetable(results,'alex_squat_motor_screening.csv');
fprintf('Saved alex_squat_motor_screening.csv\n');
end
function out=ternary(condition,a,b)
if condition,out=a;else,out=b;end
end
