/**
 * navigationdrawer.js
 */
'use strict';

angular.module('fwfe.navigationDrawer', ['fwfe.fwcore'])
    .component('navigationdrawer', {
        controller: navigationdrawerCtrl,
        templateUrl: 'components/navigationdrawer/navigationdrawer-directive.html'
    });

function navigationdrawerCtrl($rootScope, navigationDrawer, fwCore) {
    let navigate  = (callback) => (arg) => navigationDrawer.close() && callback(arg);
    this.tables   = fwCore.getTables();
    this.setTable = navigate((name) => $rootScope.$emit('setTable', name));
    this.import   = navigate(fwCore.import);
    this.export   = navigate(fwCore.export);
}
navigationdrawerCtrl.$inject = ['$rootScope', 'navigationDrawer', 'fwCore'];
