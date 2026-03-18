//
//  SiderealAstrologyView.swift
//  QodeX
//
//  A premium Vedic astrology experience with true sidereal calculations
//  Reference: Traditional Jyotish + Modern Swiss Ephemeris methodology
//

import SwiftUI
import Combine
import CoreLocation

// MARK: - Data Models

/// Represents a celestial body in Vedic astrology
enum VedicPlanet: String, CaseIterable, Identifiable {
    case sun = "Sun"
    case moon = "Moon"
    case mercury = "Mercury"
    case venus = "Venus"
    case mars = "Mars"
    case jupiter = "Jupiter"
    case saturn = "Saturn"
    case rahu = "Rahu"
    case ketu = "Ketu"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .rahu: return "☊"
        case .ketu: return "☋"
        }
    }
    
    var color: Color {
        switch self {
        case .sun: return .orange
        case .moon: return .white
        case .mercury: return .green
        case .venus: return .pink
        case .mars: return .red
        case .jupiter: return .yellow
        case .saturn: return .purple
        case .rahu: return .gray
        case .ketu: return .teal
        }
    }
}

/// The 12 zodiac signs (Rashis)
enum Rashi: Int, CaseIterable {
    case mesha = 0      // Aries
    case vrishabha = 1  // Taurus
    case mithuna = 2    // Gemini
    case karka = 3      // Cancer
    case simha = 4      // Leo
    case kanya = 5      // Virgo
    case tula = 6       // Libra
    case vrishchika = 7 // Scorpio
    case dhanu = 8      // Sagittarius
    case makara = 9     // Capricorn
    case kumbha = 10    // Aquarius
    case meena = 11     // Pisces
    
    var name: String {
        switch self {
        case .mesha: return "Mesha"
        case .vrishabha: return "Vrishabha"
        case .mithuna: return "Mithuna"
        case .karka: return "Karka"
        case .simha: return "Simha"
        case .kanya: return "Kanya"
        case .tula: return "Tula"
        case .vrishchika: return "Vrishchika"
        case .dhanu: return "Dhanu"
        case .makara: return "Makara"
        case .kumbha: return "Kumbha"
        case .meena: return "Meena"
        }
    }
    
    var symbol: String {
        switch self {
        case .mesha: return "♈"
        case .vrishabha: return "♉"
        case .mithuna: return "♊"
        case .karka: return "♋"
        case .simha: return "♌"
        case .kanya: return "♍"
        case .tula: return "♎"
        case .vrishchika: return "♏"
        case .dhanu: return "♐"
        case .makara: return "♑"
        case .kumbha: return "♒"
        case .meena: return "♓"
        }
    }
}

/// The 27 Nakshatras (Lunar Mansions)
enum Nakshatra: Int, CaseIterable {
    case ashwini = 0
    case bharani = 1
    case krittika = 2
    case rohini = 3
    case mrigashira = 4
    case ardra = 5
    case punarvasu = 6
    case pushya = 7
    case ashlesha = 8
    case magha = 9
    case purvaPhalguni = 10
    case uttaraPhalguni = 11
    case hasta = 12
    case chitra = 13
    case swati = 14
    case vishakha = 15
    case anuradha = 16
    case jyeshtha = 17
    case mula = 18
    case purvaAshadha = 19
    case uttaraAshadha = 20
    case shravana = 21
    case dhanishta = 22
    case shatabhisha = 23
    case purvaBhadrapada = 24
    case uttaraBhadrapada = 25
    case revati = 26
    
    var name: String {
        switch self {
        case .ashwini: return "Ashwini"
        case .bharani: return "Bharani"
        case .krittika: return "Krittika"
        case .rohini: return "Rohini"
        case .mrigashira: return "Mrigashira"
        case .ardra: return "Ardra"
        case .punarvasu: return "Punarvasu"
        case .pushya: return "Pushya"
        case .ashlesha: return "Ashlesha"
        case .magha: return "Magha"
        case .purvaPhalguni: return "Pūrva Phalguni"
        case .uttaraPhalguni: return "Uttara Phalguni"
        case .hasta: return "Hasta"
        case .chitra: return "Chitra"
        case .swati: return "Swati"
        case .vishakha: return "Vishakha"
        case .anuradha: return "Anuradha"
        case .jyeshtha: return "Jyeshtha"
        case .mula: return "Mula"
        case .purvaAshadha: return "Pūrva Ashadha"
        case .uttaraAshadha: return "Uttara Ashadha"
        case .shravana: return "Shravana"
        case .dhanishta: return "Dhanishta"
        case .shatabhisha: return "Shatabhisha"
        case .purvaBhadrapada: return "Pūrva Bhadrapada"
        case .uttaraBhadrapada: return "Uttara Bhadrapada"
        case .revati: return "Revati"
        }
    }
    
    var ruler: VedicPlanet {
        let rulers: [VedicPlanet] = [
            .ketu, .venus, .sun, .moon, .mars, .rahu, .jupiter, .saturn, .mercury,
            .ketu, .venus, .sun, .moon, .mars, .rahu, .jupiter, .saturn, .mercury,
            .ketu, .venus, .sun, .moon, .mars, .rahu, .jupiter, .saturn, .mercury
        ]
        return rulers[rawValue]
    }
    
    var startLongitude: Double {
        Double(rawValue) * (360.0 / 27.0)
    }
    
    var endLongitude: Double {
        Double(rawValue + 1) * (360.0 / 27.0)
    }
}

/// Vimshottari Dasha period
struct DashaPeriod: Identifiable {
    let id = UUID()
    let planet: VedicPlanet
    let startDate: Date
    let endDate: Date
    let level: Int  // 0 = Mahadasha, 1 = Antardasha, 2 = Pratyantardasha
    let subPeriods: [DashaPeriod]?
}

/// Tithi (Lunar day)
struct Tithi {
    let number: Int  // 1-30
    let isShukla: Bool  // Waxing or waning
    
    var name: String {
        let tithiNames = [
            "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami",
            "Shashthi", "Saptami", "Ashtami", "Navami", "Dashami",
            "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Purnima/Amavasya"
        ]
        let baseName = tithiNames[(number - 1) % 15]
        return isShukla ? "Shukla \(baseName)" : "Krishna \(baseName)"
    }
}

/// Yoga (Lunar-solar combination)
struct Yoga {
    let number: Int  // 1-27
    
    var name: String {
        let yogaNames = [
            "Vishkumbha", "Priti", "Ayushman", "Saubhagya", "Shobhana",
            "Atiganda", "Sukarma", "Dhriti", "Shula", "Ganda",
            "Vriddhi", "Dhruva", "Vyaghata", "Harshana", "Vajra",
            "Siddhi", "Vyatipata", "Variyana", "Parigha", "Shiva",
            "Siddha", "Sadhya", "Shubha", "Shukla", "Brahma",
            "Indra", "Vaidhriti"
        ]
        return yogaNames[number - 1]
    }
}

