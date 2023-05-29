// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Waterfall Alpha Blended"
{
	Properties
	{
		_horizonColor("Horizon color", COLOR) = (.172 , .463 , .435 , 0)
		_WaveScale("Wave scale", Range(0.02,0.15)) = .07
		[NoScaleOffset] _ColorControl("Reflective color (RGB) fresnel (A) ", 2D) = "" { }
		[NoScaleOffset] _BumpMap("Waves Normalmap ", 2D) = "" { }
		WaveSpeed("Wave speed (map1 x,y; map2 x,y)", Vector) = (19,9,-16,-7)
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"
			}
			LOD 100
			Cull Off
			ZWrite Off
			GrabPass { }
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};
				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 uv_back : TEXCOORD1;
					float4 vertex : SV_POSITION;
				};
				sampler2D _MainTex;
				sampler2D _MaskTex;
				sampler2D _GrabTexture;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.uv_back = ComputeGrabScreenPos(o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					fixed4 col = tex2D(_MainTex, i.uv);
				// sample the mask (only alpha)
				fixed mask = tex2D(_MaskTex, i.uv).a;
				// clip if mask is zero
				if (mask <= 0) discard;
				// sample the background
				float2 screenuv = i.uv_back.xy / i.uv_back.w;
				fixed4 back = tex2D(_GrabTexture, screenuv);
				// blend main texture and background together
				return lerp(back, col, mask);
				}
			ENDCG
			}
		}
}