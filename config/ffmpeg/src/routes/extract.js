var express = require('express')
const fs = require('fs');
const ffmpeg = require('fluent-ffmpeg');
const uniqueFilename = require('unique-filename');
var archiver = require('archiver');

const constants = require('../constants.js');
const logger = require('../utils/logger.js');
const utils = require('../utils/utils.js');

var router = express.Router();


//routes for /video/extract
//extracts audio from video
//extracts images from vide
router.post('/audio', function (req, res,next) {

    res.locals.extract="audio"
    return extract(req,res,next);
});

router.post('/images', function (req, res,next) {

    res.locals.extract="images"
    return extract(req,res,next);
});

router.get('/download/:filename', function (req, res,next) {
    //download extracted image
    let filename = req.params.filename;
    let file = `/tmp/${filename}`
    return utils.downloadFile(file,null,req,res,next);
});

// extract audio or images from video
function extract(req,res,next) {
    let extract = res.locals.extract;
    logger.debug(`extract ${extract}`);
    
    let fps = req.query.fps || 1;
    //compress = zip or gzip
    let compress = req.query.compress || "none";
    let preset = req.query.preset || "default";
    let ffmpegParams ={};
    var format = "png";
    if (extract === "images"){
        format = "png"
        ffmpegParams.outputOptions=[];
        switch (preset) {
            case "1":
                ffmpegParams.outputOptions.push(`-vf fps=${fps},scale=720:400:force_original_aspect_ratio=decrease`);
                ffmpegParams.outputOptions.push(`-f image2`);
                break;
            default:
                ffmpegParams.outputOptions.push(`-vf fps=${fps}`);
        }
    }
    if (extract === "audio"){
        format = "wav"
        ffmpegParams.outputOptions=[
            '-vn',
            `-f ${format}` 
        ];    
        let monoAudio = req.query.mono || "yes";
        if (monoAudio === "yes" || monoAudio === "true")
        {
            logger.debug("extracting audio, 1 channel only")
            ffmpegParams.outputOptions.push('-ac 1')
        }
        else{
            logger.debug("extracting audio, all channels")
        }
    }

    ffmpegParams.extension = format;

    let savedFile = res.locals.savedFile;

    var outputFile = uniqueFilename('/tmp/') ;
    logger.debug(`outputFile ${outputFile}`);
    var uniqueFileNamePrefix = outputFile.replace("/tmp/","");
    logger.debug(`uniqueFileNamePrefix ${uniqueFileNamePrefix}`);

    //ffmpeg processing...
    var ffmpegCommand = ffmpeg(savedFile);
    ffmpegCommand = ffmpegCommand
            .renice(constants.defaultFFMPEGProcessPriority)
            .outputOptions(ffmpegParams.outputOptions)
            .on('error', function(err) {
                logger.error(`${err}`);
                utils.deleteFile(savedFile);
                res.writeHead(500, {'Connection': 'close'});
                res.end(JSON.stringify({error: `${err}`}));
            })

    //extract audio track from video as wav
    if (extract === "audio"){
        let wavFile = `${outputFile}.${format}`;
        ffmpegCommand
            .on('end', function() {
                logger.debug(`ffmpeg process ended`);

                utils.deleteFile(savedFile)
                return utils.downloadFile(wavFile,null,req,res,next);
            })
          .save(wavFile);
        
        }

    //extract png images from video
    if (extract === "images"){
        ffmpegCommand
            .output(`${outputFile}-%04d.png`)
            .on('end', function() {
                logger.debug(`ffmpeg process ended`);

                utils.deleteFile(savedFile)

                //read extracted files
                var files = fs.readdirSync('/tmp/').filter(fn => fn.startsWith(uniqueFileNamePrefix));
                
                if (compress === "zip" || compress === "gzip")
                {
                    //do zip or tar&gzip of all images and download file
                    var archive = null;
                    var extension = "";
                    if (compress === "gzip") {
                        archive = archiver('tar', {
                            gzip: true,
                            zlib: { level: 9 } // Sets the compression level.
                        });
                        extension = "tar.gz";
                    }
                    else {
                        archive = archiver('zip', {
                            zlib: { level: 9 } // Sets the compression level.
                        });
                        extension = "zip";
                    }

                    let compressFileName = `${uniqueFileNamePrefix}.${extension}`
                    let compressFilePath = `/tmp/${compressFileName}`
                    logger.debug(`starting ${compress} process ${compressFilePath}`);
                    var compressFile = fs.createWriteStream(compressFilePath);

                    archive.on('error', function(err) {
                      return next(err);
                    });
                    
                    // pipe archive data to the output file
                    archive.pipe(compressFile);
                    
                    // add files to archive
                    for (var i=0; i < files.length; i++) {
                        var file = `/tmp/${files[i]}`;
                        archive.file(file, {name: files[i]});
                    }
                    
                    // listen for all archive data to be written
                    // 'close' event is fired only when a file descriptor is involved
                    compressFile.on('close', function() {
                        logger.debug(`${compressFileName}: ${archive.pointer()} total bytes`);
                        logger.debug('archiver has been finalized and the output file descriptor has closed.');

                        // delete all images
                        for (var i=0; i < files.length; i++) {
                            var file = `/tmp/${files[i]}`;
                            utils.deleteFile(file);
                        }

                        //return compressed file
                        return utils.downloadFile(compressFilePath,compressFileName,req,res,next);

                    });
                    // Wait for streams to complete
                    archive.finalize();

                }
                else
                {
                    //return JSON list of extracted images

                    logger.debug(`output files in /tmp`);
                    var responseJson = {};
                    let externalPort = constants.externalPort || constants.serverPort;
                    responseJson["totalfiles"] = files.length;
                    responseJson["description"] = `Extracted image files and URLs to download them. By default, downloading image also deletes the image from server. Note that port ${externalPort} in the URL may not be the same as the real port, especially if server is running on Docker/Kubernetes.`;
                    var filesArray=[];
                    for (var i=0; i < files.length; i++) {
                        var file = files[i];             
                        logger.debug("file: " + file);
                        var fileJson={};
                        fileJson["name"] = file;
                        fileJson[`url`] = `${req.protocol}://${req.hostname}:${externalPort}${req.baseUrl}/download/${file}`;
                        filesArray.push(fileJson);                    
                    }             
                    responseJson["files"] = filesArray;
                    res.status(200).send(responseJson);

                }
            })
            .run();

    }

}

module.exports = router
