const MerkleTree = require("./MerkleTree")

class Block {
    constructor() {
        this.merkeRoot = null
        this.transactions = []
        this.transactionCount = 0
    }

    addTransaction(t) {
        this.transactions.push(t)
        this.transactionCount += 1
    }

    verify() {
        const merkleTree = new MerkleTree(this)

        if (merkleTree.tree[0][0] === this.merkeRoot) console.log('Block Consistent')
        else console.log('Block Inconsistent')
    }
}

module.exports = Block