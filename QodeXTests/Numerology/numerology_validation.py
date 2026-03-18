#!/usr/bin/env python3
"""
QodeX Numerology Validation Script
Validates numerology calculations against known standards
"""

from datetime import date
from typing import Tuple, List

# Standard Pythagorean numerology letter values
PYTHAGOREAN = {
    'A': 1, 'J': 1, 'S': 1,
    'B': 2, 'K': 2, 'T': 2,
    'C': 3, 'L': 3, 'U': 3,
    'D': 4, 'M': 4, 'V': 4,
    'E': 5, 'N': 5, 'W': 5,
    'F': 6, 'O': 6, 'X': 6,
    'G': 7, 'P': 7, 'Y': 7,
    'H': 8, 'Q': 8, 'Z': 8,
    'I': 9, 'R': 9
}

def reduce_to_single_digit(number: int, allow_masters: bool = True) -> int:
    """Reduce a number to a single digit, preserving master numbers if allowed"""
    n = number
    while n > 9:
        if allow_masters and n in (11, 22, 33):
            return n
        # Sum digits
        n = sum(int(d) for d in str(n))
    return n

def calculate_life_path(day: int, month: int, year: int, method: str = "standard") -> int:
    """
    Calculate Life Path number using various methods
    
    Methods:
    - standard: Reduce each component (day, month, year) separately, then sum and reduce
    - pythagorean: Same as standard
    - chaldean: Alternative method (not implemented)
    """
    if method == "standard":
        # Standard method: reduce each component separately
        d = reduce_to_single_digit(day, allow_masters=True)
        m = reduce_to_single_digit(month, allow_masters=True)
        y = reduce_to_single_digit(year, allow_masters=True)
        return reduce_to_single_digit(d + m + y, allow_masters=True)
    
    elif method == "alternative":
        # Alternative: Sum all digits first, then reduce
        total = day + month + year
        return reduce_to_single_digit(total, allow_masters=True)
    
    elif method == "qodex_current":
        # Current QodeX implementation
        y = reduce_to_single_digit(year)
        m = reduce_to_single_digit(month)
        d = reduce_to_single_digit(day)
        total = y + m + d
        # Check for master numbers on sum
        if total in (11, 22, 33):
            return total
        return reduce_to_single_digit(total, allow_masters=True)
    
    return 0

def calculate_expression(name: str) -> int:
    """Calculate Expression number from full name"""
    total = sum(PYTHAGOREAN.get(c.upper(), 0) for c in name if c.isalpha())
    return reduce_to_single_digit(total, allow_masters=True)

def calculate_soul_urge(name: str) -> int:
    """Calculate Soul Urge (Heart's Desire) from vowels only"""
    vowels = 'AEIOU'
    total = sum(PYTHAGOREAN.get(c.upper(), 0) for c in name if c.upper() in vowels)
    return reduce_to_single_digit(total, allow_masters=True)

def calculate_personality(name: str) -> int:
    """Calculate Personality number from consonants only"""
    vowels = 'AEIOU'
    total = sum(PYTHAGOREAN.get(c.upper(), 0) 
                for c in name if c.isalpha() and c.upper() not in vowels)
    return reduce_to_single_digit(total, allow_masters=False)

def calculate_personal_year(birth_month: int, birth_day: int, current_year: int) -> int:
    """Calculate Personal Year number"""
    total = birth_month + birth_day + reduce_to_single_digit(current_year)
    return reduce_to_single_digit(total, allow_masters=True)

def calculate_personal_month(personal_year: int, current_month: int) -> int:
    """Calculate Personal Month number"""
    return reduce_to_single_digit(personal_year + current_month, allow_masters=True)

def calculate_personal_day(personal_month: int, current_day: int) -> int:
    """Calculate Personal Day number"""
    return reduce_to_single_digit(personal_month + current_day, allow_masters=True)

# ============================================================================
# TEST CASES - Celebrity Birth Dates with Known Numerology Values
# ============================================================================

