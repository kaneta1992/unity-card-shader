﻿Shader "CardShader"
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
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			#define DIRECTX

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
				return float2(cos(angle) * pos.x - sin(angle) * pos.y, sin(angle) * pos.x + cos(angle) * pos.y);
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
				float2 effect1_uv  = uv * 1.0 + normalize(float2(-0.5, -0.5)) * time * 0.25;				// スクロール
				fixed4 effect1 = platformTex(_Blend1Tex, effect1_uv);

				// エフェクト2(桜)を取得する
				float2 effect2_uv = rotate((uv - float2(2.0, 0.0)) * 2.0, time * 0.1);						// 回転
				float4 effect2 = platformTex(_Blend1Tex, effect2_uv);

				// エフェクト3(キラキラ)を取得する
				float2 effect3_uv  = uv * 1.0 + normalize(float2(1.0, 0.0)) * time * 0.01;					// スクロール
				fixed4 effect3 = platformTex(_Blend2Tex, effect3_uv);

				// エフェクト4(太陽)を取得する
				float2 effect4_uv = rotate(uv + float2(0.1, 0.1), time * 0.2) * 0.5 + float2(0.5, 0.5);		// 回転 + 原点移動
				float4 effect4 = pow(platformTex(_Blend3Tex, effect4_uv) * 6.0, 3.0);
				
				// エフェクト5(フレア)を取得する
				float2 effect5_uv = uv;																		// 通常
				float4 effect5 = platformTex(_Blend4Tex, effect5_uv);

				fixed4 result = card_col;

				// エフェクト1を合成する
				result.rgb = lerp(result.rgb, effect1.rgb, effect1.a * mask1);						// ブレンド

				// エフェクト2を合成する
				result.rgb = lerp(result.rgb, effect2.rgb, effect2.a * mask1);						// ブレンド
				
				// エフェクト3を合成する
				result.rgb += effect3.rgb * mask1 * (2.0 + sin(time * 5.0 + uv.x * 10.0)) * 0.5;	//加算 + パルス
								
				// エフェクト4を合成する
				result.rgb += effect4.rgb * mask1;													//加算
								
				// エフェクト5を合成する
				result.rgb += effect5.rgb * 1.0 * (1.0 + (2.0 + sin(time * 25.0)) * 0.05);			//加算 + パルス

				return result;
			}
			ENDCG
		}
	}
}