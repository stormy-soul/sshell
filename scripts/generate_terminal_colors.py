#!/usr/bin/env python3
import json
import sys
import os
import glob
import colorsys
import re

# the logic here is mostly from end-4's illogical-impulse color generation script btw
# but leaner(& shit)
XDG_STATE_HOME = os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state"))
GENERATED_DIR = os.path.join(XDG_STATE_HOME, "quickshell/user/generated")
SCSS_FILE = os.path.join(GENERATED_DIR, "material_colors.scss")
SEQUENCE_FILE = os.path.join(GENERATED_DIR, "terminal/sequences.txt")

BASE_SCHEME = {
    "dark": {
        "term0": "#282828", "term1": "#CC241D", "term2": "#98971A", "term3": "#D79921",
        "term4": "#458588", "term5": "#B16286", "term6": "#689D6A", "term7": "#A89984",
        "term8": "#928374", "term9": "#FB4934", "term10": "#B8BB26", "term11": "#FABD2F",
        "term12": "#83A598", "term13": "#D3869B", "term14": "#8EC07C", "term15": "#EBDBB2"
    },
    "light": {
        "term0": "#FDF9F3", "term1": "#FF6188", "term2": "#A9DC76", "term3": "#FC9867",
        "term4": "#FFD866", "term5": "#F47FD4", "term6": "#78DCE8", "term7": "#333034",
        "term8": "#121212", "term9": "#FF6188", "term10": "#A9DC76", "term11": "#FC9867",
        "term12": "#FFD866", "term13": "#F47FD4", "term14": "#78DCE8", "term15": "#333034"
    }
}

SEQUENCE_TEMPLATE = """
\x1b]4;0;{term0}\a\x1b]1;0;{term0}\a\x1b]4;1;{term1}\a\x1b]4;2;{term2}\a\x1b]4;3;{term3}\a\x1b]4;4;{term4}\a
\x1b]4;5;{term5}\a\x1b]4;6;{term6}\a\x1b]4;7;{term7}\a\x1b]4;8;{term8}\a\x1b]4;9;{term9}\a\x1b]4;10;{term10}\a
\x1b]4;11;{term11}\a\x1b]4;12;{term12}\a\x1b]4;13;{term13}\a\x1b]4;14;{term14}\a\x1b]4;15;{term15}\a
\x1b]10;{term7}\a\x1b]11;{term0}\a\x1b]12;{term7}\a\x1b]13;{term7}\a\x1b]17;{term7}\a\x1b]19;{term0}\a
\x1b]4;232;{term7}\a\x1b]4;256;{term7}\a\x1b]708;{term0}\a
"""


