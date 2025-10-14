shader_type canvas_item;

// This tells Godot we want access to the full rendered screen.
uniform sampler2D screen_tex : hint_screen_texture;

// 0 = color, 1 = full grayscale
uniform float desaturate : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 col = texture(screen_tex, SCREEN_UV);
    float gray = dot(col.rgb, vec3(0.3, 0.59, 0.11));
    col.rgb = mix(col.rgb, vec3(gray), desaturate);
    COLOR = col;
}
