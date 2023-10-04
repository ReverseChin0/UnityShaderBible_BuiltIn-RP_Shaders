Shader "Unlit/USB_SDF_fruit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // textura para el plano
        _PlaneTex ("Plane Texture", 2D) = "white" {}
        // color del borde de la proyección
        _CircleCol ("Circle Color", Color) = (1, 1, 1, 1)
        // radio del borde de la proyección
        _CircleRad ("Circle Radius", Range(0.0, 0.5)) = 0.45
        _Edge ("Edge", Range(-0.5, 0.5)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        // proyectamos ambas caras de la esfera
        Cull Off
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
                float3 hitPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _PlaneTex;
            float4 _MainTex_ST;
            float4 _CircleCol;
            float _CircleRad;
            float _Edge;

            // declaramos la función para el plano
            float planeSDF(float3 ray_position)
            {
            // restamos el edge a la posición del rayo en Y para aumentar
            // o disminuir la posición del plano
                float plane = ray_position.y - _Edge;
                return plane;
            }

            // máximo de pasos para determinar la intersección de una superficie
            #define MAX_MARCHIG_STEPS 50
            // distancia máxima para encontrar la intersección de la superficie
            #define MAX_DISTANCE 10.0
            // distancia de la superficie.
            #define SURFACE_DISTANCE 0.001

            float sphereCasting(float3 ray_origin, float3 ray_direction)
            {
                float distance_origin = 0;
                for (int i = 0; i < MAX_MARCHIG_STEPS; i++)
                {
                    float3 ray_position = ray_origin + ray_direction * distance_origin;
                    float distance_scene = planeSDF(ray_position);
                    distance_origin += distance_scene;
                    if (distance_scene < SURFACE_DISTANCE || distance_origin > MAX_MARCHIG_STEPS);
                    break;
                }
                return distance_origin;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // asignamos la posición de los vértices en object-space
                o.hitPos = v.vertex;
                return o;
            }

            fixed4 frag(v2f i, bool face : SV_isFrontFace) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);    
                // transformamos la cámara local-space
                float3 ray_origin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                // calculamos la dirección del rayo
                float3 ray_direction = normalize(i.hitPos - ray_origin);
                // pasamos los valores a la función
                float t = sphereCasting( ray_origin, ray_direction);
                float4 planeCol = 0;    
                float4 circleCol = 0;
    
                if (t < MAX_DISTANCE)
                {
                    // calculamos el punto espacial del plano
                    float3 p = ray_origin + ray_direction * t;
                    float2 uv_p = p.xz;
        
                    float l = pow(-abs(_Edge), 2) + pow(-abs(_Edge) - 1, 2);
                    // generamos un círculo siguiendo las coordenadas UV del plano
                    float c = length(uv_p);
                    // aplicamos el mismo esquema al radio del círculo
                    // de esta manera podemos modificar el tamaño del mismo
                            circleCol = (smoothstep(c - 0.01, c + 0.01, _CircleRad -
                    abs(pow(_Edge * (1 * 0.5), 2))));
                            planeCol = tex2D(_PlaneTex, (uv_p*(1 - abs(pow(_Edge * l, 2)))) - 0.5);
                    // eliminamos los bordes de la textura
                            planeCol *= circleCol;
                    // agregamos el círculo y aplicamos color al mismo
                            planeCol += (1 - circleCol) * _CircleCol;
                }
                   
    
                if (i.hitPos.y > _Edge)
                    discard;
    
                return face ? col : planeCol;
            }
            ENDCG
        }
    }
}