def hex_to_rgb(hex_code):
    hex_code = hex_code.lstrip('#')
    return tuple(int(hex_code[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb):
    return '#{:02x}{:02x}{:02x}'.format(int(max(0, min(255, rgb[0]))), int(max(0, min(255, rgb[1]))), int(max(0, min(255, rgb[2]))))

def mix_colors(hex1, hex2, weight):
    r1, g1, b1 = hex_to_rgb(hex1)
    r2, g2, b2 = hex_to_rgb(hex2)
    r_new = r1 * (1 - weight) + r2 * weight
    g_new = g1 * (1 - weight) + g2 * weight
    b_new = b1 * (1 - weight) + b2 * weight
    return rgb_to_hex((r_new, g_new, b_new))

def get_color_val(color_entry):
    if isinstance(color_entry, dict):
        return color_entry.get("default", "#000000")
    return str(color_entry)

def harmonize_color(base_hex, target_hex, strength=0.2, brightness_boost=1.0, saturation_mult=1.0):
    r1, g1, b1 = hex_to_rgb(base_hex)
    r2, g2, b2 = hex_to_rgb(target_hex)
    
    h1, l1, s1 = colorsys.rgb_to_hls(r1/255.0, g1/255.0, b1/255.0)
    h2, l2, s2 = colorsys.rgb_to_hls(r2/255.0, g2/255.0, b2/255.0)
    
    if abs(h1 - h2) > 0.5:
        if h1 > h2: h2 += 1
        else: h1 += 1
    
    h_new = (h1 * (1 - strength)) + (h2 * strength)
    if h_new > 1: h_new -= 1
    
    l_new = l1 * brightness_boost
    l_new = max(0.0, min(1.0, l_new))
    
    s_new = s1 * saturation_mult
    s_new = max(0.0, min(1.0, s_new))

    r_new, g_new, b_new = colorsys.hls_to_rgb(h_new, l_new, s_new)
    return rgb_to_hex((r_new*255, g_new*255, b_new*255))


def generate_gtk_css(colors):
    
    mapping = {
        "window_bg_color": "surface",
        "window_fg_color": "on_surface",
        "view_bg_color": "surface",
        "view_fg_color": "on_surface",
        "headerbar_bg_color": "surface_container",
        "headerbar_fg_color": "on_surface",
        "headerbar_border_color": "outline",
        "headerbar_backdrop_color": "surface",
        "headerbar_shade_color": "shadow",
        "card_bg_color": "surface_container_low",
        "card_fg_color": "on_surface",
        "card_shade_color": "shadow",
        "popover_bg_color": "surface_container_low",
        "popover_fg_color": "on_surface",
        "popover_shade_color": "shadow",
        "dialog_bg_color": "surface_container",
        "dialog_fg_color": "on_surface",
        "accent_color": "primary",
        "accent_bg_color": "primary",
        "accent_fg_color": "on_primary",
        "destructive_color": "error",
        "destructive_bg_color": "error",
        "destructive_fg_color": "on_error",
        "success_color": "tertiary",
        "warning_color": "secondary", 
        "error_color": "error",
    }
    
    css_content = "/* Generated GTK Colors */\n"
    
    for name, val in colors.items():
        v = get_color_val(val)
        css_content += f"@define-color {name} {v};\n"
        
    css_content += "\n/* Semantic Mappings */\n"
    for gtk_name, mat_name in mapping.items():
        if mat_name in colors:
            v = get_color_val(colors[mat_name])
            css_content += f"@define-color {gtk_name} {v};\n"
            
    return css_content

def update_kvantum_theme(colors):
    config_home = os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
    kv_config = os.path.join(config_home, "Kvantum", "MaterialAdw", "MaterialAdw.kvconfig")
    
    if not os.path.exists(kv_config):
        print(f"Kvantum config not found at {kv_config}, skipping Qt update.")
        return

    mappings = {
        'window.color': 'background',
        'base.color': 'background',
        'alt.base.color': 'background',
        'button.color': 'surface_container',
        'light.color': 'surface_container_low',
        'mid.light.color': 'surface_container',
        'dark.color': 'surface_container_highest',
        'mid.color': 'surface_container_high',
        'highlight.color': 'primary',
        'inactive.highlight.color': 'primary',
        'text.color': 'on_background',
        'window.text.color': 'on_background',
        'button.text.color': 'on_background',
        'disabled.text.color': 'on_background',
        'tooltip.text.color': 'on_background',
        'highlight.text.color': 'on_surface',
        'link.color': 'tertiary',
        'link.visited.color': 'tertiary_fixed',
        'progress.indicator.text.color': 'on_background',
        'text.normal.color': 'on_background',
        'text.focus.color': 'on_background',
        'text.press.color': 'on_secondary_container',
        'text.toggle.color': 'on_secondary_container',
        'text.disabled.color': 'surface_dim',
    }
    
    try:
        with open(kv_config, 'r') as f:
            content = f.read()

        for key, mat_name in mappings.items():
            if mat_name in colors:
                hex_val = get_color_val(colors[mat_name])
                pattern = rf'({re.escape(key)}\s*=\s*)#?[0-9a-fA-F]+'
                if re.search(pattern, content, re.MULTILINE):
                    content = re.sub(pattern, f"\\1{hex_val}", content)
        
        with open(kv_config, 'w') as f:
            f.write(content)
        print("Updated Kvantum theme.")
        
    except Exception as e:
        print(f"Failed to update Kvantum: {e}")




def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_terminal_colors.py <colors.json>")
        sys.exit(1)

    json_path = sys.argv[1]
    
    try:
        with open(json_path, 'r') as f:
            matugen_data = json.load(f)
    except Exception as e:
        print(f"Failed to load colors.json: {e}")
        sys.exit(1)

    colors = matugen_data.get("colors", matugen_data)
    
    is_dark = matugen_data.get("is_dark_mode", False)
    if "background" in colors:
        bg = colors["background"]
        if isinstance(bg, dict): bg = bg.get("default", "#000000")
        rgb = hex_to_rgb(bg)
        lum = (0.299*rgb[0] + 0.587*rgb[1] + 0.114*rgb[2])
        is_dark = lum < 128

    mode = "dark" if is_dark else "light"
    base_terms = BASE_SCHEME[mode]
    
    primary = "#D0BCFF"
    if "primary" in colors:
         p = colors["primary"]
         if isinstance(p, dict): p = p.get("default", "#D0BCFF")
         primary = p

    primary_rgb = hex_to_rgb(primary)

    final_terms = {}
    
    PROFILES = {
        "material": {"harmonize": 0.8, "saturation": 0.55},
        "modern":   {"harmonize": 0.2, "saturation": 0.65},
        "vibrant":  {"harmonize": 0.25, "saturation": 1.1} 
    }
    
    ACTIVE_PROFILE = "material"

    profile = PROFILES[ACTIVE_PROFILE]
    harmonize_strength = profile["harmonize"]
    saturation_mult = profile["saturation"]

    boost_fg = 1.15 if is_dark else 0.9
    boost_std = 1.15 if is_dark else 1.0

    for key, val in base_terms.items():
        if key == "term0":
             if "surface_container_lowest" in colors:
                 final_terms[key] = get_color_val(colors["surface_container_lowest"])
             elif "surface" in colors:
                 final_terms[key] = get_color_val(colors["surface"])
             else:
                 final_terms[key] = harmonize_color(val, primary, 0.1, 1.0, saturation_mult)
             continue
             
        if key in ["term15", "term7"]:
             harmonized = harmonize_color(val, primary, 0.05, boost_fg, saturation_mult)
             
             target_white = "#FFFFFF"
             if "on_surface" in colors:
                 target_white = get_color_val(colors["on_surface"])
             
             if is_dark:
                 final_terms[key] = mix_colors(harmonized, target_white, 0.45)
             else:
                 final_terms[key] = target_white
             continue

        final_terms[key] = harmonize_color(val, primary, harmonize_strength, boost_std, saturation_mult)

    os.makedirs(GENERATED_DIR, exist_ok=True)

    with open(SCSS_FILE, 'w') as f:
        for k, v in colors.items():
            val = v
            if isinstance(v, dict): val = v.get("default", str(v))
            f.write(f"${k}: {val};\n")
            
        for k, v in final_terms.items():
            f.write(f"${k}: {v};\n")
            
    print(f"Generated {SCSS_FILE}")

    seq = SEQUENCE_TEMPLATE.replace("\n", "")
    for k, v in final_terms.items():
        seq = seq.replace("{" + k + "}", v)
        
    os.makedirs(os.path.dirname(SEQUENCE_FILE), exist_ok=True)
    with open(SEQUENCE_FILE, 'w') as f:
        f.write(seq)
    print(f"Saved terminal sequences to {SEQUENCE_FILE}")

    print("Applying terminal colors...")
    
    pts_files = glob.glob("/dev/pts/[0-9]*")
    for pts in pts_files:
        try:
            with open(pts, 'w') as f:
                f.write(seq)
        except PermissionError:
            print(f"Skipped {pts} (Permission denied)")
        except Exception as e:
            print(f"Failed to write to {pts}: {e}")

    print("Applying GTK colors...")
    gtk_css = generate_gtk_css(colors)
    
    config_home = os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
    gtk3_path = os.path.join(config_home, "gtk-3.0", "gtk.css")
    gtk4_path = os.path.join(config_home, "gtk-4.0", "gtk.css")
    
    for path in [gtk3_path, gtk4_path]:
        try:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, 'w') as f:
                f.write(gtk_css)
        except Exception as e:
            print(f"Failed to write GTK CSS to {path}: {e}")

    update_kvantum_theme(colors)
    
if __name__ == "__main__":
    main()

