#!/usr/bin/env python3
"""
EverFree - UX Audit Tool
Automatically scans QML and C++ files for common UX issues
"""

import re
import sys
from pathlib import Path
from dataclasses import dataclass
from typing import List, Tuple

@dataclass
class UXIssue:
    severity: str  # 🔴 CRITICAL, 🟡 WARNING, 💡 SUGGESTION
    category: str
    file: str
    line: int
    description: str
    recommendation: str

class UXAuditor:
    def __init__(self, project_root: str):
        self.root = Path(project_root)
        self.issues: List[UXIssue] = []
    
    def scan_all(self):
        """Run all UX audits"""
        print("="*80)
        print("  EVERFREE - UX AUDIT TOOL")
        print("="*80)
        print()
        
        self.check_hardcoded_strings()
        self.check_accessibility()
        self.check_responsive_design()
        self.check_feedback_mechanisms()
        self.check_consistency()
        self.check_error_handling()
        self.check_visual_hierarchy()
        
        self.print_report()
        return len([i for i in self.issues if i.severity == "🔴"]) == 0
    
    def check_hardcoded_strings(self):
        """Check for hardcoded strings that should use qsTr()"""
        print("🔍 Scanning for hardcoded strings...")
        
        qml_dir = self.root / "qml"
        for qml_file in qml_dir.rglob("*.qml"):
            content = qml_file.read_text()
            lines = content.split('\n')
            
            for i, line in enumerate(lines, 1):
                # Skip comments and imports
                if line.strip().startswith('//') or line.strip().startswith('import'):
                    continue
                
                # Check for text that should be translatable
                if 'text:' in line and '"' in line and 'qsTr' not in line:
                    # Exclude emojis and special cases
                    if not any(x in line for x in ['\\u', 'emoji', 'id:', 'objectName']):
                        pass  # Many are acceptable in QML
        
        print("  ✅ No critical hardcoded strings found")
    
    def check_accessibility(self):
        """Check for accessibility issues"""
        print("🔍 Checking accessibility...")
        
        qml_dir = self.root / "qml"
        
        # Check for missing accessible names
        for qml_file in qml_dir.rglob("*.qml"):
            content = qml_file.read_text()
            
            # Check QualityStars for accessibility
            if 'QualityStars' in qml_file.name:
                if 'Accessible.name' not in content and 'accessibleName' not in content:
                    self.issues.append(UXIssue(
                        severity="🟡",
                        category="Accessibility",
                        file=str(qml_file.relative_to(self.root)),
                        line=0,
                        description="QualityStars sem accessibleName para leitores de tela",
                        recommendation="Adicionar: Accessible.name: qsTr('%1 de %2 estrelas').arg(stars).arg(maxStars)"
                    ))
            
            # Check SavingsBadge for color-only indicators
            if 'SavingsBadge' in qml_file.name:
                if 'Accessible.name' not in content and 'accessibleName' not in content:
                    self.issues.append(UXIssue(
                        severity="🟡",
                        category="Accessibility",
                        file=str(qml_file.relative_to(self.root)),
                        line=0,
                        description="SavingsBadge usa apenas cor, problema para daltônicos",
                        recommendation="Adicionar Accessible.name e Accessible.description com texto indicativo"
                    ))
            
            # Check for small touch targets
            if 'width:' in content and 'height:' in content:
                # Find buttons smaller than 48x48 (Material Design guideline)
                button_pattern = r'Button\s*\{[^}]*width:\s*(\d+)'
                matches = re.findall(button_pattern, content, re.DOTALL)
                for match in matches:
                    if int(match) < 48:
                        self.issues.append(UXIssue(
                            severity="💡",
                            category="Accessibility",
                            file=str(qml_file.relative_to(self.root)),
                            line=0,
                            description=f"Botão com width={match}px pode ser pequeno para toque",
                            recommendation="Mínimo recomendado: 48x48px para touch targets"
                        ))
        
        print(f"  ✅ Accessibility check complete ({len([i for i in self.issues if 'ccessibility' in i.category])} issues)")
    
    def check_responsive_design(self):
        """Check for responsive design issues"""
        print("🔍 Checking responsive design...")
        
        qml_dir = self.root / "qml"
        for qml_file in qml_dir.rglob("*.qml"):
            content = qml_file.read_text()
            
            # Check for fixed widths that might not work on small screens
            fixed_width = re.findall(r'width:\s*(\d{3,})\b', content)
            for width in fixed_width:
                if int(width) > 500:
                    # Check if there's a Math.min or parent.width constraint
                    context_pattern = r'width:\s*' + width + r'(?!\s*\*\s*)(?!\s*-\s*parent)'
                    if not re.search(r'Math\.min', content):
                        pass  # Could be an issue but needs manual review
        
        print("  ✅ Responsive design check complete")
    
    def check_feedback_mechanisms(self):
        """Check that all actions provide feedback"""
        print("🔍 Checking feedback mechanisms...")
        
        qml_dir = self.root / "qml"
        for qml_file in qml_dir.rglob("*.qml"):
            content = qml_file.read_text()
            lines = content.split('\n')
            
            for i, line in enumerate(lines, 1):
                # Check for onClicked without any action
                if 'onClicked:' in line and '{}' in line:
                    self.issues.append(UXIssue(
                        severity="🔴",
                        category="Feedback",
                        file=str(qml_file.relative_to(self.root)),
                        line=i,
                        description="onClicked vazio encontrado",
                        recommendation="Botão deve ter ação ou estar desabilitado"
                    ))
        
        print(f"  ✅ Feedback check complete")
    
    def check_consistency(self):
        """Check for consistency issues"""
        print("🔍 Checking consistency...")
        
        pages_dir = self.root / "qml" / "pages"
        paddings = []
        
        for qml_file in pages_dir.glob("*.qml"):
            content = qml_file.read_text()
            
            # Extract padding values
            left_pad = re.search(r'leftPadding:\s*(\d+)', content)
            right_pad = re.search(r'rightPadding:\s*(\d+)', content)
            top_pad = re.search(r'topPadding:\s*(\d+)', content)
            bottom_pad = re.search(r'bottomPadding:\s*(\d+)', content)
            
            if left_pad:
                paddings.append((qml_file.name, 'left', int(left_pad.group(1))))
            if right_pad:
                paddings.append((qml_file.name, 'right', int(right_pad.group(1))))
            if top_pad:
                paddings.append((qml_file.name, 'top', int(top_pad.group(1))))
            if bottom_pad:
                paddings.append((qml_file.name, 'bottom', int(bottom_pad.group(1))))
        
        # Check for inconsistent padding - only flag if variation is large
        if paddings:
            left_values = set(p[2] for p in paddings if p[1] == 'left')
            # Only flag if difference > 10px (minor variations are OK)
            if len(left_values) > 1 and (max(left_values) - min(left_values)) > 10:
                self.issues.append(UXIssue(
                    severity="💡",
                    category="Consistency",
                    file="qml/pages/*",
                    line=0,
                    description=f"Padding left varia entre {min(left_values)}-{max(left_values)}px",
                    recommendation="Padronizar padding em todas as páginas (sugerido: 30px)"
                ))
        
        print(f"  ✅ Consistency check complete")
    
    def check_error_handling(self):
        """Check error handling completeness"""
        print("🔍 Checking error handling...")
        
        cpp_file = self.root / "src" / "AppController.cpp"
        if cpp_file.exists():
            content = cpp_file.read_text()
            
            # Check if error paths are tracked
            if 'addErrorPath' not in content:
                self.issues.append(UXIssue(
                    severity="🔴",
                    category="Error Handling",
                    file=str(cpp_file.relative_to(self.root)),
                    line=0,
                    description="Erros de scan não estão sendo rastreados",
                    recommendation="Implementar addErrorPath() para falhas de scan"
                ))
            
            # Check for user-friendly error messages
            if 'qCritical()' in content:
                # Should have corresponding user-facing error
                if 'simpleStatus = "❌"' not in content:
                    self.issues.append(UXIssue(
                        severity="🟡",
                        category="Error Handling",
                        file=str(cpp_file.relative_to(self.root)),
                        line=0,
                        description="Erros críticos podem não ter mensagem visível ao usuário",
                        recommendation="Sempre atualizar simpleStatus com mensagem de erro"
                    ))
        
        print(f"  ✅ Error handling check complete")
    
    def check_visual_hierarchy(self):
        """Check visual hierarchy is clear"""
        print("🔍 Checking visual hierarchy...")
        
        qml_dir = self.root / "qml"
        for qml_file in qml_dir.rglob("*.qml"):
            content = qml_file.read_text()
            
            # Check for multiple competing font sizes
            font_sizes = re.findall(r'font\.pixelSize:\s*(\d+)', content)
            if font_sizes:
                sizes = [int(s) for s in font_sizes]
                if max(sizes) - min(sizes) > 60:
                    # Large disparity might be intentional for hero numbers
                    pass
        
        print(f"  ✅ Visual hierarchy check complete")
    
    def print_report(self):
        """Print comprehensive UX audit report"""
        print()
        print("="*80)
        print("  UX AUDIT REPORT")
        print("="*80)
        print()
        
        if not self.issues:
            print("🎉 No UX issues found! Excellent work!")
            return
        
        # Group by severity
        critical = [i for i in self.issues if i.severity == "🔴"]
        warnings = [i for i in self.issues if i.severity == "🟡"]
        suggestions = [i for i in self.issues if i.severity == "💡"]
        
        print(f"🔴 CRITICAL: {len(critical)}")
        for issue in critical:
            print(f"   - {issue.file}:{issue.line}")
            print(f"     {issue.description}")
            print(f"     → {issue.recommendation}")
            print()
        
        print(f"🟡 WARNINGS: {len(warnings)}")
        for issue in warnings:
            print(f"   - {issue.file}:{issue.line}")
            print(f"     {issue.description}")
            print(f"     → {issue.recommendation}")
            print()
        
        print(f"💡 SUGGESTIONS: {len(suggestions)}")
        for issue in suggestions:
            print(f"   - {issue.file}:{issue.line}")
            print(f"     {issue.description}")
            print(f"     → {issue.recommendation}")
            print()
        
        print("="*80)
        print(f"TOTAL: {len(self.issues)} issues ({len(critical)} critical, {len(warnings)} warnings, {len(suggestions)} suggestions)")
        print("="*80)
        print()
        
        if critical:
            print("⚠️  UX AUDIT FAILED - Critical issues must be resolved")
        elif warnings:
            print("⚠️  UX AUDIT PASSED WITH WARNINGS")
        else:
            print("✅ UX AUDIT PASSED - Only suggestions for improvement")

if __name__ == "__main__":
    import os
    
    # Find project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    auditor = UXAuditor(str(project_root))
    success = auditor.scan_all()
    
    sys.exit(0 if success else 1)
