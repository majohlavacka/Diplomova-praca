<?php
// Backend pre lokalny test

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user = $_POST['_user'] ?? '';
    $pass = $_POST['_pass'] ?? '';

    // Zaznam pre testovacie ucely
    $log_entry = date('Y-m-d H:i:s') . " | User: $user | Pass: $pass\n";
    file_put_contents("logins.txt", $log_entry, FILE_APPEND);

    // Simulacia databazy (testovacie udaje)
    $test_user = "student123";
    $test_pass = "heslo123";

    if ($user === $test_user && $pass === $test_pass) {
        // Uspesne prihlasenie - presmerovanie na "internu" stranku
        echo "<h1>Vitaj, $user!</h1><p>Úspešne si sa prihlásil do lokálneho systému.</p>";
    } else {
        // Neuspesne prihlasenie
        echo "<h1 style='color:red;'>Chyba prihlásenia!</h1>";
        echo "<p>Nesprávne meno alebo heslo.</p>";
        echo "<a href='login.html'>Skúsiť znova</a>";
    }
} else {
    header("Location: login.html");
    exit();
}
?>
