import dotenv from "dotenv";

const envFile = process.env.MOOZHAYIL_ENV_FILE ?? ".env";
dotenv.config({ path: envFile });
if (!process.env.MOOZHAYIL_ENV_FILE) {
  dotenv.config({ path: ".env.local", override: true });
}
import { createApp, validateEnvironment } from "./app";
import { initMonitoring } from "./utils/monitoring";

const env = validateEnvironment();
initMonitoring();
const app = createApp();

app.listen(env.PORT, () => {
  console.log(
    `[api] listening on port ${env.PORT} (${env.NODE_ENV})`,
  );
});
