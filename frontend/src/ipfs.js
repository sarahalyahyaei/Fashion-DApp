//To connect to ipfs

const IPFS = require('ipfs-api');
//We can host it locally
const ipfs = new IPFS({host: 'ipfs.infura.io', post: 5001, protcol: 'https'});


export default ipfs;
