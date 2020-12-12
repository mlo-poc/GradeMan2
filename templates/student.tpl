<h1 id="title" onclick="location.reload()">{{ s['givenname'] }} {{ s['familyname'] }}</h1>
<nav id="pagenav">
    <a onclick="edit()">Bearbeiten</a>
</nav>
<div id="content">
    <p>Notizen:</p>
    <div style="width:100%; border:1px solid black;">
        {{ memo }}
    </div>
    {% if img == '' %}
        <p>[kein Bild Vorhanden]</p>
        <p><a href="../setStudentImg/{{ s['sid'] }}">Bild hinzufügen</a></p>
    {% else %}
        <img src="data:image/jpeg;base64,{{ img }}"/>
        <p><a href="../setStudentImg/{{ s['sid'] }}">Bild aktualisieren</a></p>
    {% endif %}
    {% if s['gender'] == 'male' %}
        <p>Geschlecht: &#9794;</p>
    {% elif s['gender'] == 'female' %}
        <p>Geschlecht: &#9792;</p>
    {% elif s['gender'] == 'other' %}
        <p>Geschlecht: &#9893;</p>
    {% else %}
        <p>Geschlecht: unbekannt</p>
    {% endif %}
    <p>
        Klassen:<ul>
        {% for c in sclasses %}
            <li><a href="../class/{{ c['cid'] }}">{{ c['name'] }}</a></li>
        {% endfor %}
        </ul>
    </p>
</div>
<script src="../static/getFormJson.js"></script>
<script src="../static/polalert.js"></script>
<script>
var s = {{ sjson }};

