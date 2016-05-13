/**
 * electronipc.js
 */
'use strict';

const ipcRenderer = require('electron').ipcRenderer;
const ELECTRON_IPC_CHANNEL = 'ELECTRON_IPC_CHANNEL';

angular.module('electron-ipc', [])
    .service('electronIpc', electronIpc);

function electronIpc() {
    let ipcChannel = channel => channel == null ? ELECTRON_IPC_CHANNEL : channel;

    this.on = (channel, callback) => {
        // callback(event, arg)
        ipcRenderer.on(ipcChannel(channel), callback);
    };
    this.send = (channel, message) => {
        ipcRenderer.send(ipcChannel(channel), message);
    };
}
electronIpc.$inject = [];
