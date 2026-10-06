const path = require("node:path");
const entries = process.argv.slice(1, 3).map((arg) => path.basename(arg ?? ""));
const title = entries.some((entry) => /^supervisor-entrypoint\.[jt]s$/.test(entry))
  ? process.env.AGENT_SUPERVISOR_TITLE
  : entries.some((entry) => /^daemon-worker\.[jt]s$/.test(entry))
    ? process.env.AGENT_DAEMON_TITLE
    : undefined;
if (title) {
  process.title = title;
  Object.defineProperty(process, "title", { configurable: true, enumerable: true, get: () => title, set: () => {} });
}
