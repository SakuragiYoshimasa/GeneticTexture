Shader "Genetic/GeneticShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		ZTest Always Cull Off ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Noise/SimplexNoiseGrad2D.cginc"


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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			StructuredBuffer<float4> _GeneBuffer;
			int _Width;
			int _Height;

			float mod(float a, float b){
				return a - float(int(a / b)) * b;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				int x = i.uv.x * _Width;
				int y = i.uv.y * _Height;
				int id = x + y * _Width; 
				float4 gene = _GeneBuffer[id];

				//float a = 12.3 + float(gene.z * x + _Time.y) * 0.01;
				float a = 12.3 + float(float(x) + _Time.y) * 0.01;
            	//float b = 34.3 + float(gene.w * y + _Time.x) * 0.01;
				float b = 34.3 + float(float(y) + _Time.x) * 0.01;
            	//float c = -10.3 + float((gene.z * y) * (gene.w * x) % 321) * 0.01;
				float c = -10.3 + float(mod(float(y) * float(x) * _Time.y % 321, 4234.3)) * 0.01;
				float4 row1 = float4(cos(a) * cos(b) * cos(c) - sin(a) * sin(c), -cos(a) * cos(b) * sin(c) - sin(a) * cos(c), cos(a) * sin(b), 0);
            	float4 row2 = float4(sin(a) * cos(b) * cos(c) + cos(a) * sin(c), -sin(a) * cos(b) * sin(c) + cos(a) * cos(c), sin(a) * sin(b), 0);
            	float4 row3 = float4(-sin(b) * cos(c), sin(b) * sin(c), cos(b), 0); 
            	float4 row4 = float4(0, 0, 0, 1);
				float4x4 rotateMat;
				rotateMat._11_12_13_14 = row1;
            	rotateMat._21_22_23_24 = row2;
            	rotateMat._31_32_33_34 = row3;
            	rotateMat._41_42_43_44 = row4;

				float3 colorVec = float3(0, 0, 0);
				colorVec.x = (sin(gene.x + float(gene.z * 0.01 - gene.x * 0.02)) + 1.0) / 2.0;
				colorVec.yz = (snoise_grad(float2(float(gene.w) * 0.01, cos(gene.y * gene.z * 0.01))) + 1.0) / 2.0;
				colorVec =  mul(colorVec, rotateMat).yxz;

				colorVec.x = abs(colorVec.x);
				colorVec.y = abs(colorVec.y);
				colorVec.z = abs(colorVec.z);

				if(colorVec.x > 1) colorVec.x = 1.0;
				if(colorVec.y > 1) colorVec.y = 1.0;
				if(colorVec.z > 1) colorVec.z = 1.0;

				int h = int(colorVec.x * 255.0);
				int s = int(colorVec.y * 255.0);
				int v = int(colorVec.z * 255.0);
				int hi = h / 60;
				float f = h - float(hi);
				float m = float(v) * (1.0 - (float)s / 255.0);
				float n = float(v) * (1.0 - (float)s / 255.0 * f);
				float k = float(v) * (1.0 - (float)s / 255.0 * (1.0 -f));

				v /= 255.0;
				k /= 255.0;
				m /= 255.0;
				n /= 255.0;

				switch(hi){
					case 0:
						col.xyz = float3(v,k,m);
						break;
					case 1:
						col.xyz = float3(n,v,m);
						break;
					case 2:
						col.xyz = float3(m,v,k);
						break;
					case 3:
						col.xyz = float3(m,n,v);
						break;
					case 4:
						col.xyz = float3(k,m,v);
						break;
					case 5:
						col.xyz = float3(v,m,n);
						break;
					default:break;
				}
				col.w = 1.0;
				return col;
			}
			ENDCG
		}
	}
}
