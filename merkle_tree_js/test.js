const { assert } = require("console");
const Block = require("./Block");
const MerkleTree = require("./MerkleTree");
const Transaction = require("./Transaction");

const baseDate = new Date('2021-01-05T20:23:06.518Z');

const block = new Block()

for (let i = 0; i < 11; i++){
    const entropy = i+1
    const t = new Transaction(entropy, entropy * 100, entropy * 200, baseDate.setHours(baseDate.getHours() + 4))
    block.addTransaction(t)
}

const merkleTree = new MerkleTree(block)
block.merkeRoot = merkleTree.tree[0][0]

// merkleTree.verifyTransaction(block.transactions[9])
// block.verify()

block.transactions[9].balance = 30000

merkleTree.verifyTransaction(block.transactions[9])
// block.verify()