// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Lessons learned
// - vertex output should match the fragment input

Shader "Custom/FirstShader"
{
    Properties {
        _Tint("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {
        Pass {
            CGPROGRAM

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #include "UnityCG.cginc"

            float4 _Tint;
            sampler2D _MainTex;
            // tiling (xy) and offset (zw)
            float4 _MainTex_ST; // scale and translation (old term)

            struct Interpolators {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexData {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators MyVertexProgram(VertexData v)
            {
                // .xyz is a swizzle operation
                // x y z are 3 separate components
                // can use rgba and w as well
                Interpolators i;
                 
                i.position = UnityObjectToClipPos(v.position); 
                i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                // OR
                // i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return i;
            }

            float4 MyFragmentProgram(Interpolators i) : SV_TARGET 
            {
                return tex2D(_MainTex, i.uv) * _Tint;
            }

            ENDCG
        }
    }
}
