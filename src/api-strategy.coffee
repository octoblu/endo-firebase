_                = require 'lodash'
PassportStrategy = require 'passport-strategy'
request          = require 'request'
url              = require 'url'

class FirebaseStrategy extends PassportStrategy
  constructor: (env) ->
    if _.isEmpty env.ENDO_FIREBASE_CALLBACK_URL
      throw new Error('Missing required environment variable: ENDO_FIREBASE_CALLBACK_URL')
    if _.isEmpty env.ENDO_FIREBASE_AUTH_URL
      throw new Error('Missing required environment variable: ENDO_FIREBASE_AUTH_URL')
    if _.isEmpty env.ENDO_FIREBASE_SCHEMA_URL
      throw new Error('Missing required environment variable: ENDO_FIREBASE_SCHEMA_URL')
    if _.isEmpty env.ENDO_FIREBASE_FORM_SCHEMA_URL
      throw new Error('Missing required environment variable: ENDO_FIREBASE_FORM_SCHEMA_URL')


    @_authorizationUrl = env.ENDO_FIREBASE_AUTH_URL
    @_callbackUrl      = env.ENDO_FIREBASE_CALLBACK_URL
    @_schemaUrl        = env.ENDO_FIREBASE_SCHEMA_URL
    @_formSchemaUrl    = env.ENDO_FIREBASE_FORM_SCHEMA_URL
    @_apiUrl           = env.ENDO_FIREBASE_API_URL ? 'https://api.firebase.com'
    super

  authenticate: (req) -> # keep this skinny
    {bearerToken} = req.meshbluAuth
    {username, apiKey, authDomain, databaseURL, storageBucket} = req.body
    return @redirect @authorizationUrl({bearerToken}) unless apiKey? && authDomain?
    @success {
      id:       username
      username: username
      databaseURL: databaseURL
      storageBucket: storageBucket
      secrets:
        credentials: {apiKey, authDomain}
    }

  authorizationUrl: ({bearerToken}) ->
    {protocol, hostname, port, pathname} = url.parse @_authorizationUrl
    query = {
      postUrl: @postUrl()
      schemaUrl: @schemaUrl()
      formSchemaUrl: @formSchemaUrl()
      bearerToken: bearerToken
    }
    return url.format {protocol, hostname, port, pathname, query}

  formSchemaUrl: ->
    @_formSchemaUrl

  postUrl: ->
    {protocol, hostname, port} = url.parse @_callbackUrl
    return url.format {protocol, hostname, port, pathname: '/auth/api/callback'}

  schemaUrl: ->
    @_schemaUrl

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error


module.exports = FirebaseStrategy
