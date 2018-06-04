
Shader "SimplestInstancedShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		ZWrite Off
		ZTest Always
		Cull Off
        Blend oneMinusSrcAlpha srcAlpha
        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #pragma target 5.0
            #define MAXCOUNT 1023
            StructuredBuffer<float> timeSliceBuffer;
            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float timeSlice : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            v2f vert(appdata v, uint instanceID : SV_InstanceID)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.vertex = mul(unity_ObjectToWorld, v.vertex);
				o.timeSlice = timeSliceBuffer[instanceID];
                o.uv = v.uv;
                return o;
            }
           #define PI 18.84955592153876
            float4 frag(v2f i) : SV_Target
            {
                float4 c = 1;
                float2 dir = i.uv - 0.5;
                float len = length(dir);
                bool ignore = len > 0.5;
                dir /= max(len, 1e-5);
                c.xy = (dir * sin(-i.timeSlice * PI + len * 20)) * 0.5 + 0.5;
                c.a = ignore ? 1 : i.timeSlice;
                return c;
            }
            ENDCG
        }
    }
}