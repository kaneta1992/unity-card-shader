Shader "CardShader"
{
	Properties
	{
		[NoScaleOffset] _MainTex ("Card", 2D) = "white" {}
		[NoScaleOffset] _MaskTex ("Mask", 2D) = "white" {}
		_Blend1Tex ("Blend1", 2D) = "black" {}
		_Blend2Tex ("Blend2", 2D) = "black" {}
		_Blend3Tex ("Blend3", 2D) = "black" {}
		_Blend4Tex ("Blend4", 2D) = "black" {}
		_Blend5Tex ("Blend5", 2D) = "black" {}
		_Effect1BlendMode ("Effect1BlendMode", Vector) = (1,0,0,0)
		_Effect2BlendMode ("Effect2BlendMode", Vector) = (1,0,0,0)
		_Effect3BlendMode ("Effect3BlendMode", Vector) = (1,0,0,0)
		_Effect4BlendMode ("Effect4BlendMode", Vector) = (1,0,0,0)
		_Effect5BlendMode ("Effect5BlendMode", Vector) = (1,0,0,0)
		_Effect1Pulse ("_Effect1Pulse", Vector) = (0,0,0,0)
		_Effect2Pulse ("_Effect2Pulse", Vector) = (0,0,0,0)
		_Effect3Pulse ("_Effect3Pulse", Vector) = (0,0,0,0)
		_Effect4Pulse ("_Effect4Pulse", Vector) = (0,0,0,0)
		_Effect5Pulse ("_Effect5Pulse", Vector) = (0,0,0,0)
		_Effect1Coord1 ("_Effect1Coord1", Vector) = (0,0,0,0)
		_Effect2Coord1 ("_Effect2Coord1", Vector) = (0,0,0,0)
		_Effect3Coord1 ("_Effect3Coord1", Vector) = (0,0,0,0)
		_Effect4Coord1 ("_Effect4Coord1", Vector) = (0,0,0,0)
		_Effect5Coord1 ("_Effect5Coord1", Vector) = (0,0,0,0)
		_Effect1Coord2 ("_Effect1Coord2", Vector) = (0,0,0,0)
		_Effect2Coord2 ("_Effect2Coord2", Vector) = (0,0,0,0)
		_Effect3Coord2 ("_Effect3Coord2", Vector) = (0,0,0,0)
		_Effect4Coord2 ("_Effect4Coord2", Vector) = (0,0,0,0)
		_Effect5Coord2 ("_Effect5Coord2", Vector) = (0,0,0,0)
		_Effect1UseMask ("_Effect1UseMask", Vector) = (0,0,0,0)
		_Effect2UseMask ("_Effect2UseMask", Vector) = (0,0,0,0)
		_Effect3UseMask ("_Effect3UseMask", Vector) = (0,0,0,0)
		_Effect4UseMask ("_Effect4UseMask", Vector) = (0,0,0,0)
		_Effect5UseMask ("_Effect5UseMask", Vector) = (0,0,0,0)
		_WaveValue1 ("_WaveValue1", Vector) = (0,0,0,0)
		_WaveValue2 ("_WaveValue2", Vector) = (0,0,0,0)
		_WaveUseMask ("_WaveUseMask", Vector) = (0,0,0,0)
		//_Effect1Coord3 ("_Effect1Coord3", Vector) = (0,0,0,0)
		//_Effect2Coord3 ("_Effect2Coord3", Vector) = (0,0,0,0)
		//_Effect3Coord3 ("_Effect3Coord3", Vector) = (0,0,0,0)
		//_Effect4Coord3 ("_Effect4Coord3", Vector) = (0,0,0,0)
		//_Effect5Coord3 ("_Effect5Coord3", Vector) = (0,0,0,0)
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
			#define PI 3.14159265358979323846

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

			sampler2D _MaskTex;

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

			float4 _Effect1BlendMode;
			float4 _Effect2BlendMode;
			float4 _Effect3BlendMode;
			float4 _Effect4BlendMode;
			float4 _Effect5BlendMode;
			float4 _Effect1Pulse;
			float4 _Effect2Pulse;
			float4 _Effect3Pulse;
			float4 _Effect4Pulse;
			float4 _Effect5Pulse;
			float4 _Effect1Coord1;
			float4 _Effect2Coord1;
			float4 _Effect3Coord1;
			float4 _Effect4Coord1;
			float4 _Effect5Coord1;
			float4 _Effect1Coord2;
			float4 _Effect2Coord2;
			float4 _Effect3Coord2;
			float4 _Effect4Coord2;
			float4 _Effect5Coord2;
			float4 _Effect1UseMask;
			float4 _Effect2UseMask;
			float4 _Effect3UseMask;
			float4 _Effect4UseMask;
			float4 _Effect5UseMask;

			float4 _WaveValue1;
			float4 _WaveValue2;
			float4 _WaveUseMask;
			//float4 _Effect1Coord3;
			//float4 _Effect2Coord3;
			//float4 _Effect3Coord3;
			//float4 _Effect4Coord3;
			//float4 _Effect5Coord3;
			
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

			float2 calcUV(float2 uv, float2 origin, float4 tiling_offset, float angle, float2 dtVec, float dtAngle, float time) {
				//float a = angle + dtAngle * time;
				//float2 vec = rotate(dtVec * time, -a);
				//float2 scrollUV = uv - dtVec;
				//float2 rotateUV = rotate(scrollUV - pos, a) * scale + origin;
				//return rotateUV;
				return rotate(uv - tiling_offset.zw, angle + dtAngle * time) * tiling_offset.xy + origin - dtVec * time;
			}

			float2 polar(float2 uv, float4 tiling_offset, float2 dtVec, float time)
			{
				uv = (uv - tiling_offset.zw) * tiling_offset.xy;
				float distance = length(uv) - time * dtVec.y;
				float theta = ((atan2(uv.y, uv.x)) / (PI*2) + 0.5) - time * dtVec.x;
				return float2(theta, distance);
			}

			float pulse(float2 uv, float freq, float2 pulsePhase, float power) {
				float s = sin(_Time.y * freq + uv.x * pulsePhase.x + uv.y * pulsePhase.y) * 0.5 + 0.5;
				return 1.0 + s * power;
			}

			fixed3 blendColor(fixed3 src, fixed4 dest, float blend, float4 type) {
				float alpha = dest.a * blend;
				fixed3 blendedDest = dest.rgb * alpha;
				return mul(type, float4x4(lerp(src, dest, alpha), 0, src + blendedDest, 0, src - blendedDest, 0, src * blendedDest, 0));	// GLESでは非正方行列が使えないらしい；；
			}

			fixed useMask(fixed4 mask, float4 useVec) {
				return 1.0 - dot(mask, useVec);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = platformUV(i.uv);
				float time = _Time.y;
				// マスク類の取得
				fixed4 mask = platformTex(_MaskTex, uv);

				// カードを歪ませて取得
				float2 card_uv = uv + float2(sin(time * _WaveValue2.y + uv.x * _WaveValue1.x + uv.y * _WaveValue1.y), cos(time * _WaveValue2.y + uv.x * _WaveValue1.z + uv.y * _WaveValue1.w)) * _WaveValue2.x * useMask(mask, _WaveUseMask);
				fixed4 card_col = platformTex(_MainTex, card_uv);

				// エフェクト1(桜)を取得する
				float2 effect1_polar = polar(uv, _Blend1Tex_ST, _Effect1Coord1.zw, time);
				float2 effect1_uv = calcUV(uv, _Effect1Coord1.xy, _Blend1Tex_ST, _Effect1Coord2.x, _Effect1Coord1.zw, _Effect1Coord2.y, time);	// スクロール
				fixed4 effect1 = platformTex(_Blend1Tex, lerp(effect1_uv, effect1_polar, _Effect1Coord2.z));

				// エフェクト2(桜)を取得する
				float2 effect2_polar = polar(uv, _Blend2Tex_ST, _Effect2Coord1.zw, time);
				float2 effect2_uv = calcUV(uv, _Effect2Coord1.xy, _Blend2Tex_ST, _Effect2Coord2.x, _Effect2Coord1.zw, _Effect2Coord2.y, time);					// 回転
				float4 effect2 = platformTex(_Blend2Tex, lerp(effect2_uv, effect2_polar, _Effect2Coord2.z));

				// エフェクト3(キラキラ)を取得する
				float2 effect3_polar = polar(uv, _Blend3Tex_ST, _Effect3Coord1.zw, time);
				float2 effect3_uv = calcUV(uv, _Effect3Coord1.xy, _Blend3Tex_ST, _Effect3Coord2.x, _Effect3Coord1.zw, _Effect3Coord2.y, time);					// スクロール
				fixed4 effect3 = platformTex(_Blend3Tex, lerp(effect3_uv, effect3_polar, _Effect3Coord2.z));

				// エフェクト4(太陽)を取得する
				float2 effect4_polar = polar(uv, _Blend4Tex_ST, _Effect4Coord1.zw, time);
				float2 effect4_uv = calcUV(uv, _Effect4Coord1.xy, _Blend4Tex_ST, _Effect4Coord2.x, _Effect4Coord1.zw, _Effect4Coord2.y, time);		// 回転 + 原点移動
				float4 effect4 = platformTex(_Blend4Tex, lerp(effect4_uv, effect4_polar, _Effect4Coord2.z));
				
				// エフェクト5(フレア)を取得する
				float2 effect5_polar = polar(uv, _Blend5Tex_ST, _Effect5Coord1.zw, time);
				float2 effect5_uv = calcUV(uv, _Effect5Coord1.xy, _Blend5Tex_ST, _Effect5Coord2.x, _Effect5Coord1.zw, _Effect5Coord2.y, time);								// 通常
				float4 effect5 = platformTex(_Blend5Tex, lerp(effect5_uv, effect5_polar, _Effect5Coord2.z));

				fixed3 result = card_col.rgb;

				// エフェクト1を合成する
				result = blendColor(result, effect1 * pulse(uv, _Effect1Pulse.x, _Effect1Pulse.yz, _Effect1Pulse.w), useMask(mask, _Effect1UseMask), _Effect1BlendMode);				// ブレンド

				// エフェクト2を合成する
				result = blendColor(result, effect2 * pulse(uv, _Effect2Pulse.x, _Effect2Pulse.yz, _Effect2Pulse.w), useMask(mask, _Effect2UseMask), _Effect2BlendMode);				// ブレンド
				
				// エフェクト3を合成する
				result = blendColor(result, effect3 * pulse(uv, _Effect3Pulse.x, _Effect3Pulse.yz, _Effect3Pulse.w), useMask(mask, _Effect3UseMask), _Effect3BlendMode);	//加算 + パルス
								
				// エフェクト4を合成する
				result = blendColor(result, effect4 * pulse(uv, _Effect4Pulse.x, _Effect4Pulse.yz, _Effect4Pulse.w), useMask(mask, _Effect4UseMask), _Effect4BlendMode);				//加算
								
				// エフェクト5を合成する
				result = blendColor(result, effect5 * pulse(uv, _Effect5Pulse.x, _Effect5Pulse.yz, _Effect5Pulse.w), useMask(mask, _Effect5UseMask), _Effect5BlendMode);				//加算 + パルス

				return fixed4(result, 1.0);
			}
			ENDCG
		}
	}
	CustomEditor "CardShaderInspector"
}
