#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const jsonPath = path.join(__dirname, 'fasting-data.json');
const htmlPath = path.join(__dirname, 'index.html');
const outputPath = path.join(__dirname, 'index-standalone.html');

// Read JSON data
const fastingData = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

// Read HTML template
let html = fs.readFileSync(htmlPath, 'utf8');

// Create the embedded data string
const embeddedData = `
        // Embedded fasting data (generated from fasting-data.json)
        const EMBEDDED_FASTING_DATA = ${JSON.stringify(fastingData, null, 8)};
`;

// Find and replace the fetch-based loading with embedded data
const oldCode = `        // Fasting data loaded from JSON
        let copticEasterDates = {};
        let fastingSeasons = [];

        // Load fasting data from JSON file
        async function loadFastingData() {
            try {
                const response = await fetch('fasting-data.json');
                const data = await response.json();
                
                // Convert Easter dates from strings to Date objects
                copticEasterDates = {};
                for (const [year, dateStr] of Object.entries(data.copticEasterDates)) {
                    const [y, m, d] = dateStr.split('-').map(Number);
                    copticEasterDates[year] = new Date(y, m - 1, d);
                }
                
                fastingSeasons = data.fastingSeasons;
            } catch (error) {
                console.error('Error loading fasting data:', error);
            }
        }`;

const newCode = embeddedData + `
        let copticEasterDates = {};
        let fastingSeasons = [];

        // Load fasting data from embedded data
        function loadFastingData() {
            try {
                const data = EMBEDDED_FASTING_DATA;
                
                // Convert Easter dates from strings to Date objects
                copticEasterDates = {};
                for (const [year, dateStr] of Object.entries(data.copticEasterDates)) {
                    const [y, m, d] = dateStr.split('-').map(Number);
                    copticEasterDates[year] = new Date(y, m - 1, d);
                }
                
                fastingSeasons = data.fastingSeasons;
            } catch (error) {
                console.error('Error loading fasting data:', error);
            }
        }`;

// Replace the code
html = html.replace(oldCode, newCode);

// Update DOMContentLoaded to remove async
html = html.replace(
    'document.addEventListener(\'DOMContentLoaded\', async function() {',
    'document.addEventListener(\'DOMContentLoaded\', function() {'
);

html = html.replace(
    'await loadFastingData();',
    'loadFastingData();'
);

// Write output file
fs.writeFileSync(outputPath, html, 'utf8');

console.log(`✓ Successfully embedded fasting data into: ${outputPath}`);
console.log(`✓ The standalone HTML file is ready to use without fasting-data.json`);
