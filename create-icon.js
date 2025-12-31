const fs = require('fs');
const path = require('path');

// Simple base64 encoded 1024x1024 white PNG with music note (simplified version)
// This is a minimal white square - you can replace with actual design
const createSimpleWhiteIcon = () => {
  const sharp = require('sharp');
  
  // Create a 1024x1024 white background with dark blue music note
  const svg = `
    <svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
      <rect width="1024" height="1024" fill="#FFFFFF" rx="200"/>
      <g transform="translate(256, 200)">
        <rect x="380" y="50" width="60" height="520" rx="30" fill="#1E1B4B"/>
        <ellipse cx="350" cy="570" rx="120" ry="90" fill="#3730A3"/>
        <path d="M 440 50 Q 520 60, 520 140 Q 520 220, 440 240 L 440 50 Z" fill="#3730A3"/>
        <circle cx="350" cy="570" r="40" fill="#F97316" opacity="0.8"/>
      </g>
      <rect x="100" y="850" width="824" height="8" rx="4" fill="#F97316"/>
    </svg>
  `;
  
  return Buffer.from(svg);
};

// Check if sharp is available
try {
  require('sharp');
  
  const svg = createSimpleWhiteIcon();
  fs.writeFileSync('resources/icon.svg', svg);
  
  console.log('Icon created successfully at resources/icon.svg');
  console.log('Run: npx @capacitor/assets generate --android');
} catch (err) {
  console.log('Sharp not available, copying SVG manually...');
  fs.copyFileSync('icon-source.svg', 'resources/icon.svg');
  console.log('Icon copied to resources/icon.svg');
  console.log('Run: npx @capacitor/assets generate --android');
}
