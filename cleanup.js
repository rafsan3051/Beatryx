#!/usr/bin/env node

/**
 * Cleanup script for Beatryx
 * Run this before building to free up space
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const pathsToClean = [
  'dist',
  '.cache',
  'coverage',
  'android/build',
  'android/app/build',
  '.gradle',
  'android/.gradle',
  'node_modules/.cache',
];

console.log('🧹 Cleaning up Beatryx build artifacts...\n');

let totalFreed = 0;

for (const dir of pathsToClean) {
  const fullPath = path.join(__dirname, dir);
  if (fs.existsSync(fullPath)) {
    try {
      const stats = fs.statSync(fullPath);
      const size = stats.isDirectory() ? 
        execSync(`powershell -Command "Get-ChildItem -Path '${fullPath}' -Recurse | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum"`, {encoding: 'utf8'}).trim() : 
        stats.size;
      
      fs.rmSync(fullPath, { recursive: true, force: true });
      console.log(`✅ Removed: ${dir}`);
      totalFreed += parseInt(size) || 0;
    } catch (err) {
      console.log(`⚠️  Could not remove: ${dir}`);
    }
  }
}

console.log(`\n✅ Cleanup complete! Freed: ${(totalFreed / 1024 / 1024).toFixed(2)} MB\n`);
console.log('Ready to build! Run: npm run build');
