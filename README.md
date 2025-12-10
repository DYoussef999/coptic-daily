# Coptic Daily Calendar - Setup Guide

## File Structure

- `index.html` - Main calendar app that loads `fasting-data.json`
- `fasting-data.json` - Editable JSON file with Easter dates and fasting seasons
- `embed-data.ps1` - PowerShell script to generate standalone version
- `embed-data.js` - Node.js script to generate standalone version (alternative)
- `index-standalone.html` - Generated standalone version (created after running embed script)

## Workflow

### 1. Edit the Data
Edit `fasting-data.json` to update Easter dates or fasting seasons.

### 2. Generate Standalone Version
Run one of these commands to embed the JSON data into the HTML:

**Option A: PowerShell (Windows)**
```powershell
.\embed-data.ps1
```

**Option B: Node.js (any platform)**
```bash
node embed-data.js
```

### 3. Share the Standalone Version
The script generates `index-standalone.html` which:
- Contains all data embedded inside the HTML
- Works completely offline
- Can be run standalone by double-clicking
- Doesn't require the JSON file

## Usage

**During Development:**
- Edit `fasting-data.json` as needed
- Run `index.html` in browser (loads from JSON)

**For Distribution:**
- Run the embed script to create `index-standalone.html`
- Share only `index-standalone.html` with users
- Users can double-click to run it - no dependencies needed

## Example: Update Easter Dates

1. Open `fasting-data.json`
2. Update the date in the `copticEasterDates` object:
   ```json
   "2026": "2026-04-12"
   ```
3. Save the file
4. Run `embed-data.ps1` or `embed-data.js`
5. Test `index-standalone.html`
6. Share `index-standalone.html` with others
