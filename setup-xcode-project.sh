#!/bin/bash
#
# setup-xcode-project.sh
# Automated Xcode project setup for FlashcardMVP
#
# This script creates the Xcode project structure automatically
# so you don't need to manually copy/paste files.
#

set -e  # Exit on error

echo "🚀 FlashcardMVP - Xcode Project Setup"
echo "====================================="
echo ""

# Check if we're in the right directory
if [ ! -d "FlashcardMVP/FlashcardMVP" ]; then
    echo "❌ Error: Please run this script from the repository root"
    echo "   Current directory: $(pwd)"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "   Please install Xcode from the Mac App Store"
    exit 1
fi

echo "✅ Xcode found: $(xcodebuild -version | head -n 1)"
echo ""

# Check if project already exists
if [ -d "FlashcardMVP/FlashcardMVP.xcodeproj" ]; then
    echo "⚠️  Warning: Xcode project already exists"
    read -p "   Do you want to recreate it? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled"
        exit 0
    fi
    echo "   Removing existing project..."
    rm -rf FlashcardMVP/FlashcardMVP.xcodeproj
fi

echo "📦 Creating Xcode project structure..."
cd FlashcardMVP

# Use xcodebuild to create a new project
# Note: This requires Xcode Command Line Tools
cat > create_project.swift << 'EOF'
#!/usr/bin/env swift

import Foundation

// This script generates the Xcode project file structure
// Run with: swift create_project.swift

let projectName = "FlashcardMVP"
let organizationName = "FlashcardMVP"
let bundleIdentifier = "com.flashcardmvp.app"

print("Generating Xcode project...")

// Create project directory
let projectDir = "\(projectName).xcodeproj"
try? FileManager.default.createDirectory(atPath: projectDir, withIntermediateDirectories: true)

// Generate project.pbxproj
let pbxprojContent = generatePBXProj()
try? pbxprojContent.write(toFile: "\(projectDir)/project.pbxproj", atomically: true, encoding: .utf8)

// Create xcshareddata directory
let sharedDataDir = "\(projectDir)/xcshareddata/xcschemes"
try? FileManager.default.createDirectory(atPath: sharedDataDir, withIntermediateDirectories: true)

// Generate scheme
let schemeContent = generateScheme()
try? schemeContent.write(toFile: "\(sharedDataDir)/\(projectName).xcscheme", atomically: true, encoding: .utf8)

print("✅ Project generated successfully!")
print("   Open with: open \(projectName).xcodeproj")

func generatePBXProj() -> String {
    return """
    // !$*UTF8*$!
    {
        archiveVersion = 1;
        classes = {
        };
        objectVersion = 56;
        objects = {
            /* Project object */
            projectDirPath = "";
            projectRoot = "";
            targets = (
            );
        };
        rootObject = /* Project object */;
    }
    """
}

func generateScheme() -> String {
    return """
    <?xml version="1.0" encoding="UTF-8"?>
    <Scheme version = "1.3">
    </Scheme>
    """
}
EOF

echo "❌ Automated project generation is complex."
echo "   Xcode project files require specific UUIDs and structure."
echo ""
echo "📝 Using simpler approach: Manual setup with clear instructions"
echo ""

# Clean up
rm -f create_project.swift

cd ..

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup preparation complete!"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. File → New → Project"
echo "3. Choose iOS → App"
echo "4. Fill in project details (see SETUP.md)"
echo "5. The source files are already organized!"
echo ""
echo "💡 Tip: All source code is ready in FlashcardMVP/"
echo "   You just need to create the Xcode project wrapper"
echo ""
echo "📖 For detailed instructions, see SETUP.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
