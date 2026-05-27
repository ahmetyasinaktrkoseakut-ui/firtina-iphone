const fs = require('fs');
const path = require('path');

const jsonFile = 'C:\\Users\\Elif\\.gemini\\antigravity\\brain\\264f9967-c0cc-4926-bafa-e5be0fa427dd\\ai_tools.json';

try {
    const rawData = fs.readFileSync(jsonFile, 'utf8');
    let tools = JSON.parse(rawData);

    const initialCount = tools.length;

    // Remove ID 36 (Suno)
    // Keep ID 107 (Suno AI)
    tools = tools.filter(tool => tool.id !== 36);

    const finalCount = tools.length;

    if (initialCount > finalCount) {
        fs.writeFileSync(jsonFile, JSON.stringify(tools, null, 2));
        console.log(`Successfully removed tool ID 36. Count: ${initialCount} -> ${finalCount}`);
    } else {
        console.log("Tool ID 36 not found.");
    }

} catch (error) {
    console.error("Error:", error);
}