/// Karana (Half-tithi)
struct Karana {
    let number: Int  // 1-11
    
    var name: String {
        let karanaNames = [
            "Bava", "Balava", "Kaulava", "Taitila", "Gara",
            "Vanija", "Vishti", "Shakuni", "Chatushpada", "Naga", "Kimstughna"
        ]
        return karanaNames[(number - 1) % 11]
    }
    
    var isGood: Bool {
        number != 7 // Vishti/Bhadra is generally avoided
    }
}

/// Muhurta (Auspicious timing)
struct Muhurta: Identifiable {
    let id = UUID()
    let name: String
    let startTime: Date
    let endTime: Date
    let quality: MuhurtaQuality
    let activity: String
}

enum MuhurtaQuality: Int, Comparable {
    case excellent = 4
    case good = 3
    case neutral = 2
    case challenging = 1
    case avoid = 0
    
    static func < (lhs: MuhurtaQuality, rhs: MuhurtaQuality) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .mint
        case .neutral: return .yellow
        case .challenging: return .orange
        case .avoid: return .red
        }
    }
}

/// Complete Panchang data
struct Panchang {
    let date: Date
    let tithi: Tithi
    let nakshatra: Nakshatra
    let yoga: Yoga
    let karana: Karana
    let sunRise: Date
    let sunSet: Date
    let moonRise: Date?
    let moonSet: Date?
    let rahuKala: (start: Date, end: Date)
    let yamaKandam: (start: Date, end: Date)
    let gulikaKala: (start: Date, end: Date)
    let abhijitMuhurta: (start: Date, end: Date)
}

// MARK: - Vimshottari Dasha Calculator

class VimshottariDashaCalculator {
    
    /// Dasha years for each planet
    private static let dashaYears: [VedicPlanet: Double] = [
        .ketu: 7, .venus: 20, .sun: 6, .moon: 10, .mars: 7,
        .rahu: 18, .jupiter: 16, .saturn: 19, .mercury: 17
    ]
    
    /// Calculate Vimshottari Dasha sequence
    static func calculate(birthNakshatra: Nakshatra, birthPada: Int, birthDate: Date) -> [DashaPeriod] {
        // Starting planet based on birth nakshatra
        let startPlanetIndex = birthNakshatra.rawValue % 9
        let planets: [VedicPlanet] = [.ketu, .venus, .sun, .moon, .mars, .rahu, .jupiter, .saturn, .mercury]
        let startPlanet = planets[startPlanetIndex]
        
        // Calculate balance of first dasha
        let padaDegrees = Double(birthPada - 1) * 3.3333
        let nakshatraDegrees = Double(birthNakshatra.rawValue) * 13.3333 + padaDegrees
        let nextNakshatraDegrees = Double(birthNakshatra.rawValue + 1) * 13.3333
        let remainingDegrees = nextNakshatraDegrees - nakshatraDegrees
        let totalNakshatraDegrees: Double = 13.3333
        
        let balanceRatio = remainingDegrees / totalNakshatraDegrees
        let startPlanetYears = dashaYears[startPlanet]! * balanceRatio
        
        var dashas: [DashaPeriod] = []
        var currentDate = birthDate
        
        // Generate 9 Mahadashas
        for i in 0..<9 {
            let planetIndex = (startPlanetIndex + i) % 9
            let planet = planets[planetIndex]
            let years = i == 0 ? startPlanetYears : dashaYears[planet]!
            
            let days = years * 365.25
            let endDate = Calendar.current.date(byAdding: .day, value: Int(days), to: currentDate)!
            
            let subPeriods = calculateAntardashas(mahadashaPlanet: planet, start: currentDate, end: endDate)
            
            dashas.append(DashaPeriod(
                planet: planet,
                startDate: currentDate,
                endDate: endDate,
                level: 0,
                subPeriods: subPeriods
            ))
            
            currentDate = endDate
        }
        
        return dashas
    }
    
    private static func calculateAntardashas(mahadashaPlanet: VedicPlanet, start: Date, end: Date) -> [DashaPeriod] {
        // Simplified antardasha calculation
        let planets: [VedicPlanet] = [.ketu, .venus, .sun, .moon, .mars, .rahu, .jupiter, .saturn, .mercury]
        let mahadashaIndex = planets.firstIndex { $0 == mahadashaPlanet } ?? 0
        
        var antardashas: [DashaPeriod] = []
        let totalDuration = end.timeIntervalSince(start)
        var currentStart = start
        
        for i in 0..<9 {
            let planetIndex = (mahadashaIndex + i) % 9
            let planet = planets[planetIndex]
            let proportion = dashaYears[planet]! / 120.0 // 120 = total vimshottari years
            let duration = totalDuration * proportion
            
            let antardashaEnd = currentStart.addingTimeInterval(duration)
            antardashas.append(DashaPeriod(
                planet: planet,
                startDate: currentStart,
                endDate: antardashaEnd,
                level: 1,
                subPeriods: nil
            ))
            
            currentStart = antardashaEnd
        }
        
        return antardashas
    }
}

// MARK: - Panchang Calculator

class PanchangCalculator {
    
