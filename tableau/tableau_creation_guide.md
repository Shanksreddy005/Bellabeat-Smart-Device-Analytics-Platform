# Tableau Dashboard Creation Guide: Bellabeat Smart Device Analytics

This guide provides step-by-step instructions to build the premium, executive-level Bellabeat dashboard in Tableau Desktop using the local SQLite database (`bellabeat.db`) or the processed CSV files.

---

## Step 1: Connect to Data

1. Open **Tableau Desktop**.
2. Under **Connect / To a Server**, click **More...** and select **Other Databases (ODBC)** or select **SQLite** if available.
   * *Alternative:* If connecting via ODBC, select **SQLite3 Datasource**, click **Browse**, and select `Bellabeat-Smart-Device-Analytics/data/processed/bellabeat.db`.
   * *Simple Alternative:* Under **Connect / To a File**, select **Text File** and load `engineered_features.csv` directly.
3. Drag the view `v_daily_user_metrics` (or the joined `engineered_features` table) onto the canvas area.
4. Click on **Sheet 1** at the bottom to open your workspace.

---

## Step 2: Create Calculated Fields

In the left Data pane, right-click any blank space and select **Create Calculated Field...** for each of the following:

### 1. Sleep Efficiency %
* **Name:** `Sleep Efficiency %`
* **Formula:**
  ```tableau
  SUM([TotalMinutesAsleep]) / SUM([TotalTimeInBed])
  ```
* **Format:** Right-click the field $\rightarrow$ **Default Properties** $\rightarrow$ **Number Format** $\rightarrow$ select **Percentage** with `1` decimal place.

### 2. MVPA Minutes (Moderate-to-Vigorous Physical Activity)
* **Name:** `MVPA Minutes`
* **Formula:**
  ```tableau
  [VeryActiveMinutes] + [FairlyActiveMinutes]
  ```

### 3. WHO Guideline Status
* **Name:** `WHO Guideline Status`
* **Formula:**
  ```tableau
  IF [MVPA Minutes] >= 21.4 THEN "Meets WHO Guideline (>=150m/wk)"
  ELSE "Sub-optimal MVPA (<150m/wk)"
  END
  ```

### 4. Device Wear Compliance Rate
* **Name:** `Device Wear Compliance Rate`
* **Formula:**
  ```tableau
  { FIXED [Id] : COUNT([ActivityDate]) } / 61.0
  ```
* **Format:** Set Default Properties Number Format to **Percentage** with `1` decimal place.

### 5. Compliance Segment
* **Name:** `Compliance Segment`
* **Formula:**
  ```tableau
  IF [Device Wear Compliance Rate] >= 0.80 THEN "High Compliance (>=80%)"
  ELSEIF [Device Wear Compliance Rate] >= 0.50 THEN "Medium Compliance (50%-80%)"
  ELSE "Low Compliance (<50%)"
  END
  ```

### 6. Activity Cohort (Tudor-Locke)
* **Name:** `Activity Cohort (Tudor-Locke)`
* **Formula:**
  ```tableau
  IF [Avg Daily Steps Per User] < 5000 THEN "Sedentary (<5k)"
  ELSEIF [Avg Daily Steps Per User] < 7500 THEN "Low Active (5k-7.5k)"
  ELSEIF [Avg Daily Steps Per User] < 10000 THEN "Somewhat Active (7.5k-10k)"
  ELSEIF [Avg Daily Steps Per User] < 12500 THEN "Active (10k-12.5k)"
  ELSE "Highly Active (>=12.5k)"
  END
  ```

---

## Step 3: Build the Worksheets

Rename each sheet at the bottom of the screen by double-clicking the tab name.

### Worksheet 1: Executive KPI Cards
1. Create a new sheet named `KPI Cards`.
2. Drag `Measure Values` to the **Text** card.
3. Drag `Measure Names` to the **Columns** shelf.
4. In the `Measure Values` shelf, remove all fields except:
   * `CNTD(Id)` (Rename to `Total Users`)
   * `AVG(TotalSteps)` (Rename to `Avg Steps`)
   * `AVG(MVPA Minutes)` (Rename to `Avg MVPA Mins`)
   * `AVG(TotalMinutesAsleep)` (Rename to `Avg Mins Asleep`)
   * `Sleep Efficiency %` (Rename to `Sleep Efficiency`)
5. Click **Format** on the top menu $\rightarrow$ **Font** $\rightarrow$ Set Worksheet font to **Segoe UI Semibold**, size 20pt for numbers, and size 9pt dark gray for labels.
6. Change the alignment of text to **Center**.

### Worksheet 2: Behavioral Cohorts Matrix
1. Create a sheet named `Behavioral Cohorts`.
2. Drag `Activity Cohort (Tudor-Locke)` to the **Rows** shelf.
3. Drag `Sleep Deficit Category` to the **Columns** shelf. (Filter out nulls/no-sleep entries if needed).
4. Drag `Id` to the **Text** card and set its aggregation to **CNTD (Count Distinct)**.
5. Click the dropdown on the `CNTD(Id)` in Text $\rightarrow$ **Quick Table Calculation** $\rightarrow$ **Percent of Total**.
6. Set the Marks type to **Square** and drag another instance of `CNTD(Id)` (Percent of Total) to the **Color** card. Use the **Blue** color palette.

