shader_type spatial;

uniform float max_length = 10.0;

void fragment(){
    float length = length(VERTEX);
	float alpha = 1.0 - (length / max_length);
	ALPHA = alpha;
}