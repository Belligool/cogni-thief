shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.4, 0.25, 0.1, 1.0);
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.5;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    // UV is 0,0 at top-left and 1,1 at bottom-right
    // We create a distance-based vignette that gets stronger near 0,0
    float vignette = distance(UV, vec2(0.0, 0.0));
    
    // Smoothstep creates a nice blend, power adjusts the falloff curve
    vignette = 1.0 - smoothstep(0.0, vignette_intensity, vignette);
    
    // Apply intensity and opacity
    vec4 color = vignette_color;
    color.a *= vignette * (vignette_opacity * 0.7);
    
    COLOR = color;
}