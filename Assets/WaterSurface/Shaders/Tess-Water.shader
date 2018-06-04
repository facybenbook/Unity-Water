 Shader "Tessellation/Water" {
	Properties {
		_MinDist("Tess Min Distance", float) = 10
		_MaxDist("Tess Max Distance", float) = 25
		_Tessellation("Tessellation", Range(1,63)) = 1
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalScale("Normal Scale", float) = 1
		_SpecularMap("Specular Map", 2D) = "white"{}
		_HeightMap("Vertex Map", 2D) = "black"{}
		//_HeightScale("Height Scale", Range(-4,4)) = 1
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_OcclusionMap("Occlusion Map", 2D) = "white"{}
		_Occlusion("Occlusion Scale", Range(0,1)) = 1
		_SpecularColor("Specular Color",Color) = (0.2,0.2,0.2,1)
		_EmissionColor("Emission Color", Color) = (0,0,0,1)
		_VertexScale("Vertex Scale", Range(0,3)) = 0.1
		_VertexOffset("Vertex Offset", Range(-1,1)) = 0
    _FrontDiffuseColor("Front diffuse Color", Color) = (1,1,1,1)
    _BackDiffuseColor("Back diffuse Color", Color) = (0,0,0,1)
    _TransColor("Transmission Color", Color) = (0,1,0.5,1)
    _OpaqueIntensity("Opaque intensity", float) = 1
    _Distortion("Screen Distortion", Range(0,1)) = 0.1

	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
		LOD 200

		
	// ------------------------------------------------------------
	// Surface shader code generated out of a CGPROGRAM block:
CGINCLUDE
#define _ALPHAPREMULTIPLY_ON 1
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityMetaPass.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"
#include "Water.cginc"

#pragma shader_feature USE_NORMAL
#pragma shader_feature USE_SPECULAR
#pragma shader_feature USE_VERTEX
#pragma shader_feature USE_OCCLUSION
#pragma shader_feature USE_ALBEDO

		struct Input {
			float2 uv_MainTex;
		};
		
struct appdata_tess{
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 texcoord1 : TEXCOORD1;
    float4 texcoord2 : TEXCOORD2;
};

    float4 _SpecularColor;
    float4 _EmissionColor;
		float _MinDist;
		float _MaxDist;
		float _Tessellation;
		float _HeightScale;
		float _NormalScale;
		float _Occlusion;
		float _VertexScale;
		float _VertexOffset;
    float4 _FrontDiffuseColor;
    float4 _BackDiffuseColor;
    float4 _TransColor;
    float _OpaqueIntensity;
    float _Distortion;
		sampler2D _BumpMap;
		sampler2D _SpecularMap;
		sampler2D _HeightMap;
		sampler2D _OcclusionMap;
		sampler2D _MainTex;
		half _Glossiness;
		float4 _Color;

		inline void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
			// Albedo comes from a texture tinted by color
			float2 uv = IN.uv_MainTex;// - parallax_mapping(IN.uv_MainTex,IN.viewDir);
			#if USE_ALBEDO
			float4 c = tex2D (_MainTex, uv) * _Color;

			o.Albedo = c.rgb;
			o.Alpha *= c.a;
			#else
			o.Albedo = _Color.rgb;
			o.Alpha *= _Color.a;
			#endif

			#if USE_OCCLUSION
			o.Occlusion = lerp(1, tex2D(_OcclusionMap, IN.uv_MainTex).r, _Occlusion);
			#else
			o.Occlusion = 1;
			#endif

			#if USE_SPECULAR
			float4 spec = tex2D(_SpecularMap, IN.uv_MainTex);
			o.Specular = _SpecularColor  * spec.rgb;
			o.Smoothness = _Glossiness * spec.a;
			#else
			o.Specular = _SpecularColor;
			o.Smoothness = _Glossiness;
			#endif
			o.Emission = _EmissionColor;

		}

    inline void GetNormal(inout float3 normal, float2 uv){
      #if USE_NORMAL
      normal = normalize(UnpackNormal(tex2D(_BumpMap, uv)));
      #else
      normal = float3(0,0,1);
      #endif
    }

struct InternalTessInterp_appdata_full {
  float4 vertex : INTERNALTESSPOS;
  float4 tangent : TANGENT;
  float3 normal : NORMAL;
  float4 texcoord : TEXCOORD0;
  float4 texcoord1 : TEXCOORD1;
  float4 texcoord2 : TEXCOORD2;
  float4 color : COLOR;
};

inline InternalTessInterp_appdata_full tessvert_surf (appdata_tess v) {
  InternalTessInterp_appdata_full o;
  o.vertex = v.vertex;
  o.tangent = v.tangent;
  o.normal = v.normal;
  o.texcoord = v.texcoord;
  o.texcoord1 = v.texcoord1;
  o.texcoord2 = v.texcoord2;
  return o;
}

inline void vert(inout appdata_tess v){
	v.vertex.xyz += v.normal * ((tex2Dlod(_HeightMap, v.texcoord).r + _VertexOffset) * _VertexScale);

}

inline float3 UnityCalcTriEdgeTessFactors (float3 triVertexFactors)
{
    float3 tess;
    tess.x = (triVertexFactors.y + triVertexFactors.z);
    tess.y = (triVertexFactors.x + triVertexFactors.z);
    tess.z = (triVertexFactors.x + triVertexFactors.y);
    tess *= 0.5;
    return tess;
}


inline float UnityCalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess)
{
    float3 wpos = mul(unity_ObjectToWorld,vertex).xyz;
    float dist = distance (wpos, _WorldSpaceCameraPos);
    float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
    return f;
}

