shader_type canvas_item;

uniform float progress : hint_range(0, 1);

void fragment() {
    // 1. Corrigimos a proporção para ser um círculo perfeito
    float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
    vec2 aspect_uv = vec2(mix(0.5, UV.x, aspect_ratio), UV.y);

    // 2. Calculamos a distância do centro
    float dist = distance(aspect_uv, vec2(0.5, 0.5));

    // 3. Multiplicamos o raio por 1.5 para garantir que ele ultrapasse os cantos
    // quando o progress for 0.0 (aberto)
    float radius = (1.0 - progress) * 1.5;

    // 4. Se a distância for maior que o raio, fica preto
    float circle = step(radius, dist);

    COLOR = vec4(0.0, 0.0, 0.0, circle);
}