### Worksheet 3: Weekly Activity Cycle
1. Create a sheet named `Weekly Activity Cycle`.
2. Drag `ActivityDate` to the **Columns** shelf. Click its dropdown and change it to **Weekday** (discrete, showing Sunday, Monday...).
3. Drag `TotalSteps` to the **Rows** shelf and set aggregation to **AVG**.
4. Drag `SedentaryMinutes` to the **Rows** shelf and set aggregation to **AVG**.
5. Click on the second measure's dropdown in Rows $\rightarrow$ select **Dual Axis**. Right-click the right axis in the chart $\rightarrow$ select **Synchronize Axis** (optional, or leave unsynchronized to compare trends since steps and minutes use different scales).
6. Under the Marks card:
   * Select the `AVG(TotalSteps)` card $\rightarrow$ change Mark type to **Line** (Color: Classic Blue `#4D96FF`).
   * Select the `AVG(SedentaryMinutes)` card $\rightarrow$ change Mark type to **Bar** (Color: Light Gray/Charcoal, Opacity: 50%).

### Worksheet 4: Activity Intensity vs. Calorie Burn
1. Create a sheet named `Activity vs. Calories`.
2. Drag `MVPA Minutes` to the **Columns** shelf (set to Dimension or Continuous Measure).
3. Drag `Calories` to the **Rows** shelf (set to Dimension or Continuous Measure).
4. Drag `Id` to the **Detail** card so each dot represents a user, or drag `ActivityDate` to Detail to show individual user-days.
5. Drag `WHO Guideline Status` to the **Color** card.
6. Under **Analytics** (left panel tab) $\rightarrow$ drag **Trend Line** onto the chart canvas and drop it on **Linear** to show the positive correlation line.

### Worksheet 5: Sleep Efficiency & Time in Bed (Bar-in-Bar)
1. Create a sheet named `Sleep Efficiency`.
2. Drag `Id` (or user alias) to the **Rows** shelf.
3. Drag `TotalTimeInBed` to the **Columns** shelf and set to **AVG**.
4. Drag `TotalMinutesAsleep` to the **Columns** shelf and set to **AVG**.
5. Click the dropdown on `AVG(TotalMinutesAsleep)` in Columns $\rightarrow$ select **Dual Axis**. Right-click the top axis $\rightarrow$ **Synchronize Axis**.
6. In the Marks card:
   * For `AVG(TotalTimeInBed)`, set Mark type to **Bar**, set Color to Light Gray, and increase size slightly.
   * For `AVG(TotalMinutesAsleep)`, set Mark type to **Bar**, set Color to Blue, and decrease size slightly.
   * This creates a "Bar-in-Bar" chart showing how much of the time spent in bed was actually spent sleeping (the gap represents latency).

---

## Step 4: Construct the Dashboard Layout

1. Click the **New Dashboard** icon at the bottom.
2. In the Dashboard panel (left side):
   * Set **Size** to **Fixed size** $\rightarrow$ **Generic Desktop (1366 x 768)** or **1400 x 900**.
3. Drag a **Vertical Container** onto the canvas.
4. Add a **Horizontal Container** at the top of the vertical container for the Header:
   * Add a Text box for the Dashboard Title: `BELLABEAT SMART DEVICE EXECUTIVE ANALYTICS`. Set font to Segoe UI, 24pt, bold, coral accent color.
   * Add a Text box next to it for metadata: `Longitudinal 61-day Cohort Study (N=35 users)`.
5. Drag the worksheets into the vertical container in a structured grid:
   * **Row 1:** Drag the `KPI Cards` sheet. Set height to `120px`.
   * **Row 2 (Horizontal Container):** Place `Weekly Activity Cycle` (left) and `Behavioral Cohorts` (right).
   * **Row 3 (Horizontal Container):** Place `Activity vs. Calories` (left) and `Sleep Efficiency` (right).
6. Click on each sheet's dropdown menu in the dashboard and set **Fit** $\rightarrow$ **Entire View**.

---

## Step 5: Create Interactive Actions

1. In the top menu, go to **Dashboard** $\rightarrow$ **Actions...**
2. Click **Add Action** $\rightarrow$ select **Filter**.
   * **Name:** `Filter by Cohort`
   * **Source Sheets:** Check `Behavioral Cohorts`.
   * **Run action on:** Select **Select** (single-click).
   * **Target Sheets:** Check all other worksheets (`KPI Cards`, `Weekly Activity Cycle`, `Activity vs. Calories`, `Sleep Efficiency`).
   * **Clearing the selection will:** Select **Show all values**.
   * Click **OK**.
3. This allows you to click on any cell in the cohort matrix (e.g. "Low Active / Sleep Deficit") and immediately filter the entire dashboard to explore that specific user cohort.