inline float3 tessDist (float4 v0, float4 v1, float4 v2)
{
    float3 f;
    f.x = UnityCalcDistanceTessFactor (v0,_MinDist,_MaxDist,_Tessellation);
    f.y = UnityCalcDistanceTessFactor (v1,_MinDist,_MaxDist,_Tessellation);
    f.z = UnityCalcDistanceTessFactor (v2,_MinDist,_MaxDist,_Tessellation);
   	return UnityCalcTriEdgeTessFactors (f);

}

inline UnityTessellationFactors hsconst_surf (InputPatch<InternalTessInterp_appdata_full,3> v) {
  UnityTessellationFactors o;
  float3 tf = (tessDist(v[0].vertex, v[1].vertex, v[2].vertex));
  float3 objCP = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1)).xyz;
  float3 dir = step(0, float3(dot(normalize(objCP - v[0].vertex), v[0].normal), dot(normalize(objCP - v[1].vertex), v[1].normal), dot(normalize(objCP - v[2].vertex), v[2].normal)));
  tf = lerp(0, tf, saturate(dir.x + dir.y + dir.z));
  o.edge[0] = tf.x;
  o.edge[1] = tf.y;
  o.edge[2] = tf.z;
  o.inside = (tf.x + tf.y + tf.z) * 0.33333333;

  return o;
}

[UNITY_domain("tri")]
[UNITY_partitioning("fractional_odd")]
[UNITY_outputtopology("triangle_cw")]
[UNITY_patchconstantfunc("hsconst_surf")]
[UNITY_outputcontrolpoints(3)]
inline InternalTessInterp_appdata_full hs_surf (InputPatch<InternalTessInterp_appdata_full,3> v, uint id : SV_OutputControlPointID) {
  
  return v[id];
}
ENDCG
	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
ZWrite off Blend one zero
CGPROGRAM
#define UNITY_PASS_FORWARDBASE

#pragma vertex tessvert_surf
#pragma hull hs_surf
#pragma domain ds_surf
#pragma fragment frag_surf
#pragma target 5.0
#pragma multi_compile_fog
#pragma multi_compile_fwdbase

