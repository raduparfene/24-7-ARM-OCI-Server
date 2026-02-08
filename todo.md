### For LinkMonitor project
- setup gitlab runner for LinkMonitor

### Future improvements to consider
- start cs script at any restarts
- make cs script error safe so it truly runs 24/7
- consider restarting cs server after a while, so that the server doesn't maintain its state for too long
- maybe even add a rankstats database and a database for ammopacks
- nginx for fast download inside code
- improve scripts and download only what is necessary within the bootstrap.sh script
