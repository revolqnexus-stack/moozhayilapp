#!/usr/bin/env node
/**
 * Test Razorpay Signature Verification
 * 
 * This script tests the HMAC-SHA256 signature verification logic
 * without making actual API calls.
 */

const crypto = require('crypto');
require('dotenv').config();

console.log('\n========================================');
console.log('🔐 Razorpay Signature Verification Test');
console.log('========================================\n');

const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET;

if (!RAZORPAY_KEY_SECRET) {
  console.log('❌ RAZORPAY_KEY_SECRET not found in .env');
  process.exit(1);
}

// Test data (simulating Razorpay response)
const testCases = [
  {
    name: 'Valid Signature',
    orderId: 'order_Mtest123456789',
    paymentId: 'pay_Ntest987654321',
    generateSignature: true,
    expectedResult: true,
  },
  {
    name: 'Invalid Signature',
    orderId: 'order_Mtest123456789',
    paymentId: 'pay_Ntest987654321',
    signature: 'invalid_signature_12345',
    expectedResult: false,
  },
  {
    name: 'Tampered Payment ID',
    orderId: 'order_Mtest123456789',
    paymentId: 'pay_TAMPERED12345',
    generateSignature: true,
    tamperedPaymentId: 'pay_Ntest987654321',
    expectedResult: false,
  },
];

function verifySignature(orderId, paymentId, signature) {
  const message = `${orderId}|${paymentId}`;
  const expectedSignature = crypto
    .createHmac('sha256', RAZORPAY_KEY_SECRET)
    .update(message)
    .digest('hex');
  
  // Timing-safe comparison
  const expectedBuffer = Buffer.from(expectedSignature, 'utf8');
  const signatureBuffer = Buffer.from(signature, 'utf8');
  
  if (expectedBuffer.length !== signatureBuffer.length) {
    return false;
  }
  
  return crypto.timingSafeEqual(expectedBuffer, signatureBuffer);
}

function generateSignature(orderId, paymentId) {
  const message = `${orderId}|${paymentId}`;
  return crypto
    .createHmac('sha256', RAZORPAY_KEY_SECRET)
    .update(message)
    .digest('hex');
}

console.log('Testing signature verification logic...\n');

let passed = 0;
let failed = 0;

testCases.forEach((test, index) => {
  console.log(`Test ${index + 1}: ${test.name}`);
  console.log(`  Order ID:   ${test.orderId}`);
  console.log(`  Payment ID: ${test.paymentId}`);
  
  let signature;
  if (test.generateSignature) {
    // Use tampered payment ID if provided, otherwise use real one
    const signPaymentId = test.tamperedPaymentId || test.paymentId;
    signature = generateSignature(test.orderId, signPaymentId);
    console.log(`  Signature:  ${signature.substring(0, 20)}... (generated)`);
  } else {
    signature = test.signature;
    console.log(`  Signature:  ${signature.substring(0, 20)}...`);
  }
  
  const result = verifySignature(test.orderId, test.paymentId, signature);
  const success = result === test.expectedResult;
  
  if (success) {
    console.log(`  Result:     ✅ ${result ? 'VALID' : 'INVALID'} (Expected: ${test.expectedResult ? 'VALID' : 'INVALID'})`);
    passed++;
  } else {
    console.log(`  Result:     ❌ ${result ? 'VALID' : 'INVALID'} (Expected: ${test.expectedResult ? 'VALID' : 'INVALID'})`);
    failed++;
  }
  console.log('');
});

// Example of generating a valid signature
console.log('========================================');
console.log('📝 Example: Generate Valid Signature');
console.log('========================================\n');

const exampleOrderId = 'order_MexampleOrder123';
const examplePaymentId = 'pay_NexamplePayment456';
const exampleSignature = generateSignature(exampleOrderId, examplePaymentId);

console.log('Input:');
console.log(`  Order ID:   ${exampleOrderId}`);
console.log(`  Payment ID: ${examplePaymentId}`);
console.log('\nOutput:');
console.log(`  Signature:  ${exampleSignature}`);
console.log('\nMessage before HMAC:');
console.log(`  "${exampleOrderId}|${examplePaymentId}"`);

// Verify it
const isValid = verifySignature(exampleOrderId, examplePaymentId, exampleSignature);
console.log(`\nVerification: ${isValid ? '✅ VALID' : '❌ INVALID'}`);

console.log('\n========================================');
console.log('📊 Test Results');
console.log('========================================\n');

console.log(`Total Tests:  ${testCases.length}`);
console.log(`✅ Passed:    ${passed}`);
console.log(`❌ Failed:    ${failed}`);

if (failed === 0) {
  console.log('\n🎉 All tests passed! Signature verification is working correctly.\n');
  process.exit(0);
} else {
  console.log('\n⚠️  Some tests failed. Check the implementation.\n');
  process.exit(1);
}