    static func calculate(for date: Date, location: CLLocation) -> Panchang {
        let jd = JulianDay.from(date)
        
        // Calculate simplified positions for panchang
        let t = (jd - 2451545.0) / 36525.0
        
        // Sun position
        let sunLong = (280.46646 + 36000.76983 * t + 0.0003032 * t * t).truncatingRemainder(dividingBy: 360)
        
        // Moon position
        let moonLong = (218.3165 + 481267.8813 * t).truncatingRemainder(dividingBy: 360)
        let moonPos = moonLong < 0 ? moonLong + 360 : moonLong
        
        // Tithi calculation
        let moonSunDiff = moonPos - sunLong
        let adjustedDiff = moonSunDiff < 0 ? moonSunDiff + 360 : moonSunDiff
        let tithiNumber = Int(adjustedDiff / 12) + 1
        let isShukla = tithiNumber <= 15
        
        // Nakshatra
        let nakshatraIndex = Int(moonPos / (360.0 / 27.0)) % 27
        let nakshatra = Nakshatra.allCases[nakshatraIndex]
        
        // Yoga calculation
        let yogaLong = (moonPos + sunLong).truncatingRemainder(dividingBy: 360)
        let yogaNumber = Int(yogaLong / (360.0 / 27.0)) + 1
        
        // Karana calculation
        let karanaNumber = Int((adjustedDiff / 6).truncatingRemainder(dividingBy: 11)) + 1
        
        // Sunrise/sunset calculation (simplified)
        let sunRise = calculateSunRise(date: date, location: location)
        let sunSet = calculateSunSet(date: date, location: location)
        
        // Calculate inauspicious periods
        let dayOfWeek = Calendar.current.component(.weekday, from: date)
        let dayDuration = sunSet.timeIntervalSince(sunRise)
        let hourDuration = dayDuration / 8
        
        // Rahu Kala depends on day of week
        let rahuKalaHour = [0, 1, 6, 4, 5, 3, 2][dayOfWeek - 1] // Sunday = 0, etc.
        let rahuKalaStart = sunRise.addingTimeInterval(hourDuration * Double(rahuKalaHour))
        
        // Abhijit Muhurta (midday ± 24 minutes)
        let midday = sunRise.addingTimeInterval(dayDuration / 2)
        let abhijitStart = midday.addingTimeInterval(-24 * 60)
        let abhijitEnd = midday.addingTimeInterval(24 * 60)
        
        return Panchang(
            date: date,
            tithi: Tithi(number: tithiNumber, isShukla: isShukla),
            nakshatra: nakshatra,
            yoga: Yoga(number: yogaNumber),
            karana: Karana(number: karanaNumber),
            sunRise: sunRise,
            sunSet: sunSet,
            moonRise: nil,
            moonSet: nil,
            rahuKala: (rahuKalaStart, rahuKalaStart.addingTimeInterval(hourDuration)),
            yamaKandam: (rahuKalaStart.addingTimeInterval(hourDuration * 4), rahuKalaStart.addingTimeInterval(hourDuration * 5)),
            gulikaKala: (rahuKalaStart.addingTimeInterval(hourDuration * 6), rahuKalaStart.addingTimeInterval(hourDuration * 7)),
            abhijitMuhurta: (abhijitStart, abhijitEnd)
        )
    }
    
    private static func calculateSunRise(date: Date, location: CLLocation) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 6
        components.minute = 0
        return calendar.date(from: components) ?? date
    }
    
    private static func calculateSunSet(date: Date, location: CLLocation) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 18
        components.minute = 0
        return calendar.date(from: components) ?? date
    }
}

// MARK: - View Model

