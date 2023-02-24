const BondingCurveController = artifacts.require("BondingCurveController");

contract('BondingCurveController', (accounts) => {

  let bondingCurveController;

  console.log("ACCOUNTS:");
  console.log(accounts);

  beforeEach(async () => {
    bondingCurveController = await BondingCurveController.deployed();
  })

  it('runs a check on adding one pool', async () => {
    await bondingCurveController.registerPool(accounts[0]);
    const managedPoolSet = (await bondingCurveController.managedPools.call(accounts[0]));
    assert.equal(managedPoolSet, true);
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
    await bondingCurveController.transferManagement(accounts[1]);
    const manager = (await bondingCurveController.manager.call());
    assert.equal(accounts[1], manager);
  });
});
