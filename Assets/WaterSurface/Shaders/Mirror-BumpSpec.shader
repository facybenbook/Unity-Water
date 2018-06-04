Shader "Mirrors/Bump Specular" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalScale("Normal Scale", float) = 1
		_SpecularMap("Specular Map", 2D) = "white"{}
		_Distortion ("Reflective Distortion", Range (0, 1)) = 0

		_OcclusionMap("Occlusion Map", 2D) = "white"{}
		_Occlusion("Occlusion Scale", Range(0,1)) = 1
		_SpecularColor("Specular Color",Color) = (0.2,0.2,0.2,1)
		_EmissionColor("Emission Color", Color) = (0,0,0,1)
    _Glossiness("Smoothness", Range(0,1)) = 0.5
		_DetailAlbedo("Detail Albedo(RGB) Mask(A)", 2D) = "black"{}
		_AlbedoBlend("Albedo Blend Rate", Range(0,1)) = 0.3
		_DetailBump("Detail Bump(RGB) Mask(A)", 2D) = "bump"{}
		_BumpBlend("Bump Blend Rate", Range(0,1)) = 0.3

	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
		LOD 200

		
	// ------------------------------------------------------------
	// Surface shader code generated out of a CGPROGRAM block:
CGINCLUDE

#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "UnityMetaPass.cginc"
#include "AutoLight.cginc"
#pragma shader_feature USE_NORMAL
#pragma shader_feature USE_SPECULAR
#pragma shader_feature USE_PHONG
#pragma shader_feature USE_OCCLUSION
#pragma shader_feature USE_ALBEDO
#pragma shader_feature USE_DETAILALBEDO
#pragma shader_feature USE_DETAILNORMAL
		struct Input {
			float2 uv_MainTex;
			#if USE_DETAILALBEDO
			float2 uv_DetailAlbedo;
			#endif
			#if USE_DETAILNORMAL
			float2 uv_DetailNormal;
			#endif
		};
		
        float4 _SpecularColor;
        float4 _EmissionColor;
		float _EdgeLength;
		float _HeightScale;
		float _Phong;
		float _NormalScale;
		float _Occlusion;
		sampler2D _DetailAlbedo;
		float _AlbedoBlend;
		sampler2D _DetailBump;
		float _BumpBlend;
		float4 _DetailAlbedo_ST;
		float4 _DetailBump_ST;
		half _Distortion;
		float _Glossiness;
		sampler2D _BumpMap;
		sampler2D _SpecularMap;
		sampler2D _OcclusionMap;
		sampler2D _ReflectionTex;
		
		sampler2D _MainTex;
		float4 _Color;

	inline void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
			// Albedo comes from a texture tinted by color
			float2 uv = IN.uv_MainTex;// - parallax_mapping(IN.uv_MainTex,IN.viewDir);
			#if USE_ALBEDO
			float4 c = tex2D (_MainTex, uv) * _Color;

			#if USE_DETAILALBEDO
			float4 dA = tex2D(_DetailAlbedo, IN.uv_DetailAlbedo);
			c.rgb = lerp(c.rgb, dA.rgb, _AlbedoBlend);
			#endif
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			#else
			#if USE_DETAILALBEDO
			float4 dA = tex2D(_DetailAlbedo, IN.uv_DetailAlbedo);
			o.Albedo.rgb = lerp(1, dA.rgb, _AlbedoBlend) * _Color;
			#else
			o.Albedo = _Color.rgb;
			o.Alpha = _Color.a;
			#endif
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


			#if USE_NORMAL
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
			#if USE_DETAILNORMAL
			float4 dN =  tex2D(_DetailBump,IN.uv_DetailNormal);
			o.Normal = lerp(o.Normal, UnpackNormal(dN), _BumpBlend);
			#endif
			o.Normal.xy *= _NormalScale;

			#else
			o.Normal = float3(0,0,1);
			#endif
			o.Emission = _EmissionColor;
		}

ENDCG
	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }

Blend srcAlpha oneMinussrcAlpha
Zwrite off

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf

#pragma target 5.0

#pragma multi_compile_fog
#pragma multi_compile_fwdbase
#if !defined(INSTANCING_ON)

// Original surface shader snippet:
#line 22 ""
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
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
  #if USE_DETAILALBEDO
  float2 pack1 : TEXCOORD8;
  #endif

  #if USE_DETAILNORMAL
  float2 pack2 : TEXCOORD9;

  #endif
  float3 lightDir : TEXCOORD10;
  float3 worldViewDir : TEXCOORD11;
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
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO

    #if USE_DETAILALBEDO
  float2 pack1 : TEXCOORD7;
  #endif

  #if USE_DETAILNORMAL
  float2 pack2 : TEXCOORD8;

  #endif
  float4 screenPos : TEXCOORD11;
    float3 lightDir : TEXCOORD9;
    float3 worldViewDir : TEXCOORD10;
};
#endif
float4 _MainTex_ST;

