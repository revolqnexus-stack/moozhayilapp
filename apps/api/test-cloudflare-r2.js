#!/usr/bin/env node

/**
 * Test Cloudflare R2 Storage Connection
 * 
 * This verifies your R2 bucket is accessible and working
 */

import { S3Client, PutObjectCommand, GetObjectCommand, ListBucketsCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

console.log('🧪 Testing Cloudflare R2 Connection...\n');

// Configure R2 client
const s3Client = new S3Client({
  region: 'auto',
  endpoint: `https://28247e5c8e5aca83c94a869bdfbd0b6d.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.S3_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.S3_SECRET_ACCESS_KEY || '',
  },
  forcePathStyle: false,
});

const bucket = 'moozhayil-media'; // Your bucket name
const testKey = 'test/connection-test.txt';
const testContent = `Test upload at ${new Date().toISOString()}`;

async function testR2Connection() {
  try {
    console.log('📦 Bucket:', bucket);
    console.log('🔑 Testing with credentials...\n');

    // Test 1: List buckets (verify credentials work)
    console.log('1️⃣ Testing credentials...');
    try {
      await s3Client.send(new ListBucketsCommand({}));
      console.log('   ✅ Credentials valid!\n');
    } catch (error) {
      console.log('   ❌ Credentials invalid:', error.message);
      process.exit(1);
    }

    // Test 2: Upload a test file
    console.log('2️⃣ Uploading test file...');
    await s3Client.send(
      new PutObjectCommand({
        Bucket: bucket,
        Key: testKey,
        Body: testContent,
        ContentType: 'text/plain',
      })
    );
    console.log('   ✅ Upload successful!\n');

    // Test 3: Generate signed URL
    console.log('3️⃣ Generating signed URL...');
    const url = await getSignedUrl(
      s3Client,
      new GetObjectCommand({ Bucket: bucket, Key: testKey }),
      { expiresIn: 3600 } // 1 hour
    );
    console.log('   ✅ Signed URL generated!');
    console.log(`   🔗 ${url}\n`);

    // Test 4: Read back the file
    console.log('4️⃣ Reading file back...');
    const response = await s3Client.send(
      new GetObjectCommand({ Bucket: bucket, Key: testKey })
    );
    const body = await response.Body.transformToString();
    
    if (body === testContent) {
      console.log('   ✅ Content matches!\n');
    } else {
      console.log('   ⚠️  Content mismatch');
      console.log('   Expected:', testContent);
      console.log('   Got:', body);
    }

    console.log('═══════════════════════════════════════════');
    console.log('🎉 SUCCESS! R2 is configured correctly!');
    console.log('═══════════════════════════════════════════\n');

    console.log('✅ Your R2 setup is ready for production!');
    console.log('✅ You can now deploy to Render with these credentials.\n');

  } catch (error) {
    console.log('\n❌ ERROR:', error.message);
    console.log('\nTroubleshooting:');
    console.log('1. Make sure you created the "moozhayil-media" bucket in R2');
    console.log('2. Verify your API token has Read & Write permissions');
    console.log('3. Check S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY are correct\n');
    process.exit(1);
  }
}

// Check if credentials are provided
if (!process.env.S3_ACCESS_KEY_ID || !process.env.S3_SECRET_ACCESS_KEY) {
  console.log('❌ Missing R2 credentials!\n');
  console.log('Please set these environment variables:');
  console.log('  S3_ACCESS_KEY_ID');
  console.log('  S3_SECRET_ACCESS_KEY\n');
  console.log('Example:');
  console.log('  $env:S3_ACCESS_KEY_ID="your_access_key"');
  console.log('  $env:S3_SECRET_ACCESS_KEY="your_secret_key"');
  console.log('  node test-cloudflare-r2.js\n');
  process.exit(1);
}

testR2Connection();
