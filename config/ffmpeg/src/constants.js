
exports.fileSizeLimit = parseInt(process.env.FILE_SIZE_LIMIT_BYTES || "536870912"); //536870912 = 512MB 
exports.defaultFFMPEGProcessPriority=10;
exports.serverPort = 3000;//port to listen, NOTE: if using Docker/Kubernetes this port may not be the one clients are using
exports.externalPort = process.env.EXTERNAL_PORT;//external port that server listens, set this if using for example docker container and binding port is other than 3000
exports.keepAllFiles = process.env.KEEP_ALL_FILES || "false"; //if true, do not delete any uploaded/generated files
