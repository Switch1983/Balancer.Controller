const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
 
const { abi, evm } = require('../compile');

let bondingCurveController;
let accounts;

const testRatio = 25;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();
    bondingCurveController = await new web3.eth.Contract(abi)
    .deploy({
      data: evm.bytecode.object,
      arguments: ['0x95A621509071026ae5e40869698D72c74436176a']
    })
    .send({ from: accounts[0], gas: '2000000' });
})

describe('Bonding Curve Controller Contract', () => {
    it('deploys a contract', () => {
        assert.ok(bondingCurveController.options.address);
    })

    /*
    it('set ratio for a managed pool', async () => {
        await bondingCurveController.methods.setReserveRatio(accounts[0], testRatio).send({
            from: accounts[0]
        });

        const ratio = await bondingCurveController.methods.getManagedPoolRatio(accounts[0]).call({
            from: accounts[0]
        });

        assert.equal(ratio, testRatio);
    });
*/

    it('runs a check that transfers 1 token', async () => {
        const amountTransferred = await bondingCurveController.methods.runCheck(accounts[0]).call({
            from: accounts[0]
        });

        assert.equal(amountTransferred, 1);
    });

    it('only manager can set a reserve ratio', async () => {
        try {
            await bondingCurveController.methods.setReserveRatio(accounts[1], testRatio).send({
                from: accounts[1],
            });
            assert(false);
        } catch (err) {
            assert(err);
        }
    });

    it('transfers management', async () => {
            await bondingCurveController.methods.transferManagement(accounts[1]).send({
                from: accounts[0]
            });
            
            const manager = await bondingCurveController.methods.manager().call({
                from: accounts[1]
            });
    
            assert.equal(accounts[1], manager);
    });
});
