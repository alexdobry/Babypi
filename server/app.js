require('dotenv').config()

const config = require('./config.js')
const express = require('express');
const bodyParser = require('body-parser');
const shell = require('shelljs');
const fs = require('fs');
const apn = require('apn');
const app = express();

app.use(bodyParser.json());

const home = '/home/pi'
const babypi = home + '/Babypi'
const noise = home + 'ruby-noise-detection'
const apns = home + '/apns'

const cameraOn = 'sudo ' + babypi + '/picam.sh start'
const cameraOff = 'sudo ' + babypi + '/picam.sh stop'
const lightOn = 'sudo ' + babypi +'/light.sh on'
const lightOff = 'sudo ' + babypi + '/light.sh off'
const noiseOn = 'sudo ' + noise + '/noise.sh start'
const noiseOff = 'sudo ' + noise + '/noise.sh stop'
const record= 'sudo ' + home + '/record_auth.sh'
const reboot= 'sudo reboot'
const shutdown = 'sudo shutdown -h now'

const options = {
  token: {
    key: config.apns.key,
    keyId: config.apns.keyId,
    teamId: config.apns.teamId
  },
  production: false
}

app.get('/', (req, res) => {
	res.send('Hello World!');
});

app.get('/record', (req, res) => {
	shell.exec(record, {
		async: true
	});

	res.send({status: 'ok', message: 'recording started'});
});

app.get('/dht22', (req, res) => {
	fs.readFile('/home/pi/dht22.json', 'utf8', (err, data) => {
    	if (err) {
			res.send({status : 'ko', message: data});
		} else {
			res.send(JSON.parse(data));
		}
	});    	
});

app.post('/camera', (req, res) => {
	res.send(toggle('camera', req.body.state, cameraOn, cameraOff));
});

app.post('/noise', (req, res) => {
	res.send(toggle('noise', req.body.state, noiseOn, noiseOff));
});

app.post('/light', (req, res) => {
	res.send(toggle('light', req.body.state, lightOn, lightOff));
});

app.delete('/babypi/destructive', (req, res) => {
	shell.exec(shutdown, {
		async: true
	});
	
	res.send({status: 'ok', message: 'shutting down ...'});
});

app.delete('/babypi', (req, res) => {
	shell.exec(reboot, {
		async: true
	});
	
	res.send({status: 'ok', message: 'rebooting ...'});
});

app.post('/apns', (req, res) => {
	const token = req.body.token

	readTokens((json, file) => {
		json.tokens.push(token)

		fs.writeFile(file, JSON.stringify(json), (err) => {
			if (err) {
				res.send({status: 'ko', message: err})
			} else {
				res.send({status: 'ok', message: 'token was accepted'})
			}
		})
	}, errorJson => {
		res.send(errorJson)
	})
})

app.get('/apns', (req, res) => {
	send(successJson => {
		res.send(successJson)
	}, failureJson => {
		res.send(failureJson)
	})
})

function readTokens(success, failure) {
	const tokens = apns + '/tokens.json'

	fs.readFile(tokens, 'utf8', (err, data) => {
		if (err) { 
			failure({status: 'ko', message: err})
		} else {
			success(JSON.parse(data), tokens)
		}
	})
}

function send(success, failure) {
	const notification = new apn.Notification()
	notification.topic = config.apns.bundleId
	notification.badge = 1
	notification.sound = "ping.aiff";
	notification.title = "Paula ist wach!"
	
	readTokens((json, file) => {
		const tokens = json.tokens
		console.log('pushing to ' + tokens)

		const apnProvider = new apn.Provider(options)

		apnProvider.send(notification, tokens).then( (result) => {
			if (result.failed.length > 0) {
				console.log('result.failed: ' + result.failed);	
				failure({status: 'ko', message: result.failed})
			} else {
				console.log('result.sent: ' + result.sent);
				success({status: 'ok', message: result.sent})
			}
		})

		apnProvider.shutdown()
	}, errorJson => {
		failure(errorJson)
	})
}

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
})
