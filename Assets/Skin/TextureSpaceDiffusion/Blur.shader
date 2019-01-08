Shader "TextureSpaceSSS/Blur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurRadius ("Blur Radius", float) = 1.5
	}
	CGINCLUDE
	#include "UnityCG.cginc"

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

	float2 TransformTriangleVertexToUV(float2 vertex)
	{
		float2 uv = (vertex + 1.0) * 0.5;
		return uv;
	}

	v2f vertDefault(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	};
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass // hblur
		{
			CGPROGRAM
			#pragma vertex vertDefault
			#pragma fragment frag
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float _BlurRadius;
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 offset = float2(1.0, 0.0) * _MainTex_TexelSize.xy * _BlurRadius;
				fixed4 col = tex2D(_MainTex, i.uv) * 0.19648255;
				col += tex2D(_MainTex, i.uv + offset) * 0.29690696;
				col += tex2D(_MainTex, i.uv - offset) * 0.29690696;
				col += tex2D(_MainTex, i.uv + 2.0 * offset) * 0.09447039;
				col += tex2D(_MainTex, i.uv - 2.0 * offset) * 0.09447039;
				col += tex2D(_MainTex, i.uv + 3.0 * offset) * 0.01038136;
				col += tex2D(_MainTex, i.uv - 3.0 * offset) * 0.01038136;
				
				return fixed4(col.rgb, 1);
			}
			ENDCG
		}
		Pass // vblur
		{
			CGPROGRAM
			#pragma vertex vertDefault
			#pragma fragment frag
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float _BlurRadius;
			
			fixed4 frag (v2f i) : SV_Target
			{
				half2 offset = half2(0, 1) * _MainTex_TexelSize.xy * _BlurRadius;
				fixed4 col = tex2D(_MainTex, i.uv) * 0.19648255;
				col += tex2D(_MainTex, i.uv + offset) * 0.29690696;
				col += tex2D(_MainTex, i.uv - offset) * 0.29690696;
				col += tex2D(_MainTex, i.uv + 2 * offset) * 0.09447039;
				col += tex2D(_MainTex, i.uv - 2 * offset) * 0.09447039;
				col += tex2D(_MainTex, i.uv + 3 * offset) * 0.01038136;
				col += tex2D(_MainTex, i.uv - 3 * offset) * 0.01038136;
				
				return fixed4(col.rgb, 1);
			}
			ENDCG
		}
	}
}
