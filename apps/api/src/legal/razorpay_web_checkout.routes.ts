import { Router } from "express";
import { z } from "zod";
import { loadEnv } from "../config/env";
import {
  createRazorpayOrder,
  verifyRazorpayCheckoutSignature,
} from "../modules/payments/razorpay.client";

export const razorpayWebCheckoutRouter = Router();

function razorpayKeysReady(
  keyId: string | undefined,
  keySecret: string | undefined,
): boolean {
  if (!keyId?.startsWith("rzp_") || !keySecret?.trim()) {
    return false;
  }
  const placeholder = /YOUR_|REPLACE_ME|^mock$/i;
  return !placeholder.test(keyId) && !placeholder.test(keySecret);
}

const createOrderSchema = z.object({
  amount: z.number().int().min(100).optional().default(100),
  currency: z.literal("INR").optional().default("INR"),
});

const verifyPaymentSchema = z.object({
  razorpay_payment_id: z.string().min(1),
  razorpay_order_id: z.string().min(1),
  razorpay_signature: z.string().min(1),
});

function mapRazorpayOrderError(error: unknown): { status: number; message: string } {
  const message = error instanceof Error ? error.message : "Razorpay order creation failed";
  if (message.includes("(401)")) {
    return { status: 401, message: "Razorpay authentication failed" };
  }
  return { status: 500, message: "Could not create Razorpay order" };
}

razorpayWebCheckoutRouter.post("/api/create-order", async (req, res) => {
  const env = loadEnv();
  if (!razorpayKeysReady(env.RAZORPAY_KEY_ID, env.RAZORPAY_KEY_SECRET)) {
    res.status(503).json({ error: "Razorpay is not configured on this server" });
    return;
  }

  const parsed = createOrderSchema.safeParse(req.body ?? {});
  if (!parsed.success) {
    res.status(400).json({
      error: "Invalid request",
      details: parsed.error.flatten().fieldErrors,
    });
    return;
  }

  const { amount, currency } = parsed.data;

  try {
    const order = await createRazorpayOrder({
      amountPaise: amount,
      receipt: `web_${Date.now()}`,
    });

    res.status(200).json({
      order_id: order.providerOrderId,
      amount: order.amountPaise,
      currency,
      key_id: env.RAZORPAY_KEY_ID,
    });
  } catch (error) {
    const mapped = mapRazorpayOrderError(error);
    res.status(mapped.status).json({ error: mapped.message });
  }
});

razorpayWebCheckoutRouter.post("/api/verify-payment", (req, res) => {
  const env = loadEnv();
  if (!razorpayKeysReady(env.RAZORPAY_KEY_ID, env.RAZORPAY_KEY_SECRET)) {
    res.status(503).json({ error: "Razorpay is not configured on this server" });
    return;
  }

  const parsed = verifyPaymentSchema.safeParse(req.body ?? {});
  if (!parsed.success) {
    res.status(400).json({
      error: "Missing or invalid payment fields",
      details: parsed.error.flatten().fieldErrors,
    });
    return;
  }

  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } =
    parsed.data;

  const valid = verifyRazorpayCheckoutSignature({
    orderId: razorpay_order_id,
    paymentId: razorpay_payment_id,
    signature: razorpay_signature,
  });

  if (!valid) {
    res.status(400).json({ success: false, error: "Signature verification failed" });
    return;
  }

  res.status(200).json({
    success: true,
    order_id: razorpay_order_id,
    payment_id: razorpay_payment_id,
  });
});

