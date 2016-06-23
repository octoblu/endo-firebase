firebase = require 'firebase'
http   = require 'http'
_      = require 'lodash'

class RetrieveData
  constructor: ({@encrypted}) ->

    {databaseURL, storageBucket} = @encrypted
    {apiKey, authDomain} = @encrypted.secrets.credentials
    return callback @_userError(422, 'Credentials required') apiKey? && authDomain? && databaseURL? && storageBucket?

    @app = firebase.initializeApp {
      apiKey: apiKey
      authDomain: authDomain
      databaseURL: databaseURL
      storageBucket: storageBucket
    }

    @database = firebase.database()

  do: ({data}, callback) =>
    return callback @_userError(422, '') unless data?
    { reference, event } = data

    firebase.database().ref(reference).once(event).then( (snapshot) =>
       return callback null, {
         metadata:
           code: 200
           status: http.STATUS_CODES[200]
         data: @_processResults snapshot.val
       }
    )

    return callback null

  _processResult: (result) =>
    {
      snapshot: result
    }

  _processResults: (results) =>
    _.map results, @_processResult

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = RetrieveData
