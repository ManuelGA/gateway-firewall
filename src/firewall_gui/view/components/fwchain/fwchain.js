/**
 * fwchain.js
 */
'use strict';

angular.module('fwfe.fwchain', ['fwfe.navigationDrawer'])
    .component('fwchain', {
        controller: fwchainCtrl,
        templateUrl: 'components/fwchain/fwchain-directive.html',
        bindings: {
            table: '=',
            view: '&'
        }
    });

function fwchainCtrl(navigationDrawer) {
    this.check = () => console.log(this.table);

    this.builtInChain = chain => chain.policy != null;
    this.userChain    = chain => chain.policy == null;
    this.toggleSideNav = navigationDrawer.toggle;
    this.save = () => console.log(this.table);
}
fwchainCtrl.$inject = ['navigationDrawer'];
