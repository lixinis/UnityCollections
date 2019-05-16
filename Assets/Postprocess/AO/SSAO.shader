Shader "Postprocess/SSAO"
{
    Properties
    {

    }

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            struct app_data
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _CameraDepthNormalsTexture;
            float4 _CameraDepthNormalsTexture_TexelSize;

            v2f vert(app_data v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 depthnormal = tex2D(_CameraDepthNormalsTexture, i.uv);
                float depth;
                float3 normal;
                DecodeDepthNormal(depthnormal, depth, normal);
                return fixed4(normal, 1.0);
            }

            ENDCG
        }
    }
}