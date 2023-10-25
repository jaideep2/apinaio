var express = require('express')
const ffmpeg = require('fluent-ffmpeg');

const constants = require('../constants.js');
const logger = require('../utils/logger.js')
const utils = require('../utils/utils.js')

var router = express.Router()


//routes for /convert
//adds conversion type and format to res.locals. to be used in final post function
router.post('/audio/to/mp3', function (req, res,next) {

    res.locals.conversion="audio";
    res.locals.format="mp3";
    return convert(req,res,next);
});

router.post('/audio/to/wav', function (req, res,next) {

    res.locals.conversion="audio";
    res.locals.format="wav";
    return convert(req,res,next);
});

router.post('/video/to/mp4', function (req, res,next) {

    res.locals.conversion="video";
    res.locals.format="mp4";
    return convert(req,res,next);
});

router.post('/image/to/jpg', function (req, res,next) {

    res.locals.conversion="image";
    res.locals.format="jpg";
    return convert(req,res,next);
});

// convert audio or video or image to mp3 or mp4 or jpg
function convert(req,res,next) {
    let format = res.locals.format;
    let conversion = res.locals.conversion;
    logger.debug(`path: ${req.path}, conversion: ${conversion}, format: ${format}`);

    let ffmpegParams ={
        extension: format
    };
    if (conversion == "image")
    {
        ffmpegParams.outputOptions= ['-pix_fmt yuv422p'];
    }
    if (conversion == "audio")
    {
        if (format === "mp3")
        {
            ffmpegParams.outputOptions=['-codec:a libmp3lame' ];
        }
        if (format === "wav")
        {
            ffmpegParams.outputOptions=['-codec:a pcm_s16le' ];
        }
    }
    if (conversion == "video")
    {
        ffmpegParams.outputOptions=[
            '-codec:v libx264',
            '-profile:v high444',
            '-r 15',
            '-crf 23',
            '-preset ultrafast',
            '-b:v 500k',
            '-maxrate 500k',
            '-bufsize 1000k',
            '-vf scale=-2:640',
            '-threads 8',
            '-codec:a libfdk_aac',
            '-b:a 128k',
        ];
    }

    let savedFile = res.locals.savedFile;
    let outputFile = savedFile + '-output.' + ffmpegParams.extension;
    logger.debug(`begin conversion from ${savedFile} to ${outputFile}`)

    //ffmpeg processing... converting file...
    let ffmpegConvertCommand = ffmpeg(savedFile);
    ffmpegConvertCommand
            .renice(constants.defaultFFMPEGProcessPriority)
            .outputOptions(ffmpegParams.outputOptions)
            .on('error', function(err) {
                logger.error(`${err}`);
                utils.deleteFile(savedFile);
                res.writeHead(500, {'Connection': 'close'});
                res.end(JSON.stringify({error: `${err}`}));
            })
            .on('end', function() {
                utils.deleteFile(savedFile);
                return utils.downloadFile(outputFile,null,req,res,next);
            })
            .save(outputFile);
        
}

module.exports = router
