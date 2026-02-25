class_name VWIPalette

var colors : PackedColorArray
var colors_cnt : int

func readColors(buffer : StreamPeerBuffer, count : int) -> void:
	colors_cnt = count
	for i in range(count):
		colors.append(Color8(buffer.get_u8(), buffer.get_u8(), buffer.get_u8()))
		#colors.append(Vector3i(buffer.get_u8(), buffer.get_u8(), buffer.get_u8()))

func FromBytes(buffer : StreamPeerBuffer) -> void:
	buffer.seek(buffer.get_position() + 4)
	var data_size : int = buffer.get_u32()
	var data_start : int = buffer.get_position()
	while (buffer.get_position() < data_start + data_size):
		var section_name : String = buffer.get_utf8_string(4)
		var section_len  : int    = buffer.get_u32()
		match section_name:
			'PALT':
				@warning_ignore("integer_division")
				var colors_cnt : int = section_len / 3
				readColors(buffer, colors_cnt)
			_:
				buffer.seek(buffer.get_position() + section_len)

func getColorByIndex(idx : int) -> Color:
	if idx < colors_cnt:
		return colors[idx]
	return Color(0, 0, 0)