// Original surface shader snippet:
#line 10 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)
// Surface shader code generated based on:
// vertex modifier: 'disp'
// writes to per-pixel normal: YES
// writes to emission: YES
// writes to occlusion: YES
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: YES
// reads from normal: no
// 1 texcoords actually used
//   float2 _MainTex

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) float3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:

#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

// vertex-to-fragment interpolation data
// no lightmaps:
#ifndef LIGHTMAP_ON
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float4 tSpace0 : TEXCOORD1;
  float4 tSpace1 : TEXCOORD2;
  float4 tSpace2 : TEXCOORD3;

  #if UNITY_SHOULD_SAMPLE_SH
  half3 sh : TEXCOORD4; // SH
  #endif
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  #if SHADER_TARGET >= 30
  float4 lmap : TEXCOORD7;
  #endif
  float3 worldViewDir : TEXCOORD10;
  float3 lightDir : TEXCOORD11;
  float4 screenPos : TEXCOORD12;
};
#endif
// with lightmaps:
#ifdef LIGHTMAP_ON
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float4 tSpace0 : TEXCOORD1;
  float4 tSpace1 : TEXCOORD2;
  float4 tSpace2 : TEXCOORD3;

  float4 lmap : TEXCOORD4;
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  float3 worldViewDir : TEXCOORD9;
  float3 lightDir : TEXCOORD10;
  float4 screenPos : TEXCOORD11;
};
#endif
float4 _MainTex_ST;

// vertex shader
inline v2f_surf vert_surf (appdata_tess v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);

  o.pos = UnityObjectToClipPos(v.vertex);
  o.screenPos = ComputeScreenPos(o.pos);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  o.worldViewDir = (UnityWorldSpaceViewDir(worldPos));
  float3 worldNormal = UnityObjectToWorldNormal(v.normal);
  float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
   o.tSpace0 = (float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x));
  o.tSpace1 = (float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y));
  o.tSpace2 = (float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z));
    
  #ifdef DYNAMICLIGHTMAP_ON
  o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  #endif
  #ifdef LIGHTMAP_ON
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif

  // SH/ambient and vertex lights
  #ifndef LIGHTMAP_ON
    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
      o.sh = 0;
      // Approximated illumination from non-important point lights
      #ifdef VERTEXLIGHT_ON
        o.sh += Shade4PointLights (
          unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
          unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
          unity_4LightAtten0, worldPos, worldNormal);
      #endif
      o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    #endif
  #endif // !LIGHTMAP_ON

  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
    #ifndef USING_DIRECTIONAL_LIGHT
    o.lightDir = (UnityWorldSpaceLightDir(worldPos));
  #else
    o.lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  return o;
}

// tessellation domain shader
[UNITY_domain("tri")]
inline v2f_surf ds_surf (UnityTessellationFactors tessFactors, const OutputPatch<InternalTessInterp_appdata_full,3> vi, float3 bary : SV_DomainLocation) {
  appdata_tess v;
  v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
  v.tangent = vi[0].tangent*bary.x + vi[1].tangent*bary.y + vi[2].tangent*bary.z;
  v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
  v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
  v.texcoord1 = vi[0].texcoord1*bary.x + vi[1].texcoord1*bary.y + vi[2].texcoord1*bary.z;
  v.texcoord2 = vi[0].texcoord2*bary.x + vi[1].texcoord2*bary.y + vi[2].texcoord2*bary.z;
  #if USE_VERTEX
  vert(v);
  #endif
  v2f_surf o = vert_surf (v);
  return o;
}



// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  
  surfIN.uv_MainTex = IN.pack0.xy;
  float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
  float3 lightDir = normalize(IN.lightDir);
  float3 worldViewDir = normalize(IN.worldViewDir);
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
  #else
  SurfaceOutputStandardSpecular o;
  #endif


  GetNormal(o.Normal, IN.pack0);
  float3x3 wdMatrix= float3x3(normalize(IN.tSpace0.xyz),  normalize(IN.tSpace1.xyz),  normalize(IN.tSpace2.xyz));
  float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
  screenUV += o.Normal.xy * _Distortion;
  float screenDepth = LinearEyeDepth(tex2D(_CameraDepthTexture, screenUV));
  screenDepth -= LinearEyeDepth(IN.pos.z);
  screenDepth = saturate(CURVE(screenDepth * _OpaqueIntensity));
  o.Alpha = screenDepth;
  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  float4 c = 0;

  o.Normal = normalize(mul(wdMatrix, o.Normal));

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;

  gi.light.color = _LightColor0.rgb;
  gi.light.dir = lightDir;
  // Call GI (lightmaps/SH/reflections) lighting function
  UnityGIInput giInput;
  UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
  giInput.light = gi.light;
  giInput.worldPos = worldPos;
  giInput.worldViewDir = worldViewDir;
  giInput.atten = atten;
  #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = IN.lmap;
  #else
    giInput.lightmapUV = 0.0;
  #endif
  #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
    giInput.ambient = IN.sh;
  #else
    giInput.ambient.rgb = 0.0;
  #endif
  WaterGI(o, giInput, gi);
  gi.indirect.specular = tex2D(_ReflectionTex, screenUV);
  // realtime lighting: call lighting function
  c += WaterLighting (o, worldViewDir, gi);
  c.rgb += o.Emission;
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog

  float4 backGround = tex2D(_ScreenTexture, screenUV) * lerp(1, _TransColor, screenDepth);
  c.rgb += (1 - c.a) * backGround;
  return c;
}


#endif

ENDCG

}

	// ---- forward rendering additive lights pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardAdd" }
		ZWrite Off Blend One One

CGPROGRAM
// compile directives
#pragma vertex tessvert_surf
#pragma fragment frag_surf
#pragma hull hs_surf
#pragma domain ds_surf
#pragma target 5.0

#pragma multi_compile_fog
#pragma skip_variants INSTANCING_ON
#pragma multi_compile_fwdadd_fullshadows
#define UNITY_PASS_FORWARDADD

// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)
// Surface shader code generated based on:
// vertex modifier: 'disp'
// writes to per-pixel normal: YES
// writes to emission: YES
// writes to occlusion: YES
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: YES
// reads from normal: no
// 1 texcoords actually used
//   float2 _MainTex



#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) float3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 22 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

// vertex-to-fragment interpolation data
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float3 tSpace0 : TEXCOORD1;
  float3 tSpace1 : TEXCOORD2;
  float3 tSpace2 : TEXCOORD3;
  float3 worldPos : TEXCOORD4;
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  float3 worldViewDir : TEXCOORD9;
  float3 lightDir : TEXCOORD10;
};
float4 _MainTex_ST;

// vertex shader
inline v2f_surf vert_surf (appdata_tess v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);

  o.pos = UnityObjectToClipPos(v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  o.worldViewDir = (UnityWorldSpaceViewDir(worldPos));
  float3 worldNormal = UnityObjectToWorldNormal(v.normal);
  float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  o.tSpace0 = (float3(worldTangent.x, worldBinormal.x, worldNormal.x));
  o.tSpace1 = (float3(worldTangent.y, worldBinormal.y, worldNormal.y));
  o.tSpace2 = (float3(worldTangent.z, worldBinormal.z, worldNormal.z));
      
  o.worldPos = worldPos;
      #ifndef USING_DIRECTIONAL_LIGHT
    o.lightDir = (UnityWorldSpaceLightDir(worldPos));
  #else
    o.lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
  return o;
}

