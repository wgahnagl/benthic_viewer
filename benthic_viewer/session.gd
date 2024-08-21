extends MetaverseSession

var firstname = ""
var lastname = ""
var password = ""
var grid = ""

var loginSuccess = false
var loginError = ""
func get_login_values() -> Array:
	return [firstname, lastname, password, grid]

func get_login_status() -> Array: 
	return [loginSuccess, loginError]
