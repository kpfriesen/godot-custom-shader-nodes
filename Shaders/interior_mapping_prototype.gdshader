shader_type spatial;
/*render_mode unshaded;*/

//credit Pedro J. Estébanez talk at 2020 godotcon: http://pedrocorp.net
//https://www.youtube.com/watch?v=9Jy3cXwR7Ws


const vec3 ROOM_SCALE = vec3(.251, 0.251, 0.251);
const vec3 ROOM_OFFSET = vec3(0.0, 0.0, 0.0);
const float orientation_colors = 0.0;
const float room_variations = 2.0;

const vec2 grid_size = vec2(3.0, 3.0);
const vec2 ceiling_offset = vec2(0.3333, 0.0);
const vec2 floor_offset = vec2(0.3333, 0.6666);
const vec2 left_offset = vec2(0.0, -.3333);
const vec2 right_offset = vec2(.3333, -.3333);
const vec2 front_offset = vec2(0.666, -.3333);
const vec2 back_offset = vec2(0.0, -.3333);

uniform sampler2D room_a;
uniform sampler2D room_b;

varying vec3 obj_vertex;
varying flat vec3 obj_cam;

float rand(vec3 co) {
    return fract(sin(dot(co, vec3(12.9898, 78.233, 14.8972))) * 43758.5453);
}

void vertex() {
    obj_vertex = VERTEX;
    obj_cam = inverse(MODELVIEW_MATRIX)[3].xyz;
}

void fragment() {
    vec3 cam2pix = obj_vertex - obj_cam;  
    float blue;
    
    //top/bottom UVs 
    float is_floor = step(cam2pix.y, 0.0);
    float ceiling_y = ceil((obj_vertex.y - ROOM_OFFSET.y) / ROOM_SCALE.y - is_floor) * ROOM_SCALE.y + ROOM_OFFSET.y;
    float ceiling_t = (ceiling_y - obj_cam.y) / cam2pix.y;
    vec2 inverse_floor = vec2(is_floor * 2.0 - 1.0, 1.0);
    vec2 ceil_tex_coord = fract(((obj_cam.xz + (ceiling_t * cam2pix.xz)) * inverse_floor / ROOM_SCALE.xz - ROOM_OFFSET.xz * inverse_floor)) / grid_size;
    //front/back UVs
    float is_front = step(cam2pix.z, 0.0);
    float front_z = ceil((obj_vertex.z - ROOM_OFFSET.z) / ROOM_SCALE.z - is_front) * ROOM_SCALE.z + ROOM_OFFSET.z;
    float front_t = (front_z - obj_cam.z) / cam2pix.z;
    vec2 inverse_front = vec2(is_front * 2.0 - 1.0, 1.0);
    vec2 front_tex_coord = fract(((obj_cam.xy + (front_t * cam2pix.xy)) * inverse_front / ROOM_SCALE.xy - ROOM_OFFSET.xy * inverse_front)) / grid_size;
    //left/right UVs
    float is_left = step(cam2pix.x, 0.0);
    float left_x = ceil((obj_vertex.x - ROOM_OFFSET.x) / ROOM_SCALE.x - is_left) * ROOM_SCALE.x + ROOM_OFFSET.x;
    float left_t = (left_x - obj_cam.x) / cam2pix.x;
    vec2 inverse_left = vec2(is_left * 2.0 - 1.0, 1.0);
    vec2 left_tex_coord = fract(((obj_cam.zy + (left_t * cam2pix.zy)) * inverse_left / ROOM_SCALE.zy - ROOM_OFFSET.zy * inverse_left)) / grid_size;
    
    //OFFSETS  revisit these can break
    vec3 object_normal = (vec4(NORMAL, 1.0) * VIEW_MATRIX).xyz;

    vec2 ceiling_transform = (1.0 - is_floor) * ceiling_offset + (is_floor) * floor_offset;
    vec2 front_transform = (1.0 - is_front) * back_offset + (is_front) * front_offset - vec2(object_normal.z, 0) / grid_size; //subtract normal / grid to offset given view texture (not modular at all)
    vec2 left_transform = (1.0 - is_left) * right_offset + (is_left) * left_offset - vec2(object_normal.x, 0) / grid_size;
   
    //SORTING
    vec2 CombinedUV = vec2(0.0, 0.0);
    //mask out faked faces occluded behind other faces.
    float ceiling_mask = 1.0 - step(min((left_t - ceiling_t),(front_t - ceiling_t)), 0.0);
    float front_mask = 1.0 - step(min((left_t - front_t),(ceiling_t - front_t)), 0.0);
    float left_mask = 1.0 - step(min((ceiling_t - left_t),(front_t - left_t)), 0.0);
    CombinedUV += ((left_tex_coord).xy * vec2(-1.0) + left_transform) * left_mask;
    CombinedUV += (ceil_tex_coord + ceiling_transform) * ceiling_mask;
    CombinedUV += (front_tex_coord * vec2(1.0, -1.0) + front_transform) * front_mask;
    
    
    vec3 location = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz -  NODE_POSITION_WORLD - ROOM_OFFSET * 2.0;
    vec3 location_scaled = location / ROOM_SCALE / 2.0;
    float mask = round(rand(vec3(floor(location_scaled.x), floor(location_scaled.y), floor(location_scaled.z))) * 1.0) / 2.0;
    vec3 exteriorUV = fract(location_scaled);
    
    vec3 room;
    if (mask > 0.0) {
        room = texture(room_a, CombinedUV).xyz;
    } else {
        room = texture(room_b, CombinedUV).xyz;
    }
    //room = texture(room_a, CombinedUV).xyz;
    

    
    //EMISSION = texture(sample_grid, CombinedUV).xyz * mix(vec3(left_mask, ceiling_mask, front_mask), vec3(1.0), 1.0 - orientation_colors) * 0.5;
    EMISSION = room * 0.8;
    ALBEDO = vec3(mask);
    //ALBEDO = vec3(0.1);
    ROUGHNESS = 0.1;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
