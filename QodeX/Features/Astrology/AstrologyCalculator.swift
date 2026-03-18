//
//  AstrologyCalculator.swift
//  QodeX
//
//  High-level astrology calculations for birth charts, houses, and aspects
//  Integrates with EphemerisService for accurate planetary positions
//

import Foundation
import CoreLocation

// MARK: - Astrology Calculator

/// Main calculator for astrological charts and predictions
final class AstrologyCalculator {
    
    // MARK: - Singleton
    
    static let shared = AstrologyCalculator()
    
    // MARK: - Properties
    
    private let ephemeris = EphemerisService.shared
    
    // MARK: - Chart Calculations
    
    /// Calculate complete natal chart
    func calculateNatalChart(
        birthDate: Date,
        location: GeoLocation
    ) async throws -> NatalChart {
        // Get planetary positions
        let positions = try await ephemeris.calculatePositions(for: birthDate, location: location)
        
        // Calculate houses
        let houses = calculateHouses(
            birthDate: birthDate,
            latitude: location.latitude,
            longitude: location.longitude,
            system: .placidus
        )
        
        // Assign planets to houses
        var houseAssignedPositions: [Planet: PlanetaryPosition] = [:]
        for (planet, position) in positions {
            let house = findHouseForPosition(longitude: position.tropicalLongitude, houses: houses)
            houseAssignedPositions[planet] = PlanetaryPosition(
                planet: position.planet,
                sign: position.sign,
                degree: position.degree,
                tropicalLongitude: position.tropicalLongitude,
                siderealLongitude: position.siderealLongitude,
                latitude: position.latitude,
                distance: position.distance,
                speed: position.speed,
                house: house,
                isRetrograde: position.isRetrograde,
                dignity: position.dignity
            )
        }
        
        // Calculate aspects
        let aspects = calculateAspects(positions: Array(houseAssignedPositions.values))
        
        // Get ascendant and midheaven
        let ascendant = houses[1]?.cuspSign ?? .aries
        let midheaven = houses[10]?.cuspSign ?? .capricorn
        
        return NatalChart(
            sun: houseAssignedPositions[.sun]!,
            moon: houseAssignedPositions[.moon]!,
            mercury: houseAssignedPositions[.mercury],
            venus: houseAssignedPositions[.venus],
            mars: houseAssignedPositions[.mars],
            jupiter: houseAssignedPositions[.jupiter],
            saturn: houseAssignedPositions[.saturn],
            uranus: houseAssignedPositions[.uranus],
            neptune: houseAssignedPositions[.neptune],
            pluto: houseAssignedPositions[.pluto],
            northNode: houseAssignedPositions[.northNode],
            southNode: houseAssignedPositions[.southNode],
            chiron: houseAssignedPositions[.chiron],
            ascendant: ascendant,
            midheaven: midheaven,
            houses: houses,
            aspects: aspects,
            calculatedAt: birthDate
        )
    }
    
    /// Calculate current transits against a natal chart
    func calculateTransits(
        natalChart: NatalChart,
        for date: Date = Date()
    ) async throws -> [Transit] {
        let currentPositions = try await ephemeris.calculatePositions(for: date)
        
        var transits: [Transit] = []
        let jd = JulianDay.from(date)
        
        for (transitingPlanet, currentPos) in currentPositions {
            // Skip nodes for transits (they move too slowly)
            if transitingPlanet == .northNode || transitingPlanet == .southNode {
                continue
            }
            
            // Check aspects to all natal planets
            let natalPositions = natalChart.allPositions
            
            for natalPos in natalPositions {
                // Skip same planet
                if transitingPlanet == natalPos.planet {
                    continue
                }
                
                // Calculate aspect
                if let aspect = calculateAspect(
                    planet1: transitingPlanet,
                    longitude1: currentPos.tropicalLongitude,
                    planet2: natalPos.planet,
                    longitude2: natalPos.tropicalLongitude,
                    orb: 3.0
                ) {
                    // Determine if applying or separating
                    let isApplying = determineIfApplying(
                        transitingPos: currentPos,
                        natalPos: natalPos,
                        aspect: aspect.type
                    )
                    
                    // Generate transit interpretation
                    let interpretation = interpretTransit(
                        transitingPlanet: transitingPlanet,
                        natalPlanet: natalPos.planet,
                        aspect: aspect.type,
                        isApplying: isApplying
                    )
                    
                    transits.append(Transit(
                        transitingPlanet: transitingPlanet,
                        natalPoint: natalPos.planet,
                        aspect: aspect.type,
                        exactDate: date,
                        orb: aspect.orb,
                        isApplying: isApplying,
                        theme: interpretation.theme,
                        description: interpretation.description,
                        recommendation: interpretation.recommendation,
                        isChallenging: aspect.type.isChallenging
                    ))
                }
            }
        }
        
        // Sort by importance (closer orbs first)
        return transits.sorted { $0.orb < $1.orb }
    }
    