function edit() {
    content = '\
        <input type="hidden" id="what" name="what" class="formdata" value="student" />\
        <input type="hidden" id="sid" name="sid" class="formdata" />\
        <div style="clear:both;"><label for="givenname">Vorname: </label><input type="text" name="givenname" id="givenname" class="formdata" required /></div>\
        <div style="clear:both;"><label for="familyname">Nachname: </label><input type="text" name="familyname" id="familyname" class="formdata" required /></div>\
        <div style="clear:both;"><label for="gender">Geschlecht: </label><select id="gender" name="gender" class="formdata">\
            <option value="None" id="None">unbekannt</option>\
            <option value="male" id="male">männlich</option>\
            <option value="female" id="female">weiblich</option>\
            <option value="other" id="other">andere</option>\
        </select></div>\
        <div style="clear:both;"><label for="memo">Notizen: </label><textarea name="memo" id="memo" class="formdata"></textarea></div>\
        <p style="clear:both;">\
        {% for c in classes %}\
            <label for="cid{{ c["cid"] }}">{{ c["name"] }} {{ c["subject"] }}</label>\
            {% if c in sclasses %}\
                <input type="checkbox" id="cid{{ c["cid"] }}" name="cids" class="formdata" value="{{ c["cid"] }}" checked /><br />\n\
            {% else %}\
                <input type="checkbox" id="cid{{ c["cid"] }}" name="cids" class="formdata" value="{{ c["cid"] }}" /><br />\n\
            {% endif %}\
        {% endfor %}\
        </p>\
        <div style="clear:both; text-align:center;">\
        </div>\
        <input type="submit" value="Speichern" onclick="send()">\
    '
    document.getElementById('content').innerHTML = content;
    document.getElementById('sid').value = s.sid;
    document.getElementById('givenname').value = s.givenname;
    document.getElementById('familyname').value = s.familyname;
    document.getElementById('memo').innerHTML = s.memo;
    if (s['gender'] != '') {
        document.getElementById(s['gender']).selected = true;
    }
}
function send() {
    var xhr = new XMLHttpRequest();
    var formJson = getFormJson();
    console.log(formJson);
    if (formJson.sid=='') {
        xhr.open('POST', '../newDbEntry', false);
    } else {
        xhr.open('POST', '../updateDbEntry', false);
    }
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify(formJson));
    if (formJson.sid=='') { // new
        if (isNaN(xhr.responseText)) {
            document.getElementById('content').innerHTML = xhr.responseText;
        } else {
            window.location = xhr.responseText;
        }
    } else if (xhr.responseText = 'ok') {
        location.reload();
    } else {
        document.getElementById('content').innerHTML = xhr.responseText;
    }
}
function strToStudent(str, strDelimiter ){
    var strDelimiter = (strDelimiter || ',');
    var s = {'what': 'student', 'givenname': '', 'familyname': '', 'gender': 'None', 'memo': ''};
    var i=0;
    while ((str[i] != strDelimiter) && (str.length > i)) {
        s.familyname += str[i];
        i++;
    }
    i++;
    while ((str[i] == ' ') && (str.length > i)) i++;
    while ((str[i] != strDelimiter) && (str.length > i)) {
        s.givenname += str[i];
        i++;
    }
    i++;
    while ((str[i] == ' ') && (str.length > i)) i++;
    if (str[i] == 'm') s.gender = 'male';
    else if (str[i] == 'w') s.gender = 'female';
    else if (str[i] == 'o') s.gender = 'other';
    return s;
}
function csvImport() {
    var formJson = getFormJson();
    var cids = formJson.cids;
    var csv = document.getElementById('csv').value;
    var lines = csv.split('\n');
    for (var i=0; i<lines.length; i++) {
        s = strToStudent(lines[i]);
        if ((s.givenname != '') && (s.familyname != '')) {
            s.cids = cids;
            var xhr = new XMLHttpRequest();
            xhr.open('POST', '../newDbEntry', false);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.send(JSON.stringify(s));
            if (isNaN(xhr.responseText)) {
                var success = false;
                pa.error('FEHLER! Ich breche es hier ab.<br /> Fehlermeldung:<br />'+xhr.responseText);
                break;
            } else var success = true;
            // TODO: Ask for every pared student if it shall be imported!
        }
    }
    if (success) {
        pa.message('Erfolgreich gespeichert!');
    } else {
        document.getElementById('content').innerHTML = xhr.responseText;
    }
}
function showCsvImportForm() {
    document.getElementById('title').innerHTML = 'Klassenliste importieren';
    document.getElementById('pagenav').innerHTML = '<a onclick="location.reload()">Abbrechen</a>'
    content = '\
        <p>Bitte die Klassenliste im CSV-Format in das Eingabefeld kopieren.<br />\
        Formatierungsbeispiel:<br />\
        <code>Mustermann, Max, m</code> (Optionen für Geschlecht: <code>m</code>(ännlich), <code>w</code>(eiblich) oder <code>o</code>(other))<br />\
        (Leerzeichen nach dem Komma werden automatisch entfernt, ein abschließendes Komma und das Geschlecht ist nicht nötig.)</p>\
        <div style="clear:both;"><label for="memo">Klassenliste im <br />csv-Format: </label><textarea id="csv"></textarea></div>\
        <p style="clear:both;">\
        {% for c in classes %}\
            <label for="cid{{ c["cid"] }}">{{ c["name"] }} {{ c["subject"] }}</label>\
            {% if c in sclasses %}\
                <input type="checkbox" id="cid{{ c["cid"] }}" name="cids" class="formdata" value="{{ c["cid"] }}" checked /><br />\n\
            {% else %}\
                <input type="checkbox" id="cid{{ c["cid"] }}" name="cids" class="formdata" value="{{ c["cid"] }}" /><br />\n\
            {% endif %}\
        {% endfor %}\
        </p>\
        <div style="clear:both; text-align:center;">\
        </div>\
        <input type="submit" value="Speichern" onclick="csvImport()">\
    ';
    document.getElementById('content').innerHTML = content;
    
}

if (s.sid == '') {
    document.getElementById('title').innerHTML = 'Neuen Schüler hinzufügen';
    document.getElementById('pagenav').innerHTML = '<a onclick="showCsvImportForm()">Klassenliste importieren</a>'
    edit();
}
</script>
