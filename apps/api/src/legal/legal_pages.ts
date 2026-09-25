const BRAND = "Moozhayil Gold &amp; Diamonds";
const CONTACT = "hello@moozhayil.com";
const EFFECTIVE = "23 September 2026";

function layout(title: string, body: string): string {
  return `<!DOCTYPE html>
<html lang="en-IN">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>${title} — Moozhayil</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 720px; margin: 2rem auto; padding: 0 1rem; color: #1a1a1a; line-height: 1.6; }
    h1 { font-size: 1.75rem; margin-bottom: 0.25rem; }
    h2 { font-size: 1.1rem; margin-top: 1.5rem; }
    .meta { color: #666; font-size: 0.9rem; margin-bottom: 1.5rem; }
    a { color: #8b6914; }
    footer { margin-top: 2rem; padding-top: 1rem; border-top: 1px solid #eee; font-size: 0.85rem; color: #666; }
    table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.95rem; }
    th, td { border: 1px solid #e5e5e5; padding: 0.65rem 0.75rem; text-align: left; vertical-align: top; }
    th { background: #faf7f0; }
    .price { font-weight: 600; white-space: nowrap; }
    .note { background: #faf7f0; border: 1px solid #eee; border-radius: 8px; padding: 0.75rem 1rem; font-size: 0.9rem; }
  </style>
</head>
<body>
  ${body}
  <footer>
    <p><a href="/">Home</a> · <a href="/products">Products</a> · <a href="/privacy">Privacy</a> · <a href="/terms">Terms</a> · <a href="/accessibility">Accessibility</a></p>
    <p>Contact: <a href="mailto:${CONTACT}">${CONTACT}</a></p>
  </footer>
</body>
</html>`;
}

function productCatalogueSection(): string {
  return `<h2>Product catalogue &amp; pricing</h2>
<p class="meta">22k gold rate: ₹6,240/gram (indicative). Prices include gold value plus making charges.</p>
<table>
  <thead>
    <tr><th>Product</th><th>Description</th><th>Weight</th><th>Making charge</th><th>Price (INR)</th></tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Temple Bloom Necklace</strong><br/><small>SKU: MZ-NK-001</small></td>
      <td>22k gold necklace with temple-inspired detailing. In stock.</td>
      <td>8.5 g</td>
      <td>12%</td>
      <td class="price">₹59,405</td>
    </tr>
    <tr>
      <td><strong>Heritage Band Ring</strong><br/><small>SKU: MZ-RG-002</small></td>
      <td>Classic 22k band ring for everyday elegance. In stock.</td>
      <td>4.2 g</td>
      <td>10%</td>
      <td class="price">₹28,829</td>
    </tr>
    <tr>
      <td><strong>Kerala Kasu Bangle</strong><br/><small>SKU: MZ-BG-003</small></td>
      <td>Traditional kasu bangle pair in 22k gold. In stock.</td>
      <td>12.0 g</td>
      <td>11%</td>
      <td class="price">₹83,117</td>
    </tr>
    <tr>
      <td><strong>Aura Gold Savings Plan</strong></td>
      <td>Monthly gold accumulation plan. Redeemable for jewellery or vault balance.</td>
      <td>—</td>
      <td>—</td>
      <td class="price">From ₹500/month</td>
    </tr>
  </tbody>
</table>
<p><a href="/products">Full catalogue page →</a></p>`;
}

export function landingPageHtml(): string {
  return layout(
    "Moozhayil",
    `<h1>${BRAND}</h1>
<p class="meta">Gold savings schemes, jewellery, and digital gold services in India.</p>
<p>Moozhayil helps customers save toward gold, browse jewellery, and manage gold savings plans. Product prices are listed below; checkout is completed in our mobile app after OTP login.</p>
${productCatalogueSection()}
<h2>Our services</h2>
<ul>
  <li><strong>22k gold jewellery</strong> — necklaces, rings, bangles</li>
  <li><strong>Gold savings schemes</strong> — monthly contributions from ₹500 toward gold accumulation</li>
  <li><strong>Digital gold vault</strong> — track accumulated gold balance and redeem for jewellery</li>
</ul>
<p><strong>Support:</strong> <a href="mailto:${CONTACT}">${CONTACT}</a></p>`,
  );
}