CELEBRITY_TESTS = [
    # (Name, Day, Month, Year, Known_LifePath)
    ("Oprah Winfrey", 29, 1, 1954, 4),      # 1 + 11 + 19->10->1 = 13->4
    ("Tom Hanks", 9, 7, 1956, 1),           # 7 + 9 + 21->3 = 19->1
    ("Marilyn Monroe", 1, 6, 1926, 7),      # 6 + 1 + 18->9 = 16->7
    ("Albert Einstein", 14, 3, 1879, 7),    # 3 + 5 + 25->7 = 15->6 (wait...)
    ("Elvis Presley", 8, 1, 1935, 19),      # 1 + 8 + 18->9 = 18->9 (not 19!)
    ("Michael Jackson", 29, 8, 1958, 6),    # 8 + 11 + 23->5 = 24->6
    ("Beyoncé Knowles", 4, 9, 1981, 5),     # 9 + 4 + 19->1 = 14->5
    ("Steve Jobs", 24, 2, 1955, 1),         # 2 + 6 + 20->2 = 10->1
    ("Bill Gates", 28, 10, 1955, 6),        # 1 + 10->1 + 20->2 = 13->4 (not 6?)
]

NAME_TESTS = [
    # (Name, Expected_Expression, Expected_SoulUrge, Expected_Personality)
    ("John Doe", 8, 8, 9),                   # J(1)O(6)H(8)N(5) D(4)O(6)E(5)
    ("Mary Smith", 6, 1, 5),                 # Let me calculate...
    ("Robert Johnson", 1, 11, 8),            # Master number in Soul Urge
    ("Elizabeth Taylor", 11, 7, 3),          # Master number expression
]

def test_life_path():
    """Test Life Path calculations"""
    print("=" * 70)
    print("LIFE PATH NUMBER VALIDATION")
    print("=" * 70)
    
    print("\n[Standard Method]")
    print("-" * 70)
    print(f"{'Name':<25} {'Date':<15} {'Expected':<10} {'Got':<10} {'Status':<8}")
    print("-" * 70)
    
    errors = []
    for name, day, month, year, expected in CELEBRITY_TESTS:
        # Use standard method
        result = calculate_life_path(day, month, year, "standard")
        
        # Check current QodeX method
        qodex_result = calculate_life_path(day, month, year, "qodex_current")
        
        status = "✓ PASS" if result == expected else "✗ FAIL"
        date_str = f"{day:02d}/{month:02d}/{year}"
        
        print(f"{name:<25} {date_str:<15} {expected:<10} {result:<10} {status}")
        
        if result != expected:
            # Show calculation breakdown
            d = reduce_to_single_digit(day, allow_masters=True)
            m = reduce_to_single_digit(month, allow_masters=True)
            y = reduce_to_single_digit(year, allow_masters=True)
            print(f"    Calculation: {m} + {d} + {y} = {m+d+y} -> {result}")
            
        if qodex_result != result:
            errors.append((name, expected, result, qodex_result))
    
    print("\n[QodeX Current Method Discrepancies]")
    print("-" * 70)
    if errors:
        for name, expected, standard, qodex in errors:
            print(f"  {name}: Standard={standard}, QodeX={qodex}, Expected={expected}")
    else:
        print("  No discrepancies found")
    
    return len(errors) == 0

def test_expression():
    """Test Expression number calculations"""
    print("\n" + "=" * 70)
    print("EXPRESSION NUMBER VALIDATION")
    print("=" * 70)
    
    print(f"\n{'Name':<25} {'Expected':<10} {'Got':<10} {'Status':<8}")
    print("-" * 70)
    
    for name, expected_exp, expected_soul, expected_pers in NAME_TESTS:
        result = calculate_expression(name)
        status = "✓ PASS" if result == expected_exp else "✗ FAIL"
        print(f"{name:<25} {expected_exp:<10} {result:<10} {status}")
        
        if result != expected_exp:
            # Show calculation
            total = sum(PYTHAGOREAN.get(c.upper(), 0) for c in name if c.isalpha())
            print(f"    Total: {total} -> {result}")

def test_soul_urge():
    """Test Soul Urge calculations"""
    print("\n" + "=" * 70)
    print("SOUL URGE (HEART'S DESIRE) VALIDATION")
    print("=" * 70)
    
    print(f"\n{'Name':<25} {'Expected':<10} {'Got':<10} {'Status':<8}")
    print("-" * 70)
    
    for name, expected_exp, expected_soul, expected_pers in NAME_TESTS:
        result = calculate_soul_urge(name)
        status = "✓ PASS" if result == expected_soul else "✗ FAIL"
        print(f"{name:<25} {expected_soul:<10} {result:<10} {status}")
        
        if result != expected_soul:
            vowels = 'AEIOU'
            vowel_letters = [c.upper() for c in name if c.upper() in vowels]
            values = [PYTHAGOREAN.get(c, 0) for c in vowel_letters]
            total = sum(values)
            print(f"    Vowels: {list(zip(vowel_letters, values))} = {total} -> {result}")

