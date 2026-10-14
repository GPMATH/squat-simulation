# Alex Squat — AS-23 Simulink load distribution

This repository generates an **editable Simulink block model** of the Alex Squat force plates, with configurable moving loads, individual sensor reactions and plotted time histories.

## Run in MATLAB

Requires MATLAB + Simulink. Open the cloned repo as the current folder and run:

```matlab
run_squat_demo
```

The script creates **alex_squat_force_plates.slx** and three plotted figures. Open the model and double-click **Sensor scope** to watch the outputs. Run `build_squat_model` to regenerate the block diagram. Edit time-dependent input vectors in `run_squat_demo.m` to change simulation cases.

**Configuration 1:** one plate with 4 cells. **Configuration 2:** two independent foot plates with 4 cells each (8 total). Nominal sensor rating: **300 kg per cell (2,943 N)**, not 300 kg for the entire assembly.

| Signal | Meaning |
|---|---|
| athlete_accel | Vertical athlete acceleration [m/s²] |
| motor_downward_N | Extra downward rope/motor force [N]. **Default 0** because unverified |
| single_x, single_y | Position on single plate, normalized −1 to +1 |
| left_fraction | Fraction of applied external load on left plate, 0 to 1 |
| left_x, left_y, right_x, right_y | Independent load offsets on both foot plates, −1 to +1 |

Assumptions: athlete mass 150 kg, stationary total plate mass 15 kg, g=9.81 m/s². For illustration, left and right foot plates each carry half of the assumed plate dead weight. Acceleration profiles and shifts are fictional examples, not measured events.

### Mathematics

Conditional force model: `F = (150+15)*g + 150*a + F_motor`.

Illustrative four-corner distribution (normalized x/y positions):

```
R1 = F/4 * (1-x)*(1-y)
R2 = F/4 * (1+x)*(1-y)
R3 = F/4 * (1-x)*(1+y)
R4 = F/4 * (1+x)*(1+y)
```

Split plates distribute external force between left/right using `left_fraction`; the 15 kg platform weight is allocated equally before calculating corner reactions.

### Important engineering limits

**This is not a validated structural simulator or FEA.** A four-support plate is statically indeterminate: the actual reactions depend on platform rigidity, load-cell/support stiffness, contact, and potential lift-off. The reaction formula is a visualization assumption, not a unique physical solution. Compare it with experiments at center, edges and corners. Check supplier safe overload, mechanical stops and plate bending before declaring a rated platform capacity. Do not use these charts to certify safety.

Motor/rope force direction and mounting are not yet established; treat any motor load as a conditional scenario, not a requirement.

### Compatibility

MATLAB/Simulink code has not been executed in this environment, so there may be release-dependent issues with MATLAB Function blocks or timeseries dimensions. Tested algebraically by inspection only; run it in your MATLAB version and report any errors.

## Interactive slider dashboard

Run `squat_interactive` in MATLAB for a live visual explorer. Move the **total equivalent force**, **single-plate X/Y**, **left foot fraction**, and **independent left/right X/Y** sliders. Both plate configurations update immediately with per-sensor kgf readings and 300 kgf utilization. This dashboard is a MATLAB figure (not an embedded Simulink dashboard) and is meant for teaching and sensitivity exploration. It assumes the selected total load and foot-share directly; unlike the time-series model it does not independently calculate acceleration.


## Motor / controller comparison (new)

Run in MATLAB (no Simulink license required for this calculation):

```matlab
cd('squat-simulation') % if not already in this folder
results = compare_squat_motors;
```

This creates **five MATLAB figures**, prints a 5:1 comparison table and writes `alex_squat_motor_screening.csv` with results for each motor at 3:1, 5:1, 7:1 and 10:1 reductions. Existing load-plate Simulink scripts remain unchanged.

**Candidates:** JK130BLS115, 120, 140, 165, 190; Freerchobby 83 mm hub motor, 8055, MP80100 (130 Kv screening case), MP8318; JK110BLS50; Golden Motor HPM-10KW.

**Controller suggestion from professor:** Freerchobby/Makerbase VESC 75100 (advertised 75 V, 100 A). This is *not* a validated continuous rating or a recommendation to use that controller at the full design point. The 130 Kv MP80100 estimates the ideal motor FOC torque current at each ratio; compare it to **validated controller motor phase current** after checking convention and thermals. DC bus current and motor phase current are different. A nominal 72 V lithium pack can exceed 75 V when fully charged, before regeneration.

**Test case:** 150 kg athlete; virtual 200 kg lifted load; +3 m/s² acceleration during ascent; 25 mm drum; 1.5 m/s speed. Upward generation uses F=200(g+3) N; downward motoring is shown as an independently commanded *200 kgf* force, rather than silently treating it as the same mass acceleration. Transmission 85%, motor 90%, inverter 95% assumed. The 150 kg athlete mass is an environment/design constraint, NOT added to motor rope force. The platform force and individual load cells remain separate questions.

**Important:** Peak, rated and continuous figures in vendor listings are not equivalent. Continuous torque-speed curves for the Freerchobby motors and Golden Motor cooling configuration are still missing. `NaN` means unavailable data, and the calculated KV-related current is only an approximation. The script is a **screening calculator, not a verified motor physics/thermal model or a motor approval**. The plots of required torque and electrical power are intentionally identical for all motors at the same ratio; they represent the *demand*. Look at each motor's separate published capabilities and request verified data to judge whether it meets those demands.

Supplier references:
- https://www.freerchobby.cc/products/mp-83mm-hub-motor-8nm-torque-for-electric-skateboard?variant=34875688714401
- https://www.freerchobby.cc/products/8055-powerful-bldc-motor-for-off-road-electric-skateboard-all-terrain-scooter
- https://www.freerchobby.cc/products/mp-80100-rc-outrunner-brushless-motor-for-e-bike?variant=34859259297953
- https://www.freerchobby.cc/products/mp-8318-2870w-brushless-motor-for-agricultural-uav-drone-%E7%9A%84%E5%89%AF%E6%9C%AC?variant=39725100564641
- https://www.freerchobby.cc/products/makerbase-vesc-75100-75v-100a-based-on-benjamin-vesc6-highpower-for-electric-skateboard-scooter-ebike-controller
- https://www.jkongmotor.com/phoenix/admin/siteSearch/search?searchValue=110BLS50&searchSiteStyle=&searchComponentSettingId=kdKZkWUCiODE

