<style>
    div#halfRight Button {
        margin-top: 10px;
    }
    div.memo {
        border: 1px solid black;
        text-align: left;
        margin-top: 5px;
        margin-bottom: 5px;
    }
    div.prio1 {
        background-color: rgba(100,0,0,0.5);
    }
    div.prio2 {
        background-color: rgba(100,100,0,0.5);
    }
    div.prio3 {
        background-color: rgba(0,100,0,0.5);
    }
    div.memo Button{
        min-width: 50px;
        width: 50%;
    }
    table#timetable {
        border:1px solid #888;
        width:100%;
        border-collapse: collapse;
    }
    table#timetable tr {
        border:1px solid #888;
    }
    @media only screen and (min-width: 981px) {
        div#content {
            display: grid;
            grid-gap: 10px;
            grid-template-columns: 2fr 1fr;
        }
        div#halfLeft {
            grid-column: 1 / 2;
            grid-row: 1/2;
        }
        div#halfRight {
            style="grid-column: 2 / 3;
            grid-row: 1/2;
        }
    }
</style>

<h1 id="title" onclick="location.reload()">GradeMan Startseite</h1>
<nav id="pagenav">
</nav>
<div id="content">
    <div id="halfRight">
        <h2>Notizen</h2>
        <div id="memos"></div>
        <button onclick="addMemo()">Notiz hinzufügen</button>
    </div>
    <div id="halfLeft">
        <h2>Stundenplan</h2>
        <div id="timetable"><p>Stundenplan wird geladen...</p></div>
    </div>
</div>
<script src="{{ relroot }}static/getFormJson.js"></script>
<script src="{{ relroot }}static/polalert.js"></script>
<script>
var m = {{ mjson }};
var t = {{ tjson }};
var c = {{ cjson }};

