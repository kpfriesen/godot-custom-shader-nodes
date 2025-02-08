@tool
extends VisualShaderNodeCustom
class_name VisualShaderRaymarch


func _get_name():
    return "Raymarch"


func _get_category():
    return "Custom"


func _get_description():
    return "Raymarch through texture"


func _init():
    set_input_port_default_value(2, 0.1)
    set_input_port_default_value(4, 10.0)


func _get_return_icon_type():
    return VisualShaderNode.PORT_TYPE_SCALAR


func _get_input_port_count():
    return 5


func _get_input_port_name(port):
    match port:
        0:
            return "texture"
        1:
            return "position"
        2:
            return "step size"
        3:
            return "max steps"
        4:
            return "max distance"


func _get_input_port_type(port):
    match port:
        0:
            return VisualShaderNode.PORT_TYPE_SAMPLER
        1:
            return VisualShaderNode.PORT_TYPE_VECTOR_3D
        2:
            return VisualShaderNode.PORT_TYPE_SCALAR
        3:
            return VisualShaderNode.PORT_TYPE_SCALAR_INT
        4:
            return VisualShaderNode.PORT_TYPE_SCALAR


func _get_output_port_count():
    return 3


func _get_output_port_name(port):
    match port:
        0:
            return "depth"
        1:
            return "threshold"
        2:
            return "position"


func _get_output_port_type(port):
    match port:
        0:
            return VisualShaderNode.PORT_TYPE_SCALAR
        1:
            return VisualShaderNode.PORT_TYPE_SCALAR
        2:
            return VisualShaderNode.PORT_TYPE_VECTOR_3D


func _get_global_code(mode):
    return """
        struct ray {
            vec3 dir;
            float val;
            vec3 pos;
            float dist;
        };

        ray raymarch( ray r, int steps, float max_dist, float step_size, float threshold, sampler3D volume) {
            for(int i = 0; i < steps; ++i) {
                r.val = texture(volume, r.pos).x;
                r.dist += step_size;
                r.pos += r.dir * step_size;
                if(r.val >= threshold) {
                    break;
                }
                if(r.dist >= max_dist) {
                    break;
                }
            }
            return r;
        }
    """


func _get_code(input_vars, output_vars, mode, type):
    #return output_vars[0] + " = cnoise(vec3((%s.xy + %s.xy) * %s, %s)) * 0.5 + 0.5;" % [input_vars[0], input_vars[1], input_vars[2], input_vars[3]]
    var code = """
            ray r;
                r.dir = vec3((INV_VIEW_MATRIX * vec4(-VIEW, 1.0)).xyz);
                r.pos = """ + input_vars[1] + """;
                r.val = 0.0;
                r.dist = 0.0;
                """
    return code + output_vars[0] + """= raymarch(r, %s, %s, %s, 0.5, %s).dist;""" % [input_vars[3], input_vars[4], input_vars[2], input_vars[0]]
