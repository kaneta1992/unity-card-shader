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

			#define FETCH_TEXTURE(id)\
				platformTex(_Blend##id##Tex, lerp(\
					calcUV(uv, _Effect##id##Coord1.xy, _Blend##id##Tex_ST, _Effect##id##Coord2.x, _Effect##id##Coord1.zw, _Effect##id##Coord2.y),\
					polar(uv, _Blend##id##Tex_ST, _Effect##id##Coord2, _Effect##id##Coord1.zw, _Effect##id##Coord2.y), _Effect##id##Coord2.z))

			#define BLEND_COLOR(name, id)\
				blendColor(result, name * pulse(uv, _Effect##id##Pulse.x, _Effect##id##Pulse.yz, _Effect##id##Pulse.w), useMask(mask, _Effect##id##UseMask), _Effect##id##BlendMode)

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
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
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

			float2 calcUV(float2 uv, float2 origin, float4 tiling_offset, float angle, float2 dtVec, float dtAngle) {
				return rotate(uv - tiling_offset.zw, angle + dtAngle * _Time.y) * tiling_offset.xy + origin - dtVec * _Time.y;
			}

			float2 polar(float2 uv, float4 tiling_offset, float angle, float2 dtVec, float dtAngle)
			{
				uv = rotate((uv - tiling_offset.zw), angle + dtAngle * _Time.y) * tiling_offset.xy;
				float distance = length(uv) - _Time.y * dtVec.y;
				float theta = ((atan2(uv.y, uv.x)) / (PI*2) + 0.5) - _Time.y * dtVec.x;
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
				// マスク類の取得
				fixed4 mask = platformTex(_MaskTex, uv);

				// カードを歪ませて取得
				float2 card_uv = uv + float2(sin(_Time.y * _WaveValue2.y + uv.x * _WaveValue1.x + uv.y * _WaveValue1.y), cos(_Time.y * _WaveValue2.y + uv.x * _WaveValue1.z + uv.y * _WaveValue1.w)) * _WaveValue2.x * useMask(mask, _WaveUseMask);
				fixed4 card_col = platformTex(_MainTex, card_uv);

				fixed4 effect1 = FETCH_TEXTURE(1);
				fixed4 effect2 = FETCH_TEXTURE(2);
				fixed4 effect3 = FETCH_TEXTURE(3);
				fixed4 effect4 = FETCH_TEXTURE(4);
				fixed4 effect5 = FETCH_TEXTURE(5);

				fixed3 result = card_col.rgb;
				result = BLEND_COLOR(effect1, 1);
				result = BLEND_COLOR(effect2, 2);
				result = BLEND_COLOR(effect3, 3);
				result = BLEND_COLOR(effect4, 4);
				result = BLEND_COLOR(effect5, 5);

				return fixed4(result, 1.0);
			}
			ENDCG
		}
	}
	CustomEditor "CardShaderInspector"
}
