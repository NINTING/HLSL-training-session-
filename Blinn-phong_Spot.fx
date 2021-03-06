/*

% Description of my shader.
% Second line of description for my shader.

Blinn-phong Model

date: YYMMDD

*/

//
//extern var
//
extern matrix WorldViewProj;
extern matrix World;
extern matrix View;
extern matrix Proj;
extern matrix WorldView;
extern matrix WorldViewIT;
extern texture Tex;
//
//static var
//
static vector LightPos 		  = {0.0f,2.0f,0.0f,1.0f};
static vector LightDir 		  = {1.0f,-1.0f,1.0f,0.0f};
static vector diffuseLight 	  = {1.0f,1.0f,1.0f,1.0f};
static vector specularLight	  = {0.2f,0.2f,0.2f,1.0f};
static vector ambientLight 	  = {0.2,0.2,0.2,1};
static vector diffuseMaterial = {1,1,1,1};
static vector specularMaterial={0.2,0.2,0.2,1};
static float specularPower	  = 1.0f;

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
	
	vector color : COLOR;
	float2 texc : TEXCOORD;
};


V_OUTPUT mainVS(V_INPUT input){
	V_OUTPUT output = (V_OUTPUT)0;
	
	output.pos 		= mul(input.pos,WorldViewProj);
	output.texc		= input.texc;
	input.pos		= mul(input.pos,WorldView);
	
	input.Normal.w  = 0.0f;
	input.Normal 	= mul(input.Normal,WorldViewIT);
	input.Normal 	= normalize(input.Normal);		
	
	LightPos		= mul(LightPos    ,View);
	LightDir		= normalize(LightPos-input.pos);
	//LightDir		= mul(LightDir    ,View);
	
	//diffuse Color
	//LightDir		= -LightDir;
	float Dcos 		= saturate(dot(input.Normal,LightDir)) ;
	vector diffuseColor = ambientLight * diffuseMaterial +  Dcos*diffuseLight * diffuseMaterial;
	
	//specular Color
	vector v		= -input.pos;
	vector H		= normalize(v+LightDir);
	float Scos		= saturate(dot(input.Normal,H));
	vector specularColor= specularLight*specularMaterial*pow(Scos,specularPower);

	output.color    = diffuseColor + specularColor;
	return output;
}
//
//Pixel shader
//
struct P_INPUT{
	vector pos 	 : POSITION;
	vector color : COLOR;
	float2 texc	 : TEXCOORD;
};
struct P_OUTPUT{
	vector color : COLOR;
};

P_OUTPUT mainPS(P_INPUT input){
	
	P_OUTPUT output = (P_OUTPUT)0;
	
	vector tc = tex2D(S0,input.texc);
	output.color =input.color * tc;
	
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
		PixelShader = compile ps_3_0 mainPS();
	}
}