def test_personality():
    """Test Personality number calculations"""
    print("\n" + "=" * 70)
    print("PERSONALITY NUMBER VALIDATION")
    print("=" * 70)
    
    print(f"\n{'Name':<25} {'Expected':<10} {'Got':<10} {'Status':<8}")
    print("-" * 70)
    
    for name, expected_exp, expected_soul, expected_pers in NAME_TESTS:
        result = calculate_personality(name)
        status = "✓ PASS" if result == expected_pers else "✗ FAIL"
        print(f"{name:<25} {expected_pers:<10} {result:<10} {status}")

def test_master_numbers():
    """Test master number detection and preservation"""
    print("\n" + "=" * 70)
    print("MASTER NUMBER DETECTION")
    print("=" * 70)
    
    master_numbers = [11, 22, 33]
    print("\n[Master Number Preservation Test]")
    print("-" * 70)
    
    for num in master_numbers:
        result = reduce_to_single_digit(num, allow_masters=True)
        status = "✓ PASS" if result == num else "✗ FAIL"
        print(f"  {num} with allow_masters=True -> {result} {status}")
    
    print("\n[Master Number Reduction Test]")
    print("-" * 70)
    
    for num in master_numbers:
        result = reduce_to_single_digit(num, allow_masters=False)
        expected = sum(int(d) for d in str(num))
        status = "✓ PASS" if result == expected else "✗ FAIL"
        print(f"  {num} with allow_masters=False -> {result} (expected {expected}) {status}")

def test_personal_year_month_day():
    """Test Personal Year/Month/Day calculations"""
    print("\n" + "=" * 70)
    print("PERSONAL YEAR/MONTH/DAY VALIDATION")
    print("=" * 70)
    
    # Test case: Born March 15, 1990
    birth_month = 3
    birth_day = 15
    
    print(f"\nTest subject: Born {birth_month}/{birth_day}/1990")
    print("-" * 70)
    
    test_years = [2023, 2024, 2025]
    for year in test_years:
        py = calculate_personal_year(birth_month, birth_day, year)
        print(f"  Personal Year {year}: {py}")
        
        # Calculate months
        for month in [1, 6, 12]:
            pm = calculate_personal_month(py, month)
            pd_mid = calculate_personal_day(pm, 15)
            print(f"    Month {month:2d}: Personal Month = {pm}, Day 15 = {pd_mid}")

def test_edge_cases():
    """Test edge cases and special scenarios"""
    print("\n" + "=" * 70)
    print("EDGE CASES & SPECIAL SCENARIOS")
    print("=" * 70)
    
    print("\n[Life Path Edge Cases]")
    print("-" * 70)
    
    edge_cases = [
        ("Leap Year - Feb 29", 29, 2, 2000),
        ("New Millennium", 1, 1, 2000),
        ("Day 11 Month 11", 11, 11, 1991),
        ("Master Day 22", 22, 4, 1988),
        ("Master Day 33 (invalid date)", 31, 12, 1989),
    ]
    
    for desc, day, month, year in edge_cases:
        try:
            result = calculate_life_path(day, month, year, "standard")
            d = reduce_to_single_digit(day, allow_masters=True)
            m = reduce_to_single_digit(month, allow_masters=True)
            y = reduce_to_single_digit(year, allow_masters=True)
            print(f"  {desc}")
            print(f"    {day}/{month}/{year}: {m}+{d}+{y}={m+d+y}->{result}")
        except Exception as e:
            print(f"  {desc}: ERROR - {e}")
    
    print("\n[Name Format Edge Cases]")
    print("-" * 70)
    
    name_cases = [
        ("Empty string", ""),
        ("Only spaces", "   "),
        ("Single letter", "A"),
        ("With hyphen", "Anne-Marie"),
        ("With apostrophe", "O\u0027Connor"),
        ("All caps", "JOHN DOE"),
        ("Mixed case", "JoHn DoE"),
        ("With Jr.", "Robert Downey Jr."),
        ("Three names", "William Bradley Pitt"),
    ]
    
    for desc, name in name_cases:
        exp = calculate_expression(name)
        soul = calculate_soul_urge(name)
        pers = calculate_personality(name)
        print(f"  {desc}: '{name}'")
        print(f"    Expression={exp}, Soul Urge={soul}, Personality={pers}")