@MainActor
class SiderealAstrologyViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
    @Published var planetPositions: [PlanetPosition] = []
    @Published var dashaPeriods: [DashaPeriod] = []
    @Published var panchang: Panchang?
    @Published var muhurtas: [Muhurta] = []
    @Published var selectedTab: AstrologyTab = .chart
    @Published var isLoading = false
    @Published var location: CLLocation = CLLocation(latitude: 28.6139, longitude: 77.2090) // Delhi default
    @Published var ayanamsaValue: Double = 0.0
    @Published var errorMessage: String?
    
    // Birth chart calculation results
    @Published var natalChart: NatalChart?
    @Published var currentTransits: [Transit] = []
    
    enum AstrologyTab: String, CaseIterable {
        case chart = "Birth Chart"
        case dasha = "Dasha"
        case panchang = "Panchang"
        case muhurta = "Muhurta"
        case transit = "Transits"
        case compare = "Compare"
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let calculator = AstrologyCalculator.shared
    private let ephemeris = EphemerisService.shared
    
    init() {
        calculateAll()
    }
    
    func calculateAll() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Calculate current planetary positions
                let geoLocation = GeoLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    timezone: TimeZone.current.identifier,
                    locationName: nil
                )
                
                // Get current planetary positions
                let positions = try await ephemeris.calculatePositions(
                    for: selectedDate,
                    location: geoLocation
                )
                
                // Convert to Vedic planet positions
                var vedicPositions: [VedicPlanetPosition] = []
                let jd = JulianDay.from(selectedDate)
                
                // Map modern planets to Vedic planets
                if let sun = positions[.sun] {
                    vedicPositions.append(convertToVedic(sun, vedicPlanet: .sun, jd: jd))
                }
                if let moon = positions[.moon] {
                    vedicPositions.append(convertToVedic(moon, vedicPlanet: .moon, jd: jd))
                }
                if let mercury = positions[.mercury] {
                    vedicPositions.append(convertToVedic(mercury, vedicPlanet: .mercury, jd: jd))
                }
                if let venus = positions[.venus] {
                    vedicPositions.append(convertToVedic(venus, vedicPlanet: .venus, jd: jd))
                }
                if let mars = positions[.mars] {
                    vedicPositions.append(convertToVedic(mars, vedicPlanet: .mars, jd: jd))
                }
                if let jupiter = positions[.jupiter] {
                    vedicPositions.append(convertToVedic(jupiter, vedicPlanet: .jupiter, jd: jd))
                }
                if let saturn = positions[.saturn] {
                    vedicPositions.append(convertToVedic(saturn, vedicPlanet: .saturn, jd: jd))
                }
                if let northNode = positions[.northNode] {
                    vedicPositions.append(convertToVedic(northNode, vedicPlanet: .rahu, jd: jd))
                }
                if let southNode = positions[.southNode] {
                    vedicPositions.append(convertToVedic(southNode, vedicPlanet: .ketu, jd: jd))
                }
                
                // Calculate ayanamsa
                self.ayanamsaValue = Ayanamsa.lahiri.value(jd: jd)
                
                // Calculate dasha periods
                if let moonPos = positions[.moon] {
                    let moonNakshatra = calculateNakshatra(longitude: moonPos.siderealLongitude)
                    let moonPada = calculatePada(longitude: moonPos.siderealLongitude)
                    self.dashaPeriods = VimshottariDashaCalculator.calculate(
                        birthNakshatra: moonNakshatra,
                        birthPada: moonPada,
                        birthDate: birthDate
                    )
                }
                
                // Calculate panchang
                self.panchang = PanchangCalculator.calculate(for: selectedDate, location: location)
                
                // Calculate muhurtas
                if let panchang = self.panchang {
                    self.muhurtas = calculateMuhurtas(panchang: panchang)
                }
                
                // Calculate natal chart
                let natalGeoLocation = GeoLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    timezone: TimeZone.current.identifier,
                    locationName: nil
                )
                
                let chart = try await calculator.calculateNatalChart(
                    birthDate: birthDate,
                    location: natalGeoLocation
                )
                self.natalChart = chart
                
                // Calculate current transits
                let transits = try await calculator.calculateTransits(
                    natalChart: chart,
                    for: selectedDate
                )
                self.currentTransits = transits
                
                await MainActor.run {
                    self.planetPositions = Array(positions.values)
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Calculation error: \(error.localizedDescription)"
                    self.isLoading = false
                    // Fallback to simplified calculations
                    self.calculateFallback()
                }
            }
        }
    }
    
    /// Convert modern planetary position to Vedic format
    private func convertToVedic(_ position: PlanetaryPosition, vedicPlanet: VedicPlanet, jd: Double) -> VedicPlanetPosition {
        return VedicPlanetPosition(
            planet: vedicPlanet,
            tropicalLongitude: position.tropicalLongitude,
            siderealLongitude: position.siderealLongitude,
            latitude: position.latitude,
            speed: position.speed,
            isRetrograde: position.isRetrograde
        )
    }
    
    /// Calculate nakshatra from sidereal longitude
    private func calculateNakshatra(longitude: Double) -> Nakshatra {
        let nakshatraIndex = Int(longitude / (360.0 / 27.0)) % 27
        return Nakshatra.allCases[nakshatraIndex]
    }
    
    /// Calculate pada (quarter) within nakshatra
    private func calculatePada(longitude: Double) -> Int {
        let nakshatraDegree = longitude.truncatingRemainder(dividingBy: 360.0 / 27.0)
        return Int(nakshatraDegree / (360.0 / 108.0)) + 1
    }
    
    /// Fallback calculation if ephemeris fails
    private func calculateFallback() {
        // Use simplified calculations as fallback
        let jd = JulianDay.from(selectedDate)
        
        // Simplified positions
        let tropicalPositions = calculateSimplifiedTropicalPositions(jd: jd)
        
        var positions: [PlanetaryPosition] = []
        for (planet, tropicalLong) in tropicalPositions {
            let siderealLong = Ayanamsa.lahiri.tropicalToSidereal(tropicalLong, jd: jd)
            
            positions.append(PlanetaryPosition(
                planet: planet,
                sign: ZodiacSign.from(degrees: siderealLong),
                degree: siderealLong,
                tropicalLongitude: tropicalLong,
                siderealLongitude: siderealLong,
                latitude: 0,
                distance: 1,
                speed: 1,
                house: nil,
                isRetrograde: false,
                dignity: .neutral
            ))
        }
        
        self.planetPositions = positions
        self.ayanamsaValue = Ayanamsa.lahiri.value(jd: jd)
    }
    
    private func calculateSimplifiedTropicalPositions(jd: Double) -> [(Planet, Double)] {
        let t = (jd - 2451545.0) / 36525.0
        
        let sunLong = (280.46646 + 36000.76983 * t + 0.0003032 * t * t).truncatingRemainder(dividingBy: 360)
        let moonLong = (218.3165 + 481267.8813 * t).truncatingRemainder(dividingBy: 360)
        let mercuryLong = (252.25084 + 149472.6746 * t).truncatingRemainder(dividingBy: 360)
        let venusLong = (181.97973 + 58517.8156 * t).truncatingRemainder(dividingBy: 360)
        let marsLong = (355.433 + 19140.299 * t).truncatingRemainder(dividingBy: 360)
        let jupiterLong = (34.3515 + 3034.9057 * t).truncatingRemainder(dividingBy: 360)
        let saturnLong = (50.0774 + 1222.1138 * t).truncatingRemainder(dividingBy: 360)
        let rahuLong = (125.0445 - 1934.1363 * t).truncatingRemainder(dividingBy: 360)
        let ketuLong = (rahuLong + 180).truncatingRemainder(dividingBy: 360)
        
        return [
            (.sun, sunLong < 0 ? sunLong + 360 : sunLong),
            (.moon, moonLong < 0 ? moonLong + 360 : moonLong),
            (.mercury, mercuryLong < 0 ? mercuryLong + 360 : mercuryLong),
            (.venus, venusLong < 0 ? venusLong + 360 : venusLong),
            (.mars, marsLong < 0 ? marsLong + 360 : marsLong),
            (.jupiter, jupiterLong < 0 ? jupiterLong + 360 : jupiterLong),
            (.saturn, saturnLong < 0 ? saturnLong + 360 : saturnLong),
            (.northNode, rahuLong < 0 ? rahuLong + 360 : rahuLong),
            (.southNode, ketuLong < 0 ? ketuLong + 360 : ketuLong)
        ]
    }
    
    private func calculateMuhurtas(panchang: Panchang) -> [Muhurta] {
        var muhurtas: [Muhurta] = []
        
        // Abhijit Muhurta
        muhurtas.append(Muhurta(
            name: "Abhijit Muhurta",
            startTime: panchang.abhijitMuhurta.start,
            endTime: panchang.abhijitMuhurta.end,
            quality: .excellent,
            activity: "All auspicious activities, especially beginnings"
        ))
        
        // Rahu Kala (avoid)
        muhurtas.append(Muhurta(
            name: "Rahu Kala",
            startTime: panchang.rahuKala.start,
            endTime: panchang.rahuKala.end,
            quality: .avoid,
            activity: "Avoid new ventures, important decisions"
        ))
        
        // Amrit Kalam
        let calendar = Calendar.current
        let sunriseHour = calendar.component(.hour, from: panchang.sunRise)
        let amritStart = calendar.date(bySettingHour: (sunriseHour + 4) % 24, minute: 0, second: 0, of: panchang.date)!
        muhurtas.append(Muhurta(
            name: "Amrit Kalam",
            startTime: amritStart,
            endTime: amritStart.addingTimeInterval(90 * 60),
            quality: .excellent,
            activity: "Medicine, healing, spiritual practices"
        ))
        
        return muhurtas.sorted { $0.startTime < $1.startTime }
    }
    
    func refreshCalculations() {
        calculateAll()
    }
}

// MARK: - Vedic Planet Position

struct VedicPlanetPosition: Identifiable {
    let id = UUID()
    let planet: VedicPlanet
    let tropicalLongitude: Double
    let siderealLongitude: Double
    let latitude: Double
    let speed: Double
    let isRetrograde: Bool
    
    var nakshatra: Nakshatra {
        let index = Int(siderealLongitude / (360.0 / 27.0)) % 27
        return Nakshatra.allCases[index]
    }
    
    var pada: Int {
        let nakshatraDegree = siderealLongitude.truncatingRemainder(dividingBy: (360.0 / 27.0))
        return Int(nakshatraDegree / (360.0 / 108.0)) + 1
    }
    
    var rashi: Rashi {
        let index = Int(siderealLongitude / 30.0) % 12
        return Rashi.allCases[index]
    }
    
    var degreesInRashi: Double {
        siderealLongitude.truncatingRemainder(dividingBy: 30.0)
    }
}

// MARK: - Main View

struct SiderealAstrologyView: View {
    @StateObject private var viewModel = SiderealAstrologyViewModel()
    @State private var showingDatePicker = false
    @State private var showingBirthDatePicker = false
    
    var body: some View {
        ZStack {
            // Cosmic Background
            CosmicBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Ayanamsa display
                    AstrologyHeader(ayanamsa: viewModel.ayanamsaValue)
                    
                    // Error message if any
                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error)
                    }
                    
                    // Date and Location Controls
                    DateLocationControls(viewModel: viewModel)
                    
                    // Tab Selector
                    TabSelector(selectedTab: $viewModel.selectedTab)
                    
