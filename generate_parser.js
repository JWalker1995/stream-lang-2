let fs = require('fs-promise');
let path = require('path');
let child_process = require('child-process-promise');

let config = require('./config.js');

module.exports = async function() {
    // Make sure the cache directory exists
    await fs.mkdir(config.cache_dir).catch(function(err) {
        if (err.code !== 'EEXIST') {throw err;}
    });

    // Copies the g4 file into the cache directory
    let cache_g4_path = path.resolve(config.cache_dir, 'Stream.g4');
    await fs.copy(config.g4_path, cache_g4_path);

    // Prepare options to the antlr compiler that generates the antlr lexer and antlr parser
    let cmd = 'java';
    let args = [
        '-Xmx500M',
        '-cp', '../bin/antlr-4.6-complete.jar',
        'org.antlr.v4.Tool',
        '-long-messages',
        '-no-listener',
        '-no-visitor',
        '-Dlanguage=JavaScript',
        'Stream.g4',
    ];
    let opts = {
        'cwd': config.cache_dir,
        'stdio': ['ignore', process.stdout, process.stderr],
    };

    // Call antlr
    await child_process.spawn(cmd, args, opts);
};

module.exports().catch(function(err) {
    setTimeout(function() {
        throw err;
    }, 0);
});
