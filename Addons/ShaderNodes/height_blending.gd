@tool
extends VisualShaderNodeCustom
class_name VisualShaderHeightblend


func _get_name():
    return "hblend"


func _get_category():
    return "Custom"


func _get_description():
    return "Blend based on height inputs"


func _init():
    set_input_port_default_value(2, 0.5)
    pass



func _get_return_icon_type():
    return VisualShaderNode.PORT_TYPE_SCALAR


func _get_input_port_count():
    return 3


func _get_input_port_name(port):
    match port:
        0:
            return "a"
        1:
            return "b"
        2:
            return "factor"


func _get_input_port_type(port):
    match port:
        0:
            return VisualShaderNode.PORT_TYPE_SCALAR
        1:
            return VisualShaderNode.PORT_TYPE_SCALAR
        2:
            return VisualShaderNode.PORT_TYPE_SCALAR



func _get_output_port_count():
    return 1


func _get_output_port_name(port):
    match port:
        0:
            return "mask"


func _get_output_port_type(port):
    match port:
        0:
            return VisualShaderNode.PORT_TYPE_SCALAR


func _get_global_code(mode):
    return """
        float height_blend() {
            float blendval = 1.0;
            return blendval;
        }
    """


func _get_code(input_vars, output_vars, mode, type):
    #return output_vars[0] + " = cnoise(vec3((%s.xy + %s.xy) * %s, %s)) * 0.5 + 0.5;" % [input_vars[0], input_vars[1], input_vars[2], input_vars[3]]
    var code = """

                """
    return code + output_vars[0] + """= height_blend();"""
