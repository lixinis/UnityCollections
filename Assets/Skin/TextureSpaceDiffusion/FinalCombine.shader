Shader "TextureSpaceSSS/FinalCombine"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DiffuseTex0 ("Texture", 2D) = "white" {}
		_DiffuseTex1 ("Texture", 2D) = "white" {}
		_DiffuseTex2 ("Texture", 2D) = "white" {}
		_DiffuseTex3 ("Texture", 2D) = "white" {}
		_DiffuseTex4 ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _DiffuseTex0;
			sampler2D _DiffuseTex1;
			sampler2D _DiffuseTex2;
			sampler2D _DiffuseTex3;
			sampler2D _DiffuseTex4;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				half factor = 1.0 / 6.0;
				fixed4 baseColor = tex2D(_MainTex, i.uv);

				half3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
				half diffuse = dot(i.normal, lightDir);

				fixed4 col = baseColor * diffuse * _LightColor0 * factor;

				col += tex2D(_DiffuseTex0, i.uv) * factor;
				col += tex2D(_DiffuseTex1, i.uv) * factor;
				col += tex2D(_DiffuseTex2, i.uv) * factor;
				col += tex2D(_DiffuseTex3, i.uv) * factor;
				col += tex2D(_DiffuseTex4, i.uv) * factor;

				col.xyz += UNITY_LIGHTMODEL_AMBIENT.xyz * baseColor;

				return fixed4(col.rgb, 1);
			}
			ENDCG
		}
	}
}
