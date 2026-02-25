class_name LogWriter

static var str_AppVersion : String = 'v 0.1 08.04.25'

static func getDateFormated() -> String:
	var str_day : String
	var int_day : int = Time.get_datetime_dict_from_system()["day"]
	var str_month : String
	var int_month : int = Time.get_datetime_dict_from_system()["month"]
	var str_year : String = str(Time.get_datetime_dict_from_system()["year"])
	
	str_day = str(int_day) if int_day >= 10 else '0%s' % int_day
	str_month = str(int_month) if int_month >= 10 else '0%s' % int_month
	
	return '%s.%s.%s' % [str_day, str_month, str_year]
	
static func getTimeFormated() -> String:
	var str_hour : String
	var int_hour : int = Time.get_datetime_dict_from_system()["hour"]
	var str_minute : String
	var int_minute : int = Time.get_datetime_dict_from_system()["minute"]
	var str_second : String
	var int_second : int = Time.get_datetime_dict_from_system()["second"]
	
	str_hour = str(int_hour) if int_hour >= 10 else '0%s' % int_hour
	str_minute = str(int_minute) if int_minute >= 10 else '0%s' % int_minute
	str_second = str(int_second) if int_second >= 10 else '0%s' % int_second
	
	return '%s:%s:%s' % [str_hour, str_minute, str_second]

static func writeToLog(text, file_name) -> void:
	print(text)
	#file_name = profiles_dir + profile_name + '/' + file_name
	#file_name = Root.str_RootDir + file_name
	file_name = './' + file_name

	if (FileAccess.file_exists(file_name)):
		var Log : FileAccess = FileAccess.open(file_name, FileAccess.READ_WRITE)
		Log.seek_end()
		Log.store_line(text)
	else:
		var Log : FileAccess = FileAccess.open(file_name, FileAccess.WRITE)
		Log.store_line(text)
		
static func writeOutputLog(text) -> void:
	#'\t v. %s [%s %s]'
	writeToLog('\t %s [%s %s]' % [str_AppVersion, getDateFormated(), getTimeFormated()], 'output.log')
	writeToLog(text + "\n", 'output.log')
	
static func writeErrorLog(text : String, use_breakpoint : bool) -> void:
	#'\t v. %s [%s %s]'
	writeToLog('\t %s [%s %s]' % [str_AppVersion, getDateFormated(), getTimeFormated()], 'error.log')
	#writeToLog(header, file_name)
	writeToLog(text + "\n", 'error.log')
	if (use_breakpoint):
		breakpoint
	
static func writeDateToLog(file_name) -> void:
	writeToLog('\t [%s %s]' % [getDateFormated(), getTimeFormated()], file_name)
