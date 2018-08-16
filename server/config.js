const env = process.env.NODE_ENV || 'dev'

const dev = {
  apns: {
    key: process.env.KEY || '',
    keyId: process.env.KEY_ID || '',
    teamId: process.env.TEAM_ID || '',
    bundleId: process.env.BUNDLE_ID || ''
  }
}

const config = {
  dev
}

module.exports = config[env]