    /// Calculate secondary progressions
    func calculateProgressions(
        natalChart: NatalChart,
        for date: Date = Date()
    ) async throws -> ProgressedChart {
        // Secondary progressions: 1 day = 1 year
        let calendar = Calendar.current
        let yearsSinceBirth = calendar.dateComponents([.year], from: natalChart.calculatedAt, to: date).year ?? 0
        
        let progressedDate = calendar.date(byAdding: .day, value: yearsSinceBirth, to: natalChart.calculatedAt)!
        
        // Calculate progressed positions
        let progressedPositions = try await ephemeris.calculatePositions(for: progressedDate)
        
        return ProgressedChart(
            progressedSun: progressedPositions[.sun] ?? natalChart.sun,
            progressedMoon: progressedPositions[.moon] ?? natalChart.moon,
            progressedPlanets: progressedPositions,
            calculatedAt: date
        )
    }
    
    /// Calculate solar return chart
    func calculateSolarReturn(
        natalChart: NatalChart,
        year: Int
    ) async throws -> NatalChart {
        let calendar = Calendar.current
        let birthComponents = calendar.dateComponents([.month, .day, .hour, .minute], from: natalChart.calculatedAt)
        
        var targetComponents = DateComponents()
        targetComponents.year = year
        targetComponents.month = birthComponents.month
        targetComponents.day = birthComponents.day
        targetComponents.hour = birthComponents.hour
        targetComponents.minute = birthComponents.minute
        
        // Find exact time when Sun returns to natal position
        guard var targetDate = calendar.date(from: targetComponents) else {
            throw AstrologyCalculationError.invalidDate
        }
        
        // Refine to exact Sun return
        let natalSunLongitude = natalChart.sun.tropicalLongitude
        var bestDate = targetDate
        var smallestDifference = 360.0
        
        // Search within ±2 days
        for dayOffset in -2...2 {
            if let testDate = calendar.date(byAdding: .day, value: dayOffset, to: targetDate) {
                do {
                    let sunPos = try await ephemeris.calculatePlanet(.sun, for: testDate)
                    let diff = abs(normalizeAngle(sunPos.tropicalLongitude - natalSunLongitude))
                    
                    if diff < smallestDifference {
                        smallestDifference = diff
                        bestDate = testDate
                    }
                } catch {
                    continue
                }
            }
        }
        
        // Calculate chart for solar return moment
        // Use natal location for solar return
        let natalLocation = GeoLocation(
            latitude: 0, // Would be stored in chart
            longitude: 0,
            timezone: "UTC",
            locationName: nil
        )
        
        return try await calculateNatalChart(birthDate: bestDate, location: natalLocation)
    }
    
    /// Calculate lunar return chart
    func calculateLunarReturn(
        natalChart: NatalChart,
        for date: Date = Date()
    ) async throws -> NatalChart {
        let natalMoonLongitude = natalChart.moon.tropicalLongitude
        
        // Search for when Moon returns to natal position
        let calendar = Calendar.current
        var searchDate = date
        var bestDate = date
        var smallestDifference = 360.0
        
        // Search within 28 days
        for dayOffset in 0...28 {
            if let testDate = calendar.date(byAdding: .day, value: dayOffset, to: searchDate) {
                do {
                    let moonPos = try await ephemeris.calculatePlanet(.moon, for: testDate)
                    let diff = abs(normalizeAngle(moonPos.tropicalLongitude - natalMoonLongitude))
                    
                    if diff < smallestDifference {
                        smallestDifference = diff
                        bestDate = testDate
                    }
                } catch {
                    continue
                }
            }
        }
        
        let natalLocation = GeoLocation(
            latitude: 0,
            longitude: 0,
            timezone: "UTC",
            locationName: nil
        )
        
        return try await calculateNatalChart(birthDate: bestDate, location: natalLocation)
    }
    
