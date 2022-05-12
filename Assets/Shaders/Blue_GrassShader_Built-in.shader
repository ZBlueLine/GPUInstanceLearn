Shader "Blue/GrassShaderBuilt-in" {
	Properties {
		_GrassTex ("Grass Texture", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
		_GrassQuadSize("Grass Size", Range(0, 1)) = 1
	}
	SubShader {
		Tags {
			"RenderType"="Opaque"
			"Queue"="Geometry"
		}


		Pass {
			Cull off
			ZWrite On
			ZTest LEqual

			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma multi_compile_instancing
			#pragma multi_compile_forwardBase
			#pragma instancing_options procedural:setup
			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment

			float4 _GrassTex_ST;
			float _Cutoff;
			float _GrassQuadSize;
			float4x4 _TerrainToWorldMatrix;

			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
				struct GrassInfo
				{
					float4x4 localToTerrianMatrix;
				};
				StructuredBuffer<float4x4> GrassBuffer;
			#endif

			// Structs
			struct Attributes {
				float4 positionOS	: POSITION;
				float2 uv		    : TEXCOORD0;
				float3 normalOS		: NORMAL;
				uint instanceID		: SV_InstanceID;
			};

			struct Varyings {
				float4 positionCS 	: SV_POSITION;
				float2 uv		    : TEXCOORD0;
				float3 normalWS		: TEXCOORD1;
			};

			// Textures, Samplers & Global Properties
			Texture2D _GrassTex;
			SamplerState sampler_GrassTex;

			// Vertex Shader
			Varyings UnlitPassVertex(Attributes IN) {
				Varyings OUT;
				
				float4 positionWS;
				IN.positionOS.xyz *= _GrassQuadSize;
			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
				IN.positionOS = mul(GrassBuffer[IN.instanceID], IN.positionOS);
				positionWS = mul(_TerrainToWorldMatrix, IN.positionOS);
			#else
				positionWS = mul(unity_ObjectToWorld, IN.positionOS);
			#endif
				
				OUT.positionCS = mul(unity_MatrixVP,positionWS); 
				OUT.normalWS = mul(IN.normalOS	, (float3x3)unity_WorldToObject);

				OUT.uv = TRANSFORM_TEX(IN.uv, _GrassTex);
				return OUT;
			}

			// Fragment Shader
			half4 UnlitPassFragment(Varyings IN) : SV_Target {
				half4 grass = _GrassTex.Sample(sampler_GrassTex, IN.uv);
					clip(grass.a - _Cutoff);
				return grass;
			}
			ENDCG
		}
	}
}