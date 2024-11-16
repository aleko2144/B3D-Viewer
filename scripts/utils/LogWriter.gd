extends Node

var Root : Node

func reload():
	Root = get_tree().get_root().get_child(0)

func getDateFormated() -> String:
	var str_day : String
	var int_day : int = Time.get_datetime_dict_from_system()["day"]
	var str_month : String
	var int_month : int = Time.get_datetime_dict_from_system()["month"]
	var str_year : String = str(Time.get_datetime_dict_from_system()["year"])
	
	str_day = str(int_day) if int_day >= 10 else '0%s' % int_day
	str_month = str(int_month) if int_month >= 10 else '0%s' % int_month
	
	return '%s.%s.%s' % [str_day, str_month, str_year]
	
func getTimeFormated() -> String:
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

func writeToLog(text, file_name) -> void:
	print(text)
	#file_name = profiles_dir + profile_name + '/' + file_name
	file_name = Root.str_RootDir + file_name

	if (FileAccess.file_exists(file_name)):
		var Log : FileAccess = FileAccess.open(file_name, FileAccess.READ_WRITE)
		Log.seek_end()
		Log.store_line(text)
	else:
		var Log : FileAccess = FileAccess.open(file_name, FileAccess.WRITE)
		Log.store_line(text)
	
func writeErrorLog(header, text, file_name) -> void:
	#'\t v. %s [%s %s]'
	writeToLog('\t %s [%s %s]' % [Root.str_AppVersion, getDateFormated(), getTimeFormated()], file_name)
	writeToLog(header, file_name)
	writeToLog(text + "\n", file_name)
	
func writeDateToLog(file_name) -> void:
	writeToLog('\t [%s %s]' % [getDateFormated(), getTimeFormated()], file_name)
	
func writeErrorLogAndExit(header, text, file_name) -> void:
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
	get_window().borderless = (false)
	writeErrorLog(header, text, file_name)
	#breakpoint
	#Engine.get_main_loop().finish() #в 4.0 вроде как убрать хотят finish()
	get_tree().quit()
