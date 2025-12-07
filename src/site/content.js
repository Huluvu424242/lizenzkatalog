async function loadFileList() {
    try {
        // content.txt laden
        const response = await fetch('content.txt');
        if (!response.ok) {
            throw new Error(`Fehler beim Laden der Datei: ${response.status}`);
        }

        // Inhalt lesen
        const text = await response.text();

        // In Zeilen aufteilen, leere Zeilen entfernen
        const lines = text
            .split(/\r?\n/)
            .map(line => line.trim())
            .filter(line => line.length > 0);

        // OL-Element im HTML finden oder neu erzeugen
        const listContainer = document.getElementById('fileList') || document.body.appendChild(document.createElement('ol'));

        // Vorhandene Inhalte leeren
        listContainer.innerHTML = '';

        // Für jede Zeile einen Listeneintrag mit Link erstellen
        for (const licenseName of lines) {
            const li = document.createElement('li');
            const a = document.createElement('a');
            a.href = licenseName + ".tei.xml";      // Link-Ziel
            a.textContent = licenseName; // sichtbarer Text
            li.appendChild(a);
            listContainer.appendChild(li);
        }
    } catch (error) {
        console.error('Fehler beim Laden der Dateiliste:', error);
    }
}
