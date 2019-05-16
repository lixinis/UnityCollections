Shader "Unlit/SDF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Centre ("Center", vector) = (0, 0, 0)
        _Radius ("Radius", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            struct intersection
            {
                bool result;
                float3 normal;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _Centre;
            float _Radius;

            #define STEPS 100
            #define STEP_SIZE 0.01

            bool sphereHit(float3 p)
            {
                return distance(p, _Centre) < _Radius;
            }

            intersection raymarchHit(float3 position, float3 direction)
            {
                intersection isect;
                for (int i = 0; i < STEPS; ++i)
                {
                    if (sphereHit(position))
                    {
                        isect.result = true;
                        isect.normal = normalize(position - _Centre);
                        return isect;
                    }
                    position += direction * STEP_SIZE;
                }
                isect.result = false;
                return isect;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(0,0,0,0);
                half3 viewDir = -normalize(UnityWorldSpaceViewDir(i.worldPos));
                intersection isect = raymarchHit(i.worldPos, viewDir);
                if (isect.result)
                {
                    float ndotl = max(0, dot(isect.normal, _WorldSpaceLightPos0.xyz));
                    col = fixed4(ndotl * _LightColor0.rgb, 1.0);
                }
                return col;
            }
            ENDCG
        }
    }
}
