/* eslint-disable no-console */
import express from "express";
import cors from "cors";
import bodyParser from "body-parser";

import { fileURLToPath } from 'url';
import { dirname } from 'path';
import { default as fsPath } from "node:path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();

// To assure Cross-Origin-Opener-Policy and Cross-Origin-Embedder-Policy headers are set this app.use must be before any routes,
// including the static file serving middleware.
app.use( ( req, res, next ) => {
	res.setHeader( "Cross-Origin-Opener-Policy", "same-origin" );
	res.setHeader( "Cross-Origin-Embedder-Policy", "require-corp" ); // Or 'credentialless' based on your needs
	next();
} );

app.use(express.static(fsPath.join(__dirname, '.')));
app.use(express.static(fsPath.join(__dirname, './bin_pt/dbg')));
app.use('/node_modules', express.static(fsPath.join(__dirname, 'node_modules')));
app.use( cors() );
app.use( bodyParser.json( { limit: "5mb" } ) );

// Redirect the root path to pt_bin/dbg/my.html
app.get('/', (req, res) => {
    res.redirect('/bin_pt/dbg/my.html');
});


//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
const PORT = process.env.PORT || 8088;

// eslint-disable-next-line no-unused-vars
const server = app.listen( PORT, () => {
    console.log( `%cExpress HTTP server is listening on http://localhost:${PORT}`, "color: green" );
} );
