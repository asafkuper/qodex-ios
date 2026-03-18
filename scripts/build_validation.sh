#!/bin/bash
#
# Build Validation Script for QodeX iOS
# Checks for common issues before building
#

set -e

echo "🔨 QodeX Build Validation"
echo "=========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Check 1: Verify no hardcoded API keys
echo ""
echo "🔍 Checking for hardcoded API keys..."
if grep -r "AIzaSy" --include="*.swift" QodeX/ 2>/dev/null || \
   grep -r "sk_live_" --include="*.swift" QodeX/ 2>/dev/null || \
   grep -r "pk_live_" --include="*.swift" QodeX/ 2>/dev/null; then
    echo -e "${RED}❌ ERROR: Found potential hardcoded API keys${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✅ No hardcoded API keys found${NC}"
fi

# Check 2: Verify fatalError only in DEBUG
echo ""
echo "🔍 Checking for fatalError in production code..."
# Look for fatalError that's NOT preceded by #if DEBUG (within 5 lines before)
FATAL_ERRORS=$(grep -n "fatalError(" --include="*.swift" -r QodeX/ | while read line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    # Check if there's a #if DEBUG within 10 lines before
    if ! sed -n "$((lineno-10)),$((lineno-1))p" "$file" 2>/dev/null | grep -q "#if DEBUG"; then
        echo "$line"
    fi
done || true)

if [ -n "$FATAL_ERRORS" ]; then
    echo -e "${YELLOW}⚠️  WARNING: Found potential fatalError outside DEBUG blocks:${NC}"
    echo "$FATAL_ERRORS"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ All fatalError calls properly guarded${NC}"
fi

# Check 3: Check for print() statements
echo ""
echo "🔍 Checking for print() statements..."
PRINT_COUNT=$(grep -r "print(" --include="*.swift" QodeX/ | wc -l)
if [ "$PRINT_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  WARNING: Found $PRINT_COUNT print() statements (should use QodeXLogger)${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ No print() statements found${NC}"
fi

# Check 4: Verify JSON files are valid
echo ""
echo "🔍 Validating JSON files..."
JSON_ERRORS=0
for file in $(find QodeX -name "*.json" -type f 2>/dev/null); do
    if ! python3 -m json.tool "$file" > /dev/null 2>&1; then
        echo -e "${RED}❌ Invalid JSON: $file${NC}"
        JSON_ERRORS=$((JSON_ERRORS + 1))
    fi
done

if [ "$JSON_ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✅ All JSON files are valid${NC}"
else
    ERRORS=$((ERRORS + JSON_ERRORS))
fi

# Check 5: Verify required content files exist
echo ""
echo "🔍 Checking required content files..."
REQUIRED_FILES=(
    "QodeX/Core/Content/LifePathMeanings.json"
    "QodeX/Core/Content/ExpressionMeanings.json"
    "QodeX/Core/Content/SoulUrgeMeanings.json"
    "QodeX/Core/Content/PersonalityMeanings.json"
    "QodeX/Core/Content/BirthdayMeanings.json"
    "QodeX/Core/Content/PersonalizedDailyReadings.json"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Missing required file: $file${NC}"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ "$MISSING_FILES" -eq 0 ]; then
    echo -e "${GREEN}✅ All required content files present${NC}"
else
    ERRORS=$((ERRORS + MISSING_FILES))
fi

# Check 6: Verify SwiftLint configuration
echo ""
echo "🔍 Checking SwiftLint..."
if [ -f ".swiftlint.yml" ]; then
    echo -e "${GREEN}✅ SwiftLint configuration found${NC}"
else
    echo -e "${YELLOW}⚠️  WARNING: No .swiftlint.yml found${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check 7: Check for TODO/FIXME comments
echo ""
echo "🔍 Checking for TODO/FIXME comments..."
TODO_COUNT=$(grep -r "TODO\|FIXME" --include="*.swift" QodeX/ | wc -l)
if [ "$TODO_COUNT" -gt 10 ]; then
    echo -e "${YELLOW}⚠️  WARNING: Found $TODO_COUNT TODO/FIXME comments${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ TODO/FIXME count acceptable ($TODO_COUNT)${NC}"
fi

# Check 8: Verify file permissions
echo ""
echo "🔍 Checking file permissions..."
if [ -x "scripts/build.sh" ] || [ -x "ship.sh" ] || [ -x "test.sh" ]; then
    echo -e "${GREEN}✅ Build scripts are executable${NC}"
else
    chmod +x scripts/*.sh *.sh 2>/dev/null || true
    echo -e "${YELLOW}⚠️  Fixed script permissions${NC}"
fi

# Summary
echo ""
echo "=========================="
echo "📊 Validation Summary"
echo "=========================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Ready to build.${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warning(s) found. Build may proceed.${NC}"
    exit 0
else
    echo -e "${RED}❌ $ERRORS error(s) and $WARNINGS warning(s) found. Fix before building.${NC}"
    exit 1
fi
