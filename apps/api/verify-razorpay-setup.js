#!/usr/bin/env node
/**
 * Razorpay Integration Verification Script
 * 
 * This script verifies that Razorpay is properly configured.
 * Run: node verify-razorpay-setup.js
 */

require('dotenv').config();

const CHECKS = {
  ENV_LOADED: '✅',
  ENV_MISSING: '❌',
  VALUE_PRESENT: '✅',
  VALUE_MISSING: '❌',
  TEST_MODE: '🧪',
  LIVE_MODE: '🚀',
  MOCK_MODE: '🎭',
};

console.log('\n========================================');
console.log('🔍 Razorpay Integration Verification');
console.log('========================================\n');

// Check 1: Environment variables loaded
console.log('1. Environment File (.env)');
const envLoaded = process.env.NODE_ENV !== undefined;
console.log(`   ${envLoaded ? CHECKS.ENV_LOADED : CHECKS.ENV_MISSING} .env file ${envLoaded ? 'loaded' : 'NOT FOUND'}`);

// Check 2: Payment provider configuration
console.log('\n2. Payment Provider Configuration');
const provider = process.env.PAYMENT_PROVIDER;
const providerMode = process.env.PAYMENT_PROVIDER_MODE;

if (provider === 'razorpay') {
  console.log(`   ${CHECKS.VALUE_PRESENT} PAYMENT_PROVIDER: razorpay`);
} else {
  console.log(`   ${CHECKS.VALUE_MISSING} PAYMENT_PROVIDER: ${provider || 'NOT SET'} (should be 'razorpay')`);
}

if (providerMode) {
  const modeIcon = providerMode === 'mock' ? CHECKS.MOCK_MODE : 
                   providerMode === 'live' ? CHECKS.LIVE_MODE : '❓';
  console.log(`   ${modeIcon} PAYMENT_PROVIDER_MODE: ${providerMode}`);
} else {
  console.log(`   ${CHECKS.VALUE_MISSING} PAYMENT_PROVIDER_MODE: NOT SET`);
}

// Check 3: Razorpay credentials
console.log('\n3. Razorpay Credentials');

const keyId = process.env.RAZORPAY_KEY_ID;
const keySecret = process.env.RAZORPAY_KEY_SECRET;
const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;

if (keyId) {
  const isTestKey = keyId.startsWith('rzp_test_');
  const isLiveKey = keyId.startsWith('rzp_live_');
  const keyType = isTestKey ? 'TEST' : isLiveKey ? 'LIVE' : 'INVALID';
  const keyIcon = isTestKey ? CHECKS.TEST_MODE : isLiveKey ? CHECKS.LIVE_MODE : '⚠️';
  
  console.log(`   ${keyIcon} RAZORPAY_KEY_ID: ${keyId} (${keyType})`);
  
  if (!isTestKey && !isLiveKey) {
    console.log(`   ⚠️  WARNING: KEY_ID should start with 'rzp_test_' or 'rzp_live_'`);
  }
} else {
  console.log(`   ${CHECKS.VALUE_MISSING} RAZORPAY_KEY_ID: NOT SET`);
}

if (keySecret) {
  console.log(`   ${CHECKS.VALUE_PRESENT} RAZORPAY_KEY_SECRET: ${'*'.repeat(keySecret.length)} (hidden)`);
} else {
  console.log(`   ${CHECKS.VALUE_MISSING} RAZORPAY_KEY_SECRET: NOT SET`);
}

if (webhookSecret) {
  console.log(`   ${CHECKS.VALUE_PRESENT} RAZORPAY_WEBHOOK_SECRET: ${'*'.repeat(webhookSecret.length)} (hidden)`);
} else {
  console.log(`   ⚠️  RAZORPAY_WEBHOOK_SECRET: NOT SET (optional for now)`);
}

// Check 4: Razorpay package
console.log('\n4. Razorpay Package');
try {
  const razorpay = require('razorpay');
  console.log(`   ${CHECKS.VALUE_PRESENT} razorpay package installed`);
  
  // Try to instantiate
  if (keyId && keySecret) {
    try {
      const instance = new razorpay({
        key_id: keyId,
        key_secret: keySecret,
      });
      console.log(`   ${CHECKS.VALUE_PRESENT} Razorpay instance created successfully`);
    } catch (error) {
      console.log(`   ${CHECKS.VALUE_MISSING} Failed to create Razorpay instance: ${error.message}`);
    }
  }
} catch (error) {
  console.log(`   ${CHECKS.VALUE_MISSING} razorpay package NOT installed`);
  console.log(`   💡 Run: npm install razorpay`);
}

// Check 5: Integration files
console.log('\n5. Integration Files');
const fs = require('fs');
const path = require('path');

const files = [
  'src/modules/payments/razorpay.client.ts',
  'src/modules/payments/payments.service.ts',
  'src/modules/payments/payments.routes.ts',
  'test-razorpay.html',
];

files.forEach(file => {
  const exists = fs.existsSync(path.join(__dirname, file));
  console.log(`   ${exists ? CHECKS.VALUE_PRESENT : CHECKS.VALUE_MISSING} ${file}`);
});

// Summary
console.log('\n========================================');
console.log('📊 Summary');
console.log('========================================\n');

const allGood = keyId && keySecret && provider === 'razorpay' && providerMode;

if (allGood) {
  const isTestMode = keyId && keyId.startsWith('rzp_test_');
  console.log(`✅ Razorpay is properly configured!`);
  console.log(`\n${isTestMode ? CHECKS.TEST_MODE : CHECKS.LIVE_MODE} Mode: ${isTestMode ? 'TEST (safe for development)' : 'LIVE (real payments)'}`);
  console.log(`\n🚀 Ready to test! Next steps:`);
  console.log(`   1. Start server: npm run dev`);
  console.log(`   2. Open test page: test-razorpay.html`);
  console.log(`   3. Use test card: 4111 1111 1111 1111`);
  console.log(`\n📖 See TESTING_GUIDE.md for detailed instructions`);
} else {
  console.log(`❌ Configuration incomplete!`);
  console.log(`\n🔧 Required actions:`);
  
  if (!keyId) {
    console.log(`   - Add RAZORPAY_KEY_ID to .env`);
  }
  if (!keySecret) {
    console.log(`   - Add RAZORPAY_KEY_SECRET to .env`);
  }
  if (provider !== 'razorpay') {
    console.log(`   - Set PAYMENT_PROVIDER=razorpay in .env`);
  }
  if (!providerMode) {
    console.log(`   - Set PAYMENT_PROVIDER_MODE=live in .env`);
  }
  
  console.log(`\n💡 Copy credentials from Razorpay Dashboard`);
  console.log(`   https://dashboard.razorpay.com/app/keys`);
}

console.log('\n========================================\n');

// Exit with appropriate code
process.exit(allGood ? 0 : 1);