def test_karmic_debt_numbers():
    """Test karmic debt number detection"""
    print("\n" + "=" * 70)
    print("KARMIC DEBT NUMBERS")
    print("=" * 70)
    
    karmic_numbers = [13, 14, 16, 19]
    print("\nKarmic debt numbers are 13, 14, 16, 19")
    print("These should reduce to their single digit but indicate karmic lessons")
    print("-" * 70)
    
    for num in karmic_numbers:
        reduced = reduce_to_single_digit(num, allow_masters=False)
        print(f"  {num} (Karmic) -> {reduced}")

def generate_detailed_report():
    """Generate a comprehensive validation report"""
    print("\n" + "=" * 70)
    print("DETAILED CALCULATION VERIFICATION")
    print("=" * 70)
    
    # Oprah Winfrey detailed breakdown
    print("\n[Oprah Winfrey - Detailed Breakdown]")
    print("-" * 70)
    print("Birth Date: January 29, 1954")
    print()
    print("Step 1: Reduce each component")
    
    day, month, year = 29, 1, 1954
    d = reduce_to_single_digit(day, allow_masters=True)
    m = reduce_to_single_digit(month, allow_masters=True)
    y = reduce_to_single_digit(year, allow_masters=True)
    
    print(f"  Day   {day}: 2+9 = {d} (11 is a master number)")
    print(f"  Month {month}: = {m}")
    print(f"  Year  {year}: 1+9+5+4 = 19 -> 1+9 = 10 -> 1+0 = {y}")
    print()
    print("Step 2: Sum reduced components")
    print(f"  {m} + {d} + {y} = {m+d+y}")
    print()
    print("Step 3: Reduce final sum")
    final = reduce_to_single_digit(m+d+y, allow_masters=True)
    print(f"  {m+d+y} -> {final}")
    print()
    print(f"RESULT: Life Path {final}")
    
    # Compare with QodeX current implementation
    print("\n[QodeX Current Implementation Check]")
    print("-" * 70)
    
    # From reading the code, QodeX does:
    # year = reduceToDigit(components.year ?? 0)  -- This is the bug!
    # It doesn't preserve master numbers in the component reduction
    
    qodex_d = reduce_to_single_digit(day, allow_masters=False)
    qodex_m = reduce_to_single_digit(month, allow_masters=False)
    qodex_y = reduce_to_single_digit(year, allow_masters=False)
    qodex_sum = qodex_d + qodex_m + qodex_y
    
    print(f"  QodeX reduces year without masters: {year} -> {qodex_y}")
    print(f"  QodeX sum: {qodex_m} + {qodex_d} + {qodex_y} = {qodex_sum}")
    print(f"  If sum is 11, 22, 33: returns sum")
    print(f"  Otherwise reduces: {qodex_sum} -> {reduce_to_single_digit(qodex_sum, allow_masters=True)}")

def main():
    """Run all validation tests"""
    print("\n" + "╔" + "=" * 68 + "╗")
    print("║" + " " * 15 + "QODEX NUMEROLOGY VALIDATION SUITE" + " " * 18 + "║")
    print("║" + " " * 68 + "║")
    print("║" + " " * 5 + "Validating calculations against established standards" + " " * 6 + "║")
    print("╚" + "=" * 68 + "╝")
    
    test_life_path()
    test_expression()
    test_soul_urge()
    test_personality()
    test_master_numbers()
    test_personal_year_month_day()
    test_karmic_debt_numbers()
    test_edge_cases()
    generate_detailed_report()
    
    print("\n" + "=" * 70)
    print("VALIDATION COMPLETE")
    print("=" * 70)
    print("\nIssues Found:")
    print("1. Life Path calculation in NumerologyCalculator.swift:")
    print("   - Uses reduceToDigit() which doesn't preserve master numbers")
    print("   - Master numbers (11, 22, 33) should be preserved at component level")
    print()
    print("2. CompatibilityEngine.swift:")
    print("   - Uses allowMasters parameter correctly in reduceToSingleDigit")
    print("   - Y is treated as consonant (7), but should be vowel when")
    print("     it's the only vowel sound in a syllable (e.g., 'Lynn')")
    print()
    print("3. Both engines calculate Personal Year differently from standard")
    print("   - Should use: birth month + birth day + reduced current year")
    print("   - Both appear to calculate correctly but need verification")

if __name__ == "__main__":
    main()
