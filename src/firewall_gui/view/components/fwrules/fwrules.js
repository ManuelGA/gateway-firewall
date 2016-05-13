/**
 * fwrules.js
 */
'use strict';

angular.module('fwfe.fwrules', ['ngMaterial', 'fwfe.fwcore'])
    .component('fwrules', {
        templateUrl: 'components/fwrules/fwrules-directive.html',
        controller: fwrulesCtrl,
        bindings: {
            chain: '=',
            view: '&'
        }
    });

function fwrulesCtrl($mdToast, fwCore) {
    this.save = () => {
        fwCore.export()
              .then(() => $mdToast.showSimple('Rules saved'));
    };
    this.newRule = () => {
        let rule = '';
        rule += `-A ${this.chain.name} -p ${this.form.protocol}`
              + (this.form.protocol === 'icmp'
                  ? ` --icmp-type ${this.form.port}`
                  : ` ${this.form.direction === 'out' ? '--sport' : '--dport'} ${this.form.port}`)
              + ` -m state --state ${this.form.direction === 'out' ? 'ESTABLISHED' : 'NEW,ESTABLISHED'}`
              + ` -i ${this.form.gatewayinterface}`
              + ` -o ${this.form.networkinterface}`
              + ` -j ${this.form.permission}\n`;
        rule += `-A ${this.chain.name} -p ${this.form.protocol}`
              + (this.form.protocol === 'icmp'
                  ? ` --icmp-type ${this.form.port}`
                  : ` ${this.form.direction === 'in' ? '--sport' : '--dport'} ${this.form.port}`)
              + ` -m state --state ${this.form.direction === 'in' ? 'ESTABLISHED' : 'NEW,ESTABLISHED'}`
              + ` -i ${this.form.gatewayinterface}`
              + ` -o ${this.form.networkinterface}`
              + ` -j ${this.form.permission}\n`;
        this.chain.rules = rule + this.chain.rules;

        let routing = `-t nat -A PREROUTING`
                    + (this.form.protocol === 'icmp'
                        ? ` --icmp-type ${this.form.port}`
                        : ` ${this.form.direction === 'out' ? '--sport' : '--dport'} ${this.form.port}`)
                    + ` -j DNAT --to ${this.form.ipaddress}:${this.form.port}`;
        angular.forEach(fwCore.getTables()['nat'].chains, (chain) => {
            if (chain.name === 'PREROUTING') chain.rules = routing + chain.rules;
        });
        $mdToast.showSimple('New rule created');
    };
}
fwrulesCtrl.$inject = ['$mdToast', 'fwCore'];
