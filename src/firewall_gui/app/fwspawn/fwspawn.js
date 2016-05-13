'use strict';

const child_process = require('child_process')
const ipcMain = require('electron').ipcMain;

let importCmd = 'iptables-save',
    exportCmd = 'iptables-restore';

ipcMain.on(importCmd, (event, arg) => {
    if (typeof arg === 'string' && arg.length > 0) {
        let argv = arg.split(' ');
        let prog = argv.shift();
        let child = child_process.spawn(prog, argv);
        child.on('error', (err) => console.error(err));
        child.stdout.on('data', (chunk) => event.sender.send(importCmd, chunk.toString()));
    }
});

ipcMain.on(exportCmd, (event, arg, arg1) => {
    if (typeof arg === 'string' && arg.length > 0) {
        let argv = arg.split(' ');
        let prog = argv.shift();
        let child = child_process.spawn(prog, argv);
        child.on('error', (err) => console.error(err));
        child.stdout.on('close', (code) => event.sender.send(exportCmd, code));

        child.stdin.write(arg1);
        child.stdin.end();
    }
});
