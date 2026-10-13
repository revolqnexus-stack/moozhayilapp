import dotenv from "dotenv";

dotenv.config({
  path: process.env.MOOZHAYIL_ENV_FILE ?? ".env",
});
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
