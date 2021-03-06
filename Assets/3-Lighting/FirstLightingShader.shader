// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Lessons learned
// - vertex output should match the fragment input

Shader "Custom/FirstLightingShader"
{
    Properties {
        _Tint("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
    }

    SubShader {
        Pass {
            Tags {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM

            #pragma target 3.0

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #include "UnityStandardBRDF.cginc"
            #include "UnityStandardUtils.cginc"
            #include "UnityPBSLighting.cginc"

            float4 _Tint;
            sampler2D _MainTex;
            // tiling (xy) and offset (zw)
            float4 _MainTex_ST; // scale and translation (old term)
            float _Smoothness;
            float _Metallic;

            struct Interpolators {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            struct VertexData {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            Interpolators MyVertexProgram(VertexData v)
            {
                // .xyz is a swizzle operation
                // x y z are 3 separate components
                // can use rgba and w as well
                Interpolators i;
                 
                i.position = UnityObjectToClipPos(v.position); 
                i.worldPos = mul(unity_ObjectToWorld, v.position);
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                // OR
                // i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return i;
            }

            float4 MyFragmentProgram(Interpolators i) : SV_TARGET 
            {
                // normalizing normals fixes a very small error in how it looks
                // choosing not to normalize can lead to some
                // performance optimization 
                // (usually used for mobile devices)
                i.normal = normalize(i.normal); 
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 lightColor = _LightColor0.rgb;
                float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

                float3 specularTint;
                float oneMinusReflectivity;
                albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

                UnityLight light;
                light.color = lightColor;
                light.dir = lightDir;
                light.ndotl = DotClamped(i.normal, lightDir);

                UnityIndirect indirectLight;
                indirectLight.diffuse = 0;
                indirectLight.specular = 0;

                return UNITY_BRDF_PBS(albedo, specularTint,
                oneMinusReflectivity, _Smoothness,
                i.normal, viewDir,
                light, indirectLight);
            }

            ENDCG
        }
    }
}
