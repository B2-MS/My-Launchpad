# Test It Instructions

Quick rebuild and redeploy for testing My Launchpad.

## Quick Command

```bash
./build.sh && pkill -f "My Launchpad" 2>/dev/null; rm -rf "/Applications/My Launchpad.app" && cp -R "build/My Launchpad.app" "/Applications/" && open "/Applications/My Launchpad.app"
```

## What It Does

1. 🔨 Rebuilds the app with `./build.sh`
2. 🛑 Stops any running instances
3. 🗑️ Removes the installed version from Applications
4. 📦 Copies the new build to Applications
5. 🚀 Launches the app for testing