    // MARK: - House Calculations
    
    /// Calculate house cusps using specified house system
    func calculateHouses(
        birthDate: Date,
        latitude: Double,
        longitude: Double,
        system: HouseSystem
    ) -> [Int: AstrologicalHouse] {
        let jd = JulianDay.from(birthDate)
        
        // Calculate local sidereal time
        let lst = calculateLocalSiderealTime(jd: jd, longitude: longitude)
        
        var houses: [Int: AstrologicalHouse] = [:]
        
        switch system {
        case .placidus:
            houses = calculatePlacidusHouses(lst: lst, latitude: latitude)
        case .koch:
            houses = calculateKochHouses(lst: lst, latitude: latitude)
        case .equal:
            houses = calculateEqualHouses(lst: lst)
        case .wholeSign:
            houses = calculateWholeSignHouses(ascendant: ZodiacSign.from(degrees: lst))
        case .campanus:
            houses = calculateCampanusHouses(lst: lst, latitude: latitude)
        case .regiomontanus:
            houses = calculateRegiomontanusHouses(lst: lst, latitude: latitude)
        }
        
        return houses
    }
    
    /// Calculate Placidus house cusps
    private func calculatePlacidusHouses(lst: Double, latitude: Double) -> [Int: AstrologicalHouse] {
        var houses: [Int: AstrologicalHouse] = [:]
        
        let latRad = degreesToRadians(latitude)
        let tanLat = tan(latRad)
        
        // Calculate house cusps
        for houseNum in 1...12 {
            let cuspLongitude: Double
            
            switch houseNum {
            case 1:
                // Ascendant
                cuspLongitude = calculateAscendant(lst: lst, latitude: latitude)
            case 10:
                // Midheaven (MC)
                cuspLongitude = lst
            case 7:
                // Descendant (opposite Ascendant)
                cuspLongitude = normalizeAngle(houses[1]!.cuspDegree + 180)
            case 4:
                // IC (opposite MC)
                cuspLongitude = normalizeAngle(houses[10]!.cuspDegree + 180)
            default:
                // Placidus calculation for intermediate houses
                let ra = calculatePlacidusRA(houseNum: houseNum, lst: lst, tanLat: tanLat)
                cuspLongitude = radiansToDegrees(ra)
            }
            
            let sign = ZodiacSign.from(degrees: cuspLongitude)
            let degreeInSign = cuspLongitude.truncatingRemainder(dividingBy: 30)
            
            houses[houseNum] = AstrologicalHouse(
                number: houseNum,
                cuspSign: sign,
                cuspDegree: cuspLongitude,
                cuspDegreeInSign: degreeInSign
            )
        }
        
        return houses
    }
    
    /// Calculate Koch house cusps
    private func calculateKochHouses(lst: Double, latitude: Double) -> [Int: AstrologicalHouse] {
        var houses: [Int: AstrologicalHouse] = [:]
        
        // Calculate Ascendant and MC
        let ascendant = calculateAscendant(lst: lst, latitude: latitude)
        let mc = lst
        
        // Calculate ascensional differences for Koch houses
        let ascensionalDifference = mc - ascendant
        let ad3 = ascensionalDifference / 3
        
        for houseNum in 1...12 {
            let cuspLongitude: Double
            
            switch houseNum {
            case 1:
                cuspLongitude = ascendant
            case 10:
                cuspLongitude = mc
            case 7:
                cuspLongitude = normalizeAngle(ascendant + 180)
            case 4:
                cuspLongitude = normalizeAngle(mc + 180)
            case 2, 3:
                cuspLongitude = normalizeAngle(ascendant + Double(houseNum - 1) * ad3)
            case 5, 6:
                cuspLongitude = normalizeAngle(mc + Double(houseNum - 4) * ad3)
            case 8, 9:
                cuspLongitude = normalizeAngle(ascendant + 180 + Double(houseNum - 7) * ad3)
            case 11, 12:
                cuspLongitude = normalizeAngle(mc + 180 + Double(houseNum - 10) * ad3)
            default:
                cuspLongitude = ascendant
            }
            
            let sign = ZodiacSign.from(degrees: cuspLongitude)
            
            houses[houseNum] = AstrologicalHouse(
                number: houseNum,
                cuspSign: sign,
                cuspDegree: cuspLongitude,
                cuspDegreeInSign: cuspLongitude.truncatingRemainder(dividingBy: 30)
            )
        }
        
        return houses
    }
    
