const fs = require('fs');
const path = require('path');

const htmlPath = path.join(__dirname, 'app/src/main/assets/index.html');
const outputPath = path.join(__dirname, 'ai_tools_firebase.json');

try {
    const htmlContent = fs.readFileSync(htmlPath, 'utf8');

    // Find the start of the array
    const startMarker = 'const initialTools = [';
    const startIndex = htmlContent.indexOf(startMarker);

    if (startIndex === -1) {
        throw new Error('Could not find initialTools array start');
    }

    // Find the end of the array - looking for the closing ]; after the start
    // We scan carefully. Since it's a top level array, we can try to find the next ]; 
    // But to be safer against nested arrays (though structure is simple), let's just find the closing bracket matching the hierarchy if we want to be fancy, 
    // OR just look for the known end pattern in this specific file.
    // In the file, it ends with "        ];" preceded by object logic. 
    // Let's use a simpler approach: Extract the substring from [ to ];

    // Scan forward from start to find the matching brackets?
    // Actually, simply `eval`ing the string might be easiest if we extract a generous chunk.
    // But `eval` needs valid JS.

    // Let's use regex to capture the block. 
    // "const initialTools = (\[[\s\S]*?\]);" 
    // This captures everything from [ to the first ];

    const regex = /const initialTools = (\[[\s\S]*?\]);/;
    const match = htmlContent.match(regex);

    if (!match || !match[1]) {
        throw new Error('Could not extract array content via regex');
    }

    const arrayString = match[1];

    // Evaluate the string to get the actual JS object
    // Using Function to avoid local scope issues
    const tools = new Function('return ' + arrayString)();

    console.log(`Successfully extracted ${tools.length} tools.`);

    // Convert to strict JSON
    const jsonOutput = JSON.stringify(tools, null, 2);

    fs.writeFileSync(outputPath, jsonOutput);
    console.log(`JSON saved to: ${outputPath}`);

} catch (error) {
    console.error('Error:', error.message);
}
