/*

% Description of my shader.
% Second line of description for my shader.

Bank BRDF Model

渲染各向异性简单算法
date: YYMMDD

*/

//
//extern object var
//
extern matrix WorldViewProj;
extern matrix World;
extern matrix View;
extern matrix Proj;
extern matrix WorldView;
extern matrix WorldViewIT;
extern texture Tex;
extern float m = 10.0f; //粗糙程度
extern float f0 = 0;	//fresnel因子在入射角为0时的取值
//
//static Light var
//

static vector ambientLight	  = {0.2f,0.2f,0.2f,1.0f};
static vector LightPos 		  = {0.0f,1.0f,-1.0f,1.0f};
static vector LightDir 		  = {1.0f,-1.0f,1.0f,0.0f};
static vector LightColor 	  = {1.0f,1.0f,1.0f,1.0f};
static vector diffuseMaterial = {1,1,1,1};
static vector specularMaterial= {0.2,0.2,0.2,1};
static float specularPower	  = 0.5f;

sampler S0 = sampler_state
{
	Texture = (Tex);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};
sampler s1;



//
//vertex shader
//
struct V_INPUT{
	vector pos : POSITION;
	vector Normal : NORMAL;
	float2 texc : TEXCOORD;
};
struct V_OUTPUT{
	vector pos : POSITION;
	//vector color : COLOR;
	float2 texc : TEXCOORD0;
	
	float4 ViewPos : TEXCOORD1;
	float4 ViewNormal : TEXCOORD2;
	
};


V_OUTPUT mainVS(V_INPUT input){
	V_OUTPUT output = (V_OUTPUT)0;
	
	output.pos 		= mul(input.pos,WorldViewProj);
	output.texc		= input.texc;
	output.ViewPos	= mul(input.pos,WorldView);
	
	input.Normal.w  = 0.0f;
	output.ViewNormal 	= normalize(mul(input.Normal,WorldView));
	
	return output; 
}
//
//Pixel shader
//
struct P_INPUT{
	//vector color : COLOR;
	float2 texc	 : TEXCOORD0;
	
	float4 pos : TEXCOORD1;
	float4 Normal : TEXCOORD2;
	
	
};
struct P_OUTPUT{
	vector color : COLOR;
};

P_OUTPUT mainPS(P_INPUT input){
	
	P_OUTPUT output = (P_OUTPUT)0;
	
	vector tc = tex2D(S0,input.texc);
	
	LightPos		= mul(LightPos,View);
	LightDir		= normalize(LightPos-input.pos);
	
	//diffuse Color
	float cosNL 		= saturate(dot(input.Normal,LightDir)) ;	//(N*L)
	vector diffuseColor = ambientLight * diffuseMaterial +  cosNL*LightColor * diffuseMaterial;
	
	//specular Color

	vector V 	= normalize(-input.pos);
	float3 T 	= normalize(cross(input.Normal.xyz,V.xyz));
	
	float cosNV = dot(input.Normal,V);
	float cosVT = dot(T,V);
	float cosLT = dot(T,LightDir);
	
	float Rs 	= 0;
	if(cosNV>0&&cosNL>0){
		Rs = sqrt(1-cosVT*cosVT)*sqrt(1-cosLT*cosLT)-cosLT*cosVT;
		Rs = pow(abs(Rs),specularPower);
	}
	vector specularColor = Rs * LightColor * cosNL * specularMaterial;//Lr = F(x,w0,wi) * L * (N*L) * SM;
	
	output.color    = (diffuseColor + specularColor)*tc;	
	return output;
}

technique technique0 {
	pass p0 {
		fvf = XYZ | NORMAL | TEX1;
		CullMode = None;	
		Lighting = true;
		//NormalizeNormals = true;
		SpecularEnable   = false;
		FillMode = SOLID;
		//Sampler[0] = (S0);
		
		VertexShader = compile vs_3_0 mainVS();
		PixelShader  = compile ps_3_0 mainPS();
	}
}
