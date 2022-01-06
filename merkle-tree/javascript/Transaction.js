const { sha256 } = require('./Utils')

class Transaction {
    constructor(id, amount, balance, timestamp) {
        this.id = id
        this.amount = amount
        this.balance = balance
        this.timestamp = timestamp

        this.hash = this.getHash()
    }

    getHash() {
        const { id, amount, balance, timestamp } = this
        const t = { id, amount, balance, timestamp }
        return sha256(JSON.stringify(t))
    }

    toJson() {
        const { id, amount, balance, timestamp } = this
        return { id, amount, balance, timestamp }
    }
}

module.exports = Transaction



