const express = require('express');
const bodyParser = require('body-parser');
const shell = require('shelljs');
const fs = require('fs');
const app = express();

app.use(bodyParser.json());

const home = '/home/pi'
const babypi = home + '/Babypi'
const cameraOn = 'sudo ' + babypi + '/picam.sh start';
const cameraOff = 'sudo ' + babypi + '/picam.sh stop';
const lightOn = 'sudo ' + babypi +'/light.sh on';
const lightOff = 'sudo ' + babypi + '/light.sh off';
const record= 'sudo ' + home + '/record_auth.sh'
const reboot= 'sudo reboot'
const shutdown = 'sudo shutdown -h now'

app.get('/', (req, res) => {
	res.send('Hello World!');
});

app.get('/record', (req, res) => {
	shell.exec(record, {
		async: true
	});

	res.json({status: 'ok', message: 'recording started'});
});

app.get('/dht22', (req, res) => {
	fs.readFile('/home/pi/dht22.json', 'utf8', (err, data) => {
    		if (err) {
			res.json({status : 'ko', message: data});
		} else {
			res.json(JSON.parse(data));
		}
	});    	
});

app.post('/camera', (req, res) => {
	res.json(toggle('camera', req.body.state, cameraOn, cameraOff));
});

app.post('/light', (req, res) => {
	res.json(toggle('light', req.body.state, lightOn, lightOff));
});

app.delete('/babypi/destructive', (req, res) => {
	shell.exec(shutdown, {
		async: true
	});
	
	res.json({status: 'ok', message: 'shutting down ...'});
});

app.delete('/babypi', (req, res) => {
	shell.exec(reboot, {
		async: true
	});
	
	res.json({status: 'ok', message: 'rebooting ...'});
});

function toggle(device, state, onScript, offScript) {
	switch (state) {
		case 'on':
			if (shell.exec(onScript).code !== 0) {
				return {status: 'ko', message: 'failed to turn ' + device + ' on'};
			} else {
				return {status: 'ok', message: device + ' is on'};
			}
		case 'off':
			if (shell.exec(offScript).code !== 0) {
				return {status: 'ko', message: 'failed to turn ' + device + ' off'};
			} else {
				return {status: 'ok', message: '${device} is off'};
			}
		default:
			return {status: 'ko', message: 'key "state" must be either on or off'};
	}
}

const server = app.listen(8080, () => {
	const host = server.address().address;
	const port = server.address().port;

	console.log('Example app listening at http://%s:%s', host, port);
});