function checkoutPageHtml(keyId: string, defaultAmountPaise: number): string {
  const safeKey = keyId.replace(/"/g, "");
  const amountDisplay = (defaultAmountPaise / 100).toFixed(2);
  return `<!DOCTYPE html>
<html lang="en-IN">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Razorpay checkout — Moozhayil</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 520px; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; }
    button { background: #528FF0; color: #fff; border: 0; padding: 12px 20px; border-radius: 6px; font-size: 1rem; cursor: pointer; width: 100%; }
    button:disabled { opacity: 0.6; cursor: not-allowed; }
    .note { background: #fff8e6; border: 1px solid #f0d78c; padding: 12px; border-radius: 8px; font-size: 0.9rem; margin: 1rem 0; }
    #error { display: none; margin-top: 1rem; padding: 12px; border-radius: 8px; background: #fdecea; border: 1px solid #e57373; color: #b71c1c; }
    #result { margin-top: 1rem; display: none; padding: 12px; border-radius: 8px; background: #f1f8f4; border: 1px solid #4caf50; }
  </style>
</head>
<body>
  <h1>Moozhayil — Razorpay Standard Checkout</h1>
  <p>Pay ₹${amountDisplay} (test mode). Card <strong>4100 2800 0000 1007</strong>, CVV <strong>123</strong>, any future expiry.</p>
  <div class="note">Standard Web Checkout: create order → modal → verify signature on server.</div>
  <button id="pay" type="button">Pay now</button>
  <div id="error" role="alert"></div>
  <div id="result"></div>
  <p><a href="/">← Back to website</a></p>
  <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
  <script>
    (function () {
      var keyId = "${safeKey}";
      var amountPaise = ${defaultAmountPaise};
      var payBtn = document.getElementById("pay");
      var errEl = document.getElementById("error");
      var okEl = document.getElementById("result");

      function showError(msg) {
        errEl.style.display = "block";
        errEl.textContent = msg;
        okEl.style.display = "none";
      }

      payBtn.onclick = function () {
        errEl.style.display = "none";
        okEl.style.display = "none";
        payBtn.disabled = true;

        fetch("/api/create-order", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ amount: amountPaise, currency: "INR" })
        })
          .then(function (r) { return r.json().then(function (d) { return { ok: r.ok, status: r.status, data: d }; }); })
          .then(function (res) {
            if (!res.ok) {
              throw new Error(res.data.error || ("Order failed (" + res.status + ")"));
            }
            var orderId = res.data.order_id;
            var options = {
              key: keyId,
              amount: res.data.amount,
              currency: res.data.currency || "INR",
              name: "Moozhayil Gold & Diamonds",
              description: "Standard checkout payment",
              order_id: orderId,
              theme: { color: "#8b6914" },
              handler: function (response) {
                fetch("/api/verify-payment", {
                  method: "POST",
                  headers: { "Content-Type": "application/json" },
                  body: JSON.stringify({
                    razorpay_payment_id: response.razorpay_payment_id,
                    razorpay_order_id: response.razorpay_order_id,
                    razorpay_signature: response.razorpay_signature
                  })
                })
                  .then(function (vr) { return vr.json().then(function (vd) { return { ok: vr.ok, data: vd }; }); })
                  .then(function (verified) {
                    if (!verified.ok || !verified.data.success) {
                      showError(verified.data.error || "Payment verification failed");
                      return;
                    }
                    okEl.style.display = "block";
                    okEl.textContent = "Payment verified. Payment ID: " + verified.data.payment_id;
                  })
                  .catch(function () { showError("Could not verify payment on server"); })
                  .finally(function () { payBtn.disabled = false; });
              },
              modal: {
                ondismiss: function () {
                  payBtn.disabled = false;
                  showError("Payment cancelled");
                }
              }
            };
            var rzp = new Razorpay(options);
            rzp.on("payment.failed", function (resp) {
              payBtn.disabled = false;
              showError(resp.error.description || "Payment failed");
            });
            rzp.open();
          })
          .catch(function (e) {
            showError(e.message || "Could not start checkout");
            payBtn.disabled = false;
          });
      };
    })();
  </script>
</body>
</html>`;
}

async function serveCheckoutPage(
  res: import("express").Response,
  amountPaise: number,
): Promise<void> {
  const env = loadEnv();
  const keyId = env.RAZORPAY_KEY_ID;
  const keySecret = env.RAZORPAY_KEY_SECRET;

  if (!razorpayKeysReady(keyId, keySecret)) {
    res.status(503).type("html").send(`<!DOCTYPE html>
<html lang="en-IN"><body style="font-family:system-ui;max-width:520px;margin:2rem auto;padding:0 1rem">
<h1>Razorpay checkout not configured</h1>
<p>Set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in server environment.</p>
<p><a href="/">Back to website</a></p>
</body></html>`);
    return;
  }

  res.type("html").send(checkoutPageHtml(keyId!, amountPaise));
}

razorpayWebCheckoutRouter.get("/pay/checkout", (req, res) => {
  void serveCheckoutPage(res, 100);
});

razorpayWebCheckoutRouter.get("/pay/test", (req, res) => {
  void serveCheckoutPage(res, 100);
});
