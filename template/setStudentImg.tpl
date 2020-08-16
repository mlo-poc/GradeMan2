<h1>Schülerbild festlegen</h1>
<p>TODO: css geeignet für alle viewports anpassen, ggf. zentralisieren</p>
<h2>Entweder: Direkt per Kamera</h2>
<button id="startCam" onclick="startCam()">Kamera öffnen</button>
<div id="cam" style="display:none;">
    <div id="videoDiv">
        <div id="videoFrame" style="position:absolute; z-index:1; border: 3px dashed red; width:350px; height:450px; margin: 0 auto; margin-top: 40px;"></div>
        <video id="video" autoplay style="border:1px solid red; margin:auto;">Hallo Welt</video>
    </div><br />
    <button id="takePicture" onclick="takePicture()" style="width:100%;height:100px;">Aufnehmen</button><br />
    <canvas id="canvas"style="border:1px dashed yellow; width:352px;height:452px; display:none;"></canvas>
    <img id="photo" alt="Feld zur Ansicht des Fotos vor der Übernahme" style="border:1px solid green; width:352px;height:452px;"><br />
    <button id="uploadImage" onclick="uploadImage('cam')">Bild übernehmen (Hochladen und Speichern)</button>
</div>
<h2>Oder: Vorhandenes Bild hochladen</h2>
<p>TODO: Bildformat nach jpg wandeln und Grösse verzerrungsfrei zuschneiden!</p>
<input type="file" name="uploadFile" id="uploadFile" accept="image/jpg,image/png"><br />
<button id="sendImage" onclick="uploadImage('upload')">Bild übernehmen (Hochladen und Speichern)</button>
<h2>Hinweise</h2>
<p>Das Bild wird klein skaliert, beschnitten und in eine Auflösung von 350x450px in der Datenbank gespeichert. Das Einverständnis der betreffenden Personen ist einzuholen.<br />
Durch setzen eines neuen Bildes wird das alte überschrieben und damit unwiederbringlich gelöscht.</p>
<p>Browser verhindern das direkte Aufnehmen eines Bildes bei einer unsicheren Verbindung!</p>
<p>TODO: Blitz/torch tut im Firefox nicht</p>
<script>
// the video has a native height of 530 to have enough to crop from a 3:2-Camera to keep 450x350px (passport aspect ratio)
var video = document.getElementById('video');
var photo = document.getElementById('photo');
var canvas = document.getElementById('canvas');
function takePicture() {
    var width = video.videoWidth;
    var height = video.videoHeight;
    video.setAttribute('width', width);
    video.setAttribute('height', height);
    canvas.setAttribute('width', 350);
    canvas.setAttribute('height', 450);
    var context = canvas.getContext('2d');
    var xoffset = width/2 - 175;
    var yoffset = 40;
    context.drawImage(video,xoffset,yoffset,350,450,0,0,350,450);
    var data = canvas.toDataURL('image/jpeg', 0.95);
    photo.setAttribute('src', data);
}

function startCam() {
    document.getElementById('cam').style.display = 'block';
    document.getElementById('startCam').style.display = 'none';
    try {
        navigator.mediaDevices.getUserMedia({
            video: { width: {min:350}, height: {min:530}, facingMode:'environment' },
            audio: false, torch: true
        }).then(stream => {
            video.srcObject = stream;// connect to stream
            video.play();// play it in the video-box
            // turn on the light:
            const track = stream.getVideoTracks()[0];
            video.addEventListener('loadedmetadata', (e) => {  
                window.setTimeout(() => (
                    onCapabilitiesReady() // firefox doesn't support track.getCapabilities()
                    //onCapabilitiesReady(track.getCapabilities())
                ), 500);
            });
            function onCapabilitiesReady(capabilities) {
                var videoW = document.getElementById('video').videoWidth;
                document.getElementById('videoFrame').style.marginLeft = ((videoW / 2)-175)+'px';
                console.log('camera-capabilities loaded:');
                console.log(capabilities);
                track.applyConstraints({
                    advanced: [{torch: true}]
                })
                .catch(e => console.log(e));
                //console.log(capabilities);
                //if (capabilities.torch) {
                //    track.applyConstraints({
                //    advanced: [{torch: true}]
                //    })
                //    .catch(e => console.log(e));
                //}
            }
        }).catch(function(err) {
            console.log("An error occurred: " + err);
            document.getElementById('cam').innerHTML = '\
<p><span style="color:red;">FEHLER beim Öffnen der Kamera! Die direkte Aufnahme ist nicht möglich.</span><br />\
Mögliche Ursache: Keine Kamera oder Kamerazugriff nicht erlaubt. Kamera-berechtigungen des Browsers prüfen!<br />';
        });
    } catch (err) {
            console.log("An error occurred: " + err);
            document.getElementById('cam').innerHTML = '\
<p><span style="color:red;">FEHLER beim Öffnen der Kamera! Die direkte Aufnahme ist nicht möglich.</span><br />\
Mögliche Ursache: Keine Sichere Verbindung zum Server. Die Verbindung muss über https erfolgen!<br />';
    }
    
}

function dataURItoBlob(dataURI) {
    var byteString = atob(dataURI.split(',')[1]);
    var ab = new ArrayBuffer(byteString.length);
    var ia = new Uint8Array(ab);
    for (var i = 0; i < byteString.length; i++) {
        ia[i] = byteString.charCodeAt(i);
    }
    return new Blob([ab], {type: 'image/jpeg'});
}

function uploadImage(source) {
    var formData = new FormData();
    if (source == 'cam') {
        dataURI = document.getElementById('photo').src;
        img = dataURItoBlob(dataURI);
        //var img = canvas.getContext('2d').drawImage('filename', 0, 0);
    } else if (source == 'upload') {
        x = document.getElementById("uploadFile");
        if (x.files.length == 0) {
            alert('select a file!');
        } else {
            console.log('sending '+x.files[0].name);
            img = x.files[0];
        }
    }
    formData.append("img", img);                                
    var xhr = new XMLHttpRequest();
    xhr.open("POST", '../setStudentImg/{{ sid }}');
    xhr.send(formData);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4 && xhr.status == 200) {
            window.location = '../'+xhr.responseText;
        }
    }
}

</script>
