#!/usr/bin/env node

/**
 * Generate secure random secrets for production deployment
 * 
 * Usage:
 *   node generate-secrets.js
 * 
 * This will output all required secrets for your .env file
 */

const crypto = require('crypto');

function generateSecret(length = 32) {
  return crypto.randomBytes(length).toString('hex');
}

console.log('🔐 Generated Secrets for Production\n');
console.log('Copy these to your hosting provider\'s environment variables:\n');
console.log('─'.repeat(70));

const secrets = {
  'JWT_SECRET': generateSecret(32),
  'JWT_REFRESH_SECRET': generateSecret(32),
  'OTP_HASH_SECRET': generateSecret(32),
  'PII_ENCRYPTION_SECRET': generateSecret(32),
  'ADMIN_JWT_SECRET': generateSecret(32),
  'KYC_WEBHOOK_SECRET': generateSecret(32),
  'GOLD_RATE_WEBHOOK_SECRET': generateSecret(32),
  'RAZORPAY_WEBHOOK_SECRET': generateSecret(16),  // Shorter for webhook
};

// Print in .env format
console.log('\n# Security Secrets (keep these safe!)\n');
for (const [key, value] of Object.entries(secrets)) {
  console.log(`${key}=${value}`);
}

console.log('\n' + '─'.repeat(70));
console.log('\n⚠️  IMPORTANT:');
console.log('1. Store these secrets securely (password manager)');
console.log('2. NEVER commit these to Git');
console.log('3. Use different secrets for staging/production');
console.log('4. Rotate secrets periodically for security\n');

// Also save to a file (git-ignored)
const fs = require('fs');
const output = Object.entries(secrets)
  .map(([key, value]) => `${key}=${value}`)
  .join('\n');

fs.writeFileSync('.secrets-generated.txt', output + '\n');
console.log('✅ Secrets also saved to .secrets-generated.txt (git-ignored)\n');
