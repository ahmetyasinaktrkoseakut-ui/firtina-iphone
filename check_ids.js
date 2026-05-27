const fs = require('fs');
const tools = require('./ai_tools_firebase.json');

const ids = tools.map(t => t.id).sort((a, b) => a - b);
const missing = [];

for (let i = 1; i <= 100; i++) {
    if (!ids.includes(i)) {
        missing.push(i);
    }
}

console.log('Total tools:', tools.length);
console.log('Missing IDs in 1-100 range:', missing);
console.log('Checking duplications...');
const seen = new Set();
const duplicates = [];
for (const id of ids) {
    if (seen.has(id)) duplicates.push(id);
    seen.add(id);
}
console.log('Duplicates:', duplicates);
