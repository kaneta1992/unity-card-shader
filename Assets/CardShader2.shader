Shader "CardShader2"
{
	Properties
	{
		[NoScaleOffset]_MainTex ("Card", 2D) = "white" {}
		[NoScaleOffset] _Mask1Tex ("Mask1", 2D) = "white" {}
		[NoScaleOffset] _Mask2Tex ("Mask2", 2D) = "white" {}
		_Blend1Tex ("Blend1", 2D) = "white" {}
		_Blend2Tex ("Blend2", 2D) = "white" {}
		_Blend3Tex ("Blend3", 2D) = "white" {}
		_Blend4Tex ("Blend4", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			#define DIRECTX
			#define ZERO2 float2(0.0, 0.0)

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

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _Mask1Tex;
			float4 _Mask1Tex_ST;

			sampler2D _Mask2Tex;
			float4 _Mask2Tex_ST;

			sampler2D _Blend1Tex;
			float4 _Blend1Tex_ST;

			sampler2D _Blend2Tex;
			float4 _Blend2Tex_ST;

			sampler2D _Blend3Tex;
			float4 _Blend3Tex_ST;

			sampler2D _Blend4Tex;
			float4 _Blend4Tex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.uv;
				return o;
			}

			float2 rotate(float2 pos, float angle) {
				float s = sin(angle);
				float c = cos(angle);
				return mul(float2x2(c, -s, s, c), pos);
			}

			float2 platformUV(float2 uv) {
				#ifdef DIRECTX
				uv.y = 1.0 - uv.y;
				#endif
				return uv;
			}

			fixed4 platformTex(sampler2D tex, float2 uv) {
				return tex2D(tex, platformUV(uv));
			}

			float2 calcUV(float2 uv, float2 origin, float2 pos, float scale, float angle, float2 dtVec, float dtAngle, float time) {
				//float a = angle + dtAngle * time;
				//float2 vec = rotate(dtVec * time, -a);
				//float2 scrollUV = uv - dtVec;
				//float2 rotateUV = rotate(scrollUV - pos, a) * scale + origin;
				//return rotateUV;
				return rotate(uv - pos, angle + dtAngle * time) * scale + origin - dtVec * time;
			}

			float pulse(float2 uv, float freq, float2 pulsePhase, float offset, float power) {
				float s = sin(_Time.y * freq + uv.x * pulsePhase.x + uv.y * pulsePhase.y) * 0.5 + 0.5;
				return offset + s * power;
			}

			fixed3 blendColor(fixed3 src, fixed4 dest, float blend, float4 type) {
				float alpha = dest.a * blend;
				fixed3 blendedDest = dest.rgb * alpha;
				return mul(type, float4x4(lerp(src, dest, alpha), 0, src + blendedDest, 0, src - blendedDest, 0, src * blendedDest, 0));	// GLESでは非正方行列が使えないらしい；；
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = platformUV(i.uv);
				float time = _Time.y;
				// マスク類の取得
				fixed mask1 = 1.0 - platformTex(_Mask1Tex, uv).r;
				fixed mask2 = 1.0 - platformTex(_Mask2Tex, uv).r;



				float2 left_point = platformUV(float2(0.57, 0.52));
				float len = pow(1.0 - saturate(length(left_point - uv)), 60.0);

				float2 right_point = platformUV(float2(0.44, 0.58));
				float len2 = pow(1.0 - saturate(length(right_point - uv)), 60.0);

				// カードを歪ませて取得
				float2 left_uv = rotate(uv- left_point, sin(time * 2.0 + length(left_point - uv) * 1.0) * mask2 * 0.02) + left_point - uv;
				float2 right_uv = rotate(uv- right_point, -sin(time * 2.0 + length(right_point - uv) * 1.0) * mask1 * 0.05) + right_point - uv;
				fixed4 card_col = platformTex(_MainTex, uv + left_uv + right_uv);

				fixed3 result = card_col.rgb;

				return fixed4(result, card_col.a);
			}
			ENDCG
		}
	}
}
