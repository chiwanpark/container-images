import childProcess from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { syncBuiltinESMExports } from "node:module";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";

const DIRENT_METHODS = ["isFile", "isDirectory", "isSymbolicLink", "isBlockDevice", "isCharacterDevice", "isFIFO", "isSocket"];

function toPath(value) {
  return value instanceof URL && value.protocol === "file:" ? fileURLToPath(value) : value;
}

function inSnapshot(value) {
  return typeof value === "string" && (value === "/snapshot" || value.startsWith("/snapshot/"));
}

function wantsDirents(dir, options) {
  return inSnapshot(dir) && typeof options === "object" && options !== null && options.withFileTypes;
}

function toDirents(dir, names) {
  return names.map((name) => {
    const stats = fs.statSync(path.join(dir, name));
    const dirent = new fs.Dirent(name, 0, dir);
    for (const method of DIRENT_METHODS) {
      dirent[method] = () => stats[method]();
    }
    return dirent;
  });
}

function acceptFileUrl(target, name) {
  const original = target[name];
  if (typeof original !== "function") return;
  target[name] = function (first, ...rest) {
    return original.call(this, toPath(first), ...rest);
  };
}

for (const name of ["readFileSync", "existsSync", "statSync", "lstatSync", "createReadStream", "accessSync", "realpathSync", "openSync", "readFile", "stat", "lstat", "readdir", "access", "open"]) {
  acceptFileUrl(fs, name);
}
for (const name of ["readFile", "stat", "lstat", "access", "open", "realpath"]) {
  acceptFileUrl(fs.promises, name);
}

const readdirSync = fs.readdirSync;
fs.readdirSync = function (dir, options) {
  dir = toPath(dir);
  if (wantsDirents(dir, options)) {
    return toDirents(dir, readdirSync.call(this, dir, { ...options, withFileTypes: false }));
  }
  return readdirSync.call(this, dir, options);
};

const readdir = fs.promises.readdir;
fs.promises.readdir = async function (dir, options) {
  dir = toPath(dir);
  if (wantsDirents(dir, options)) {
    return toDirents(dir, await readdir.call(this, dir, { ...options, withFileTypes: false }));
  }
  return readdir.call(this, dir, options);
};

for (const name of ["exec", "execFile"]) {
  const original = childProcess[name];
  if (typeof original !== "function" || original[promisify.custom]) continue;
  Object.defineProperty(original, promisify.custom, {
    value: (...args) => {
      let child;
      const promise = new Promise((resolve, reject) => {
        child = original(...args, (error, stdout, stderr) => {
          if (error) {
            error.stdout = stdout;
            error.stderr = stderr;
            reject(error);
          } else {
            resolve({ stdout, stderr });
          }
        });
      });
      promise.child = child;
      return promise;
    },
  });
}

syncBuiltinESMExports();
