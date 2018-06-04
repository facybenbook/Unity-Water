Shader "Hidden/RoughnessBlur"
{
	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _DepthTexture;
		sampler2D _MainTex;
		float _BlurOffset;
		float4 _MainTex_TexelSize;
        #define BLUR3 float4(0.0205,0.0205,0.0205,0)
        #define BLUR2 float4(0.0855,0.0855,0.0855,0)
        #define BLUR1 float4(0.232,0.232,0.232,0)
        #define BLUR0 float4(0.324,0.324,0.324,1)
		#define BLURCULLVALUE 10

		inline float4 GausBlur(float2 uv, float2 offset){
			float depth = tex2D(_DepthTexture, uv).r;
			offset *= depth;
			offset = max(0, min(_MainTex_TexelSize.x * 6, offset));
			float4 originColor = tex2D(_MainTex, uv);
			float4 c = originColor * BLUR0;
			float4 offsetTimes = float4(offset * 2, offset * 3);
			float2 currentUV = uv + offset;
			float currentDepth = tex2D(_DepthTexture, currentUV);
			float4 currentColor = tex2D(_MainTex, currentUV);
			currentColor = lerp(currentColor, originColor, saturate(abs(currentDepth - depth) * BLURCULLVALUE));
			c += currentColor * BLUR1;
			currentUV = uv + offsetTimes.xy;
			currentDepth = tex2D(_DepthTexture, currentUV);
			currentColor = tex2D(_MainTex, currentUV);
			currentColor = lerp(currentColor, originColor, saturate(abs(currentDepth - depth) * BLURCULLVALUE));
			c += currentColor * BLUR2;
			currentUV = uv + offsetTimes.zw;
			currentDepth = tex2D(_DepthTexture, currentUV);
			currentColor = tex2D(_MainTex, currentUV);
			currentColor = lerp(currentColor, originColor, saturate(abs(currentDepth - depth) * BLURCULLVALUE));
			c += currentColor * BLUR3;
			currentUV = uv - offset;
			currentDepth = tex2D(_DepthTexture, currentUV);
			currentColor = tex2D(_MainTex, currentUV);
			currentColor = lerp(currentColor, originColor, saturate(abs(currentDepth - depth) * BLURCULLVALUE));
			c += currentColor * BLUR1;
			currentUV = uv - offsetTimes.xy;
			currentDepth = tex2D(_DepthTexture, currentUV);
			currentColor = tex2D(_MainTex, currentUV);
			currentColor = lerp(currentColor, originColor, saturate(abs(currentDepth - depth) * BLURCULLVALUE));
			c += currentColor * BLUR2;
			currentUV = uv - offsetTimes.zw;
			currentDepth = tex2D(_DepthTexture, currentUV);
			currentColor = tex2D(_MainTex, currentUV);
			currentColor = lerp(currentColor, originColor, saturate(abs(currentDepth - depth) * BLURCULLVALUE));
			c += currentColor * BLUR3;
			return c;
		}
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
		Pass	//0 Horizontal Blur
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			float4 frag (v2f i) : SV_Target
			{
				return GausBlur(i.uv, float2(_BlurOffset, 0));
			}
			ENDCG
		}

		Pass	//1 Vertical Blur
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			float4 frag (v2f i) : SV_Target
			{
				return GausBlur(i.uv, float2(0, _BlurOffset));
			}
			ENDCG
		}
	}
}
