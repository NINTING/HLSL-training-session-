/*

% Description of my shader.
% Second line of description for my shader.

cubeMap-reflect Model

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
extern texture Cube0,Cube1,Cube2,Cube3,Cube4,Cube5;
extern float m = 10.0f; //粗糙程度
extern float f0 = 0;	//fresnel因子在入射角为0时的取值
extern vector eye;

//
//static Light var
//

static vector ambientLight	  = {0.2f,0.2f,0.2f,1.0f};
static vector LightPos 		  = {0.0f,0.0f,-3.0f,1.0f};
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

//create CubeMap


sampler cube0 = sampler_state
{
	Texture = (Cube0);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};

sampler cube1 = sampler_state
{
	Texture = (Cube1);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};
sampler cube2 = sampler_state
{
	Texture = (Cube2);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};
sampler cube3 = sampler_state
{
	Texture = (Cube3);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};
sampler cube4 = sampler_state
{
	Texture = (Cube4);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};

sampler cube5 = sampler_state
{
	Texture = (Cube5);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};

float3 getTexCoord(float3 dirc){
	float3 coord;			//x,y(TexCoord),z(Texindex)
	float s = dirc.x,t = dirc.y,p = dirc.z;
	if(abs(s)>=abs(t)&&abs(s)>=abs(p)){
		if(s<0)
			coord.x = 0.5f + p /(2*s),coord.y = 0.5f - t/(2*s),coord.z = 3;
		else
			coord.x = 0.5f + p /(2*s),coord.y = 0.5f + t/(2*s),coord.z = 1;
	}
	if(abs(t)>=abs(p)&&abs(t)>=abs(s)){
		if(t<0)
			coord.x = 0.5f + s/(2*t),coord.y = 0.5f - p/(2*t),coord.z = 5;
		else
			coord.x = 0.5f + p/(2*t),coord.y = 0.5f + p/(2*t),coord.z = 4;
	}
	if(abs(p)>=abs(s)&&abs(p)>=abs(t)){
		if(p<0)
			coord.x = 0.5f - s/(2*p),coord.y = 0.5f - t/(2*p),coord.z = 0;
		else
			coord.x = 0.5f - s/(2*p),coord.y = 0.5f + t/(2*p),coord.z = 2;
	}
	return  coord;
}

vector getTexColor(float3 dirc){
	float3 coord;
	coord = getTexCoord(dirc);
	vector color;
	switch (coord.z){
		case 0:
			color = tex2D(cube0,coord.xy);
			break;
		case 1:
			color = tex2D(cube1,coord.xy);
			break;
		case 2:
			color = tex2D(cube2,coord.xy);
			break;
		case 3:
			color = tex2D(cube3,coord.xy);
			break;
		case 4:
			color = tex2D(cube4,coord.xy);
			break;
		case 5:
			color = tex2D(cube5,coord.xy);
			break;
	}
	return color;
}

//
//vertex shader
//
struct V_INPUT{
	vector pos : POSITION;
	vector Normal : NORMAL;
	//float2 texc : TEXCOORD;
};
struct V_OUTPUT{
	vector pos : POSITION;
	//vector color : COLOR;
	//float2 texc : TEXCOORD0;
	float4 ViewPos : TEXCOORD1;
	float4 ViewNormal : TEXCOORD2;
	
};


V_OUTPUT mainVS(V_INPUT input){
	V_OUTPUT output = (V_OUTPUT)0;
	
	output.pos 		= mul(input.pos,WorldViewProj);
	output.ViewPos	= mul(input.pos,World);
	
	input.Normal.w  = 0.0f;
	output.ViewNormal 	= normalize(mul(input.Normal,World));
	
	return output; 
}

//
//Pixel shader
//

struct P_INPUT{
	//vector color : COLOR;
	float4 pos : TEXCOORD1;
	float4 Normal : TEXCOORD2;
};
struct P_OUTPUT{
	vector color : COLOR;
};

P_OUTPUT mainPS(P_INPUT input){
	
	P_OUTPUT output = (P_OUTPUT)0;
		
	LightPos		= mul(LightPos,View);
	LightDir		= normalize(LightPos-input.pos);
	
	//diffuse Color
	
	//specular Color

	//vector V 	= normalize(input.pos);
	//V.w = 0;
	//vector R	= reflect(V,input.Normal);
	eye.w = 0;
	vector V = input.pos-eye;
	vector color = 0;
	output.color = getTexColor(V.xyz);
	return output;
}

P_OUTPUT mainPS1(P_INPUT input){
	
	P_OUTPUT output = (P_OUTPUT)0;
		
	LightPos		= mul(LightPos,View);
	LightDir		= normalize(LightPos-input.pos);
	
	//diffuse Color
	
	//specular Color

	vector V 	= normalize(input.pos-eye);
	V.w = 0;
	vector R	= reflect(V,input.Normal);
	//eye.w = 0;
	//vector V = input.pos-eye;
	//vector color = 0;
	output.color = getTexColor(R.xyz);
	return output;
}


technique technique0 {
	pass p0 {
		fvf = XYZ | NORMAL | TEX1;
		CullMode = cw;	
		Lighting = true;
		//NormalizeNormals = true;
		SpecularEnable   = false;
		FillMode = SOLID;
		//Sampler[0] = (S0);
		
		VertexShader = compile vs_3_0 mainVS();
		PixelShader  = compile ps_3_0 mainPS();
	}
	pass p1 {
		fvf = XYZ | NORMAL | TEX1;
		CullMode = cw;	
		Lighting = true;
		//NormalizeNormals = true;
		SpecularEnable   = false;
		FillMode = SOLID;
		//Sampler[0] = (S0);
		
		VertexShader = compile vs_3_0 mainVS();
		PixelShader  = compile ps_3_0 mainPS1();
	}
	
}
