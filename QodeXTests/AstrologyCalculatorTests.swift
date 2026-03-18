import XCTest
@testable import QodeX

final class AstrologyCalculatorTests: XCTestCase {
    
    var calculator: AstrologyCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = AstrologyCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    // MARK: - Sun Sign Tests
    
    func testSunSign_Aries() {
        let date = DateComponents(year: 1990, month: 4, day: 5).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .aries)
    }
    
    func testSunSign_Taurus() {
        let date = DateComponents(year: 1990, month: 5, day: 10).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .taurus)
    }
    
    func testSunSign_Gemini() {
        let date = DateComponents(year: 1990, month: 6, day: 15).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .gemini)
    }
    
    func testSunSign_Cancer() {
        let date = DateComponents(year: 1990, month: 7, day: 10).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .cancer)
    }
    
    func testSunSign_Leo() {
        let date = DateComponents(year: 1990, month: 8, day: 15).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .leo)
    }
    
    func testSunSign_Virgo() {
        let date = DateComponents(year: 1990, month: 9, day: 10).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .virgo)
    }
    
    func testSunSign_Libra() {
        let date = DateComponents(year: 1990, month: 10, day: 5).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .libra)
    }
    
    func testSunSign_Scorpio() {
        let date = DateComponents(year: 1990, month: 11, day: 10).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .scorpio)
    }
    
    func testSunSign_Sagittarius() {
        let date = DateComponents(year: 1990, month: 12, day: 5).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .sagittarius)
    }
    
    func testSunSign_Capricorn() {
        let date = DateComponents(year: 1990, month: 1, day: 5).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .capricorn)
    }
    
    func testSunSign_Aquarius() {
        let date = DateComponents(year: 1990, month: 2, day: 5).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .aquarius)
    }
    
    func testSunSign_Pisces() {
        let date = DateComponents(year: 1990, month: 3, day: 5).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .pisces)
    }
    
    // MARK: - Cusp Date Tests
    
    func testSunSign_AriesTaurusCusp() {
        let date = DateComponents(year: 1990, month: 4, day: 19).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .aries)
    }
    
    func testSunSign_TaurusFirstDay() {
        let date = DateComponents(year: 1990, month: 4, day: 20).date!
        let sign = calculator.sunSign(for: date)
        XCTAssertEqual(sign, .taurus)
    }
    
    // MARK: - Moon Phase Tests
    
    func testMoonPhase_NewMoon() {
        let date = DateComponents(year: 2024, month: 1, day: 11).date!
        let phase = calculator.moonPhase(for: date)
        XCTAssertEqual(phase, .newMoon)
    }
    
    func testMoonPhase_FirstQuarter() {
        let date = DateComponents(year: 2024, month: 1, day: 18).date!
        let phase = calculator.moonPhase(for: date)
        XCTAssertEqual(phase, .firstQuarter)
    }
    
    func testMoonPhase_FullMoon() {
        let date = DateComponents(year: 2024, month: 1, day: 25).date!
        let phase = calculator.moonPhase(for: date)
        XCTAssertEqual(phase, .fullMoon)
    }
    
    func testMoonPhase_LastQuarter() {
        let date = DateComponents(year: 2024, month: 2, day: 2).date!
        let phase = calculator.moonPhase(for: date)
        XCTAssertEqual(phase, .lastQuarter)
    }
    
    func testMoonPhase_WaxingCrescent() {
        let date = DateComponents(year: 2024, month: 1, day: 14).date!
        let phase = calculator.moonPhase(for: date)
        XCTAssertEqual(phase, .waxingCrescent)
    }
    
    func testMoonPhase_WaningGibbous() {
        let date = DateComponents(year: 2024, month: 1, day: 28).date!
        let phase = calculator.moonPhase(for: date)
        XCTAssertEqual(phase, .waningGibbous)
    }
    
    // MARK: - Element Tests
    
    func testElement_FireSigns() {
        XCTAssertEqual(calculator.element(for: .aries), .fire)
        XCTAssertEqual(calculator.element(for: .leo), .fire)
        XCTAssertEqual(calculator.element(for: .sagittarius), .fire)
    }
    
    func testElement_EarthSigns() {
        XCTAssertEqual(calculator.element(for: .taurus), .earth)
        XCTAssertEqual(calculator.element(for: .virgo), .earth)
        XCTAssertEqual(calculator.element(for: .capricorn), .earth)
    }
    
    func testElement_AirSigns() {
        XCTAssertEqual(calculator.element(for: .gemini), .air)
        XCTAssertEqual(calculator.element(for: .libra), .air)
        XCTAssertEqual(calculator.element(for: .aquarius), .air)
    }
    
    func testElement_WaterSigns() {
        XCTAssertEqual(calculator.element(for: .cancer), .water)
        XCTAssertEqual(calculator.element(for: .scorpio), .water)
        XCTAssertEqual(calculator.element(for: .pisces), .water)
    }
    
    // MARK: - Modality Tests
    
    func testModality_Cardinal() {
        XCTAssertEqual(calculator.modality(for: .aries), .cardinal)
        XCTAssertEqual(calculator.modality(for: .cancer), .cardinal)
        XCTAssertEqual(calculator.modality(for: .libra), .cardinal)
        XCTAssertEqual(calculator.modality(for: .capricorn), .cardinal)
    }
    
    func testModality_Fixed() {
        XCTAssertEqual(calculator.modality(for: .taurus), .fixed)
        XCTAssertEqual(calculator.modality(for: .leo), .fixed)
        XCTAssertEqual(calculator.modality(for: .scorpio), .fixed)
        XCTAssertEqual(calculator.modality(for: .aquarius), .fixed)
    }
    
    func testModality_Mutable() {
        XCTAssertEqual(calculator.modality(for: .gemini), .mutable)
        XCTAssertEqual(calculator.modality(for: .virgo), .mutable)
        XCTAssertEqual(calculator.modality(for: .sagittarius), .mutable)
        XCTAssertEqual(calculator.modality(for: .pisces), .mutable)
    }
    
    // MARK: - Compatibility Tests
    
    func testCompatibility_High() {
        let score = calculator.compatibility(between: .aries, and: .leo)
        XCTAssertGreaterThan(score, 70)
    }
    
    func testCompatibility_Medium() {
        let score = calculator.compatibility(between: .aries, and: .gemini)
        XCTAssertGreaterThan(score, 50)
        XCTAssertLessThan(score, 80)
    }
    
    func testCompatibility_Low() {
        let score = calculator.compatibility(between: .aries, and: .cancer)
        XCTAssertLessThan(score, 50)
    }
    
    // MARK: - Daily Horoscope Tests
    
    func testDailyHoroscope_ReturnsContent() {
        let date = Date()
        let horoscope = calculator.dailyHoroscope(for: .aries, on: date)
        XCTAssertFalse(horoscope.isEmpty)
        XCTAssertGreaterThan(horoscope.count, 50)
    }
    
    func testDailyHoroscope_ConsistentForSameDay() {
        let date = Date()
        let horoscope1 = calculator.dailyHoroscope(for: .taurus, on: date)
        let horoscope2 = calculator.dailyHoroscope(for: .taurus, on: date)
        XCTAssertEqual(horoscope1, horoscope2)
    }
    
    func testDailyHoroscope_DifferentForDifferentDays() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let horoscope1 = calculator.dailyHoroscope(for: .gemini, on: today)
        let horoscope2 = calculator.dailyHoroscope(for: .gemini, on: tomorrow)
        XCTAssertNotEqual(horoscope1, horoscope2)
    }
    
    // MARK: - Birth Chart Tests
    
    func testBirthChart_CalculatesAllPlacements() {
        let birthDate = DateComponents(year: 1990, month: 6, day: 15, hour: 12, minute: 0).date!
        let chart = calculator.birthChart(for: birthDate)
        
        XCTAssertNotNil(chart.sunSign)
        XCTAssertNotNil(chart.moonSign)
        XCTAssertNotNil(chart.risingSign)
        XCTAssertGreaterThan(chart.planetPlacements.count, 0)
    }
    
    func testBirthChart_DifferentTimesDifferentRising() {
        let date1 = DateComponents(year: 1990, month: 6, day: 15, hour: 6, minute: 0).date!
        let date2 = DateComponents(year: 1990, month: 6, day: 15, hour: 18, minute: 0).date!
        
        let chart1 = calculator.birthChart(for: date1)
        let chart2 = calculator.birthChart(for: date2)
        
        XCTAssertNotEqual(chart1.risingSign, chart2.risingSign)
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_SunSignCalculation() {
        let date = DateComponents(year: 1990, month: 4, day: 5).date!
        measure {
            for _ in 0..<1000 {
                _ = calculator.sunSign(for: date)
            }
        }
    }
    
    func testPerformance_BirthChartCalculation() {
        let birthDate = DateComponents(year: 1990, month: 6, day: 15, hour: 12, minute: 0).date!
        measure {
            for _ in 0..<100 {
                _ = calculator.birthChart(for: birthDate)
            }
        }
    }
}
