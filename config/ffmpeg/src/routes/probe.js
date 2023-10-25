var express = require('express')
const ffmpeg = require('fluent-ffmpeg');

const logger = require('../utils/logger.js');
const utils = require('../utils/utils.js');

var router = express.Router();

//probe input file and return metadata
router.post('/', function (req, res,next) {

    let savedFile = res.locals.savedFile;
    logger.debug(`Probing ${savedFile}`);
    
    //ffmpeg processing...
    var ffmpegCommand = ffmpeg(savedFile)
    
    ffmpegCommand.ffprobe(function(err, metadata) {
        if (err)
        {
            next(err);            
        }
        else
        {
            utils.deleteFile(savedFile);        
            res.status(200).send(metadata);
        }
    
    });

});

module.exports = router