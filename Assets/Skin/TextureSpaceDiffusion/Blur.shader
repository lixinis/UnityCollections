Shader "TextureSpaceSSS/Blur"
{
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
		o.uv = TransformTriangleVertexToUV(o.vertex.xy);
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
