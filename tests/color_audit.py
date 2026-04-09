#!/usr/bin/env python3
"""
EverFree - Color Contrast Audit Tool
Verifica WCAG AA (4.5:1 para texto normal, 3:1 para texto grande)
"""

import re
import sys
from pathlib import Path

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    if len(hex_color) == 6:
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    return None

def relative_luminance(rgb):
    """Calculate relative luminance per WCAG 2.0"""
    def linearize(c):
        c = c / 255.0
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = [linearize(c) for c in rgb]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def contrast_ratio(color1, color2):
    """Calculate contrast ratio between two hex colors"""
    rgb1 = hex_to_rgb(color1)
    rgb2 = hex_to_rgb(color2)
    if not rgb1 or not rgb2:
        return 0
    l1 = relative_luminance(rgb1)
    l2 = relative_luminance(rgb2)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

# Material Design colors
MATERIAL_COLORS = {
    "Green.Shade300": "#81C784",
    "Green.Shade400": "#66BB6A",
    "Green.Shade500": "#4CAF50",
    "Green.Shade600": "#43A047",
    "Green.Shade700": "#388E3C",
    "Green.Shade800": "#2E7D32",
    "Green.Shade900": "#1B5E20",
    "Grey.Shade300": "#E0E0E0",
    "Grey.Shade500": "#9E9E9E",
    "Grey.Shade600": "#757575",
    "Grey.Shade700": "#616161",
    "Grey.Shade800": "#424242",
    "Grey.Shade900": "#212121",
    "Red.Shade300": "#E57373",
    "Red.Shade400": "#EF5350",
    "Red.Shade500": "#F44336",
    "Amber.Shade300": "#FFD54F",
    "Amber.Shade400": "#FFCA28",
    "Blue.Shade600": "#1E88E5",
    "Orange.Shade300": "#FFB74D",
    "Orange.Shade600": "#FB8C00",
    "Teal.Shade800": "#00695C",
    "white": "#FFFFFF",
    "black": "#000000",
}

# Dark theme backgrounds
DARK_BG = {
    "window": "#121212",
    "card": "#1E1E1E",
    "card_alt": "#212121",
    "button": "#3A3A3A",
}

# Known problematic combinations
ISSUES = []

def check_contrast(fg_color, bg_color, context, min_ratio=4.5):
    """Check if contrast ratio meets WCAG requirements"""
    ratio = contrast_ratio(fg_color, bg_color)
    if ratio < min_ratio:
        ISSUES.append({
            "context": context,
            "fg": fg_color,
            "bg": bg_color,
            "ratio": f"{ratio:.2f}:1",
            "required": f"{min_ratio}:1",
            "severity": "🔴 FAIL" if ratio < 3.0 else "🟡 WARNING"
        })
        return False
    return True

def scan_qml_file(filepath):
    """Scan a QML file for color issues"""
    content = filepath.read_text()
    lines = content.split('\n')
    
    # Track current background context
    current_bg = DARK_BG["window"]
    
    for i, line in enumerate(lines, 1):
        line = line.strip()
        
        # Track background changes
        if 'color:' in line and 'Material.color' not in line:
            bg_match = re.search(r'color:\s*"(#[0-9A-Fa-f]{6})"', line)
            if bg_match:
                current_bg = bg_match.group(1)
        
        # Check Material color usage
        if 'Material.color(Material.Grey' in line:
            shade_match = re.search(r'Material\.color\(Material\.Grey,\s*(Material\.\w+)\)', line)
            if shade_match:
                shade = shade_match.group(1)
                shade_name = shade.replace('Material.', 'Grey.')
                if shade_name in MATERIAL_COLORS:
                    # Check if used as text color
                    if 'color:' in line or 'foreground:' in line:
                        check_contrast(
                            MATERIAL_COLORS[shade_name],
                            current_bg,
                            f"{filepath.name}:{i} - {line.strip()[:60]}",
                            4.5
                        )
        
        # Check hardcoded colors
        color_matches = re.findall(r'color:\s*"(#[0-9A-Fa-f]{6})"', line)
        for color in color_matches:
            # Skip very dark colors on dark backgrounds (might be intentional)
            check_contrast(
                color,
                current_bg,
                f"{filepath.name}:{i} - {line.strip()[:60]}",
                4.5
            )
        
        # Check specific problematic patterns
        # Grey text on Grey background
        if 'Material.Grey' in line and ('color:' in line or 'foreground:' in line):
            if 'Shade300' in line or 'Shade500' in line:
                if 'Shade900' in content[max(0, content.rfind(line)-200):content.find(line)]:
                    ISSUES.append({
                        "context": f"{filepath.name}:{i} - Texto cinza em fundo cinza escuro",
                        "fg": "Grey.Shade300/500",
                        "bg": "Grey.Shade900",
                        "ratio": "Potencialmente baixo",
                        "required": "4.5:1",
                        "severity": "🟡 REVIEW"
                    })

def main():
    print("="*80)
    print("  EVERFREE - COLOR CONTRAST AUDIT")
    print("="*80)
    print()
    
    qml_dir = Path("/home/marco/Dvl/projetos/GitHub/EverFree/qml")
    
    for qml_file in sorted(qml_dir.rglob("*.qml")):
        scan_qml_file(qml_file)
    
    if not ISSUES:
        print("✅ No color contrast issues detected!")
        return True
    
    # Group by severity
    fails = [i for i in ISSUES if "🔴" in i["severity"]]
    warnings = [i for i in ISSUES if "🟡" in i["severity"]]
    reviews = [i for i in ISSUES if "REVIEW" in i["severity"]]
    
    print(f"🔴 FAILS: {len(fails)}")
    for issue in fails[:10]:  # Show first 10
        print(f"   {issue['context']}")
        print(f"      FG: {issue['fg']} on BG: {issue['bg']}")
        print(f"      Ratio: {issue['ratio']} (required: {issue['required']})")
        print()
    
    print(f"\n🟡 WARNINGS: {len(warnings)}")
    for issue in warnings[:10]:
        print(f"   {issue['context']}")
        print(f"      FG: {issue['fg']} on BG: {issue['bg']}")
        print(f"      Ratio: {issue['ratio']}")
        print()
    
    print(f"\n💡 NEEDS REVIEW: {len(reviews)}")
    for issue in reviews[:10]:
        print(f"   {issue['context']}")
        print()
    
    print("="*80)
    print(f"TOTAL: {len(ISSUES)} issues ({len(fails)} fails, {len(warnings)} warnings, {len(reviews)} review)")
    print("="*80)
    
    return len(fails) == 0

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