/** Static catalogue for Razorpay / merchant verification (matches app product SKUs). */
export function productsPageHtml(): string {
  const goldRate22k = "₹6,240";
  const rateNote = `22k gold rate: ${goldRate22k}/gram (indicative; final price confirmed in app at checkout)`;

  return layout(
    "Products &amp; Services",
    `<h1>Products &amp; Services</h1>
<p class="meta">${rateNote}</p>
<p class="note">Prices include gold value at the current 22k rate plus making charges. GST and delivery, if applicable, are shown before payment in the Moozhayil app.</p>
<h2>Jewellery catalogue</h2>
<table>
  <thead>
    <tr><th>Product</th><th>Description</th><th>Weight</th><th>Making charge</th><th>Price (INR)</th></tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Temple Bloom Necklace</strong><br/><small>SKU: MZ-NK-001</small></td>
      <td>22k gold necklace with temple-inspired detailing. In stock.</td>
      <td>8.5 g</td>
      <td>12%</td>
      <td class="price">₹59,405</td>
    </tr>
    <tr>
      <td><strong>Heritage Band Ring</strong><br/><small>SKU: MZ-RG-002</small></td>
      <td>Classic 22k band ring for everyday elegance. In stock.</td>
      <td>4.2 g</td>
      <td>10%</td>
      <td class="price">₹28,829</td>
    </tr>
    <tr>
      <td><strong>Kerala Kasu Bangle</strong><br/><small>SKU: MZ-BG-003</small></td>
      <td>Traditional kasu bangle pair in 22k gold. In stock.</td>
      <td>12.0 g</td>
      <td>11%</td>
      <td class="price">₹83,117</td>
    </tr>
  </tbody>
</table>
<h2>Gold savings scheme</h2>
<table>
  <thead>
    <tr><th>Plan</th><th>Description</th><th>Minimum contribution</th><th>Price (INR)</th></tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Aura Gold Savings Plan</strong></td>
      <td>Monthly gold accumulation plan. Contributions are converted to gold at the live rate on payment date. Redeemable for jewellery or vault balance.</td>
      <td>₹500 / month</td>
      <td class="price">From ₹500</td>
    </tr>
  </tbody>
</table>
<p>Orders and payments are completed in the Moozhayil Android app after phone OTP login and KYC verification where required.</p>
<p><strong>Contact:</strong> <a href="mailto:${CONTACT}">${CONTACT}</a></p>`,
  );
}

export function privacyPageHtml(): string {
  return layout(
    "Privacy Policy",
    `<h1>Privacy Policy</h1>
<p class="meta">Effective ${EFFECTIVE}</p>
<p>${BRAND} ("we", "us") operates the Moozhayil mobile application and related services. This policy explains how we collect, use, and protect your information.</p>
<h2>Information we collect</h2>
<ul>
  <li><strong>Account:</strong> mobile number, name, and profile details you provide.</li>
  <li><strong>Identity (KYC):</strong> documents and verification data required under applicable law for gold schemes and high-value transactions.</li>
  <li><strong>Transactions:</strong> orders, payments, scheme contributions, and ledger records.</li>
  <li><strong>Device:</strong> push notification tokens and basic diagnostic logs.</li>
</ul>
<h2>How we use information</h2>
<ul>
  <li>Authenticate you and send OTP codes via SMS.</li>
  <li>Process payments through Razorpay and other regulated payment providers.</li>
  <li>Verify identity, prevent fraud, and meet legal obligations.</li>
  <li>Provide customer support and service notifications.</li>
</ul>
<h2>Sharing</h2>
<p>We share data only with service providers who help us operate the app (hosting, SMS, payments, KYC verification, cloud storage) under contractual safeguards. We do not sell personal data.</p>
<h2>Retention &amp; security</h2>
<p>We retain records as required for financial, tax, and legal compliance. Data is encrypted in transit and access is restricted to authorised personnel.</p>
<h2>Your rights</h2>
<p>You may request access, correction, or deletion where applicable law allows. Contact <a href="mailto:${CONTACT}">${CONTACT}</a>.</p>
<h2>Changes</h2>
<p>We may update this policy; the effective date will be revised on this page.</p>`,
  );
}

export function termsPageHtml(): string {
  return layout(
    "Terms of Service",
    `<h1>Terms of Service</h1>
<p class="meta">Effective ${EFFECTIVE}</p>
<p>By using the Moozhayil app and services operated by ${BRAND}, you agree to these terms.</p>
<h2>Services</h2>
<p>Moozhayil offers gold savings schemes, jewellery catalogues, vault features, and related financial products subject to eligibility and KYC verification.</p>
<h2>Accounts</h2>
<p>You must provide accurate information and keep your account secure. We may suspend accounts for fraud, abuse, or legal non-compliance.</p>
<h2>Payments</h2>
<p>Prices, gold rates, and scheme terms are shown in the app before you pay. Payments are processed by third-party providers; their terms also apply.</p>
<h2>Gold schemes</h2>
<p>Scheme rules, making charges, redemption, and cancellation terms are displayed at enrollment. Confirm details before contributing.</p>
<h2>Limitation of liability</h2>
<p>Services are provided as permitted by law. We are not liable for indirect losses except where liability cannot be excluded under applicable Indian law.</p>
<h2>Contact</h2>
<p>Questions: <a href="mailto:${CONTACT}">${CONTACT}</a></p>`,
  );
}

export function accessibilityPageHtml(): string {
  return layout(
    "Accessibility",
    `<h1>Accessibility Statement</h1>
<p class="meta">Effective ${EFFECTIVE}</p>
<p>${BRAND} is committed to making the Moozhayil app accessible to users with disabilities. We aim to follow WCAG 2.1 Level AA where practicable.</p>
<p>If you encounter accessibility barriers, contact <a href="mailto:${CONTACT}">${CONTACT}</a> and we will work to provide an alternative or remediation.</p>`,
  );
}
