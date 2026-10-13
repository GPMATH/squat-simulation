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