                    // Content based on selected tab
                    Group {
                        switch viewModel.selectedTab {
                        case .chart:
                            BirthChartSection(viewModel: viewModel)
                        case .dasha:
                            DashaSection(dashas: viewModel.dashaPeriods)
                        case .panchang:
                            PanchangSection(panchang: viewModel.panchang)
                        case .muhurta:
                            MuhurtaSection(muhurtas: viewModel.muhurtas)
                        case .transit:
                            TransitSection(viewModel: viewModel)
                        case .compare:
                            ComparisonSection(viewModel: viewModel)
                        }
                    }
                    .animation(.easeInOut, value: viewModel.selectedTab)
                }
                .padding()
            }
            
            // Loading overlay
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .navigationTitle("Sidereal Astrology")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.refreshCalculations() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(hex: "#E5C158"))
                }
            }
        }
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(hex: "#E5C158"))
                
                Text("Calculating Positions...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Date and Location Controls

struct DateLocationControls: View {
    @ObservedObject var viewModel: SiderealAstrologyViewModel
    @State private var showingDatePicker = false
    
    var body: some View {
        GlassmorphicCard {
            VStack(spacing: 12) {
                // Selected Date
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    Text("Reference Date:")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button(action: { showingDatePicker.toggle() }) {
                        Text(formattedDate(viewModel.selectedDate))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#E5C158"))
                    }
                }
                
                if showingDatePicker {
                    DatePicker(
                        "",
                        selection: $viewModel.selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .colorMultiply(Color(hex: "#E5C158"))
                    .onChange(of: viewModel.selectedDate) { _ in
                        viewModel.calculateAll()
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Birth Date
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    Text("Birth Date:")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(formattedDate(viewModel.birthDate))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#E5C158"))
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Location
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    Text("Location:")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(String(format: "%.2f°, %.2f°", 
                               viewModel.location.coordinate.latitude,
                               viewModel.location.coordinate.longitude))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#E5C158"))
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Background

struct CosmicBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep space gradient
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.05, green: 0.02, blue: 0.15),
                        Color(red: 0.1, green: 0.05, blue: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Stars
                Canvas { context, size in
                    let starCount = 100
                    for i in 0..<starCount {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let brightness = CGFloat.random(in: 0.3...1.0)
                        let starSize = CGFloat.random(in: 0.5...2)
                        
                        var path = Path()
                        path.addEllipse(in: CGRect(x: x, y: y, width: starSize, height: starSize))
                        context.fill(path, with: .color(.white.opacity(brightness)))
                    }
                }
                .ignoresSafeArea()
                
                // Nebula effect
                RadialGradient(
                    colors: [
                        Color.purple.opacity(0.15),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.8
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    colors: [
                        Color(hex: "#E5C158").opacity(0.08),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.6
                )
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Header

struct AstrologyHeader: View {
    let ayanamsa: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("✦")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#E5C158"))
            
            Text("True Sidereal Astrology")
                .font(.system(size: 28, weight: .light, design: .serif))
                .foregroundColor(.white)
            
            Text("Lahiri Ayanamsa • \(String(format: "%.4f", ayanamsa))°")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#E5C158").opacity(0.8))
                .tracking(2)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Tab Selector

struct TabSelector: View {
    @Binding var selectedTab: SiderealAstrologyViewModel.AstrologyTab
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SiderealAstrologyViewModel.AstrologyTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.rawValue,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? Color(hex: "#E5C158") : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    GlassmorphicBackground()
                        .opacity(isSelected ? 1 : 0.5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#E5C158").opacity(isSelected ? 0.8 : 0), lineWidth: 1)
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - Birth Chart Section

struct BirthChartSection: View {
    @ObservedObject var viewModel: SiderealAstrologyViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Chart Wheel
            ZStack {
                GlassmorphicCard {
                    VStack {
                        Text("Sidereal Birth Chart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        if let chart = viewModel.natalChart {
                            ChartWheel(chart: chart)
                                .frame(height: 280)
                        } else {
                            // Fallback to simple wheel with current positions
                            SimpleChartWheel(positions: viewModel.planetPositions)
                                .frame(height: 280)
                        }
                    }
                }
            }
            
            // Planet Positions List
            GlassmorphicCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Planetary Positions (Sidereal)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    ForEach(viewModel.planetPositions.sorted(by: { $0.siderealLongitude < $1.siderealLongitude })) { position in
                        ModernPlanetRow(position: position)
                    }
                }
            }
            
            // Nakshatra Info
            if let moonPos = viewModel.planetPositions.first(where: { $0.planet == .moon }) {
                ModernNakshatraCard(position: moonPos, ayanamsa: viewModel.ayanamsaValue)
            }
        }
    }
}

// MARK: - Modern Chart Components

struct ChartWheel: View {
    let chart: NatalChart
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size * 0.4
            
            ZStack {
                // Outer zodiac ring
                ZodiacRing(radius: radius, center: center)
                
                // Nakshatra inner ring
                NakshatraRing(radius: radius * 0.75, center: center)
                
                // House divisions
                HouseDividers(radius: radius * 0.85, center: center, chart: chart)
                
                // Planets
                ForEach(chart.allPositions) { position in
                    ModernPlanetGlyph(
                        position: position,
                        center: center,
                        radius: radius * 0.6
                    )
                }
                
                // Center
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#E5C158").opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: radius * 0.3
                        )
                    )
                    .frame(width: radius * 0.4, height: radius * 0.4)
                    .position(center)
                
                // Lagna marker
                Circle()
                    .stroke(Color(hex: "#E5C158"), lineWidth: 2)
                    .frame(width: radius * 0.15, height: radius * 0.15)
                    .position(center)
            }
        }
    }
}

struct SimpleChartWheel: View {
    let positions: [PlanetaryPosition]
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size * 0.4
            
            ZStack {
                // Outer zodiac ring
                ZodiacRing(radius: radius, center: center)
                
                // Nakshatra inner ring
                NakshatraRing(radius: radius * 0.75, center: center)
                
                // Planets
                ForEach(positions) { position in
                    SimplePlanetGlyph(
                        position: position,
                        center: center,
                        radius: radius * 0.6
                    )
                }
                
                // Center
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#E5C158").opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: radius * 0.3
                        )
                    )
                    .frame(width: radius * 0.4, height: radius * 0.4)
                    .position(center)
            }
        }
    }
}

struct SimplePlanetGlyph: View {
    let position: PlanetaryPosition
    let center: CGPoint
    let radius: CGFloat
    
