Shader "Unlit/USB_simple_color"
{
    Properties
    { // propiedades en este bloque
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("MainColor",Color) = (1,1,1,1)
        [Header(Specular properties)]
        _Especular ("Specular", Range(0.0, 1.1)) = 0.3
        _Factor ("Factor", Float) = 0.3
        [Space(20)]
        [Header(Extra Properties)]
        _Cid ("Color id", Int) = 1
        _VPos ("Vertex Position", Vector) = (0, 0, 0, 1)

        _Reflection ("Reflection", Cube) = "black" {}
        _3DTexture ("3D Texture", 3D) = "white" {}
         [Toggle] _Enable ("Enable ?", Float) = 0
         
         // declaramos drawer Toggle
        [KeywordEnum(Off, Red, Blue)]
        _Options ("Color Options", Float) = 0

        // Declaramos drawer
        [Enum(Off, 0, Front, 1, Back, 2)]
        _Face ("Face Culling", Float) = 0

        //declaramos drawer
        [PowerSlider(3.0)]
        _Brightness ("Brightness", Range (0.01, 1)) = 0.08
        
        [IntRange]
        _Samples ("Samples", Range (0, 255)) = 100
    }

    SubShader 
    { // configuración de SubShader en este bloque
        Tags { "RenderType"="Opaque" }
        LOD 100
            
        Cull [_Face]

        Pass
        {
            CGPROGRAM
            // programa Cg - HLSL en este bloque
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            // declaramos pragma para usar propertie _Enable
            #pragma shader_feature _ENABLE_ON

            // declaramos pragma y condiciones
            #pragma multi_compile _OPTIONS_OFF _OPTIONS_RED _OPTIONS_BLUE

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

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float4 _Color;

            // generamos variables de conexión
            float _Brightness;
            int _Samples;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);                
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                // #if _ENABLE_ON
                //     return col;
                // #else
                //     return col * _Color;
                // #endif
                // generamos condiciones
                #if _OPTIONS_OFF
                    return col * _Color;
                #elif _OPTIONS_RED
                    return col * float4(1, 0, 0, 1);
                #elif _OPTIONS_BLUE
                    return col * float4(0, 0, 1, 1);
                #endif
            }

            // HLSLPROGRAM
            /*half4 frag(v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                return col * _Color;
            }*/

            ENDCG
        }
    }
    //Fallback "ExampleOtherShader"
}
