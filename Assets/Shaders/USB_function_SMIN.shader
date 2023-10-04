Shader "Unlit/USB_function_SMIN"
{
    Properties
    {     
        _MainTex ("Texture", 2D) = "white" {}
        _Position ("Circle Position", Range(0, 1)) = 0.5
        _Smooth ("Circle Smooth", Range(0.0, 0.1)) = 0.01
        _K ("K", Range(0.0, 0.5)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Position;
            float _Smooth;
            float _K;

            float circle(float2 p, float r)
            {
                float d = length(p) - r;
                return d;
            }

            float smin(float a, float b, float k)
            {
                float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
                return lerp(b, a, k) - k * h * (1.0 - h);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float a = circle(i.uv, 0.5);
                float b = circle(i.uv - _Position, 0.2);
                float s = smin(a, b, _K);                
                float render = smoothstep(s - _Smooth, s + _Smooth, 0.0);
                return float4(render.xxx, 1);
            }
            ENDCG
        }
    }
}
