const { createHash } = require('crypto')

const sha256 = (data) => {
   return createHash("sha256")
        .update(data)
        .digest("hex")
}

const getNumNextNodes = (children) => {
    if (children % 2 === 0) return children / 2
    else return (children + 1)
}

module.exports = { sha256, getNumNextNodes }