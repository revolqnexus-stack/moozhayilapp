const { randomBytes, scryptSync } = require('crypto');

const KEY_LENGTH = 64;

function hashPassword(password) {
  const salt = randomBytes(16).toString('hex');
  const hash = scryptSync(password, salt, KEY_LENGTH).toString('hex');
  return `${salt}:${hash}`;
}

const password = 'Admin123!@#';
const hashed = hashPassword(password);

console.log('Password:', password);
console.log('Hashed:', hashed);
console.log('\nCopy this hash to use in SQL:');
console.log(hashed);
