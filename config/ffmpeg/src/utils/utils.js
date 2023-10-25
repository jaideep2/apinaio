const fs = require('fs');
const logger = require('./logger.js')
const constants = require('../constants.js');

function deleteFile (filepath) {
    if (constants.keepAllFiles === "false")
    {
        fs.unlinkSync(filepath);
        logger.debug(`deleted ${filepath}`);
    }
    else
    {
        logger.debug(`NOT deleted ${filepath}`);
    }
}

function downloadFile (filepath,filename,req,res,next) {

    logger.debug(`starting download to client. file: ${filepath}`);

    res.download(filepath, filename, function(err) {
        if (err) {
            logger.error(`download error: ${err}`);
            return next(err);
        }
        else
        {
            logger.debug(`download complete ${filepath}`);
            let doDelete = req.query.delete || "true";
            //delete file if doDelete is true
            if (doDelete === "true" || doDelete === "yes")
            {
                deleteFile(filepath);
            }
        }
    });

}


module.exports = {
    deleteFile,
    downloadFile
}