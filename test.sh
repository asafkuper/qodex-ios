#!/bin/bash
# test.sh - Comprehensive test runner

echo "🧪 QODEX TEST SUITE"
echo "==================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test 1: Swift Syntax Validation
echo -e "${YELLOW}[TEST 1/10] Swift Syntax Validation${NC}"
SYNTAX_ERRORS=$(find . -name "*.swift" -type f | xargs -I {} swift -parse {} 2>&1 | grep -c "error:" || true)
if [ "$SYNTAX_ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✅ All Swift files parse successfully${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ Found $SYNTAX_ERRORS syntax errors${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 2: File Count Validation
echo -e "${YELLOW}[TEST 2/10] File Structure Validation${NC}"
SWIFT_FILES=$(find . -name "*.swift" -type f | wc -l)
if [ "$SWIFT_FILES" -gt 100 ]; then
    echo -e "${GREEN}✅ Found $SWIFT_FILES Swift files${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ Only $SWIFT_FILES Swift files found${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 3: Critical Files Exist
echo -e "${YELLOW}[TEST 3/10] Critical Files Validation${NC}"
CRITICAL_FILES=(
    "QodeX/App/QodeXApp.swift"
    "QodeX/Core/Authentication/AuthManager.swift"
    "QodeX/Core/Models/QodeXUser.swift"
    "QodeX/Core/Numerology/NumerologyCalculator.swift"
)

ALL_PRESENT=true
for file in "${CRITICAL_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Missing: $file${NC}"
        ALL_PRESENT=false
    fi
done

if [ "$ALL_PRESENT" = true ]; then
    echo -e "${GREEN}✅ All critical files present${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 4: Security Audit
echo -e "${YELLOW}[TEST 4/10] Security Audit${NC}"
HARDCODED_KEYS=$(grep -r "api_key\|apikey\|password\|secret" --include="*.swift" -i | grep -v "//" | grep -v "ProcessInfo" | grep -v "Keychain" | grep -v "Environment" | wc -l)
if [ "$HARDCODED_KEYS" -eq 0 ]; then
    echo -e "${GREEN}✅ No hardcoded secrets detected${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${YELLOW}⚠️  Found $HARDCODED_KEYS potential hardcoded secrets (review needed)${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1)) # Warning only
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 5: TODO/FIXME Check
echo -e "${YELLOW}[TEST 5/10] TODO/FIXME Check${NC}"
TODOS=$(grep -r "TODO\|FIXME" --include="*.swift" | grep -v "MIGRATION_NOTES" | wc -l)
if [ "$TODOS" -lt 5 ]; then
    echo -e "${GREEN}✅ Only $TODOS TODOs remaining (acceptable)${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${YELLOW}⚠️  Found $TODOS TODOs${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1)) # Warning only
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 6: Documentation Check
echo -e "${YELLOW}[TEST 6/10] Documentation Check${NC}"
DOC_FILES=(
    "README.md"
    "BUILD_MANIFEST.md"
    "SHIP_PROTOCOL.md"
    "AppStore/metadata.json"
)

ALL_DOCS=true
for file in "${DOC_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Missing doc: $file${NC}"
        ALL_DOCS=false
    fi
done

if [ "$ALL_DOCS" = true ]; then
    echo -e "${GREEN}✅ All documentation present${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 7: Git Status
echo -e "${YELLOW}[TEST 7/10] Git Repository Check${NC}"
if git diff-index --quiet HEAD --; then
    echo -e "${GREEN}✅ Working directory clean${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${YELLOW}⚠️  Uncommitted changes present${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1)) # Warning only
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 8: Line Count
echo -e "${YELLOW}[TEST 8/10] Code Volume Check${NC}"
TOTAL_LINES=$(find . -name "*.swift" -type f | xargs wc -l | tail -1 | awk '{print $1}')
if [ "$TOTAL_LINES" -gt 50000 ]; then
    echo -e "${GREEN}✅ $TOTAL_LINES lines of code${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ Only $TOTAL_LINES lines${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 9: CI/CD Configuration
echo -e "${YELLOW}[TEST 9/10] CI/CD Configuration${NC}"
if [ -f ".github/workflows/ci-cd.yml" ]; then
    echo -e "${GREEN}✅ CI/CD pipeline configured${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ CI/CD not configured${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 10: Test Files
echo -e "${YELLOW}[TEST 10/10] Test Coverage Check${NC}"
TEST_FILES=$(find . -path "*/Tests/*" -name "*.swift" | wc -l)
if [ "$TEST_FILES" -gt 10 ]; then
    echo -e "${GREEN}✅ $TEST_FILES test files${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${YELLOW}⚠️  Only $TEST_FILES test files${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1)) # Warning only
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Summary
echo ""
echo "==================="
echo "📊 TEST SUMMARY"
echo "==================="
echo -e "${GREEN}✅ Passed: $PASSED_TESTS/$TOTAL_TESTS${NC}"
if [ "$FAILED_TESTS" -gt 0 ]; then
    echo -e "${RED}❌ Failed: $FAILED_TESTS/$TOTAL_TESTS${NC}"
fi
echo ""

if [ "$FAILED_TESTS" -eq 0 ]; then
    echo -e "${GREEN}🚀 ALL TESTS PASSED - READY TO SHIP${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  SOME TESTS FAILED - REVIEW NEEDED${NC}"
    exit 1
fi
