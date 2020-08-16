<h1 id="title" onclick="location.reload()">Datenverwaltung</h1>
<nav id="pagenav">
    <a href="{{ relroot}}class/">Neue Klasse</a> | 
    <a onclick="showClasses()">Alle Klassen</a> | 
    <a href="{{ relroot}}student/">Neuer Schüler</a> | 
    <a onclick="showStudents()">Alle Schüler</a> | 
    <a onclick="del()">Daten löschen</a> | 
    <a href="{{ relroot}}reloadDb">Datenbank neu laden</a>
</nav>
<div id="content">
</div>
<script>
var c = {{ cjson }};
var content = document.getElementById('content');

// default: classes:
function showClasses () {
    out = '<div id="classes">\n';
    out += '<h2>Klassen</h2>\n';
    out += '<ul>\n';
    for (i=0; i<c.length; i++) {
        out += '<li><a href="{{relroot}}class/'+c[i].cid+'">'+c[i].name+' '+c[i].subject+'</a></li>\n';
    }
    out += '</ul>\n</div>\n';
    content = document.getElementById('content');
    content.innerHTML = out;
}
showClasses();

// students:
function showStudents() {
    var url = '../json/students';
    fetch(url).then(function(response) {
        if (response.ok) 
            return response.json();
        else 
            throw new Error('ERROR: Students could not be fetched from server!');
    })
    .then(function(sjson) {
        out = '<h2>Alle Schüler</h2>\n<ul>';
        for (i=0; i<sjson.length; i++) {
            out += '\
                <li><a href="{{ relroot }}student/'+sjson[i].sid+'">\
                '+sjson[i].givenname+' '+sjson[i].familyname+'</a></li>';
        }
        content.innerHTML = out+'</ul>';
    })
    .catch(function(err) {
        console.log(err);
    });
/* xhr-way to do it:
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '{{ relroot }}json/students');
//    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send();
    xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.DONE) {
            var status = xhr.status;
            if (status === 0 || (status >= 200 && status < 400)) {
                sjson = JSON.parse(xhr.responseText);
                out = '<h2>Alle Schüler</h2>\n<ul>';
                for (i=0; i<sjson.length; i++) {
                    out += '\
                        <li><a href="{{ relroot }}student/'+sjson[i].sid+'">\
                        '+sjson[i].givenname+' '+sjson[i].familyname+'</a></li>';
                }
                content.innerHTML = out+'</ul>';
            } else {
                console.log('ERROR: unknown response: '+xhr.responseText)
            }
        }
    }
*/
}
// delelte:
function del() {
    content.innerHTML = 'TODO';
}    

</script>
