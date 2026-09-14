const crypto = require('crypto');

// Using Argon2 format that @node-rs/argon2 expects
// Or we can use a pre-computed bcrypt hash
const bcryptHash = '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW';

console.log('Password: Admin123!@#');
console.log('Bcrypt Hash:', bcryptHash);
