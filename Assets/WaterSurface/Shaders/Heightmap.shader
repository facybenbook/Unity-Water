Shader "Hidden/Heightmap"
{
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
CGINCLUDE
			#include "UnityCG.cginc"
			#pragma target 5.0
			StructuredBuffer<float3> results;
			#define BUFFERSIZE 32.0
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = v.vertex;
				o.uv = v.uv;
				return o;
			}

ENDCG
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 frag (v2f i) : SV_Target
			{
				float2 bufferPos = i.uv * BUFFERSIZE;
				int4 index = int4(int2(bufferPos - 1e-5), 0, 0);
				index.zw = index.xy + 1;
				index = min(31, max(0, index));	//Left bottom right top
				int2 yAxisCoord = index.yw * BUFFERSIZE;
				int4 Coord = int4(yAxisCoord.xxyy + index.xzxz);
				float2 lerpValue = frac(bufferPos);
				float3 down = lerp(results[Coord.x], results[Coord.y], lerpValue.x);
				float3 top = lerp(results[Coord.z], results[Coord.w], lerpValue.x);
				return float4(lerp(down, top, lerpValue.y) * 0.5 + 0.5, 1);
			}
			ENDCG
		}
	}
}
