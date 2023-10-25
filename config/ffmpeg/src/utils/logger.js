//setup custom logger
const { createLogger, format, transports } = require('winston');
const { combine, timestamp, label, printf } = format;

const logFormat = printf(({ level, message, label, timestamp }) => {
  return `${timestamp} ${level.toUpperCase()}: ${message}`;
});

module.exports = createLogger({
  format: combine(    
    timestamp(),
    logFormat
  ),
  transports: [new transports.Console({
    level: process.env.LOG_LEVEL || 'info'
  })]
});
