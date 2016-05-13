/**
 * fwtable.js
 */
'use strict';

angular.module('fwfe.fwtable', [
        'fwfe.fwcore',
        'fwfe.fwchain',
        'fwfe.fwrules',
    ])
    .component('fwtable', {
        controller: fwtableCtrl,
        templateUrl: 'components/fwtable/fwtable-directive.html'
    });

function fwtableCtrl($rootScope, $scope, fwCore) {
    this.form = {
        iptSave:    '/sbin/iptables-save',
        iptRestore: '/sbin/iptables-restore'
    };
    this.viewMode      = '';
    this.selectedChain = null;
    this.table         = null;
    this.tables        = fwCore.getTables();
    this.importTables  = () => {
        fwCore.setImportCmd(this.form.iptSave);
        fwCore.setExportCmd(this.form.iptRestore);
        fwCore.import()
              .then(() => {
                  this.viewMode = 'chain';
                  this.table = this.tables['filter'];
              });
    }
    this.viewRules = (chain) => {
        this.viewMode = 'rules';
        this.selectedChain = chain;
    };
    this.viewChains = () => {
        this.viewMode = 'chain';
        this.selectedChain = null;
    };
    let rmUpdate = $rootScope.$on('setTable', (_, name) => {
        this.viewMode = 'chain';
        this.table = this.tables[name];
    });
    $scope.$on('$destroy', rmUpdate);
}
fwtableCtrl.$inject = ['$rootScope', '$scope', 'fwCore'];
