#ifndef WATER_INCLUDE
#define WATER_INCLUDE
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityMetaPass.cginc"
#include "AutoLight.cginc"

/*
 * Variables
 */
sampler2D _CameraDepthTexture;
sampler2D _WaterRampTex;
//RGB normal A height
sampler2D _DisplacementTex0;
sampler2D _DisplacementTex1;
sampler2D _DisplacementTex2;
sampler2D _DisplacementTex3;
sampler2D _ScreenTexture;
sampler2D _ReflectionTex;
/*
 * Functions
 */
#define half float
#define half2 float2
#define half3 float3
#define half4 float4
#define GET_DIFFUSE_COLOR(NdotL) (tex2D(_WaterRampTex, float2(NdotL * 0.5 + 0.5, 0.5)))
#define CURVE(x) (1-exp(-x))
//Get depth from depth texture to pixel
inline float getDepth(float4 viewPos, float2 uv){
    float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, uv).r);
    return depth - length(viewPos);
}

float3 cubic_interpolate(float3 value1, float3 value2, float3 value3, float3 value4, float x){
    float3 p = (value4 - value3) - (value1 - value2);
    float3 q = (value1 - value2) - p;
	float3 r = value3 - value1;
    float2 xValue;
    xValue.x = x * x;
    xValue.y = xValue.x * x;
    return p * xValue.y + q * xValue.x + r * x + value2;
}

float cubic_interpolate(float value1, float value2, float value3, float value4, float x){
    float p = (value4 - value3) - (value1 - value2);
    float q = (value1 - value2) - p;
	float r = value3 - value1;
    float3 final = float3(p,q,r);
    float3 xValue;
    xValue.y = x * x;
    xValue.x = xValue.x * x;
    xValue.z = x;
    final *= xValue;
    return final.x + final.y + final.z + value2;
}

inline void WaterGI (
    SurfaceOutputStandardSpecular s,
    UnityGIInput data,
    inout UnityGI gi)
{
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
}

half4 Water_BRDF (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

    half nv = dot(normal, viewDir);    // This abs allow to limit artifact


    half nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));

    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    // Diffuse term
    half diffuseTerm = GET_DIFFUSE_COLOR(nl);
    //SSS transmission required here
    //Diffuse = DisneyDiffuse(NoV, NoL, LoH, SmoothnessToPerceptualRoughness (smoothness)) * NoL;
    // Specular term
    // HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
    // BUT 1) that will make shader look significantly darker than Legacy ones
    // and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    // GGX with roughtness to 0 would mean no specular at all, using max(roughness, 0.002) here to match HDrenderloop roughtness remapping.
    roughness = max(roughness, 0.002);
    half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    float D = GGXTerm (nh, roughness);


    half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

#   ifdef UNITY_COLORSPACE_GAMMA
        specularTerm = sqrt(max(1e-4h, specularTerm));
#   endif

    // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
    specularTerm = max(0, specularTerm * nl);
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
#endif
#if !UNITY_PASS_FORWARDADD
    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
#   ifdef UNITY_COLORSPACE_GAMMA
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#   else
        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#   endif
#endif

    #if UNITY_PASS_FORWARDADD
     half3 color =   (diffColor * diffuseTerm + specularTerm * FresnelTerm (specColor, lh)) * light.color;
    #else
    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   diffColor * (gi.diffuse + light.color * diffuseTerm)
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
    #endif
    return half4(color, 1);
}

inline half4 WaterLighting (SurfaceOutputStandardSpecular s, float3 viewDir, UnityGI gi)
{
    // energy conservation
    half oneMinusReflectivity;
    s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

    half4 c = Water_BRDF (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
    c.a = outputAlpha;
    return c;
}

#endif