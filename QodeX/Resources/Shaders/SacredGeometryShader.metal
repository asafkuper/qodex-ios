//
//  SacredGeometryShader.metal
//  Metal shader for sacred geometry backgrounds
//  High-performance GPU-accelerated particle and geometry effects
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// MARK: - Vertex Shader
struct VertexIn {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
    float time;
};

vertex VertexOut sacredGeometryVertex(
    VertexIn in [[stage_in]],
    constant float &time [[buffer(0)]],
    constant float2 &resolution [[buffer(1)]]
) {
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0);
    out.texCoord = in.texCoord;
    out.time = time;
    return out;
}

// MARK: - Flower of Life Pattern
float flowerOfLife(float2 uv, float time) {
    float2 center = float2(0.5, 0.5);
    float scale = 0.15;
    float intensity = 0.0;
    
    // Central circle
    float d = length(uv - center);
    intensity += smoothstep(scale, scale - 0.01, d);
    
    // Surrounding circles (6 petals)
    for (int i = 0; i < 6; i++) {
        float angle = float(i) * (M_PI_F / 3.0) + time * 0.1;
        float2 offset = float2(cos(angle), sin(angle)) * scale;
        float d2 = length(uv - (center + offset));
        intensity += smoothstep(scale, scale - 0.01, d2) * 0.5;
    }
    
    // Second layer (12 circles)
    for (int i = 0; i < 12; i++) {
        float angle = float(i) * (M_PI_F / 6.0) - time * 0.05;
        float2 offset = float2(cos(angle), sin(angle)) * scale * 2.0;
        float d3 = length(uv - (center + offset));
        intensity += smoothstep(scale, scale - 0.01, d3) * 0.25;
    }
    
    return intensity;
}

// MARK: - Metatron's Cube
float metatronsCube(float2 uv, float time) {
    float2 center = float2(0.5, 0.5);
    float scale = 0.2;
    float lineWidth = 0.002;
    float intensity = 0.0;
    
    // Two overlapping triangles
    float triangle1 = 0.0;
    float triangle2 = 0.0;
    
    for (int i = 0; i < 3; i++) {
        float angle1 = float(i) * (2.0 * M_PI_F / 3.0) + time * 0.1;
        float angle2 = angle1 + M_PI_F;
        
        float2 p1 = center + float2(cos(angle1), sin(angle1)) * scale;
        float2 p2 = center + float2(cos(angle1 + 2.0 * M_PI_F / 3.0), sin(angle1 + 2.0 * M_PI_F / 3.0)) * scale;
        
        // Draw lines (simplified)
        float d = length(uv - p1);
        triangle1 += smoothstep(lineWidth * 2.0, lineWidth, d);
    }
    
    return intensity;
}

// MARK: - Particle System
float particles(float2 uv, float time, int particleCount) {
    float intensity = 0.0;
    
    for (int i = 0; i < particleCount; i++) {
        float fi = float(i);
        float speed = 0.1 + fract(fi * 0.123) * 0.2;
        float size = 0.002 + fract(fi * 0.456) * 0.003;
        
        float2 particlePos = float2(
            fract(fi * 0.789 + time * speed),
            fract(fi * 0.321 - time * speed * 0.5)
        );
        
        float d = length(uv - particlePos);
        intensity += smoothstep(size * 3.0, size, d) * 0.5;
    }
    
    return intensity;
}

// MARK: - Sacred Geometry Fragment Shader
fragment float4 sacredGeometryFragment(
    VertexOut in [[stage_in]],
    constant float4 &color1 [[buffer(0)]],
    constant float4 &color2 [[buffer(1)]],
    constant int &patternType [[buffer(2)]],
    texture2d<float> noiseTexture [[texture(0)]]
) {
    float2 uv = in.texCoord;
    float time = in.time;
    
    // Base gradient
    float4 bgColor = mix(
        float4(0.04, 0.04, 0.06, 1.0),  // Deep cosmic black
        float4(0.06, 0.05, 0.08, 1.0),  // Slightly lighter
        uv.y
    );
    
    float pattern = 0.0;
    
    // Select pattern based on type
    switch (patternType) {
        case 0: // Flower of Life
            pattern = flowerOfLife(uv, time);
            break;
        case 1: // Metatron's Cube
            pattern = metatronsCube(uv, time);
            break;
        case 2: // Particles
            pattern = particles(uv, time, 50);
            break;
        default:
            pattern = flowerOfLife(uv, time);
    }
    
    // Apply glow effect
    float glow = pattern * 1.5;
    glow += particles(uv, time, 30) * 0.3; // Add subtle particles
    
    // Color mixing
    float4 patternColor = mix(color1, color2, pattern + sin(time * 0.5) * 0.2);
    
    // Final composition
    float4 finalColor = mix(bgColor, patternColor, glow * 0.6);
    finalColor.a = 1.0;
    
    return finalColor;
}

// MARK: - Glow Effect Shader
fragment float4 glowFragment(
    VertexOut in [[stage_in]],
    texture2d<float> sourceTexture [[texture(0)]],
    constant float &intensity [[buffer(0)]]
) {
    constexpr sampler textureSampler(coord::normalized, address::clamp_to_edge, filter::linear);
    
    float2 uv = in.texCoord;
    float4 color = sourceTexture.sample(textureSampler, uv);
    
    // Simple blur for glow
    float blurSize = 0.005 * intensity;
    float4 glow = float4(0.0);
    
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            float2 offset = float2(float(x), float(y)) * blurSize;
            glow += sourceTexture.sample(textureSampler, uv + offset);
        }
    }
    
    glow /= 25.0;
    
    return color + glow * intensity;
}
