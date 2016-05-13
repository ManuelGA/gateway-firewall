require('./fwspawn/fwspawn.js');

const app = require('app');
const BrowserWindow = require('browser-window');

var mainWindow = null;

app.on('window-all-closed', function() {
    // OS X specific behaviour
    if (process.platform != 'darwin') {
        app.quit();
    }
});

app.on('ready', function() {
    mainWindow = new BrowserWindow({width:800, height:600, 'auto-hide-menu-bar':true});
    mainWindow.loadURL('file://' + __dirname + '/../view/index.html');

    mainWindow.on('closed', function() {
        mainWindow = null;
    });
});
