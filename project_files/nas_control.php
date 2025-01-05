<?php
$configFile = '/usr/local/etc/devices.conf';

function parseConfig($configFile) {
    $devices = [];
    $currentDevice = null;

    foreach (file($configFile) as $line) {
        $line = trim($line);
        if (empty($line) || $line[0] === ';' || $line[0] === '#') {
            continue;
        }
        if ($line[0] === '[' && $line[-1] === ']') {
            $currentDevice = substr($line, 1, -1);
        } elseif ($currentDevice !== null) {
            list($key, $value) = explode('=', $line, 2);
            $devices[$currentDevice][trim($key)] = trim($value);
        }
    }

    return $devices;
}

if (!isset($_GET['action']) || !isset($_GET['device'])) {
    http_response_code(400);
    echo "Invalid request. Parameters 'action' and 'device' are required.";
    exit;
}

$action = $_GET['action'];
$deviceName = $_GET['device'];
$devices = parseConfig($configFile);

if (!isset($devices[$deviceName])) {
    http_response_code(404);
    echo "Device not found: $deviceName";
    exit;
}

$device = $devices[$deviceName];

// Construire la commande pour appeler le script bash
$scriptPath = '/usr/local/bin/nas_changestate.sh';
$command = escapeshellcmd("$scriptPath $action --device=$deviceName");

// Exécuter la commande et capturer la sortie
$output = [];
$return_var = 0;
exec($command, $output, $return_var);

if ($return_var == 0) {
    echo "Action executed successfully: $action for device: $deviceName. Output : ".implode("\n", array_map('htmlspecialchars', $output));
} else {
    http_response_code(500);
    echo "Failed to execute action: $action for device: $deviceName. Command : $command";
}
?>
