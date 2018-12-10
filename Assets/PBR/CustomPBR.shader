Shader "UnityCollection/Pbr/CustomPBR"
{
	Properties
	{
		_Albedo ("Albedo", 2D) = "white" {}
		_MetalRoughness ("Metal(R) & Roughness(G)", 2D) = "black" {}
	}

	CGINCLUDE
	#include "./PBRLib.cginc"
	#include "./PBRGILib.cginc"
	ENDCG

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
			#pragma multi_compile_fwdbase

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
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			sampler2D _Albedo;
			float4 _Albedo_ST;
			sampler2D _MetalRoughness;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _Albedo);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_Albedo, i.uv);
				fixed4 metalRoughnessAO = tex2D(_MetalRoughness, i.uv);
				half metallic = metalRoughnessAO.r;
				half roughness = metalRoughnessAO.g;
				half occlusion = metalRoughnessAO.b;
				
				half3 worldNormal = normalize(i.worldNormal);
				half3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
				half3 viewDir = SafeNormalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 reflectDir = reflect(-viewDir, worldNormal);

				half NdotL = saturate(dot(worldNormal, lightDir));
				half NdotV = saturate(dot(worldNormal, viewDir));
				half3 halfDir = SafeNormalize(lightDir + viewDir);
				half NdotH = saturate(dot(worldNormal, halfDir));
				half HdotL = saturate(dot(halfDir, lightDir));

				roughness = max(roughness, 0.002);
				half D = GGXTerm(NdotH, roughness);
				half G = SmithJointGGXVisibilityTerm(NdotL, NdotV, roughness);
				
				half oneMinusReflectivity;
				half3 specColor;
				half3 diffuseColor = DiffuseAndSpecularFromMetallic(albedo, metallic, specColor, oneMinusReflectivity);

				half diffuseTerm = LambertTerm(worldNormal, lightDir);
				half specularTerm = D * G * UNITY_PI;
				specularTerm = max(0, specularTerm * NdotL);

				half surfaceReduction = 1.0 / (roughness * 	roughness + 1.0);
				half3 specularGI = GI_IndirectSpecular(roughness, occlusion, reflectDir);

				half grazingTerm = saturate(1 - roughness + (1-oneMinusReflectivity));
				half3 color = diffuseColor * diffuseTerm * _LightColor0.rgb 
							+ specularTerm * _LightColor0.rgb * FresnelTerm(specColor, HdotL)
							+ surfaceReduction * specularGI * FresnelLerp(specColor, grazingTerm, NdotV);

				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}
