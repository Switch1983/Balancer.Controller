const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
 
const { abi, evm } = require('../compile');

let reserveRatioController;
let accounts;

const testRatio = 25;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();
    reserveRatioController = await new web3.eth.Contract(abi)
    .deploy({
      data: evm.bytecode.object,
      arguments: [1]
    })
    .send({ from: accounts[0], gas: '2000000' });
})

describe('Bonding Curve Controller Contract', () => {
    it('deploys a contract', () => {
        assert.ok(reserveRatioController.options.address);
    })

    it('set ratio for a managed pool', async () => {
        await reserveRatioController.methods.setReserveRatio(accounts[0], testRatio).send({
            from: accounts[0]
        });

        const ratio = await reserveRatioController.methods.getManagedPoolRatio(accounts[0]).call({
            from: accounts[0]
        });

        assert.equal(ratio, testRatio);
    });

    it('runs a check that transfers 1 token', async () => {
        const amountTransferred = await reserveRatioController.methods.runCheck(accounts[0]).call({
            from: accounts[0]
        });

        assert.equal(amountTransferred, 1);
    });

    it('only manager can set a reserve ratio', async () => {
        try {
            await reserveRatioController.methods.setReserveRatio(accounts[1], testRatio).send({
                from: accounts[1],
            });
            assert(false);
        } catch (err) {
            assert(err);
        }
    });

    it('transfers management', async () => {
            await reserveRatioController.methods.transferManagement(accounts[1]).send({
                from: accounts[0]
            });
            
            const manager = await reserveRatioController.methods.manager().call({
                from: accounts[1]
            });
    
            assert.equal(accounts[1], manager);
    });
});