// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Lessons learned
// - vertex output should match the fragment input

Shader "Custom/TVShader"
{
    Properties {
        _Color1("Color 1", Color) = (1, 1, 1, 1)
        _Color2("Color 2", Color) = (0, 0, 0, 1)
        _Tiling("Tiling", Range(1,100)) = 10
    }

    SubShader {
        Pass {
            CGPROGRAM

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #include "UnityCG.cginc"

            float _Tiling;
            float4 _Color1;
            float4 _Color2;

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
                Interpolators i;
                 
                i.position = UnityObjectToClipPos(v.position); 
                i.uv = v.uv;
                return i;
            }

            float4 MyFragmentProgram(Interpolators i) : SV_TARGET
            {
                float pos = i.uv.y * _Tiling;
                fixed stripe = floor(frac(pos) + 0.5);
                return lerp(_Color1, _Color2, stripe);
            }

            ENDCG
        }
    }
}
