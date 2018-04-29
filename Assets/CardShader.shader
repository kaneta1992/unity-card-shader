Shader "CardShader"
{
	Properties
	{
		[NoScaleOffset] _MainTex ("Card", 2D) = "white" {}
		[NoScaleOffset] _Mask1Tex ("Mask1", 2D) = "white" {}
		[NoScaleOffset] _Mask2Tex ("Mask2", 2D) = "white" {}
		_Blend1Tex ("Blend1", 2D) = "white" {}
		_Blend2Tex ("Blend2", 2D) = "white" {}
		_Blend3Tex ("Blend3", 2D) = "white" {}
		_Blend4Tex ("Blend4", 2D) = "white" {}
		_Blend5Tex ("Blend5", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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

			sampler2D _Mask1Tex;

			sampler2D _Mask2Tex;

			sampler2D _Blend1Tex;
			float4 _Blend1Tex_ST;

			sampler2D _Blend2Tex;
			float4 _Blend2Tex_ST;

			sampler2D _Blend3Tex;
			float4 _Blend3Tex_ST;

			sampler2D _Blend4Tex;
			float4 _Blend4Tex_ST;

			sampler2D _Blend5Tex;
			float4 _Blend5Tex_ST;

			float4 _Effect1Data[6];
			float4 _Effect2Data[6];
			float4 _Effect3Data[6];
			float4 _Effect4Data[6];
			float4 _Effect5Data[6];
			
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
				fixed mask1 = platformTex(_Mask1Tex, uv).r;
				fixed mask2 = platformTex(_Mask2Tex, uv).r;

				// カードを歪ませて取得
				float2 card_uv = uv + float2(sin(time * 4.0 + uv.x * 5.0 + uv.y * 20.0), cos(time * 4.0 + uv.x * 20.0 + uv.y * 5.0)) * 0.005 * (1.0 - mask2);
				fixed4 card_col = platformTex(_MainTex, card_uv);

				// エフェクト1(桜)を取得する
				float2 effect1_uv = calcUV(uv, ZERO2, ZERO2, 1.0, 0.0, normalize(float2(0.5, 0.5)) * 0.25, 0.0, time);	// スクロール
				fixed4 effect1 = platformTex(_Blend1Tex, effect1_uv);

				// エフェクト2(桜)を取得する
				float2 effect2_uv = calcUV(uv, ZERO2, float2(2.0, 0.0), 2.0, 0.0, ZERO2, 0.1, time);					// 回転
				float4 effect2 = platformTex(_Blend2Tex, effect2_uv);

				// エフェクト3(キラキラ)を取得する
				float2 effect3_uv = calcUV(uv, ZERO2, ZERO2, 1.0, 0.0, float2(-0.01, 0.0), 0.0, time);					// スクロール
				fixed4 effect3 = platformTex(_Blend3Tex, effect3_uv);

				// エフェクト4(太陽)を取得する
				float2 effect4_uv = calcUV(uv, float2(0.5, 0.5), float2(-0.1, -0.1), 0.5, 0.0, ZERO2, 0.2, time);		// 回転 + 原点移動
				float4 effect4 = saturate(pow(platformTex(_Blend4Tex, effect4_uv) * 6.0, 3.0));
				
				// エフェクト5(フレア)を取得する
				float2 effect5_uv = calcUV(uv, ZERO2, ZERO2, 1.0, 0.0, ZERO2, 0.0, time);								// 通常
				float4 effect5 = platformTex(_Blend5Tex, effect5_uv);

				fixed3 result = card_col.rgb;

				// エフェクト1を合成する
				result = blendColor(result, effect1 * pulse(uv, 0.0, ZERO2, 1.0, 0.0), mask1, _Effect1Data[0]);				// ブレンド

				// エフェクト2を合成する
				result = blendColor(result, effect2 * pulse(uv, 0.0, ZERO2, 1.0, 0.0), mask1, _Effect2Data[0]);				// ブレンド
				
				// エフェクト3を合成する
				result = blendColor(result, effect3 * pulse(uv, 5.0, float2(10.0, 0.0), 0.5, 1.0), mask1, _Effect3Data[0]);	//加算 + パルス
								
				// エフェクト4を合成する
				result = blendColor(result, effect4 * pulse(uv, 0.0, ZERO2, 1.0, 0.0), mask1, _Effect4Data[0]);				//加算
								
				// エフェクト5を合成する
				result = blendColor(result, effect5 * pulse(uv, 25.0, ZERO2, 1.0, 0.05), 1.0, _Effect5Data[0]);				//加算 + パルス

				return fixed4(result, 1.0);
			}
			ENDCG
		}
	}
	CustomEditor "CardShaderInspector"
}
