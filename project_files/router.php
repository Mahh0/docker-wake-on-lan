<?php
// Redirection si la racine est appelée
$request_uri = $_SERVER['REQUEST_URI'];
if ($request_uri === '/' || $request_uri === '/index.php') {
    // Rediriger la requête vers index.php
    $_SERVER['SCRIPT_NAME'] = '/index.php';
    $_SERVER['SCRIPT_FILENAME'] = __DIR__ . '/index.php';
}

// Traiter les requêtes statiques normalement (images, CSS, JavaScript, etc.)
if (preg_match('/\.(?:png|jpg|jpeg|gif|css|js)$/', $_SERVER['REQUEST_URI'])) {
    return false;    // Serve the requested resource as-is.
}

// Inclure le fichier PHP correspondant
require $_SERVER['SCRIPT_FILENAME'];
?>
