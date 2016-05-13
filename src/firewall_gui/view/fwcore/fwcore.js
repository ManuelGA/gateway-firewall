/**
 * fwtable.js
 */

(function() {
    'use strict';

    angular.module('fwfe.fwcore', [])
        .service('fwCore', fwCore);

    function fwCore($q) {
        const ipcRenderer = require('electron').ipcRenderer;
        let deferred,
            deferredExport;
        let importChannel = 'iptables-save',
            exportChannel = 'iptables-restore';
        let importCmd = '/sbin/iptables-save',
            exportCmd = '/sbin/iptables-restore';

        this.tables = {};
        this.getTables = () => this.tables;

        this.import = () => {
            ipcRenderer.send(importChannel, importCmd);
            deferred = $q.defer();
            return deferred.promise;
        }
        this.export = () => {
            let output = '';
            angular.forEach(this.tables, (table) => {
                output += '*' + table.name + '\n'
                        + table.chains
                               .reduce((s, chain) => s += ':' + chain.name
                                   + ' ' + (chain.policy || '-') + ' '
                                   + '[' + chain.packets + ':' + chain.bytes + ']\n', '')
                        + table.chains
                               .reduce((a, chain) => a.concat(chain.rules.split('\n')), [])
                               .reduce((s, rule)  => rule.length ? s += rule + '\n': s, '')
                        + 'COMMIT\n';
            });
            ipcRenderer.send(exportChannel, exportCmd, output);
            deferredExport = $q.defer();
            return deferredExport.promise;
        };
        this.getImportCmd = () => importCmd;
        this.getEmportCmd = () => exportCmd;
        this.setImportCmd = cmd => importCmd = cmd;
        this.setExportCmd = cmd => exportCmd = cmd;

        ipcRenderer.on(importChannel, (ev, arg) => {
            arg
                .match(/\*(.|\s)*?(?=COMMIT)/g)
                .map((v,i,a) => new Table(v))
                .reduce((a, b) => {
                    a[b.name] = b;
                    return a;
                }, this.tables);
            deferred && deferred.resolve(this.tables);
        });
        ipcRenderer.on(exportChannel, (ev, arg) => deferredExport && deferredExport.resolve());
    }
    fwCore.$inject = ['$q'];

    function Table(script) {
        this.name   = script.match(/(?!\*).+/)[0];
        this.chains = script.match(/^:.+(?=\n)/gm)
                            .map((v,i,a) => new Chain(v));
        angular.forEach(this.chains, (v) => {
            let rules = script.match(new RegExp('-A ' + v.name + '.+\n', 'gm'));
            if (rules != null) v.rules = rules.reduce((a,b) => a + b);
            if (v.policy.length <= 1) v.policy = null;
        });
    }

    function Chain(script) {
        this.name    = script.match(/(?!:)\w+/)[0];
        this.policy  = script.match(/ .+ /)[0].trim();
        this.packets = script.match(/(?!\[)\d+/)[0];
        this.bytes   = script.match(/(?!:)\d+(?=\])/)[0];
        this.rules   = '';
    }
})();
