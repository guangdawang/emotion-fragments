shader_type canvas_item;

// 情绪颜色
uniform vec3 order_color : source_color = vec3(0.2, 0.4, 0.6);
uniform vec3 chaos_color : source_color = vec3(0.8, 0.2, 0.2);
uniform vec3 refactor_color : source_color = vec3(0.2, 0.8, 0.4);

// 情绪值 (0.0 - 1.0)
uniform float emotion_value : hint_range(0.0, 1.0) = 0.0;

// 噪点强度
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.0;

// 发光强度
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.0;

// 时间
uniform float time : hint_range(0.0, 100.0) = 0.0;

// 简单的伪随机函数
float random(vec2 coord) {
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
}

// 噪点函数
float noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	// 计算UV坐标
	vec2 uv = UV;

	// 添加噪点
	vec2 noise_coord = uv * 10.0 + time * 0.5;
	float n = noise(noise_coord) * noise_intensity;

	// 根据情绪值混合颜色
	vec3 final_color;
	if (emotion_value < 0.5) {
		final_color = mix(order_color, chaos_color, emotion_value * 2.0);
	} else {
		final_color = mix(chaos_color, refactor_color, (emotion_value - 0.5) * 2.0);
	}

	// 添加发光效果
	float dist = distance(uv, vec2(0.5));
	float glow = (1.0 - dist) * glow_intensity;
	final_color += glow;

	// 应用噪点偏移
	final_color += n;

	// 设置最终颜色
	COLOR = vec4(final_color, 1.0);
}
