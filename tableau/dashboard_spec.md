# Tableau Dashboard Specification: Bellabeat Executive Analytics

This specification details the layout, visual encodings, calculated fields, and interactive actions designed for the Bellabeat Executive Smart Device Analytics Dashboard.

---

## 1. Visual Theme & Styling
* **Color Palette:** Slate-minimal with vibrant primary accents.
  * **Very Active/Vigorous Activity:** Coral Gold (`#FF6B6B`)
  * **Optimal Sleep/Moderate Activity:** Classic Blue (`#4D96FF`)
  * **Light Activity:** Emerald Mint (`#6BCB77`)
  * **Sedentary:** Soft Charcoal (`#4B5563`)
  * **Alerts/Deficits:** Warm Amber (`#FFD93D`) or Crimson (`#EF4444`)
  * **Backgrounds:** Off-white/slate light (`#F8FAFC`)
* **Typography:** Modern typography using the **Segoe UI** or **Inter** family.
* **Layout Design:** 1400px x 900px (Fixed Desktop Layout) arranged in a grid with glassmorphism boundaries.

---

## 2. Calculated Fields

Create the following calculated fields in Tableau:

1. **[Sleep Efficiency %]**
   ```
   SUM([TotalMinutesAsleep]) / SUM([TotalTimeInBed])
   ```
   * *Format:* Percentage (`0.0%`)

2. **[MVPA Minutes]** (Moderate-to-Vigorous Physical Activity)
   ```
   [VeryActiveMinutes] + [FairlyActiveMinutes]
   ```

3. **[WHO Guideline Flag]**
   ```
   IF [MVPA Minutes] >= 21.4 THEN "Meets Guideline (>=150 mins/wk)"
   ELSE "Sub-optimal MVPA (<150 mins/wk)"
   END
   ```

4. **[Device Wear compliance Rate]**
   ```
   { FIXED [Id] : COUNT([ActivityDate]) } / 61.0
   ```
   * *Format:* Percentage (`0.0%`)

5. **[Compliance Segment]**
   ```
   IF [Device Wear compliance Rate] >= 0.80 THEN "High Compliance (>=80%)"
   ELSEIF [Device Wear compliance Rate] >= 0.50 THEN "Medium Compliance (50%-80%)"
   ELSE "Low Compliance (<50%)"
   END
   ```

6. **[Activity Cohort (Tudor-Locke)]**
   ```
   { FIXED [Id] : AVG([TotalSteps]) }
   -- Grouped into:
   -- Sedentary (< 5,000)
   -- Low Active (5,000 - 7,499)
   -- Somewhat Active (7,500 - 9,999)
   -- Active (10,000 - 12,499)
   -- Highly Active (>= 12,500)
   ```

---

## 3. Worksheets (Visual Components)

### Sheet 1: Executive KPI Cards
* **Type:** Text Matrix (Horizontal layout)
* **Fields:**
  * **Total Unique Users:** `COUNTD([Id])`
  * **Average Daily Steps:** `AVG([TotalSteps])` (Target: 10,000)
  * **Average Active Minutes:** `AVG([VeryActiveMinutes] + [FairlyActiveMinutes] + [LightlyActiveMinutes])`
  * **Average Sleep Duration:** `AVG([TotalMinutesAsleep]) / 60` (Target: 7.0 hours)
  * **Average Sleep Efficiency:** `[SleepEfficiency %]` (Target: 85%)
* **Formatting:** Bold numbers (size 22pt, Dark Slate) with descriptive sub-labels (size 9pt, Slate Gray) showing targets.

### Sheet 2: Behavioral Cohorts Matrix (Bar Charts)
* **Type:** Horizontal Stacked Bar Charts
* **Dimensions:** `[Activity Cohort (Tudor-Locke)]`, `[Sleep Deficit Segment]`
* **Measures:** `COUNTD([Id])` as a percentage of total users.
* **Visuals:** Shows the distribution of the user base. Highlight that the largest cohorts are "Low Active" and "Sleep Deficit".

### Sheet 3: Weekly Activity Cycle (Weekday vs. Weekend)
* **Type:** Dual Axis Line & Column Chart
* **Rows:** `AVG([TotalSteps])` (Line, Blue) and `AVG([SedentaryMinutes])` (Bar, Soft Charcoal)
* **Columns:** `ActivityDate` formatted as Weekday.
* **Tooltips:** Steps, Calories, Active minutes, Sedentary minutes.

### Sheet 4: Activity Intensity vs. Calorie Burn (Scatter Plot)
* **Type:** Scatter Plot (User-day grain)
* **X-Axis:** `[MVPA Minutes]`
* **Y-Axis:** `[Calories]`
* **Color:** `[Id]` (different color marker per user) or `[WHO Guideline Flag]`.
* **Trend Line:** Linear regression line demonstrating positive correlation ($R^2$ fit).

### Sheet 5: Sleep Efficiency & Time in Bed (Bar in Bar / Gantt)
* **Type:** Bar-in-Bar chart
* **Rows:** `Id` (Sorted by Sleep Efficiency)
* **Measures:** `AVG([TotalTimeInBed])` (Light gray background bar) and `AVG([TotalMinutesAsleep])` (Overlaid Blue bar). The difference represents time awake in bed (latency).

---

## 4. Interactive Filters & Dashboard Actions

### Dashboard Filters
* **Device Compliance:** Multi-value dropdown (`[Compliance Segment]`)
* **Activity Cohort:** Checkbox list (`[Activity Cohort (Tudor-Locke)]`)
* **Weekend Flag:** Toggle button

### Dashboard Actions (Highlight & Filter)
1. **User Cross-Filter Action:** Clicking on a specific user cohort bar in **Behavioral Cohorts Matrix** filters all other charts to show only those users' weekly cycles, sleep records, and scatter points.
2. **Scatter Point Detail Action:** Clicking a user dot in the **Scatter Plot** highlights their specific sleep efficiency bar in the **Sleep Efficiency chart** to show individual activity-sleep coupling.
