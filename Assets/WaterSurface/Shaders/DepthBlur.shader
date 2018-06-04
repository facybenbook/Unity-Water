Shader "Hidden/DepthBlur"
{
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag		
			#include "UnityCG.cginc"
			float4 _MirrorNormal;
			float4 _MirrorPos;
			#define DISTANCEFADE 0.01
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 wpos : TEXCOORD0;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.wpos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				i.wpos /= i.wpos.w;
				float3 wpos = i.wpos.xyz-_MirrorPos;
				return max(1e-5, 1 - exp(-dot(wpos, _MirrorNormal.xyz) * DISTANCEFADE));	//Keep 30 meters
			}
			ENDCG
		}
	}
}