function mdtex2html(mdtex) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'mdtex2html', false);
    xhr.setRequestHeader('Content-Type', 'application/mdtex');
    xhr.send(mdtex);
    return xhr.responseText;
}
function cidFullName(cid) {
    if (cid == '') {
        return '';
    }
    for (var i = 0; i < c.length; i++) {
        if (c[i].cid == cid) {
            return c[i].name+' '+c[i].subject;
        }
    }
}
// Memos:
function showMemos() {
    if (m.length == 0) {
        out = 'Keine Notizen vorhanden!';
    } else {
        out = '';
        for (var i = 0; i < m.length; i++) {
            out += '<div class="memo prio'+m[i].prio+'">';
            out += '<p class="date">'+m[i].date+' | Prio '+m[i].prio+'</p>\n';
            out += mdtex2html(m[i].memo);
            out += '<button onclick=editMemo('+i+')>Bearbeiten</button>'
            out += '<button onclick=deleteMemo('+m[i].mid+')>Löschen</button>'
            out += '</div>';
        }
    }
    document.getElementById('memos').innerHTML = out;
}
function addMemo() {
    out = '\
    <input type="hidden" id="what" name="what" class="formdata" value="memo" />\
    <input type="hidden" id="mid" name="mid" class="formdata" value="" />\
    <label for="prio">Prio: </label>\
    <input type="date" name="date" id="date" class="formdata" />\
    <select id="prio" name="prio" class="formdata selectSmall"></select>\
    <textarea name="memo" id="memo" class="formdata"></textarea>\
    <div style="clear:both;"><input type="submit" value="Speichern" onclick="sendMemo()"></div>'
    document.getElementById('memos').innerHTML += out;
    // insert select-options for prio:
    var prio = document.getElementById('prio');
    var options = ['1', '2', '3'];
    options.forEach(function(element,key) {
        if (element == '3') {
            prio[key] = new Option(element, element, true, true);
        } else {
            prio[key] = new Option(element, element);
        }
    });
    // set default to today:
    Date.prototype.toDateInputValue = (function() {
        var local = new Date(this);
        local.setMinutes(this.getMinutes() - this.getTimezoneOffset());
        return local.toJSON().slice(0,10);
    });
    document.getElementById('date').value = new Date().toDateInputValue();
}
function editMemo(i) {
    out = '\
    <input type="hidden" id="what" name="what" class="formdata" value="memo" />\
    <input type="hidden" id="mid" name="mid" class="formdata" value="'+m[i].mid+'" />\
    <label for="prio">Prio: </label>\
    <input type="date" name="date" id="date" class="formdata" value="'+m[i].date+'" />\
    <select id="prio" name="prio" class="formdata selectSmall"></select>\
    <textarea name="memo" id="memo" class="formdata">'+m[i].memo+'</textarea>\
    <div style="clear:both;"><input type="submit" value="Speichern" onclick="sendMemo()"></div>'
    document.getElementById('memos').innerHTML = out;
    // insert select-options for prio:
    var prio = document.getElementById('prio');
    var options = ['1', '2', '3'];
    options.forEach(function(element,key) {
        if (element == m[i].prio) {
            prio[key] = new Option(element, element, true, true);
        } else {
            prio[key] = new Option(element, element);
        }
    });
}
function deleteMemo(mid) {
    var delMid = mid;
    pa.boolean('Soll die Notiz wirklich gelöscht werden?', mid);
}
function paOk(mid) {
    delJsonCmd = {'what': 'memo', 'mid': mid};
    var xhr = new XMLHttpRequest();
    xhr.open('DELETE', 'deleteDbEntry', false);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify(delJsonCmd));
    if (xhr.responseText = 'ok') {
        location.reload();
    } else {
        document.getElementById('content').innerHTML = xhr.responseText;
    }
}
function paNo(mid) {
    pa.message('Alles klar, nichts passiert!')
}
function sendMemo() {
    var xhr = new XMLHttpRequest();
    var formJson = getFormJson();
    if (formJson.mid=='') {
        xhr.open('POST', 'newDbEntry', false);
    } else {
        xhr.open('POST', 'updateDbEntry', false);
    }
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify(formJson));
    if (xhr.responseText = 'ok') {
        location.reload();
    } else {
        document.getElementById('content').innerHTML = xhr.responseText;
    }
}
// timetable:
function showTimetable() {
    out = '<table id="timetable">\n <tr><th> </th><th>Mo</th><th>Di</th><th>Mi</th><th>Do</th><th>Fr</th></tr>\n';
    for (var i = 0; i < t.length; i++) {
        out += '\
            <tr><td>'+t[i].time+'</td>\
            <td><a href="class/'+t[i].mo+'">'+cidFullName(t[i].mo)+'</a></td>\
            <td><a href="class/'+t[i].tu+'">'+cidFullName(t[i].tu)+'</a></td>\
            <td><a href="class/'+t[i].we+'">'+cidFullName(t[i].we)+'</a></td>\
            <td><a href="class/'+t[i].th+'">'+cidFullName(t[i].th)+'</a></td>\
            <td><a href="class/'+t[i].fr+'">'+cidFullName(t[i].fr)+'</a></td>\
            </tr>'
    }
    out += '</table>\n';
    out += '<button onclick="editTimetable()">Stundenplan bearbeiten</button>';
    document.getElementById('timetable').innerHTML = out;
}
function editTimetable() {
    out = '<input type="hidden" id="what" name="what" class="formdata" value="timetable" />';
    out += '<table id="timetable">\n <tr><th>Zeit</th><th>Mo</th><th>Di</th><th>Mi</th><th>Do</th><th>Fr</th></tr>\n';
    out += '<tbody></tbody></table>';
    out += '<button onclick="editTimetableAddRow()">Zeile hinzufügen</button>';
    out += '<button onclick="editTimetableRemoveRow()">letzte Zeile löschen</button>';
    out += '<div style="clear:both;"><input type="submit" value="Speichern" onclick="sendTimetable()"></div>';
    document.getElementById('timetable').innerHTML = out;
    // insert rows:
    var tableRef = document.getElementById('timetable').getElementsByTagName('tbody')[0];
    var keys = ['time', 'mo', 'tu', 'we', 'th', 'fr', 'sa'];
    for (i=0; i<t.length; i++) {
        var newRow = tableRef.insertRow(tableRef.rows.length);
        var newCell = newRow.insertCell(0);
        newCell.innerHTML = '<input type="text" name="time" class="inputSmall formdata" value="'+t[i].time+'"></input>\n';
        for (j=1; j<=5; j++) {
            var newCell = newRow.insertCell(j);
            var newSelect = document.createElement('select');
            newSelect.id = tableRef.rows.length-1+','+j;
            newSelect.name = keys[j];
            newSelect.classList.add('selectSmall');
            newSelect.classList.add('formdata');
            newCell.appendChild(newSelect);
            var cid = t[i][keys[j]];
            if (cid == '1') {
                var option = document.createElement('option');
                option.value = cid;
                option.text = cidFullName(cid);
                newSelect.appendChild(option);
            }
            var option = document.createElement('option');
            option.value = '';
            option.text = '';
            newSelect.appendChild(option);
            for (var k = 0; k < c.length; k++) {
                var option = document.createElement('option');
                option.value = c[k].cid;
                option.text = c[k].name+' '+c[k].subject;
                newSelect.appendChild(option);
            }
        }
        var newCell = newRow.insertCell(6);
        newCell.innerHTML = '<input type="hidden" name="sa" class="formdata" value=""></input>\n';
    }
}
function editTimetableAddRow() {
    var tableRef = document.getElementById('timetable').getElementsByTagName('tbody')[0];
    var newRow = tableRef.insertRow(tableRef.rows.length);
    var keys = ['time', 'mo', 'tu', 'we', 'th', 'fr', 'sa'];
    var newCell = newRow.insertCell(0);
    newCell.innerHTML = '<input type="text" name="time" class="inputSmall formdata" value="'+(tableRef.rows.length-1)+'"></input>\n';
    for (i=1; i<=5; i++) {
        var newCell = newRow.insertCell(i);
        var newSelect = document.createElement('select');
        newSelect.id = tableRef.rows.length-1+','+i;
        newSelect.name = keys[i];
        newSelect.classList.add('selectSmall');
        newSelect.classList.add('formdata');
        newCell.appendChild(newSelect);
        // insert select-options:
        var option = document.createElement('option');
        option.value = '';
        option.text = '';
        newSelect.appendChild(option);
        for (j=0; j<c.length; j++) {
            var option = document.createElement('option');
            option.value = c[j].cid;
            option.text = c[j].name+' '+c[j].subject;
            newSelect.appendChild(option);
        }
    }
    // no saturday (day 6) at the moment, but prepared in the database:
    var newCell = newRow.insertCell(6);
    newCell.innerHTML = '<input type="hidden" name="sa" class="formdata" value=""></input>\n';
}
function editTimetableRemoveRow() {
    var tableRef = document.getElementById('timetable').getElementsByTagName('tbody')[0];
    var newRow = tableRef.deleteRow(tableRef.rows.length-1);
}
function sendTimetable() {
    var xhr = new XMLHttpRequest();
    var formJson = getFormJson();
    console.log(JSON.stringify(formJson));
    xhr.open('POST', 'updateDbEntry', false);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify(formJson));
    if (xhr.responseText = 'ok') {
        location.reload();
    } else {
        document.getElementById('content').innerHTML = xhr.responseText;
    }
}

showMemos();
showTimetable();

</script>
