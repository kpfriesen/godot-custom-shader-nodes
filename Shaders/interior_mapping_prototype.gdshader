shader_type spatial;
/*render_mode unshaded;*/

//credit Pedro J. Estébanez talk at 2020 godotcon: http://pedrocorp.net
//https://www.youtube.com/watch?v=9Jy3cXwR7Ws

const float ROOM_SIZE = 0.251;
const float FLOOR_OFFSET = 0.1;
const vec3 ROOM_SCALE = vec3(0.251, 0.251, 0.334);
const vec3 ROOM_OFFSET = vec3(0.0, 0.0, 0.1666);

//const vec2 grid_size = vec2(3.0, 3.0);
const float grid_size = 3.0;
const vec2 ceiling_offset = vec2(-.333, -.333);
const vec2 floor_offset = vec2(0.333, -.333);

uniform sampler2D sample_grid;

varying vec3 obj_vertex;
varying flat vec3 obj_cam;

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
    vec2 ceil_tex_coord = (obj_cam.xz + (ceiling_t * cam2pix.xz)) * vec2(is_floor * 2.0 - 1.0, 1.0);
    //front/back UVs
    float is_front = step(cam2pix.z, 0.0);
    float front_z = ceil((obj_vertex.z - ROOM_OFFSET.z) / ROOM_SCALE.z - is_front) * ROOM_SCALE.z + ROOM_OFFSET.z;
    float front_t = (front_z - obj_cam.z) / cam2pix.z;
    vec2 front_tex_coord = (obj_cam.xy + (front_t * cam2pix.xy)) * vec2( is_front * 2.0 - 1.0, 1.0);
    //left/right UVs
    float is_left = step(cam2pix.x, 0.0);
    float left_x = ceil((obj_vertex.x - ROOM_OFFSET.x) / ROOM_SCALE.x - is_left) * ROOM_SCALE.x + ROOM_OFFSET.x;
    float left_t = (left_x - obj_cam.x) / cam2pix.x;
    vec2 left_tex_coord = (obj_cam.yz + (left_t * cam2pix.yz)) * vec2(1.0, is_left * 2.0 - 1.0);
 
    vec2 ceiling_transform = (1.0 - is_floor) * ceiling_offset + (is_floor) * floor_offset;
   
    //SORTING
    vec2 CombinedUV = vec2(0.0, 0.0);
    //mask out faked faces occluded behind other faces.
    float ceiling_mask = 1.0 - step(min((left_t - ceiling_t),(front_t - ceiling_t)), 0.0001);
    float front_mask = 1.0 - step(min((left_t - front_t),(ceiling_t - front_t)), 0.001);
    float left_mask = 1.0 - step(min((ceiling_t - left_t),(front_t - left_t)), 0.00001);
    CombinedUV += (left_tex_coord * left_mask).yx * vec2(-1.0) / ROOM_SCALE.zy;
    CombinedUV += (ceil_tex_coord / ROOM_SCALE.xz / grid_size + ceiling_transform) * ceiling_mask;
    CombinedUV += (front_tex_coord * front_mask) * vec2(1.0, -1.0) / ROOM_SCALE.xy;
    
    ALBEDO = texture(sample_grid, CombinedUV).xyz * mix(vec3(left_mask, ceiling_mask, front_mask), vec3(1.0), 0.44);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
