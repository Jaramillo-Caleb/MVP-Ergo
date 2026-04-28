# ERGO Posture Engine

The Posture Engine is responsible for interpreting raw AI landmarks into actionable health insights.

## Landmark Mapping

We use 5 key landmarks from MediaPipe Pose:
- **0**: Nose
- **2**: Left Eye
- **5**: Right Eye
- **11**: Left Shoulder
- **12**: Right Shoulder

These points form a stable "Posture Triangle" (Nose-Shoulder-Shoulder) and a facial orientation vector (Eye-Eye).

## Geometric Ratio Approach

To make monitoring distance-agnostic (working regardless of how far the user is from the webcam), we use ratios instead of raw coordinate distances.

### 1. Vertical Ratio (Slouching Detection)
We calculate the vertical distance between the midpoint of the eyes and the midpoint of the shoulders.

$$VerticalHeight = |MidShoulders_Y - MidEyes_Y|$$
$$ShoulderDistance = Distance(Shoulder_{11}, Shoulder_{12})$$
$$Ratio = \frac{VerticalHeight}{ShoulderDistance}$$

**Alert**: If the current ratio drops below **80%** of the calibrated reference ratio.

### 2. Tilt Detection
We calculate the angle between the eyes using `Atan2`.

$$Angle = Atan2(Eye_{5,Y} - Eye_{2,Y}, Eye_{5,X} - Eye_{2,X})$$

**Alert**: If the absolute angle exceeds **12 degrees**.

### 3. Proximity Detection
We monitor the shoulder distance to detect if the user is leaning too far into the screen.

**Alert**: If the current shoulder distance is **> 125%** of the reference.

## Stability Features

- **EMA Filter**: An Exponential Moving Average (Alpha = 0.6) is applied to raw landmarks to eliminate high-frequency jitter.
- **Temporal Coherence**: Sudden jumps in landmark positions (>35% of frame) are discarded as sensor noise.
- **Visibility Checks**: Frames where key points have <50% confidence are ignored to prevent false positives.
- **Static Handing**: The system allows "zero movement" (focused user) without dropping the detection state, provided the posture remains geometrically valid.