    /// Calculate Equal house cusps
    private func calculateEqualHouses(lst: Double) -> [Int: AstrologicalHouse] {
        var houses: [Int: AstrologicalHouse] = [:]
        
        // Ascendant is first house cusp
        let ascendant = lst
        
        for houseNum in 1...12 {
            let cuspLongitude = normalizeAngle(ascendant + Double(houseNum - 1) * 30)
            let sign = ZodiacSign.from(degrees: cuspLongitude)
            
            houses[houseNum] = AstrologicalHouse(
                number: houseNum,
                cuspSign: sign,
                cuspDegree: cuspLongitude,
                cuspDegreeInSign: cuspLongitude.truncatingRemainder(dividingBy: 30)
            )
        }
        
        return houses
    }
    
    /// Calculate Whole Sign houses
    private func calculateWholeSignHouses(ascendant: ZodiacSign) -> [Int: AstrologicalHouse] {
        var houses: [Int: AstrologicalHouse] = [:]
        
        let ascendantIndex = ZodiacSign.allCases.firstIndex(of: ascendant) ?? 0
        
        for houseNum in 1...12 {
            let signIndex = (ascendantIndex + houseNum - 1) % 12
            let sign = ZodiacSign.allCases[signIndex]
            
            houses[houseNum] = AstrologicalHouse(
                number: houseNum,
                cuspSign: sign,
                cuspDegree: Double(signIndex) * 30,
                cuspDegreeInSign: 0
            )
        }
        
        return houses
    }
    
    /// Calculate Campanus house cusps
    private func calculateCampanusHouses(lst: Double, latitude: Double) -> [Int: AstrologicalHouse] {
        // Simplified Campanus calculation
        // Full implementation requires spherical trigonometry
        return calculatePlacidusHouses(lst: lst, latitude: latitude)
    }
    
    /// Calculate Regiomontanus house cusps
    private func calculateRegiomontanusHouses(lst: Double, latitude: Double) -> [Int: AstrologicalHouse] {
        // Simplified Regiomontanus calculation
        return calculatePlacidusHouses(lst: lst, latitude: latitude)
    }
    
    /// Calculate Ascendant
    private func calculateAscendant(lst: Double, latitude: Double) -> Double {
        let lstRad = degreesToRadians(lst)
        let latRad = degreesToRadians(latitude)
        
        let ascendantRad = atan2(
            sin(lstRad),
            cos(lstRad) * cos(latRad) + sin(latRad) * tan(degreesToRadians(23.4367))
        )
        
        var ascendant = radiansToDegrees(ascendantRad)
        ascendant = normalizeAngle(ascendant)
        
        return ascendant
    }
    
    /// Calculate Local Sidereal Time
    private func calculateLocalSiderealTime(jd: Double, longitude: Double) -> Double {
        // Julian centuries from J2000
        let T = (jd - 2451545.0) / 36525.0
        
        // Mean sidereal time at Greenwich (in degrees)
        let gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
                   0.000387933 * T * T - T * T * T / 38710000.0
        
        // Convert to local sidereal time
        let lst = gmst + longitude
        
        return normalizeAngle(lst)
    }
    
    /// Calculate Placidus Right Ascension for intermediate houses
    private func calculatePlacidusRA(houseNum: Int, lst: Double, tanLat: Double) -> Double {
        let offset = Double(houseNum <= 6 ? houseNum - 1 : houseNum - 7) * 30.0
        let ra = degreesToRadians(lst + offset)
        
        // Placidus formula
        let tanHA = tan(ra) / tanLat
        let ha = atan(tanHA)
        
        return lst + offset + radiansToDegrees(ha)
    }
    
