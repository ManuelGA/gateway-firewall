/**
 * navigationdrawer-service.js
 */
'use strict';

angular.module('fwfe.navigationDrawer')
    .service('navigationDrawer', navigationDrawer);

function navigationDrawer($mdSidenav) {
    const NAVIGATION_DRAWER_ID = 'navigationdrawer';
    this.toggle = () => $mdSidenav(NAVIGATION_DRAWER_ID).toggle();
    this.open   = () => $mdSidenav(NAVIGATION_DRAWER_ID).open();
    this.close  = () => $mdSidenav(NAVIGATION_DRAWER_ID).close();
}
navigationDrawer.$inject = ['$mdSidenav'];
