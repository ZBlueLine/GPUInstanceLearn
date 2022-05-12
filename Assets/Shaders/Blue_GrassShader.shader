Shader "Blue/GrassShaderURP" {
	Properties {
		_GrassTex ("Grass Texture", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
		_GrassColor("Grass Color", Color) = (1, 1, 1, 1)
		_GrassQuadSize("Grass Size", Range(0, 1)) = 1
		_ShadowColor("Shadow Color", Color) = (0, 0, 0, 1)
	}
	SubShader {
		Tags {
			"RenderPipeline"="UniversalPipeline"
			"RenderType"="Opaque"
			"Queue"="Geometry"
			"UniversalMaterialType" = "Lit" "IgnoreProjector" = "True"
		}

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

		CBUFFER_START(UnityPerMaterial)
		float4 _GrassTex_ST;
		float _Cutoff;
		half4 _GrassColor;
		float _GrassQuadSize;
		float4x4 _TerrainToWorldMatrix;
		half4 _ShadowColor;
		CBUFFER_END
		ENDHLSL

		Pass {
			Name "Unlit"
			//Tags { "LightMode"="SRPDefaultUnlit" } // (is default anyway)
			
			Cull off
			ZWrite On
			ZTest LEqual
			//Blend SrcAlpha OneMinusSrcAlpha

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma instancing_options procedural:setup
			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			
			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
				//struct GrassInfo
				//{
				//	float4x4 localToTerrianMatrix;
				//}
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
				float4 positionWS	: TEXCOORD2;
			};

			// Textures, Samplers & Global Properties
			TEXTURE2D(_GrassTex);
			SAMPLER(sampler_GrassTex);

			// Vertex Shader
			Varyings UnlitPassVertex(Attributes IN) {
				Varyings OUT;
				
				IN.positionOS.xyz *= _GrassQuadSize;
				OUT.positionWS = float4(0, 0, 0, 1);
			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
				IN.positionOS = mul(GrassBuffer[IN.instanceID], IN.positionOS);
				OUT.positionWS = mul(_TerrainToWorldMatrix, IN.positionOS);
				IN.normalOS = mul(IN.normalOS	, (float3x3)GrassBuffer[IN.instanceID]);
			#else
				OUT.positionWS = mul(unity_ObjectToWorld, IN.positionOS);
			#endif

				OUT.normalWS = mul(IN.normalOS	, (float3x3)unity_WorldToObject);
				OUT.positionCS = mul(unity_MatrixVP,OUT.positionWS); 

				OUT.uv = TRANSFORM_TEX(IN.uv, _GrassTex);
				return OUT;
			}

			// Fragment Shader
			half4 UnlitPassFragment(Varyings IN) : SV_Target {
				half4 grassColor = _GrassColor * SAMPLE_TEXTURE2D(_GrassTex, sampler_GrassTex, IN.uv);
					clip(grassColor.a - _Cutoff);

				float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS.xyz);
				Light mainLight = GetMainLight(shadowCoord);
				float3 normalWS = normalize(IN.normalWS).xyz;
				
				float minDotV = 0.2;
				float4 diffuse = float4(1, 1, 1, 1);
				diffuse.rgb = mainLight.color * max(minDotV, abs(dot(mainLight.direction, normalWS)));
				float attenuation = mainLight.shadowAttenuation;
				attenuation = lerp(float4(1, 1, 1, 1), _ShadowColor, 1 - attenuation);
				diffuse *= attenuation;
				grassColor.rgb *= diffuse.rgb;
				return grassColor;
			}
			ENDHLSL
		}
	}
}

//struct Light
//{
//    half3   direction;
//    half3   color;
//    half    distanceAttenuation;
//    half    shadowAttenuation;
//};