    /// Find which house contains a given longitude
    private func findHouseForPosition(longitude: Double, houses: [Int: AstrologicalHouse]) -> Int {
        let normalizedLongitude = normalizeAngle(longitude)
        
        // Sort houses by cusp degree
        let sortedHouses = houses.values.sorted { $0.cuspDegree < $1.cuspDegree }
        
        for i in 0..<sortedHouses.count {
            let currentHouse = sortedHouses[i]
            let nextHouse = sortedHouses[(i + 1) % sortedHouses.count]
            
            let currentCusp = normalizeAngle(currentHouse.cuspDegree)
            let nextCusp = normalizeAngle(nextHouse.cuspDegree)
            
            if nextCusp > currentCusp {
                // Normal case
                if normalizedLongitude >= currentCusp && normalizedLongitude < nextCusp {
                    return currentHouse.number
                }
            } else {
                // House crosses 0° Aries
                if normalizedLongitude >= currentCusp || normalizedLongitude < nextCusp {
                    return currentHouse.number
                }
            }
        }
        
        return 1 // Default to first house
    }
    
    // MARK: - Aspect Calculations
    
    /// Calculate all aspects between planets
    func calculateAspects(positions: [PlanetaryPosition]) -> [Aspect] {
        var aspects: [Aspect] = []
        
        for i in 0..<positions.count {
            for j in (i + 1)..<positions.count {
                let pos1 = positions[i]
                let pos2 = positions[j]
                
                // Skip lunar nodes for aspects
                if pos1.planet == .northNode || pos1.planet == .southNode ||
                   pos2.planet == .northNode || pos2.planet == .southNode {
                    continue
                }
                
                if let aspect = calculateAspect(
                    planet1: pos1.planet,
                    longitude1: pos1.tropicalLongitude,
                    planet2: pos2.planet,
                    longitude2: pos2.tropicalLongitude
                ) {
                    aspects.append(aspect)
                }
            }
        }
        
        return aspects.sorted { $0.orb < $1.orb }
    }
    
    /// Calculate aspect between two points
    func calculateAspect(
        planet1: Planet,
        longitude1: Double,
        planet2: Planet,
        longitude2: Double,
        orb: Double = 6.0
    ) -> Aspect? {
        let diff = abs(normalizeAngle(longitude1 - longitude2))
        let diff2 = abs(360 - diff)
        let separation = min(diff, diff2)
        
        // Define aspect angles and their orbs
        let aspectDefinitions: [(AspectType, Double, Double)] = [
            (.conjunction, 0, orb),
            (.sextile, 60, orb - 1),
            (.square, 90, orb - 1),
            (.trine, 120, orb - 1),
            (.quincunx, 150, orb - 2),
            (.opposition, 180, orb)
        ]
        
        for (type, angle, typeOrb) in aspectDefinitions {
            let orbDiff = abs(separation - angle)
            if orbDiff <= typeOrb {
                return Aspect(
                    planet1: planet1,
                    planet2: planet2,
                    type: type,
                    orb: orbDiff,
                    isApplying: true // Simplified - would need speed calculation
                )
            }
        }
        
        return nil
    }
    
    /// Determine if an aspect is applying or separating
    private func determineIfApplying(
        transitingPos: PlanetaryPosition,
        natalPos: PlanetaryPosition,
        aspect: AspectType
    ) -> Bool {
        // If transiting planet is faster and moving toward exact aspect
        let transitingSpeed = transitingPos.speed
        let natalSpeed = natalPos.speed
        
        // Simplified logic: transiting planets are usually applying
        // unless they're slowing down or stationing
        return transitingSpeed > natalSpeed
    }
    
    // MARK: - Transit Interpretations
    