    var body: some View {
        let angle = position.siderealLongitude - 90.0
        let radian = angle * .pi / 180
        let x = center.x + radius * CGFloat(cos(radian))
        let y = center.y + radius * CGFloat(sin(radian))
        
        let symbol = planetSymbol(for: position.planet)
        let color = planetColor(for: position.planet)
        
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.6))
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 1.5)
                )
            
            Text(symbol)
                .font(.system(size: 14))
                .foregroundColor(color)
        }
        .position(x: x, y: y)
    }
    
    private func planetSymbol(for planet: Planet) -> String {
        switch planet {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        case .southNode: return "☋"
        case .chiron: return "⚷"
        }
    }
    
    private func planetColor(for planet: Planet) -> Color {
        switch planet {
        case .sun: return .orange
        case .moon: return .white
        case .mercury: return .green
        case .venus: return .pink
        case .mars: return .red
        case .jupiter: return .yellow
        case .saturn: return .purple
        case .uranus: return .cyan
        case .neptune: return .blue
        case .pluto: return .brown
        case .northNode, .southNode: return .gray
        case .chiron: return .teal
        }
    }
}

struct ModernPlanetGlyph: View {
    let position: PlanetaryPosition
    let center: CGPoint
    let radius: CGFloat
    
    var body: some View {
        let angle = position.siderealLongitude - 90.0
        let radian = angle * .pi / 180
        let x = center.x + radius * CGFloat(cos(radian))
        let y = center.y + radius * CGFloat(sin(radian))
        
        let symbol = planetSymbol(for: position.planet)
        let color = planetColor(for: position.planet)
        
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.6))
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: position.isRetrograde ? 3 : 1.5)
                        .dashIfRetrograde(isRetrograde: position.isRetrograde)
                )
            
            Text(symbol)
                .font(.system(size: 14))
                .foregroundColor(color)
        }
        .position(x: x, y: y)
    }
    
    private func planetSymbol(for planet: Planet) -> String {
        switch planet {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        case .southNode: return "☋"
        case .chiron: return "⚷"
        }
    }
    
    private func planetColor(for planet: Planet) -> Color {
        switch planet {
        case .sun: return .orange
        case .moon: return .white
        case .mercury: return .green
        case .venus: return .pink
        case .mars: return .red
        case .jupiter: return .yellow
        case .saturn: return .purple
        case .uranus: return .cyan
        case .neptune: return .blue
        case .pluto: return .brown
        case .northNode, .southNode: return .gray
        case .chiron: return .teal
        }
    }
}

struct ModernPlanetRow: View {
    let position: PlanetaryPosition
    
