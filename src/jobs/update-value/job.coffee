firebase = require 'firebase'
http   = require 'http'
_      = require 'lodash'

class SetValue
  constructor: ({@encrypted}) ->

    {apiKey, authDomain, databaseURL, storageBucket} = @encrypted.secrets.credentials
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
    { reference, setValue } = data

    firebase.database().ref(reference).set(setValue)

    # return callback null, {
    #   metadata:
    #     code: 200
    #     status: http.STATUS_CODES[200]
    #   data: @_processResults results
    # }
    return callback null

  _processResult: (result) =>
    {
      result: result
    }

  _processResults: (results) =>
    _.map results, @_processResult

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = SetValue