    private func interpretTransit(
        transitingPlanet: Planet,
        natalPlanet: Planet,
        aspect: AspectType,
        isApplying: Bool
    ) -> (theme: String, description: String, recommendation: String) {
        
        let direction = isApplying ? "building" : "fading"
        
        // Generate theme
        let theme = "\(transitingPlanet.rawValue) \(aspect.rawValue.lowercased()) \(natalPlanet.rawValue)"
        
        // Generate description based on planets and aspect
        var description = ""
        var recommendation = ""
        
        switch (transitingPlanet, natalPlanet, aspect) {
        case (.saturn, _, .conjunction):
            description = "A time of consolidation and maturation regarding \(natalPlanet.rawValue.lowercased()) matters."
            recommendation = "Take responsibility and build lasting structures."
        case (.jupiter, _, .trine), (.jupiter, _, .sextile):
            description = "Expansion and opportunity in \(natalPlanet.rawValue.lowercased()) areas of life."
            recommendation = "Take calculated risks and embrace growth."
        case (.uranus, _, .conjunction), (.uranus, _, .square):
            description = "Sudden changes and awakenings related to \(natalPlanet.rawValue.lowercased())."
            recommendation = "Embrace change and break free from limitations."
        case (.pluto, _, .conjunction), (.pluto, _, .opposition):
            description = "Deep transformation and power dynamics involving \(natalPlanet.rawValue.lowercased())."
            recommendation = "Let go of what no longer serves you."
        case (_, .sun, _):
            description = "This transit affects your core identity and life direction."
            recommendation = "Pay attention to how you express yourself."
        case (_, .moon, _):
            description = "Emotional patterns and inner needs are highlighted."
            recommendation = "Honor your feelings and nurture yourself."
        default:
            description = "\(transitingPlanet.rawValue) activates your \(natalPlanet.rawValue) energy through a \(aspect.rawValue.lowercased())."
            recommendation = "Observe how this manifests in your life."
        }
        
        return (theme, "\(description) This influence is \(direction).", recommendation)
    }
    
    // MARK: - Utility Functions
    
    private func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    private func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    
    private func normalizeAngle(_ degrees: Double) -> Double {
        var angle = degrees.truncatingRemainder(dividingBy: 360.0)
        if angle < 0 { angle += 360.0 }
        return angle
    }
}

// MARK: - Supporting Types

enum HouseSystem: String, CaseIterable {
    case placidus = "Placidus"
    case koch = "Koch"
    case equal = "Equal"
    case wholeSign = "Whole Sign"
    case campanus = "Campanus"
    case regiomontanus = "Regiomontanus"
    
    var description: String {
        switch self {
        case .placidus:
            return "Most popular system; houses divided by time"
        case .koch:
            return "Birthplace-based; popular in mid-latitudes"
        case .equal:
            return "All houses 30°; ascendant-based"
        case .wholeSign:
            return "Each sign is a house; Hellenistic tradition"
        case .campanus:
            return "Prime vertical division"
        case .regiomontanus:
            return "Celestial equator division"
        }
    }
}

struct AstrologicalHouse {
    let number: Int
    let cuspSign: ZodiacSign
    let cuspDegree: Double
    let cuspDegreeInSign: Double
}

struct Aspect {
    let planet1: Planet
    let planet2: Planet
    let type: AspectType
    let orb: Double
    let isApplying: Bool
}

struct Transit {
    let transitingPlanet: Planet
    let natalPoint: Planet
    let aspect: AspectType
    let exactDate: Date
    let orb: Double
    let isApplying: Bool
    let theme: String
    let description: String
    let recommendation: String
    let isChallenging: Bool
}

struct ProgressedChart {
    let progressedSun: PlanetaryPosition
    let progressedMoon: PlanetaryPosition
    let progressedPlanets: [Planet: PlanetaryPosition]
    let calculatedAt: Date
}

enum AstrologyCalculationError: Error {
    case invalidDate
    case invalidLocation
    case calculationFailed(String)
    case ephemerisError(String)
}

// MARK: - Natal Chart Extension

extension NatalChart {
    /// All planet positions in a single array
    var allPositions: [PlanetaryPosition] {
        var positions: [PlanetaryPosition] = [sun, moon]
        
        if let mercury = mercury { positions.append(mercury) }
        if let venus = venus { positions.append(venus) }
        if let mars = mars { positions.append(mars) }
        if let jupiter = jupiter { positions.append(jupiter) }
        if let saturn = saturn { positions.append(saturn) }
        if let uranus = uranus { positions.append(uranus) }
        if let neptune = neptune { positions.append(neptune) }
        if let pluto = pluto { positions.append(pluto) }
        if let northNode = northNode { positions.append(northNode) }
        if let southNode = southNode { positions.append(southNode) }
        if let chiron = chiron { positions.append(chiron) }
        
        return positions
    }
    
    /// Get dominant element
    var dominantElement: Element {
        let elements = allPositions.map { $0.sign.element }
        var counts: [Element: Int] = [:]
        for element in elements {
            counts[element, default: 0] += 1
        }
        return counts.max { $0.value < $1.value }?.key ?? .fire
    }
    
