import { Router } from "express";
import { loadEnv } from "../config/env";
import { createRazorpayOrder } from "../modules/payments/razorpay.client";

export const razorpayTestRouter = Router();

function testCheckoutHtml(keyId: string, orderId: string): string {
  const safeKey = keyId.replace(/"/g, "");
  const safeOrder = orderId.replace(/"/g, "");
  return `<!DOCTYPE html>
<html lang="en-IN">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Razorpay test payment — Moozhayil</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 520px; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; }
    button { background: #528FF0; color: #fff; border: 0; padding: 12px 20px; border-radius: 6px; font-size: 1rem; cursor: pointer; width: 100%; }
    .note { background: #fff8e6; border: 1px solid #f0d78c; padding: 12px; border-radius: 8px; font-size: 0.9rem; margin: 1rem 0; }
    #result { margin-top: 1rem; display: none; padding: 12px; border-radius: 8px; background: #f1f8f4; border: 1px solid #4caf50; }
  </style>
</head>
<body>
  <h1>Moozhayil — Razorpay test checkout</h1>
  <p>₹1 verification payment (test mode). Use Razorpay test card <strong>4100 2800 0000 1007</strong>, CVV <strong>123</strong>, expiry any future date.</p>
  <div class="note">Test keys only — no real money is charged.</div>
  <button id="pay">Pay ₹1 (test)</button>
  <div id="result"></div>
  <p><a href="/">← Back to website</a></p>
  <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
  <script>
    document.getElementById("pay").onclick = function () {
      var options = {
        key: "${safeKey}",
        amount: 100,
        currency: "INR",
        name: "Moozhayil Gold & Diamonds",
        description: "Integration test payment",
        order_id: "${safeOrder}",
        theme: { color: "#8b6914" },
        handler: function (response) {
          var el = document.getElementById("result");
          el.style.display = "block";
          el.textContent = "Payment successful (test). Payment ID: " + response.razorpay_payment_id;
        }
      };
      new Razorpay(options).open();
    };
  </script>
</body>
</html>`;
}

function razorpayTestKeysReady(keyId: string | undefined, keySecret: string | undefined): boolean {
  if (!keyId?.startsWith("rzp_test_") || !keySecret?.trim()) {
    return false;
  }
  const placeholder = /YOUR_|REPLACE_ME|^mock$/i;
  return !placeholder.test(keyId) && !placeholder.test(keySecret);
}

razorpayTestRouter.get("/pay/test", async (_req, res) => {
  try {
    const env = loadEnv();
    const keyId = env.RAZORPAY_KEY_ID;
    const keySecret = env.RAZORPAY_KEY_SECRET;

    if (!razorpayTestKeysReady(keyId, keySecret)) {
      res.status(503).type("html").send(`<!DOCTYPE html>
<html lang="en-IN"><body style="font-family:system-ui;max-width:520px;margin:2rem auto;padding:0 1rem">
<h1>Razorpay test checkout not configured</h1>
<p>Add your <strong>Test API keys</strong> from Razorpay Dashboard → Account &amp; Settings → API Keys to production env, redeploy, then reload this page.</p>
<p>Or complete the wizard using <strong>Payment Links</strong> in the Razorpay dashboard with test card 4100 2800 0000 1007.</p>
<p><a href="/">Back to website</a></p>
</body></html>`);
      return;
    }

    const order = await createRazorpayOrder({
      amountPaise: 100,
      receipt: `web_test_${Date.now()}`,
    });

    res.type("html").send(testCheckoutHtml(keyId!, order.providerOrderId));
  } catch {
    res.status(503).type("html").send(`<!DOCTYPE html>
<html lang="en-IN"><body style="font-family:system-ui;max-width:520px;margin:2rem auto;padding:0 1rem">
<h1>Could not start test payment</h1>
<p>Verify Razorpay test Key ID and Secret on the server match your dashboard.</p>
<p><a href="/pay/test">Retry</a> · <a href="/">Home</a></p>
</body></html>`);
  }
});
