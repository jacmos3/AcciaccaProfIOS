<?php
// Simple support ticket page (stores tickets as .txt files in /web/tickets)

$ticketsDir = __DIR__ . '/tickets';
if (!is_dir($ticketsDir)) {
    mkdir($ticketsDir, 0755, true);
}

$errors = [];
$success = false;

function field($name) {
    return htmlspecialchars($_POST[$name] ?? '', ENT_QUOTES, 'UTF-8');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $subject = trim($_POST['subject'] ?? '');
    $message = trim($_POST['message'] ?? '');
    $reason = trim($_POST['reason'] ?? '');
    $reasonOther = trim($_POST['reason_other'] ?? '');

    if ($name === '') { $errors[] = 'Inserisci il nome.'; }
    if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) { $errors[] = 'Inserisci una email valida.'; }
    if ($subject === '') { $errors[] = 'Inserisci un oggetto.'; }
    if ($message === '') { $errors[] = 'Inserisci il messaggio.'; }
    if ($reason === '') { $errors[] = 'Seleziona una motivazione.'; }
    if ($reason === 'Altro' && $reasonOther === '') { $errors[] = 'Specifica la motivazione.'; }

    if (!$errors) {
        $id = date('Ymd_His') . '_' . bin2hex(random_bytes(4));
        $file = $ticketsDir . '/ticket_' . $id . '.txt';
        $body = [];
        $body[] = "Ticket ID: " . $id;
        $body[] = "Data: " . date('Y-m-d H:i:s');
        $body[] = "Nome: " . $name;
        $body[] = "Email: " . $email;
        $body[] = "Oggetto: " . $subject;
        $body[] = "Motivazione: " . ($reason === 'Altro' ? "Altro - $reasonOther" : $reason);
        $body[] = "Messaggio:";
        $body[] = $message;
        $bodyText = implode("\n", $body) . "\n";

        if (file_put_contents($file, $bodyText) !== false) {
            $success = true;
        } else {
            $errors[] = 'Errore nel salvataggio del ticket. Riprova.';
        }
    }
}
?>
<!doctype html>
<html lang="it">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Supporto Acciacca Prof</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #f2f2f2; color: #222; }
        .wrap { max-width: 720px; margin: 30px auto; background: #fff; padding: 24px; border-radius: 12px; box-shadow: 0 6px 20px rgba(0,0,0,0.08); }
        h1 { margin-top: 0; }
        label { display: block; margin-top: 12px; font-weight: 600; }
        input, textarea, select { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 8px; margin-top: 6px; }
        textarea { min-height: 120px; resize: vertical; }
        .row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .actions { margin-top: 16px; display: flex; gap: 10px; }
        .btn { background: #1f6feb; color: #fff; border: none; padding: 10px 16px; border-radius: 8px; font-weight: 600; cursor: pointer; }
        .btn-secondary { background: #6c757d; }
        .alert { padding: 12px; border-radius: 8px; margin: 12px 0; }
        .alert-success { background: #e6f4ea; color: #0f5132; }
        .alert-error { background: #f8d7da; color: #842029; }
        .note { color: #666; font-size: 0.9em; }
        @media (max-width: 640px) { .row { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div class="wrap">
        <h1>Supporto Acciacca Prof</h1>
        <p class="note">Compila il modulo per aprire un ticket di assistenza.</p>

        <?php if ($success): ?>
            <div class="alert alert-success">
                ✅ Ticket inviato con successo. Ti risponderemo al più presto.
            </div>
        <?php elseif ($errors): ?>
            <div class="alert alert-error">
                <strong>Errore:</strong>
                <ul>
                    <?php foreach ($errors as $err): ?>
                        <li><?= htmlspecialchars($err, ENT_QUOTES, 'UTF-8') ?></li>
                    <?php endforeach; ?>
                </ul>
            </div>
        <?php endif; ?>

        <form method="post" action="">
            <div class="row">
                <div>
                    <label for="name">Nome</label>
                    <input type="text" id="name" name="name" value="<?= field('name') ?>" required>
                </div>
                <div>
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" value="<?= field('email') ?>" required>
                </div>
            </div>

            <label for="subject">Oggetto</label>
            <input type="text" id="subject" name="subject" value="<?= field('subject') ?>" required>

            <label for="reason">Motivazione</label>
            <select id="reason" name="reason" required>
                <?php
                $options = [
                    "Problema tecnico",
                    "Acquisti in‑app",
                    "Personalizzazioni",
                    "Segnalazione bug",
                    "Altro"
                ];
                $selected = field('reason');
                ?>
                <option value="">Seleziona...</option>
                <?php foreach ($options as $opt): ?>
                    <option value="<?= $opt ?>" <?= $selected === $opt ? 'selected' : '' ?>><?= $opt ?></option>
                <?php endforeach; ?>
            </select>

            <label for="reason_other">Altro (specifica)</label>
            <input type="text" id="reason_other" name="reason_other" value="<?= field('reason_other') ?>">

            <label for="message">Messaggio</label>
            <textarea id="message" name="message" required><?= field('message') ?></textarea>

            <div class="actions">
                <button class="btn" type="submit">Invia ticket</button>
                <button class="btn btn-secondary" type="reset">Reset</button>
            </div>
        </form>
    </div>
</body>
</html>
