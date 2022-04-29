//Shader "Blue/GrassShader" {
//	Properties {
//		_GrassTex ("Grass Texture", 2D) = "white" {}
//		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
//		_GrassQuadSize("Grass Size", Range(0, 1)) = 1
//	}
//	SubShader {
//		Tags {
//			"RenderPipeline"="UniversalPipeline"
//			"RenderType"="Opaque"
//			"Queue"="Geometry"
//			"UniversalMaterialType" = "Lit" "IgnoreProjector" = "True"
//		}

//		HLSLINCLUDE
//		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

//		CBUFFER_START(UnityPerMaterial)
//		float4 _GrassTex_ST;
//		float _Cutoff;
//		float _GrassQuadSize;
//		float4x4 _TerrainToWorldMatrix;
//		CBUFFER_END
//		ENDHLSL

//		Pass {
//			Name "Unlit"
//			//Tags { "LightMode"="SRPDefaultUnlit" } // (is default anyway)
			
//			Cull off
//			ZWrite On
//			ZTest LEqual

//			HLSLPROGRAM
//			#pragma multi_compile_instancing
//			#pragma instancing_options procedural:setup
//			#pragma vertex UnlitPassVertex
//			#pragma fragment UnlitPassFragment

			
//			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
//				struct GrassInfo
//				{
//					float4x4 localToTerrianMatrix;
//				}
//				StructuredBuffer<GrassInfo> GrassBuffer;
//			#endif

//			// Structs
//			struct Attributes {
//				float4 positionOS	: POSITION;
//				float2 uv		    : TEXCOORD0;
//				float3 normalOS		: NORMAL;
//				uint instanceID		: SV_InstanceID;
//			};

//			struct Varyings {
//				float4 positionCS 	: SV_POSITION;
//				float2 uv		    : TEXCOORD0;
//				float3 normalWS		: TEXCOORD1;
//			};

//			// Textures, Samplers & Global Properties
//			TEXTURE2D(_GrassTex);
//			SAMPLER(sampler_GrassTex);

//			// Vertex Shader
//			Varyings UnlitPassVertex(Attributes IN) {
//				Varyings OUT;
				
//				float4 positionWS;
//				IN.positionOS *= _GrassQuadSize;
//			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
//				IN.positionOS = mul(GrassBuffer[IN.instanceID], IN.positionOS);
//				positionWS = mul(_TerrainToWorldMatrix, IN.positionOS);
//			#else
//				positionWS = mul(unity_ObjectToWorld, IN.positionOS);
//			#endif
				
//				OUT.positionCS = mul(unity_MatrixVP,positionWS); 
//				OUT.normalWS = mul(IN.normalOS	, (float3x3)unity_WorldToObject);

//				OUT.uv = TRANSFORM_TEX(IN.uv, _GrassTex);
//				return OUT;
//			}

//			// Fragment Shader
//			half4 UnlitPassFragment(Varyings IN) : SV_Target {
//				half4 grass = SAMPLE_TEXTURE2D(_GrassTex, sampler_GrassTex, IN.uv);
				
//					clip(grass.a - _Cutoff);
//				return grass;
//			}
//			ENDHLSL
//		}

//		// UsePass "Universal Render Pipeline/Lit/ShadowCaster"
//		// UsePass "Universal Render Pipeline/Lit/DepthOnly"
//		// Would be nice if we could just use the passes from existing shaders,
//		// However this breaks SRP Batcher compatibility. Instead, we should define them :

//		// ShadowCaster, for casting shadows
//		//Pass {
//		//	Name "ShadowCaster"
//		//	Tags { "LightMode"="ShadowCaster" }

//		//	ZWrite On
//		//	ZTest LEqual
//		//	ColorMask 0
//		//	Cull[_Cull]

//		//	HLSLPROGRAM
//		//	#pragma vertex ShadowPassVertex
//		//	#pragma fragment ShadowPassFragment

//		//	// Material Keywords
//		//	#pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

//		//	// GPU Instancing
//		//	#pragma multi_compile_instancing
//		//	//#pragma multi_compile _ DOTS_INSTANCING_ON

//		//	// Universal Pipeline Keywords
//		//	// (v11+) This is used during shadow map generation to differentiate between directional and punctual (point/spot) light shadows, as they use different formulas to apply Normal Bias
//		//	#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

//		//	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
//		//	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
//		//	#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

//		//	// Note if we do any vertex displacement, we'll need to change the vertex function. e.g. :
//		//	/*
//		//	#pragma vertex DisplacedShadowPassVertex (instead of ShadowPassVertex above)
			
//		//	Varyings DisplacedShadowPassVertex(Attributes input) {
//		//		Varyings output = (Varyings)0;
//		//		UNITY_SETUP_INSTANCE_ID(input);
				
//		//		// Example Displacement
//		//		input.positionOS += float4(0, _SinTime.y, 0, 0);
				
//		//		output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
//		//		output.positionCS = GetShadowPositionHClip(input);
//		//		return output;
//		//	}
//		//	*/
//		//	ENDHLSL
//		//}
//	}
//}