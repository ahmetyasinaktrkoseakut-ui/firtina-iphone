const fs = require('fs');
const path = require('path');

const inputFile = 'C:\\Users\\Elif\\.gemini\\antigravity\\scratch\\ai_directory_android\\app\\src\\main\\assets\\index.html';
const outputFile = 'C:\\Users\\Elif\\.gemini\\antigravity\\brain\\264f9967-c0cc-4926-bafa-e5be0fa427dd\\ai_tools.json';

try {
    const content = fs.readFileSync(inputFile, 'utf8');
    // Extract the array content. 
    // We look for 'const initialTools = [' and the closing '];'
    // This regex matches from the start of the definition to the nearest semicolon.
    const match = content.match(/const initialTools = (\[[\s\S]*?\]);/);

    if (match) {
        const arrayStr = match[1];
        // Use eval to parse the JavaScript array literal
        // Verified content is safe (local file)
        const tools = eval(arrayStr);

        fs.writeFileSync(outputFile, JSON.stringify(tools, null, 2));
        console.log(`Successfully wrote ${tools.length} tools to ${outputFile}`);

        // Check for "Suno" duplicates
        const sunoTools = tools.filter(t => t.name.includes("Suno"));
        if (sunoTools.length > 0) {
            console.log("Found 'Suno' tools:", JSON.stringify(sunoTools.map(t => ({ id: t.id, name: t.name }))));
        }
    } else {
        console.error("Could not find 'initialTools' array in index.html");
        process.exit(1);
    }
} catch (error) {
    console.error("Error:", error);
    process.exit(1);
}