// vertex shader
inline v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);

  o.pos = UnityObjectToClipPos(v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.screenPos = ComputeScreenPos(o.pos);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  float3 worldNormal = UnityObjectToWorldNormal(v.normal);
  float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  #if USE_DETAILALBEDO
 o.pack1 = TRANSFORM_TEX(v.texcoord,_DetailAlbedo);
  #endif
  #if USE_DETAILNORMAL
  o.pack2 = TRANSFORM_TEX(v.texcoord, _DetailBump);
  #endif
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
      o.worldViewDir =  (UnityWorldSpaceViewDir(worldPos));
  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
        #ifndef USING_DIRECTIONAL_LIGHT
    o.lightDir = (UnityWorldSpaceLightDir(worldPos));
  #else
    o.lightDir = _WorldSpaceLightPos0.xyz;

  return o;
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION


#endif // UNITY_CAN_COMPILE_TESSELLATION


// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  surfIN.uv_MainTex = IN.pack0;
  #if USE_DETAILALBEDO
  surfIN.uv_DetailAlbedo = IN.pack1;
  #endif

  #if USE_DETAILNORMAL
  surfIN.uv_DetailNormal = IN.pack2;
  #endif
  float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
  float3 lightDir = normalize(IN.lightDir);
  float3 worldViewDir = normalize(IN.worldViewDir);
  #endif
  //float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
  #else
  SurfaceOutputStandardSpecular o;
  #endif


  

  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  float4 c = 0;
  float3x3 wdMatrix= float3x3(normalize(IN.tSpace0.xyz),normalize(IN.tSpace1.xyz),normalize (IN.tSpace2.xyz));
  o.Normal = normalize(mul(wdMatrix,  o.Normal));

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
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

  LightingStandardSpecular_GI(o, giInput, gi);

  // realtime lighting: call lighting function
  c += LightingStandardSpecular (o, worldViewDir, gi);
  c.rgb += o.Emission;
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
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
#pragma vertex vert_surf
#pragma fragment frag_surf

#pragma target 5.0

#pragma multi_compile_fog
#pragma skip_variants INSTANCING_ON
#pragma multi_compile_fwdadd_fullshadows

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

		

#ifdef UNITY_CAN_COMPILE_TESSELLATION

// tessellation vertex shader


// tessellation hull constant shader


// tessellation hull shader


#endif // UNITY_CAN_COMPILE_TESSELLATION


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
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
   #if USE_DETAILALBEDO
  float2 pack1 : TEXCOORD7;
  #endif

  #if USE_DETAILNORMAL
  float2 pack2 : TEXCOORD8;
  #endif
  float3 worldViewDir : TEXCOORD9;
  float3 lightDir : TEXCOORD10;
  float4 screenPos : TEXCOORD11;
};
float4 _MainTex_ST;

// vertex shader
inline v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);

  o.pos = UnityObjectToClipPos(v.vertex);
  o.screenPos = ComputeScreenPos(o.pos);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    #if USE_DETAILALBEDO
 o.pack1 = TRANSFORM_TEX(v.texcoord,_DetailAlbedo);
  #endif
  #if USE_DETAILNORMAL
  o.pack2 = TRANSFORM_TEX(v.texcoord, _DetailBump);
  #endif
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

#ifdef UNITY_CAN_COMPILE_TESSELLATION



#endif // UNITY_CAN_COMPILE_TESSELLATION


// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  surfIN.uv_MainTex = IN.pack0.xy;
    #if USE_DETAILALBEDO
  surfIN.uv_DetailAlbedo = IN.pack1;
  #endif

  #if USE_DETAILNORMAL
  surfIN.uv_DetailNormal = IN.pack2;
  #endif
  float3 worldPos = IN.worldPos;
  float3 lightDir = normalize(IN.lightDir);
  float3 worldViewDir = normalize(IN.worldViewDir);
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
  #else
  SurfaceOutputStandardSpecular o;
  #endif


  

  // call surface function
  surf (surfIN, o);
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  float4 c = 0;
  float3x3 wdMatrix= float3x3(normalize(IN.tSpace0.xyz),normalize(IN.tSpace1.xyz),normalize (IN.tSpace2.xyz));
  o.Normal = normalize(mul(wdMatrix, o.Normal));
  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  gi.light.color = _LightColor0.rgb;
  gi.light.dir = lightDir;
  gi.light.color *= atten;
  c += LightingStandardSpecular (o, worldViewDir, gi);
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  return c;
}


#endif


ENDCG

}

	Pass {
		Name "ShadowCaster"
		Tags { "LightMode" = "ShadowCaster" }
		ZWrite On ZTest LEqual

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf

#pragma target 5.0

#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_shadowcaster

// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 10 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

struct v2f_surf {
  V2F_SHADOW_CASTER;

  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};

// vertex shader
inline v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
  return o;
}

// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
 	SHADOW_CASTER_FRAGMENT(IN)
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
#pragma vertex vert_surf
#pragma fragment frag_surf

#pragma target 5.0

#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma skip_variants INSTANCING_ON
#pragma shader_feature EDITOR_VISUALIZATION


// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)



// Original surface shader snippet:
#line 22 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

#ifdef UNITY_CAN_COMPILE_TESSELLATION

// tessellation vertex shader


// tessellation hull constant shader

// tessellation hull shader


#endif // UNITY_CAN_COMPILE_TESSELLATION



// vertex-to-fragment interpolation data
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float4 tSpace0 : TEXCOORD1;
  float4 tSpace1 : TEXCOORD2;
  float4 tSpace2 : TEXCOORD3;
  float4 screenPos : TEXCOORD4;
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};
float4 _MainTex_ST;

// vertex shader
inline v2f_surf vert_surf (appdata_full v) {
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
   o.tSpace0 = (float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x));
  o.tSpace1 = (float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y));
  o.tSpace2 = (float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z));
  o.screenPos = ComputeScreenPos(o.pos);
  return o;
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION

// tessellation domain shader

#endif // UNITY_CAN_COMPILE_TESSELLATION


// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
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
  metaIN.SpecularColor = 0;
  return UnityMetaFragment(metaIN);
}


#endif


ENDCG

}

	// ---- end of surface shader generated code

#LINE 90

	}
CustomEditor "MirrorShaderEditor"
}

