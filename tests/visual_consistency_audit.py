#!/usr/bin/env python3
"""
EverFree - Visual Consistency Audit Tool
Verifica se todas as páginas seguem o mesmo esquema visual
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

class VisualAudit:
    def __init__(self):
        self.issues = []
        self.stats = defaultdict(lambda: defaultdict(list))
    
    def scan_all_pages(self):
        """Scan all QML pages for consistency"""
        qml_dir = Path("/home/marco/Dvl/projetos/GitHub/EverFree/qml/pages")
        
        print("="*80)
        print("  EVERFREE - VISUAL CONSISTENCY AUDIT")
        print("="*80)
        print()
        
        for qml_file in sorted(qml_dir.glob("*.qml")):
            self.scan_page(qml_file)
        
        self.print_report()
        return len(self.issues) == 0
    
    def scan_page(self, filepath):
        """Scan a single page for visual consistency"""
        content = filepath.read_text()
        lines = content.split('\n')
        page_name = filepath.name
        
        # Track padding consistency
        self.extract_padding(content, page_name)
        
        # Track color usage
        self.extract_colors(content, page_name)
        
        # Track typography sizes
        self.extract_font_sizes(content, page_name)
        
        # Track button patterns
        self.extract_buttons(content, page_name)
        
        # Track card patterns
        self.extract_cards(content, page_name)
    
    def extract_padding(self, content, page_name):
        """Extract padding values"""
        patterns = {
            'leftPadding': r'leftPadding:\s*(\d+)',
            'rightPadding': r'rightPadding:\s*(\d+)',
            'topPadding': r'topPadding:\s*(\d+)',
            'bottomPadding': r'bottomPadding:\s*(\d+)',
            'anchors.margins': r'anchors\.margins:\s*(\d+)',
        }
        
        for pattern_name, pattern in patterns.items():
            matches = re.findall(pattern, content)
            if matches:
                self.stats[page_name][pattern_name] = [int(m) for m in matches]
    
    def extract_colors(self, content, page_name):
        """Extract color usage patterns"""
        color_patterns = {
            'Material.color(Material.Grey': r'Material\.color\(Material\.Grey.*?\)',
            'Material.color(Material.Green': r'Material\.color\(Material\.Green.*?\)',
            'Material.foreground': r'Material\.foreground',
            'Material.hintTextColor': r'Material\.hintTextColor',
            'Material.primaryTextColor': r'Material\.primaryTextColor',
            '#hex': r'#[0-9A-Fa-f]{6}',
        }
        
        for pattern_name, pattern in color_patterns.items():
            matches = re.findall(pattern, content)
            if matches:
                self.stats[page_name][f'color:{pattern_name}'] = len(matches)
    
    def extract_font_sizes(self, content, page_name):
        """Extract font size usage"""
        sizes = re.findall(r'font\.pixelSize:\s*(\d+)', content)
        if sizes:
            self.stats[page_name]['font_sizes'] = [int(s) for s in sizes]
    
    def extract_buttons(self, content, page_name):
        """Extract button patterns"""
        buttons = re.findall(r'Button\s*\{', content)
        highlighted = re.findall(r'highlighted:\s*true', content)
        self.stats[page_name]['buttons_total'] = len(buttons)
        self.stats[page_name]['buttons_highlighted'] = len(highlighted)
    
    def extract_cards(self, content, page_name):
        """Extract card/container patterns"""
        rectangles = re.findall(r'Rectangle\s*\{', content)
        radius = re.findall(r'radius:\s*(\d+)', content)
        self.stats[page_name]['rectangles'] = len(rectangles)
        if radius:
            self.stats[page_name]['radius_values'] = [int(r) for r in radius]
    
    def print_report(self):
        """Print comprehensive consistency report"""
        print("📊 PADDING CONSISTENCY")
        print("-" * 80)
        
        # Check leftPadding consistency
        left_paddings = {}
        for page, stats in self.stats.items():
            if 'leftPadding' in stats:
                left_paddings[page] = stats['leftPadding']
        
        if left_paddings:
            unique_values = set()
            for page, values in left_paddings.items():
                unique_values.update(values)
            
            if len(unique_values) > 2:
                print(f"🟡 Inconsistente: leftPadding varia entre {sorted(unique_values)}")
                for page, values in left_paddings.items():
                    print(f"   {page}: {values}")
            else:
                print(f"✅ Consistente: leftPadding = {unique_values}")
        
        print()
        print("🎨 COLOR USAGE")
        print("-" * 80)
        
        # Check if all pages use Material theme colors
        for page, stats in self.stats.items():
            hex_colors = stats.get('color:#hex', 0)
            if hex_colors > 5:
                print(f"🟡 {page}: Usa {hex_colors} cores hardcoded (deveria usar Material colors)")
        
        print()
        print("📝 TYPOGRAPHY CONSISTENCY")
        print("-" * 80)
        
        all_font_sizes = {}
        for page, stats in self.stats.items():
            if 'font_sizes' in stats:
                all_font_sizes[page] = sorted(set(stats['font_sizes']))
        
        if all_font_sizes:
            # Check for common sizes
            common_sizes = {11, 12, 13, 14, 15, 16, 20, 22, 24, 26}
            inconsistent = []
            
            for page, sizes in all_font_sizes.items():
                unusual = [s for s in sizes if s not in common_sizes and s > 20]
                if unusual:
                    inconsistent.append((page, unusual))
            
            if inconsistent:
                print("🟡 Tamanhos de fonte incomuns encontrados:")
                for page, sizes in inconsistent:
                    print(f"   {page}: {sizes}")
            else:
                print("✅ Tamanhos de fonte consistentes")
        
        print()
        print("🔘 BUTTON CONSISTENCY")
        print("-" * 80)
        
        for page, stats in self.stats.items():
            total = stats.get('buttons_total', 0)
            highlighted = stats.get('buttons_highlighted', 0)
            if total > 0:
                print(f"   {page}: {total} botões ({highlighted} destacados)")
        
        print()
        print("📦 CARD/RADIUS CONSISTENCY")
        print("-" * 80)
        
        radius_values = {}
        for page, stats in self.stats.items():
            if 'radius_values' in stats:
                radius_values[page] = set(stats['radius_values'])
        
        if radius_values:
            all_radius = set()
            for values in radius_values.values():
                all_radius.update(values)
            
            if len(all_radius) > 4:
                print(f"🟡 Radius varia muito: {sorted(all_radius)}")
                print("   Sugestão: padronizar em 8, 10, 12, 14")
            else:
                print(f"✅ Radius consistente: {sorted(all_radius)}")
        
        print()
        print("="*80)
        print(f"TOTAL ISSUES: {len(self.issues)}")
        print("="*80)

if __name__ == "__main__":
    audit = VisualAudit()
    success = audit.scan_all_pages()
    sys.exit(0 if success else 1)