    var body: some View {
        HStack {
            // Planet symbol
            ZStack {
                Circle()
                    .fill(planetColor(for: position.planet).opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Text(planetSymbol(for: position.planet))
                    .font(.system(size: 16))
                    .foregroundColor(planetColor(for: position.planet))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(position.planet.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    if position.isRetrograde {
                        Text("℞")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
                
                Text("\(position.sign.rawValue) \(String(format: "%.1f", position.degree.truncatingRemainder(dividingBy: 30)))°")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                // Show sidereal position
                let siderealSign = ZodiacSign.from(degrees: position.siderealLongitude)
                let siderealDegree = position.siderealLongitude.truncatingRemainder(dividingBy: 30)
                
                Text("\(siderealSign.rawValue) \(String(format: "%.1f", siderealDegree))°")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#E5C158"))
                
                if let house = position.house {
                    Text("House \(house)")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func planetSymbol(for planet: Planet) -> String {
        switch planet {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        case .southNode: return "☋"
        case .chiron: return "⚷"
        }
    }
    
    private func planetColor(for planet: Planet) -> Color {
        switch planet {
        case .sun: return .orange
        case .moon: return .white
        case .mercury: return .green
        case .venus: return .pink
        case .mars: return .red
        case .jupiter: return .yellow
        case .saturn: return .purple
        case .uranus: return .cyan
        case .neptune: return .blue
        case .pluto: return .brown
        case .northNode, .southNode: return .gray
        case .chiron: return .teal
        }
    }
}

struct ModernNakshatraCard: View {
    let position: PlanetaryPosition
    let ayanamsa: Double
    
    var body: some View {
        GlassmorphicCard {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Moon Nakshatra")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(1)
                        
                        let nakshatra = calculateNakshatra(longitude: position.siderealLongitude)
                        Text(nakshatra.name)
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Nakshatra number indicator
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "#E5C158").opacity(0.5), lineWidth: 1)
                            .frame(width: 50, height: 50)
                        
                        let nakshatraIndex = Int(position.siderealLongitude / (360.0 / 27.0)) % 27
                        VStack(spacing: 0) {
                            Text("\(nakshatraIndex + 1)")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#E5C158"))
                            Text("/27")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ruler")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        
                        let nakshatra = calculateNakshatra(longitude: position.siderealLongitude)
                        Text(nakshatra.ruler.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(planetColor(for: nakshatra.ruler))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Sidereal Longitude")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(String(format: "%.2f", position.siderealLongitude))°")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private func calculateNakshatra(longitude: Double) -> Nakshatra {
        let index = Int(longitude / (360.0 / 27.0)) % 27
        return Nakshatra.allCases[index]
    }
    
    private func planetColor(for planet: VedicPlanet) -> Color {
        switch planet {
        case .sun: return .orange
        case .moon: return .white
        case .mercury: return .green
        case .venus: return .pink
        case .mars: return .red
        case .jupiter: return .yellow
        case .saturn: return .purple
        case .rahu: return .gray
        case .ketu: return .teal
        }
    }
}

// MARK: - House Dividers

struct HouseDividers: View {
    let radius: CGFloat
    let center: CGPoint
    let chart: NatalChart
    
    var body: some View {
        ForEach(1...12, id: \.self) { houseNum in
            if let house = chart.houses[houseNum] {
                let angle = house.cuspDegree - 90.0
                let radian = angle * .pi / 180
                let innerRadius = radius * 0.5
                let outerRadius = radius * 1.05
                
                Path { path in
                    path.move(to: CGPoint(
                        x: center.x + innerRadius * CGFloat(cos(radian)),
                        y: center.y + innerRadius * CGFloat(sin(radian))
                    ))
                    path.addLine(to: CGPoint(
                        x: center.x + outerRadius * CGFloat(cos(radian)),
                        y: center.y + outerRadius * CGFloat(sin(radian))
                    ))
                }
                .stroke(Color.white.opacity(houseNum == 1 || houseNum == 10 ? 0.4 : 0.15), 
                        lineWidth: houseNum == 1 || houseNum == 10 ? 1.5 : 0.5)
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func dashIfRetrograde(isRetrograde: Bool) -> some View {
        self.modifier(RetrogradeStrokeModifier(isRetrograde: isRetrograde))
    }
}

struct RetrogradeStrokeModifier: ViewModifier {
    let isRetrograde: Bool
    
    func body(content: Content) -> some View {
        if isRetrograde {
            content.overlay(
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        path.move(to: CGPoint(x: 0, y: height/2))
                        path.addLine(to: CGPoint(x: width, y: height/2))
                    }
                    .stroke(Color.red.opacity(0.6), lineWidth: 2)
                    .clipShape(Circle())
                }
            )
        } else {
            content
        }
    }
}

// MARK: - Zodiac Ring

struct ZodiacRing: View {
    let radius: CGFloat
    let center: CGPoint
    
    var body: some View {
        ForEach(0..<12) { i in
            let angle = Double(i) * 30.0 - 90.0
            let radian = angle * .pi / 180
            let x = center.x + radius * CGFloat(cos(radian))
            let y = center.y + radius * CGFloat(sin(radian))
            
            let rashi = Rashi.allCases[i]
            
            Text(rashi.symbol)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#E5C158").opacity(0.9))
                .position(x: x, y: y)
        }
        
        // Outer circle
        Circle()
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
            .frame(width: radius * 2.15, height: radius * 2.15)
            .position(center)
        
        // Inner circle
        Circle()
            .stroke(Color.white.opacity(0.15), lineWidth: 1)
            .frame(width: radius * 2, height: radius * 2)
            .position(center)
    }
}

// MARK: - Nakshatra Ring

struct NakshatraRing: View {
    let radius: CGFloat
    let center: CGPoint
    
    var body: some View {
        ForEach(0..<27) { i in
            let angle = Double(i) * (360.0 / 27.0) - 90.0
            let radian = angle * .pi / 180
            let x = center.x + radius * CGFloat(cos(radian))
            let y = center.y + radius * CGFloat(sin(radian))
            
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 3, height: 3)
                .position(x: x, y: y)
        }
        
        Circle()
            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            .frame(width: radius * 2, height: radius * 2)
            .position(center)
    }
}

// MARK: - Dasha Section

struct DashaSection: View {
    let dashas: [DashaPeriod]
    @State private var expandedDasha: UUID?
    
    var body: some View {
        VStack(spacing: 16) {
            GlassmorphicCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Vimshottari Dasha")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        Spacer()
                        
                        Text("120 Year Cycle")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Text("Mahadasha periods based on Moon's nakshatra at birth")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            ForEach(dashas.prefix(5)) { dasha in
                DashaCard(dasha: dasha, isExpanded: expandedDasha == dasha.id) {
                    withAnimation(.spring(response: 0.3)) {
                        expandedDasha = expandedDasha == dasha.id ? nil : dasha.id
                    }
                }
            }
        }
    }
}

struct DashaCard: View {
    let dasha: DashaPeriod
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        GlassmorphicCard {
            VStack(spacing: 0) {
                Button(action: onTap) {
                    HStack {
                        // Planet indicator
                        ZStack {
                            Circle()
                                .fill(vedicPlanetColor(dasha.planet).opacity(0.2))
                                .frame(width: 44, height: 44)
                            
                            Text(vedicPlanetSymbol(dasha.planet))
                                .font(.system(size: 20))
                                .foregroundColor(vedicPlanetColor(dasha.planet))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dasha.planet.rawValue + " Mahadasha")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text(formatDate(dasha.startDate) + " - " + formatDate(dasha.endDate))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(Color(hex: "#E5C158"))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if isExpanded, let subPeriods = dasha.subPeriods {
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.vertical, 12)
                    
                    VStack(spacing: 8) {
                        Text("Antardasha (Sub-periods)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#E5C158").opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(subPeriods.prefix(5)) { antardasha in
                            HStack {
                                Text(vedicPlanetSymbol(antardasha.planet))
                                    .foregroundColor(vedicPlanetColor(antardasha.planet))
                                
                                Text(antardasha.planet.rawValue)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text(formatShortDate(antardasha.startDate))
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func vedicPlanetSymbol(_ planet: VedicPlanet) -> String {
        switch planet {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .rahu: return "☊"
        case .ketu: return "☋"
        }
    }
    
    private func vedicPlanetColor(_ planet: VedicPlanet) -> Color {
        switch planet {
        case .sun: return .orange
        case .moon: return .white
        case .mercury: return .green
        case .venus: return .pink
        case .mars: return .red
        case .jupiter: return .yellow
        case .saturn: return .purple
        case .rahu: return .gray
        case .ketu: return .teal
        }
    }
}

// MARK: - Panchang Section

struct PanchangSection: View {
    let panchang: Panchang?
    
    var body: some View {
        VStack(spacing: 16) {
            if let panchang = panchang {
                // Main Panchang Card
                GlassmorphicCard {
                    VStack(spacing: 16) {
                        Text("Daily Panchang")
                            .font(.system(size: 20, weight: .light, design: .serif))
                            .foregroundColor(Color(hex: "#E5C158"))
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Five Elements Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            PanchangItem(
                                icon: "🌙",
                                title: "Tithi",
                                value: panchang.tithi.name,
                                subtitle: "Lunar Day \(panchang.tithi.number)"
                            )
                            
                            PanchangItem(
                                icon: "⭐",
                                title: "Nakshatra",
                                value: panchang.nakshatra.name,
                                subtitle: "Ruler: \(panchang.nakshatra.ruler.rawValue)"
                            )
                            
                            PanchangItem(
                                icon: "🧘",
                                title: "Yoga",
                                value: panchang.yoga.name,
                                subtitle: "No. \(panchang.yoga.number)"
                            )
                            
                            PanchangItem(
                                icon: "⚖️",
                                title: "Karana",
                                value: panchang.karana.name,
                                subtitle: panchang.karana.isGood ? "Favorable" : "Challenging"
                            )
                        }
                    }
                }
                
                // Day Times
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Day Events")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            TimeItem(label: "Sunrise", time: panchang.sunRise, icon: "sunrise.fill")
                            Spacer()
                            TimeItem(label: "Sunset", time: panchang.sunSet, icon: "sunset.fill")
                        }
                    }
                }
                
                // Inauspicious Periods
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Avoid These Times")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red.opacity(0.8))
                        
                        WarningTimeItem(
                            name: "Rahu Kala",
                            start: panchang.rahuKala.start,
                            end: panchang.rahuKala.end,
                            description: "Avoid new beginnings"
                        )
                        
                        WarningTimeItem(
                            name: "Yama Kandam",
                            start: panchang.yamaKandam.start,
                            end: panchang.yamaKandam.end,
                            description: "Inauspicious for important work"
                        )
                    }
                }
                
            } else {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(hex: "#E5C158"))
            }
        }
    }
}

struct PanchangItem: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .tracking(1)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(Color(hex: "#E5C158").opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct TimeItem: View {
    let label: String
    let time: Date
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#E5C158"))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
            
            Text(formatTime(time))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct WarningTimeItem: View {
    let name: String
    let start: Date
    let end: Date
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange.opacity(0.8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text("\(formatTime(start)) - \(formatTime(end))")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(description)
                .font(.system(size: 10))
                .foregroundColor(.orange.opacity(0.7))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Muhurta Section

struct MuhurtaSection: View {
    let muhurtas: [Muhurta]
    
    var body: some View {
        VStack(spacing: 16) {
            GlassmorphicCard {
                VStack(spacing: 12) {
                    Text("Auspicious Timings")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    Text("Today's favorable periods for important activities")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            }
            
            ForEach(muhurtas) { muhurta in
                MuhurtaCard(muhurta: muhurta)
            }
        }
    }
}

struct MuhurtaCard: View {
    let muhurta: Muhurta
    
    var body: some View {
        GlassmorphicCard {
            HStack(spacing: 16) {
                // Quality indicator
                VStack(spacing: 4) {
                    Circle()
                        .fill(muhurta.quality.color.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(muhurta.quality.color, lineWidth: 2)
                        )
                        .overlay(
                            Image(systemName: qualityIcon)
                                .foregroundColor(muhurta.quality.color)
                        )
                    
                    Text(qualityText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(muhurta.quality.color)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(muhurta.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("\(formatTime(muhurta.startTime)) - \(formatTime(muhurta.endTime))")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    Text(muhurta.activity)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
            }
        }
    }
    
    private var qualityIcon: String {
        switch muhurta.quality {
        case .excellent: return "star.fill"
        case .good: return "hand.thumbsup.fill"
        case .neutral: return "minus.circle"
        case .challenging: return "exclamationmark.circle"
        case .avoid: return "xmark.circle"
        }
    }
    
    private var qualityText: String {
        switch muhurta.quality {
        case .excellent: return "Best"
        case .good: return "Good"
        case .neutral: return "Fair"
        case .challenging: return "Caution"
        case .avoid: return "Avoid"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Transit Section

struct TransitSection: View {
    @ObservedObject var viewModel: SiderealAstrologyViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            GlassmorphicCard {
                VStack(spacing: 12) {
                    Text("Current Transits")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    Text("Planetary influences to your natal chart")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            if viewModel.currentTransits.isEmpty {
                GlassmorphicCard {
                    Text("No major transits at this time")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .padding()
                }
            } else {
                ForEach(viewModel.currentTransits.prefix(6), id: \.theme) { transit in
                    TransitCard(transit: transit)
                }
            }
        }
    }
}

struct TransitCard: View {
    let transit: Transit
    
    var body: some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Aspect indicator
                    Text(transit.aspect.symbol)
                        .font(.system(size: 20))
                        .foregroundColor(transit.isChallenging ? .orange : .green)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(transit.theme)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Orb: \(String(format: "%.1f", transit.orb))°")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("•")
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text(transit.isApplying ? "Applying" : "Separating")
                                .font(.system(size: 11))
                                .foregroundColor(transit.isApplying ? Color(hex: "#E5C158") : .white.opacity(0.5))
                        }
                    }
                    
                    Spacer()
                }
                
                Text(transit.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                Text(transit.recommendation)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#E5C158").opacity(0.8))
            }
        }
    }
}

// MARK: - Comparison Section

struct ComparisonSection: View {
    @ObservedObject var viewModel: SiderealAstrologyViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            GlassmorphicCard {
                VStack(spacing: 12) {
                    Text("Tropical vs Sidereal")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "#E5C158"))
                    
                    Text("Compare Western (Tropical) with Vedic (Sidereal) positions")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            }
            
            // Ayanamsa Display
            GlassmorphicCard {
                VStack(spacing: 12) {
                    HStack {
                        Text("Lahiri Ayanamsa")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.4f", viewModel.ayanamsaValue))°")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(hex: "#E5C158"))
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    Text("The ayanamsa is the difference between tropical and sidereal zodiacs. Lahiri ayanamsa is the official standard for India.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Comparison Table
            GlassmorphicCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Position Comparison")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    // Header
                    HStack {
                        Text("Planet")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 60, alignment: .leading)
                        
                        Spacer()
                        
                        Text("Tropical")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 80, alignment: .trailing)
                        
                        Spacer()
                        
                        Text("Sidereal")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "#E5C158").opacity(0.8))
                            .frame(width: 80, alignment: .trailing)
                        
                        Spacer()
                        
                        Text("Diff")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Data rows
                    ForEach(viewModel.planetPositions.sorted(by: { $0.planet.rawValue < $1.planet.rawValue })) { pos in
                        ComparisonRow(position: pos)
                    }
                }
            }
        }
    }
}

struct ComparisonRow: View {
    let position: PlanetaryPosition
    
    var body: some View {
        HStack {
            Text(planetSymbol(for: position.planet))
                .font(.system(size: 16))
                .foregroundColor(planetColor(for: position.planet))
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            Text(formatDegrees(position.tropicalLongitude))
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 80, alignment: .trailing)
            
            Spacer()
            
            Text(formatDegrees(position.siderealLongitude))
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(Color(hex: "#E5C158"))
                .frame(width: 80, alignment: .trailing)
            
            Spacer()
            
            let diff = position.tropicalLongitude - position.siderealLongitude
            Text("\(String(format: "%.1f", diff))°")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 6)
    }
    
    private func formatDegrees(_ degrees: Double) -> String {
        let sign = ZodiacSign.from(degrees: degrees)
        let deg = Int(degrees.truncatingRemainder(dividingBy: 30))
        return "\(sign.rawValue.prefix(3)) \(deg)°"
    }
    
    private func planetSymbol(for planet: Planet) -> String {
        switch planet {
        case .sun: return "☉ Sun"
        case .moon: return "☽ Moon"
        case .mercury: return "☿ Mer"
        case .venus: return "♀ Ven"
        case .mars: return "♂ Mars"
        case .jupiter: return "♃ Jup"
        case .saturn: return "♄ Sat"
        case .uranus: return "♅ Ura"
        case .neptune: return "♆ Nep"
        case .pluto: return "♇ Plu"
        case .northNode: return "☊ N.Node"
        case .southNode: return "☋ S.Node"
        case .chiron: return "⚷ Chi"
        }
    }
    
    private func planetColor(for planet: Planet) -> Color {
        switch planet {
        case .sun: return .orange
        case .moon: return .white
        case .mercury: return .green
        case .venus: return .pink
        case .mars: return .red
        case .jupiter: return .yellow
        case .saturn: return .purple
        case .uranus: return .cyan
        case .neptune: return .blue
        case .pluto: return .brown
        case .northNode, .southNode: return .gray
        case .chiron: return .teal
        }
    }
}

// MARK: - Glassmorphism Components

struct GlassmorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(GlassmorphicBackground())
            .cornerRadius(20)
    }
}

struct GlassmorphicBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.white.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

struct SiderealAstrologyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SiderealAstrologyView()
        }
        .preferredColorScheme(.dark)
    }
}