    /// Get dominant modality
    var dominantModality: Modality {
        let modalities = allPositions.map { $0.sign.modality }
        var counts: [Modality: Int] = [:]
        for modality in modalities {
            counts[modality, default: 0] += 1
        }
        return counts.max { $0.value < $1.value }?.key ?? .cardinal
    }
    
    /// Check for chart patterns
    var chartPatterns: [ChartPattern] {
        detectChartPatterns()
    }
    
    private func detectChartPatterns() -> [ChartPattern] {
        var patterns: [ChartPattern] = []
        
        let positions = allPositions
        
        // Check for stellium (3+ planets in one sign or house)
        var signCounts: [ZodiacSign: Int] = [:]
        var houseCounts: [Int: Int] = [:]
        
        for pos in positions {
            signCounts[pos.sign, default: 0] += 1
            if let house = pos.house {
                houseCounts[house, default: 0] += 1
            }
        }
        
        for (sign, count) in signCounts where count >= 3 {
            patterns.append(.stelliumInSign(sign))
        }
        
        for (house, count) in houseCounts where count >= 3 {
            patterns.append(.stelliumInHouse(house))
        }
        
        // Check for T-square
        let oppositions = aspects.filter { $0.type == .opposition }
        for opposition in oppositions {
            let squareTo1 = aspects.contains {
                ($0.planet1 == opposition.planet1 || $0.planet2 == opposition.planet1) &&
                $0.type == .square
            }
            let squareTo2 = aspects.contains {
                ($0.planet1 == opposition.planet2 || $0.planet2 == opposition.planet2) &&
                $0.type == .square
            }
            
            if squareTo1 && squareTo2 {
                patterns.append(.tSquare(opposition.planet1, opposition.planet2))
            }
        }
        
        // Check for Grand Trine
        let trines = aspects.filter { $0.type == .trine }
        // Simplified check - full implementation would look for closed triangles
        if trines.count >= 3 {
            patterns.append(.grandTrine)
        }
        
        // Check for Grand Cross
        let squares = aspects.filter { $0.type == .square }
        let oppositionsForCross = aspects.filter { $0.type == .opposition }
        if squares.count >= 4 && oppositionsForCross.count >= 2 {
            patterns.append(.grandCross)
        }
        
        return patterns
    }
}

enum ChartPattern {
    case stelliumInSign(ZodiacSign)
    case stelliumInHouse(Int)
    case tSquare(Planet, Planet)
    case grandTrine
    case grandCross
    case yod
    case kite
    
    var description: String {
        switch self {
        case .stelliumInSign(let sign):
            return "Stellium in \(sign.rawValue) - Intense focus on \(sign.element.rawValue.lowercased()) energy"
        case .stelliumInHouse(let house):
            return "Stellium in House \(house) - Concentrated energy in this life area"
        case .tSquare(let p1, let p2):
            return "T-Square involving \(p1.rawValue) and \(p2.rawValue) - Dynamic tension requiring action"
        case .grandTrine:
            return "Grand Trine - Natural talent and flow in elemental energy"
        case .grandCross:
            return "Grand Cross - Major life challenges requiring balance"
        case .yod:
            return "Yod (Finger of God) - Fated turning points and special purpose"
        case .kite:
            return "Kite - Opportunities to elevate Grand Trine energy"
        }
    }
}

// MARK: - Aspect Type Extension

extension AspectType {
    var isMajor: Bool {
        switch self {
        case .conjunction, .sextile, .square, .trine, .opposition:
            return true
        case .quincunx:
            return false
        }
    }
    
    var isHarmonious: Bool {
        switch self {
        case .conjunction, .sextile, .trine:
            return true
        case .square, .opposition, .quincunx:
            return false
        }
    }
    
    var isChallenging: Bool {
        switch self {
        case .square, .opposition:
            return true
        case .conjunction, .sextile, .trine, .quincunx:
            return false
        }
    }
    
    var angle: Double {
        switch self {
        case .conjunction: return 0
        case .sextile: return 60
        case .square: return 90
        case .trine: return 120
        case .quincunx: return 150
        case .opposition: return 180
        }
    }
    
    var symbol: String {
        switch self {
        case .conjunction: return "☌"
        case .sextile: return "⚹"
        case .square: return "□"
        case .trine: return "△"
        case .quincunx: return "⚻"
        case .opposition: return "☍"
        }
    }
}