// tessellation domain shader
[UNITY_domain("tri")]
inline v2f_surf ds_surf (UnityTessellationFactors tessFactors, const OutputPatch<InternalTessInterp_appdata_full,3> vi, float3 bary : SV_DomainLocation) {
  appdata_tess v;
  v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
  v.tangent = vi[0].tangent*bary.x + vi[1].tangent*bary.y + vi[2].tangent*bary.z;
  v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
  v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
  v.texcoord1 = vi[0].texcoord1*bary.x + vi[1].texcoord1*bary.y + vi[2].texcoord1*bary.z;
  v.texcoord2 = 0;

    #if USE_VERTEX
  vert(v);
  #endif
  v2f_surf o = vert_surf (v);
  return o;
}


// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  
  surfIN.uv_MainTex = IN.pack0.xy;
  float3 worldPos = (IN.worldPos);
  float3 lightDir = normalize(IN.lightDir);
  float3 worldViewDir = normalize(IN.worldViewDir);
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
  #else
  SurfaceOutputStandardSpecular o;
  #endif


  GetNormal(o.Normal, IN.pack0);
  float3x3 wdMatrix= float3x3(  normalize(IN.tSpace0.xyz),  normalize(IN.tSpace1.xyz),  normalize(IN.tSpace2.xyz));
  // call surface function
  surf (surfIN, o);
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)

  o.Normal = normalize(mul(wdMatrix, o.Normal));
  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  gi.light.color = _LightColor0.rgb;
  gi.light.dir = lightDir;
  gi.light.color *= atten;
  float4 c = WaterLighting (o, worldViewDir, gi);
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  return c;
}


#endif


ENDCG

}
	// ---- meta information extraction pass:
	Pass {
		Name "Meta"
		Tags { "LightMode" = "Meta" }
		Cull Off

CGPROGRAM
// compile directives
#pragma vertex tessvert_surf
#pragma fragment frag_surf
#pragma hull hs_surf
#pragma domain ds_surf
#pragma target 5.0

#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma skip_variants INSTANCING_ON
#pragma shader_feature EDITOR_VISUALIZATION


// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)
// Surface shader code generated based on:
// vertex modifier: 'disp'
// writes to per-pixel normal: YES
// writes to emission: YES
// writes to occlusion: YES
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: YES
// reads from normal: no
// 1 texcoords actually used
//   float2 _MainTex
#define UNITY_PASS_META

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) float3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 22 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

// vertex-to-fragment interpolation data
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float4 tSpace0 : TEXCOORD1;
  float4 tSpace1 : TEXCOORD2;
  float4 tSpace2 : TEXCOORD3;
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};
float4 _MainTex_ST;

// vertex shader
inline v2f_surf vert_surf (appdata_tess v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);

  o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  float3 worldNormal = UnityObjectToWorldNormal(v.normal);
  float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign; 
  return o;
}

// tessellation domain shader
[UNITY_domain("tri")]
inline v2f_surf ds_surf (UnityTessellationFactors tessFactors, const OutputPatch<InternalTessInterp_appdata_full,3> vi, float3 bary : SV_DomainLocation) {
  appdata_tess v;
  v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
  v.tangent = vi[0].tangent*bary.x + vi[1].tangent*bary.y + vi[2].tangent*bary.z;
  v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
  v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
  v.texcoord1 = vi[0].texcoord1*bary.x + vi[1].texcoord1*bary.y + vi[2].texcoord1*bary.z;
  v.texcoord2 = vi[0].texcoord2*bary.x + vi[1].texcoord2*bary.y + vi[2].texcoord2*bary.z;
   #if USE_VERTEX
  vert(v);
  #endif
  v2f_surf o = vert_surf (v);
  return o;
}


// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  
  surfIN.uv_MainTex = IN.pack0.xy;
  float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
  #else
  SurfaceOutputStandardSpecular o;
  #endif



  // call surface function
  surf (surfIN, o);
  UnityMetaInput metaIN;
  UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
  metaIN.Albedo = o.Albedo;
  metaIN.Emission = o.Emission;
  metaIN.SpecularColor = o.Specular;
  return UnityMetaFragment(metaIN);
}


#endif


ENDCG

}
	}
  Fallback "Standard"
CustomEditor "SpecularShaderEditor"
}

