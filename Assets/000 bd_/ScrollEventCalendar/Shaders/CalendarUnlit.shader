Shader "bd_/VRC Scroll Event Calendar (unlit)"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Position ("Position", Range(0,1)) = 0.0
        _Brightness ("Brightness", Range(0,1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            float _Position, _Brightness;

            #include "scroll_calendar.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(0)
                SCROLLCAL_CTX_V2F
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                SCROLLCAL_CTX_TO_V2F(o, v.uv);
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                SCROLLCAL_CTX_FROM_V2F(ctx, i);

                return scrollcal_albedo(ctx);
            }
            ENDCG
        }
    }
}
