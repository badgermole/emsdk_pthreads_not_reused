if ( globalThis?.document ) {
    // This will be called on completion/exit of the pthread function
    globalThis.settlePromise = ( promiseId, succeeded, response ) => {
        console.log( `Succeeded: ${succeeded ? 'true' : 'false'}, Response: ${response}` );
    }

    // Set up "Exec" buttons to exec the bound C++ method
    globalThis.document.addEventListener( 'DOMContentLoaded', function () {
        const button1 = globalThis.document.createElement( 'button' );
        button1.textContent = 'Exec 1 pthread';
        button1.onclick = function () {
            Module[ 'getVersionAsync' ]( 0 );
        };

        const button8 = globalThis.document.createElement( 'button' );
        button8.textContent = 'Exec 8 pthreads';
        button8.onclick = function () {
            const maxThreads = 8;
            for ( let i = 0; i < maxThreads; i++ ) {
                Module[ 'getVersionAsync' ]( i );
            }
        };


        // Add buttons to the canvas container or other element
        globalThis.document.getElementById( 'controls' ).appendChild( button1 );
        globalThis.document.getElementById( 'controls' ).appendChild( button8 );
    } );
}
