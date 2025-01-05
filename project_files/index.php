<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Contrôle des Appareils</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f7f9fc;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background-color: #fff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
            width: 400px;
            text-align: center;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        select {
            width: 100%;
            padding: 10px;
            margin-bottom: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .buttons {
            display: flex;
            justify-content: space-between;
        }
        button {
            flex: 1;
            padding: 10px 15px;
            color: #fff;
            background-color: #007BFF;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
            transition: background-color 0.3s ease;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
    <script>
        function showActions() {
            const deviceSelect = document.getElementById('device');
            const selectedValue = deviceSelect.options[deviceSelect.selectedIndex].value;
            if (selectedValue) {
                document.getElementById('actions').style.display = 'block';
                document.getElementById('deviceInput').value = selectedValue;
            } else {
                document.getElementById('actions').style.display = 'none';
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>Contrôle des Appareils</h1>
        <select name="device" id="device" onchange="showActions()">
            <option value="">-- Sélectionner un appareil --</option>
            <?php
            $configFile = '/usr/local/etc/devices.conf';
            $devices = [];
            $deviceNames = [];

            // Lire et analyser le fichier de configuration
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

            // Afficher les options d'appareils
            foreach ($devices as $deviceId => $deviceInfo) {
                $deviceName = isset($deviceInfo['name']) ? $deviceInfo['name'] : $deviceId;
                echo "<option value=\"$deviceId\">$deviceName ($deviceId)</option>";
            }
            ?>
        </select>

        <div id="actions" style="display: none;">
            <form method="GET" action="nas_control.php">
                <input type="hidden" name="device" id="deviceInput" value="">
                <div class="buttons">
                    <button type="submit" name="action" value="on"><i class="fas fa-power-off"></i> Allumer</button>
                    <button type="submit" name="action" value="off"><i class="fas fa-power-off"></i> Éteindre</button>
                    <button type="submit" name="action" value="getstatus"><i class="fas fa-info-circle"></i> Vérifier l'état</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
