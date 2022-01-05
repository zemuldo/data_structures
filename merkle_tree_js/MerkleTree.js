const { sha256, getNumNextNodes} = require('./Utils')

class MerkleTree {
    constructor(block) {
        this.tree = []
        this.block = block
        this.tree.unshift(this.hashTransactions())
        this.createTree()
    }

    createTree() {
        while (this.tree[0].length > 1) {
            const nextLevelNodes = []
            
            for (let i = 0; i < this.tree[0].length; i += 2){
                if (!this.tree[0][i + 1]) {
                    nextLevelNodes.push(this.tree[0][i])
                } else {
                    const hash = sha256(this.tree[0][i] + this.tree[0][i + 1] || this.tree[0][i])
                    nextLevelNodes.push(hash)
                }
            }
            this.tree.unshift(nextLevelNodes)
        }
    }

    verifyTransaction(transaction) {
        let currentHash = transaction.getHash()
        
        let position = this.tree.slice(-1)[0].findIndex(hash => hash === currentHash)
        if (position < 0) {
            for (let level = this.tree.length - 1; level >= 0; level--) {
                if (position % 2 === 0) {
                    const pairHash = this.tree[level][position + 1]
                    currentHash = pairHash ? sha256(currentHash + pairHash) : currentHash
                    position = position / 2
                }
                else {
                    const pairHash = this.tree[level][position - 1]
                    currentHash = sha256(pairHash + currentHash)
                    position = (position - 1) / 2
                }
            }
        }
        
        if (currentHash === this.tree[0][0]) console.log('Taransaction Valid')
        else console.log('Transaction NOT Valid')
    }

    hashTransactions() {
        return this.block.transactions.map(t => t.hash)
    }
}

module.exports = MerkleTree