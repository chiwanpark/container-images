const path = require("node:path");
const entry = path.basename(process.argv[1] ?? "");
const title = /^supervisor-entrypoint\.[jt]s$/.test(entry)
  ? process.env.AGENT_SUPERVISOR_TITLE
  : /^daemon-worker\.[jt]s$/.test(entry)
    ? process.env.AGENT_DAEMON_TITLE
    : undefined;
if (title) {
  process.title = title;
  Object.defineProperty(process, "title", { configurable: true, enumerable: true, get: () => title, set: () => {} });
}
