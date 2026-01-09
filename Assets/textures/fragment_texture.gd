extends Resource
class_name FragmentTexture

# 碎片纹理资源
# 用于游戏中碎片的视觉表现

@export var size: Vector2 = Vector2(20, 20)
@export var color: Color = Color.WHITE
@export var shape_type: int = 0  # 0: 圆形, 1: 方形, 2: 三角形

func create_texture() -> Texture2D:
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	match shape_type:
		0:
			_create_circle_texture(image)
		1:
			_create_square_texture(image)
		2:
			_create_triangle_texture(image)

	return ImageTexture.create_from_image(image)

func _create_circle_texture(image: Image):
	var center = size / 2
	var radius = min(size.x, size.y) / 2

	for x in range(size.x):
		for y in range(size.y):
			var distance = Vector2(x, y).distance_to(center)
			if distance <= radius:
				image.set_pixel(x, y, color)

func _create_square_texture(image: Image):
	var padding = 2
	for x in range(padding, size.x - padding):
		for y in range(padding, size.y - padding):
			image.set_pixel(x, y, color)

func _create_triangle_texture(image: Image):
	var center_x = size.x / 2
	var height = size.y

	for x in range(size.x):
		for y in range(size.y):
			var normalized_x = abs(x - center_x) / (size.x / 2)
			var normalized_y = y / height

			if normalized_y >= normalized_x:
				image.set_pixel(x, y, color)
