// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Lessons learned
// - vertex output should match the fragment input

Shader "Custom/TVShader"
{
    Properties {
        _Color1("Color 1", Color) = (1, 1, 1, 1)
        _Color2("Color 2", Color) = (0, 0, 0, 1)
        _AmbientColor("Ambient Color", Color) = (0.4, 0.4, 0.4, 1)
        _SpecularColor("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
        _Glossiness("Glossiness", Float) = 42
        _Tiling("Tiling", Range(1,100)) = 10
    }

    SubShader {
        Pass {
            Tags 
            {
                "LightMode" = "ForwardBase"
                "PassFlags" = "OnlyDirectional"
            }   

            CGPROGRAM

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float _Tiling;
            float4 _Color1;
            float4 _Color2;
            float4 _AmbientColor;
            float _Glossiness;
            float4 _SpecularColor;

            /*v2f*/
            struct Interpolators {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD1;
            };

            
            struct VertexData {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            Interpolators MyVertexProgram(VertexData v)
            {
                Interpolators i;
                 
                i.position = UnityObjectToClipPos(v.position); 
                i.uv = v.uv;

                i.worldNormal = UnityObjectToWorldNormal(v.normal);

                return i;
            }

            float4 MyFragmentProgram(Interpolators i) : SV_TARGET
            {
                /* Toon shader */
                float3 normal = normalize(i.worldNormal);
                float NdotL = dot(_WorldSpaceLightPos0, normal);
                //float lightIntensity = NdotL > 0 ? 1 : 0;
                float lightIntensity = smoothstep(0, 0.01, NdotL); // smooth out the transition between light and dark
                float4 light = lightIntensity * _LightColor0;

                /* Stripe shader */
                float pos = i.uv.y * _Tiling;
                fixed stripe = floor(frac(pos) + 0.5);

                return lerp(_Color1, _Color2, stripe) * (_AmbientColor + lightIntensity);
            }

            ENDCG
        }
    }
}
